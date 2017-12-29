﻿using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Transactions;
using Accidis.Sjoslaget.WebService.Auth;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.WebServices.Db;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class BookingRepository
	{
		const string LockResource = "Booking";
		const int LockTimeout = 10000;

		readonly CabinRepository _cabinRepository;
		readonly CruiseRepository _cruiseRepository;
		readonly DeletedBookingRepository _deletedBookingRepository;
		readonly PriceCalculator _priceCalculator;
		readonly ProductRepository _productRepository;
		readonly RandomKeyGenerator _randomKeyGenerator;
		readonly SjoslagetUserManager _userManager;

		public BookingRepository(
			CabinRepository cabinRepository,
			CruiseRepository cruiseRepository,
			DeletedBookingRepository deletedBookingRepository,
			PriceCalculator priceCalculator,
			ProductRepository productRepository,
			RandomKeyGenerator randomKeyGenerator,
			SjoslagetUserManager userManager)
		{
			_cabinRepository = cabinRepository;
			_cruiseRepository = cruiseRepository;
			_deletedBookingRepository = deletedBookingRepository;
			_priceCalculator = priceCalculator;
			_productRepository = productRepository;
			_randomKeyGenerator = randomKeyGenerator;
			_userManager = userManager;
		}

		public async Task<BookingResult> CreateAsync(Cruise cruise, BookingSource source, bool allowCreateIfLocked = false)
		{
			if(cruise.IsLocked && !allowCreateIfLocked)
				throw new BookingException("Cruise is locked, may not create bookings.");

			BookingSource.Validate(source);
			var booking = Booking.FromSource(source, cruise.Id, _randomKeyGenerator.GenerateBookingReference());

			/*
			 * Start a low-isolation transaction just to give us rollback capability in case something fails in the middle of 
			 * the booking. Then acquire a lock (which is automagically tied to the transaction scope) to prevent multiple bookings
			 * being written at once and potentially overcommitting our available cabins.
			 */
			var tranOptions = new TransactionOptions {IsolationLevel = IsolationLevel.ReadUncommitted};
			using(var tran = new TransactionScope(TransactionScopeOption.Required, tranOptions, TransactionScopeAsyncFlowOption.Enabled))
			using(var db = DbUtil.Open())
			{
				IEnumerable<CruiseCabinWithType> cabinTypes = await _cabinRepository.GetActiveAsync(db, cruise);
				IEnumerable<CruiseProductWithType> productTypes = await _productRepository.GetActiveAsync(db, cruise);

				await db.GetAppLockAsync(LockResource, LockTimeout);
				await CheckAvailability(db, cruise, source.Cabins, cabinTypes);
				await CreateBooking(db, booking);
				await CreateCabins(db, booking, source.Cabins);
				await CreateProducts(db, booking, source.Products);

				decimal totalPrice = _priceCalculator.CalculatePrice(source.Cabins, source.Products, booking.Discount, cabinTypes, productTypes);
				await db.ExecuteAsync("update [Booking] set [TotalPrice] = @TotalPrice where [Id] = @Id", new {TotalPrice = totalPrice, Id = booking.Id});

				tran.Complete();
			}

			var password = _randomKeyGenerator.GeneratePinCode();
			await _userManager.CreateAsync(new User {UserName = booking.Reference, IsBooking = true}, password);

			return BookingResult.FromBooking(booking, password);
		}

		public async Task DeleteAsync(Booking booking)
		{
			User user = await _userManager.FindByNameAsync(booking.Reference);
			if(null != user && user.IsBooking)
				await _userManager.DeleteAsync(user);

			await _deletedBookingRepository.CreateAsync(booking);

			using(var db = DbUtil.Open())
				await db.ExecuteAsync("delete from [Booking] where [Id] = @Id", new {Id = booking.Id});
		}

		public async Task<Booking> FindByIdAsync(Guid id)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<Booking>("select * from [Booking] where [Id] = @Id", new {Id = id});
				return result.FirstOrDefault();
			}
		}

		public async Task<Booking> FindByReferenceAsync(string reference)
		{
			using(var db = DbUtil.Open())
				return await FindByReferenceAsync(db, reference);
		}

		public async Task<Booking> FindByReferenceAsync(SqlConnection db, string reference)
		{
			var result = await db.QueryAsync<Booking>("select * from [Booking] where [Reference] = @Reference", new {Reference = reference});
			return result.FirstOrDefault();
		}

		public async Task<BookingCabinWithPax[]> GetCabinsForBookingAsync(Booking booking)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<BookingCabinWithPax>("select * from [BookingCabin] where [BookingId] = @BookingId order by [Order]",
					new {BookingId = booking.Id});

				BookingCabinWithPax[] bookingCabins = result.ToArray();
				foreach(BookingCabinWithPax cabin in bookingCabins)
				{
					var pax = await db.QueryAsync<BookingPax>("select * from [BookingPax] where [BookingCabinId] = @BookingCabinId order by [Order]",
						new {BookingCabinId = cabin.Id});
					cabin.Pax.AddRange(pax);
				}

				return bookingCabins;
			}
		}

		public async Task<BookingResult> UpdateAsync(Cruise cruise, BookingSource source, bool allowUpdateDetails = false, bool allowUpdateIfLocked = false)
		{
			BookingSource.ValidateCabins(source);
			if(allowUpdateDetails)
				source.ValidateDetails();

			Booking booking;

			// See CreateAsync regarding the use of transaction + applock here.
			var tranOptions = new TransactionOptions {IsolationLevel = IsolationLevel.ReadUncommitted};
			using(var tran = new TransactionScope(TransactionScopeOption.Required, tranOptions, TransactionScopeAsyncFlowOption.Enabled))
			using(var db = DbUtil.Open())
			{
				IEnumerable<CruiseCabinWithType> cabinTypes = await _cabinRepository.GetActiveAsync(db, cruise);
				IEnumerable<CruiseProductWithType> productTypes = await _productRepository.GetActiveAsync(db, cruise);

				await db.GetAppLockAsync(LockResource, LockTimeout);

				booking = await FindByReferenceAsync(db, source.Reference);
				if(null == booking || booking.CruiseId != cruise.Id)
					throw new BookingException($"Booking with reference {source.Reference} not found or not in active cruise.");
				if((cruise.IsLocked || booking.IsLocked) && !allowUpdateIfLocked)
					throw new BookingException($"Booking with reference {source.Reference} is locked, may not update.");

				await DeleteCabins(db, booking);
				await CheckAvailability(db, cruise, source.Cabins, cabinTypes);
				await CreateCabins(db, booking, source.Cabins);

				await DeleteProducts(db, booking);
				await CreateProducts(db, booking, source.Products);

				decimal totalPrice = _priceCalculator.CalculatePrice(source.Cabins, source.Products, booking.Discount, cabinTypes, productTypes);

				if(allowUpdateDetails)
				{
					await db.ExecuteAsync("update [Booking] set [FirstName] = @FirstName, [LastName] = @LastName, [Email] = @Email, [PhoneNo] = @PhoneNo, [Lunch] = @Lunch, [TotalPrice] = @TotalPrice, [Updated] = sysdatetime() where [Id] = @Id",
						new {FirstName = source.FirstName, LastName = source.LastName, Email = source.Email, PhoneNo = source.PhoneNo, Lunch = source.Lunch, TotalPrice = totalPrice, Id = booking.Id});
				}
				else
					await db.ExecuteAsync("update [Booking] set [TotalPrice] = @TotalPrice, [Updated] = sysdatetime() where [Id] = @Id", new {TotalPrice = totalPrice, Id = booking.Id});

				tran.Complete();
			}

			return BookingResult.FromBooking(booking, null);
		}

		public async Task UpdateDiscountAsync(Booking booking)
		{
			using(var db = DbUtil.Open())
			{
				Cruise cruise = await _cruiseRepository.FindByIdAsync(db, booking.CruiseId);
				IEnumerable<CruiseCabinWithType> cabinTypes = await _cabinRepository.GetActiveAsync(db, cruise);
				IEnumerable<CruiseProductWithType> productTypes = await _productRepository.GetActiveAsync(db, cruise);
				var bookingCabins = (await db.QueryAsync<BookingSource.Cabin>("select [CabinTypeId] [TypeId] from [BookingCabin] where [BookingId] = @Id", new {Id = booking.Id})).ToList();
				var bookingProducts = (await db.QueryAsync<BookingSource.Product>("select [ProductTypeId] [TypeId], [Quantity] from [BookingProduct] where [BookingId] = @Id", new {Id = booking.Id})).ToList();

				decimal totalPrice = _priceCalculator.CalculatePrice(bookingCabins, bookingProducts, booking.Discount, cabinTypes, productTypes);

				await db.ExecuteAsync("update [Booking] set [Discount] = @Discount, [TotalPrice] = @TotalPrice where [Id] = @Id",
					new {Id = booking.Id, Discount = booking.Discount, TotalPrice = totalPrice});
			}
		}

		public async Task UpdateIsLockedAsync(Booking booking)
		{
			using(var db = DbUtil.Open())
			{
				await db.ExecuteAsync("update [Booking] set [IsLocked] = @IsLocked where [Id] = @Id",
					new {Id = booking.Id, IsLocked = booking.IsLocked});
			}
		}

		async Task CheckAvailability(SqlConnection db, Cruise cruise, List<BookingSource.Cabin> sourceList, IEnumerable<CabinType> cruiseCabins)
		{
			Dictionary<Guid, CabinType> typeDict = cruiseCabins.ToDictionary(c => c.Id, c => c);
			Dictionary<Guid, CruiseCabinAvailability> availabilityDict = (await _cabinRepository.GetAvailabilityAsync(db, cruise)).ToDictionary(c => c.CabinTypeId, c => c);

			foreach(BookingSource.Cabin cabinSource in sourceList)
			{
				CabinType type;
				if(!typeDict.TryGetValue(cabinSource.TypeId, out type))
					throw new BookingException($"Cabin type \"{cabinSource.TypeId}\" does not refer to an existing type.");
				if(cabinSource.Pax.Count > type.Capacity)
					throw new BookingException($"Cabin of type \"{cabinSource.TypeId}\" is overbooked, capacity is {type.Capacity}, got {cabinSource.Pax.Count} pax.");

				CruiseCabinAvailability availability;
				if(!availabilityDict.TryGetValue(cabinSource.TypeId, out availability))
					throw new BookingException($"Cabin type \"{cabinSource.TypeId}\" does not refer to an active type.");

				availability.Available--;
				if(availability.Available < 0)
					throw new AvailabilityException($"No more cabins of type \"{cabinSource.TypeId}\" are available on this cruise.");
			}
		}

		async Task CreateBooking(SqlConnection db, Booking booking)
		{
			bool createdBooking = false;
			while(!createdBooking)
			{
				try
				{
					Guid id = await db.ExecuteScalarAsync<Guid>("insert into [Booking] ([CruiseId], [Reference], [FirstName], [LastName], [Email], [PhoneNo], [Lunch]) output inserted.[Id] values (@CruiseId, @Reference, @FirstName, @LastName, @Email, @PhoneNo, @Lunch)",
						new {CruiseId = booking.CruiseId, Reference = booking.Reference, FirstName = booking.FirstName, LastName = booking.LastName, Email = booking.Email, PhoneNo = booking.PhoneNo, Lunch = booking.Lunch});

					createdBooking = true;
					booking.Id = id;
				}
				catch(SqlException ex)
				{
					// in the unlikely event that a duplicate reference is generated, simply try again
					if(ex.IsUniqueKeyViolation())
						booking.Reference = _randomKeyGenerator.GenerateBookingReference();
					else
						throw;
				}
			}
		}

		async Task CreateCabins(SqlConnection db, Booking booking, List<BookingSource.Cabin> sourceList)
		{
			int cabinIdx = 0;
			foreach(BookingSource.Cabin cabinSource in sourceList)
			{
				var cabin = BookingCabin.FromSource(cabinSource, booking.Id);
				Guid id = await db.ExecuteScalarAsync<Guid>("insert into [BookingCabin] ([CruiseId], [BookingId], [CabinTypeId], [Order]) output inserted.[Id] values (@CruiseId, @BookingId, @CabinTypeId, @Order)",
					new {CruiseId = booking.CruiseId, BookingId = booking.Id, CabinTypeId = cabin.CabinTypeId, Order = cabinIdx++});

				int paxIdx = 0;
				IEnumerable<BookingPax> pax = cabinSource.Pax.Select(p => BookingPax.FromSource(p, id));
				await db.ExecuteAsync("insert into [BookingPax] ([BookingCabinId], [Group], [FirstName], [LastName], [Gender], [Dob], [Nationality], [Years], [Order]) values (@BookingCabinId, @Group, @FirstName, @LastName, @Gender, @Dob, @Nationality, @Years, @Order)",
					pax.Select(p => new {BookingCabinId = p.BookingCabinId, Group = p.Group, FirstName = p.FirstName, LastName = p.LastName, Gender = p.Gender, Dob = p.Dob.ToString(), Nationality = p.Nationality, Years = p.Years, Order = paxIdx++}));
			}
		}

		async Task CreateProducts(SqlConnection db, Booking booking, List<BookingSource.Product> sourceList)
		{
			if(null == sourceList || !sourceList.Any())
				return;

			foreach(BookingSource.Product prodSource in sourceList.Where(p => p.Quantity > 0))
			{
				await db.ExecuteAsync("insert into [BookingProduct] ([CruiseId], [BookingId], [ProductTypeId], [Quantity]) values (@CruiseId, @BookingId, @ProductTypeId, @Quantity)",
					new {CruiseId = booking.CruiseId, BookingId = booking.Id, ProductTypeId = prodSource.TypeId, Quantity = prodSource.Quantity});
			}
		}

		async Task DeleteCabins(SqlConnection db, Booking booking)
		{
			await db.ExecuteAsync("delete from [BookingCabin] where [BookingId] = @BookingId", new {BookingId = booking.Id});
		}

		async Task DeleteProducts(SqlConnection db, Booking booking)
		{
			await db.ExecuteAsync("delete from [BookingProduct] where [BookingId] = @BookingId", new {BookingId = booking.Id});
		}
	}
}
