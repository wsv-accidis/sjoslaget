using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Transactions;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Db;
using Accidis.WebServices.Models;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class BookingRepository
	{
		const string LockResource = "Booking";
		const int LockTimeout = 10000;

		readonly BookingCabinsComparer _bookingComparer;
		readonly CabinRepository _cabinRepository;
		readonly CredentialsGenerator _credentialsGenerator;
		readonly CruiseRepository _cruiseRepository;
		readonly DeletedBookingRepository _deletedBookingRepository;
		readonly PriceCalculator _priceCalculator;
		readonly ProductRepository _productRepository;
		readonly AecUserManager _userManager;

		public BookingRepository(
			BookingCabinsComparer bookingComparer,
			CabinRepository cabinRepository,
			CruiseRepository cruiseRepository,
			DeletedBookingRepository deletedBookingRepository,
			PriceCalculator priceCalculator,
			ProductRepository productRepository,
			CredentialsGenerator credentialsGenerator,
			AecUserManager userManager)
		{
			_bookingComparer = bookingComparer;
			_cabinRepository = cabinRepository;
			_cruiseRepository = cruiseRepository;
			_deletedBookingRepository = deletedBookingRepository;
			_priceCalculator = priceCalculator;
			_productRepository = productRepository;
			_credentialsGenerator = credentialsGenerator;
			_userManager = userManager;
		}

		public async Task<BookingResult> CreateAsync(Cruise cruise, BookingSource source, bool allowCreateIfLocked = false)
		{
			if(cruise.IsLocked && !allowCreateIfLocked)
				throw new BookingException("Cruise is locked, may not create bookings.");

			BookingSource.Validate(source);
			var booking = Booking.FromSource(source, cruise.Id, _credentialsGenerator.GenerateBookingReference());

			/*
			 * Start a low-isolation transaction just to give us rollback capability in case something fails in the middle of 
			 * the booking. Then acquire a lock (which is automagically tied to the transaction scope) to prevent multiple bookings
			 * being written at once and potentially overcommitting our available cabins.
			 */
			var tranOptions = new TransactionOptions {IsolationLevel = IsolationLevel.ReadUncommitted};
			using(var tran = new TransactionScope(TransactionScopeOption.Required, tranOptions, TransactionScopeAsyncFlowOption.Enabled))
			using(var db = DbUtil.Open())
			{
				var cabinTypes = await _cabinRepository.GetActiveAsync(db, cruise);
				var productTypes = await _productRepository.GetActiveAsync(db, cruise);
				CheckCabinTypesValidity(booking.SubCruise, source.Cabins, cabinTypes);

				await db.GetAppLockAsync(LockResource, LockTimeout);
				await CheckCabinsAvailability(db, cruise, source.Cabins, cabinTypes);
				await CheckProductsAvailability(db, cruise, source.Products);
				await CreateBooking(db, booking);
				await CreateCabins(db, booking, source.Cabins);
				await CreateProducts(db, booking, source.Products);

				decimal totalPrice = _priceCalculator.CalculatePrice(source.Cabins, source.Products, booking.Discount, cabinTypes, productTypes);
				await db.ExecuteAsync("update [Booking] set [TotalPrice] = @TotalPrice where [Id] = @Id", new {TotalPrice = totalPrice, Id = booking.Id});

				tran.Complete();
			}

			var password = _credentialsGenerator.GeneratePinCode();
			await _userManager.CreateAsync(new AecUser {UserName = booking.Reference, IsBooking = true}, password);

			return new BookingResult {Reference = booking.Reference, Password = password};
		}

		public async Task DeleteAsync(Booking booking)
		{
			AecUser user = await _userManager.FindByNameAsync(booking.Reference);
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
				return await GetCabinsForBooking(db, booking.Id);
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
				var cabinTypes = await _cabinRepository.GetActiveAsync(db, cruise);
				var productTypes = await _productRepository.GetActiveAsync(db, cruise);
				CheckCabinTypesValidity(SubCruiseCode.FromString(source.SubCruise), source.Cabins, cabinTypes);

				await db.GetAppLockAsync(LockResource, LockTimeout);

				booking = await FindByReferenceAsync(db, source.Reference);
				if(null == booking || booking.CruiseId != cruise.Id)
					throw new BookingException($"Booking with reference {source.Reference} not found or not in active cruise.");
				if((cruise.IsLocked || booking.IsLocked) && !allowUpdateIfLocked)
					throw new BookingException($"Booking with reference {source.Reference} is locked, may not update.");

				// Get the booking contents before deleting it so we can detect changes
				BookingCabinWithPax[] originalCabins = await GetCabinsForBooking(db, booking.Id);

				await DeleteCabins(db, booking);
				await CheckCabinsAvailability(db, cruise, source.Cabins, cabinTypes);
				await CreateCabins(db, booking, source.Cabins);

				await DeleteProducts(db, booking);
				await CheckProductsAvailability(db, cruise, source.Products);
				await CreateProducts(db, booking, source.Products);

				await CreateChanges(db, booking, originalCabins, source.Cabins);

				decimal totalPrice = _priceCalculator.CalculatePrice(source.Cabins, source.Products, booking.Discount, cabinTypes, productTypes);
				if(allowUpdateDetails)
				{
					await db.ExecuteAsync(
						"update [Booking] set [FirstName] = @FirstName, [LastName] = @LastName, [Email] = @Email, [PhoneNo] = @PhoneNo, [Lunch] = @Lunch, [InternalNotes] = @InternalNotes, [SubCruise] = @SubCruise, [TotalPrice] = @TotalPrice, [Updated] = sysdatetime() where [Id] = @Id",
						new
						{
							FirstName = source.FirstName, LastName = source.LastName, Email = source.Email, PhoneNo = source.PhoneNo, Lunch = source.Lunch, InternalNotes = source.InternalNotes, SubCruise = source.SubCruise,
							TotalPrice = totalPrice, Id = booking.Id
						});
				}
				else
				{
					await db.ExecuteAsync("update [Booking] set [SubCruise] = @SubCruise, [TotalPrice] = @TotalPrice, [Updated] = sysdatetime() where [Id] = @Id",
						new {SubCruise = source.SubCruise, TotalPrice = totalPrice, Id = booking.Id});
				}

				tran.Complete();
			}

			return new BookingResult {Reference = booking.Reference};
		}

		public async Task UpdateDiscountAsync(Booking booking)
		{
			using(var db = DbUtil.Open())
			{
				Cruise cruise = await _cruiseRepository.FindByIdAsync(db, booking.CruiseId);
				var cabinTypes = await _cabinRepository.GetActiveAsync(db, cruise);
				var productTypes = await _productRepository.GetActiveAsync(db, cruise);
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

		async Task CheckCabinsAvailability(SqlConnection db, Cruise cruise, List<BookingSource.Cabin> sourceList, IEnumerable<CabinType> cruiseCabins)
		{
			var typeDict = cruiseCabins.ToDictionary(c => c.Id, c => c);
			var availabilityDict = (await _cabinRepository.GetAvailabilityAsync(db, cruise)).ToDictionary(c => c.CabinTypeId, c => c);

			foreach(BookingSource.Cabin cabinSource in sourceList)
			{
				if(!typeDict.TryGetValue(cabinSource.TypeId, out var type))
					throw new BookingException($"Cabin type \"{cabinSource.TypeId}\" does not refer to an existing type.");
				if(cabinSource.Pax.Count > type.Capacity)
					throw new BookingException($"Cabin of type \"{cabinSource.TypeId}\" is overbooked, capacity is {type.Capacity}, got {cabinSource.Pax.Count} pax.");

				if(!availabilityDict.TryGetValue(cabinSource.TypeId, out var availability))
					throw new BookingException($"Cabin type \"{cabinSource.TypeId}\" does not refer to an active type.");

				availability.Available--;
				if(availability.Available < 0)
					throw new AvailabilityException($"No more cabins of type \"{cabinSource.TypeId}\" are available on this cruise.");
			}
		}

		void CheckCabinTypesValidity(SubCruiseCode subCruiseForBooking, List<BookingSource.Cabin> sourceCabins, CruiseCabinWithType[] cabinTypes)
		{
			var typeDict = cabinTypes.ToDictionary(c => c.Id, c => c.SubCruise);
			if(sourceCabins.Any(cabin => !typeDict.ContainsKey(cabin.TypeId) || !subCruiseForBooking.Equals(SubCruiseCode.FromString(typeDict[cabin.TypeId]))))
				throw new BookingException($"One or more cabin types in the booking are not valid for sub-cruise {subCruiseForBooking}.");
		}

		async Task CheckProductsAvailability(SqlConnection db, Cruise cruise, List<BookingSource.Product> sourceList)
		{
			var availabilityDict = (await _productRepository.GetAvailabilityAsync(db, cruise)).ToDictionary(p => p.ProductTypeId, p => p);

			foreach(BookingSource.Product prodSource in sourceList)
			{
				if(!availabilityDict.TryGetValue(prodSource.TypeId, out var availability))
					throw new BookingException($"Product type \"{prodSource.TypeId}\" does not refer to an active type.");
				if(availability.IsLimited && availability.Availability < prodSource.Quantity)
					throw new AvailabilityException($"Not enough products of type \"{prodSource.TypeId}\" are available. Had {availability.Availability}, needed {prodSource.Quantity}.");
			}
		}

		async Task CreateBooking(SqlConnection db, Booking booking)
		{
			bool createdBooking = false;
			while(!createdBooking)
			{
				try
				{
					Guid id = await db.ExecuteScalarAsync<Guid>(
						"insert into [Booking] ([CruiseId], [Reference], [FirstName], [LastName], [Email], [PhoneNo], [Lunch], [InternalNotes], [SubCruise]) output inserted.[Id] values (@CruiseId, @Reference, @FirstName, @LastName, @Email, @PhoneNo, @Lunch, @InternalNotes, @SubCruise)",
						new
						{
							CruiseId = booking.CruiseId,
							Reference = booking.Reference,
							FirstName = booking.FirstName,
							LastName = booking.LastName,
							Email = booking.Email,
							PhoneNo = booking.PhoneNo,
							Lunch = booking.Lunch,
							InternalNotes = booking.InternalNotes ?? string.Empty,
							SubCruise = booking.SubCruise
						});

					createdBooking = true;
					booking.Id = id;
				}
				catch(SqlException ex)
				{
					// in the unlikely event that a duplicate reference is generated, simply try again
					if(ex.IsUniqueKeyViolation())
						booking.Reference = _credentialsGenerator.GenerateBookingReference();
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
				await db.ExecuteAsync(
					"insert into [BookingPax] ([BookingCabinId], [Group], [FirstName], [LastName], [Gender], [Dob], [Nationality], [Years], [Order]) values (@BookingCabinId, @Group, @FirstName, @LastName, @Gender, @Dob, @Nationality, @Years, @Order)",
					pax.Select(p => new
					{
						BookingCabinId = p.BookingCabinId, Group = p.Group, FirstName = p.FirstName, LastName = p.LastName, Gender = p.Gender, Dob = p.Dob.ToString(), Nationality = p.Nationality, Years = p.Years, Order = paxIdx++
					}));
			}
		}

		async Task CreateChanges(SqlConnection db, Booking booking, BookingCabinWithPax[] originalCabins, List<BookingSource.Cabin> updatedCabins)
		{
			IEnumerable<BookingChange> changes = _bookingComparer.FindChanges(originalCabins.ToList(), updatedCabins);
			foreach(BookingChange change in changes)
			{
				await db.ExecuteAsync("insert into [BookingChange] ([BookingId], [CabinIndex], [PaxIndex], [FieldName]) values (@BookingId, @CabinIndex, @PaxIndex, @FieldName)",
					new {BookingId = booking.Id, CabinIndex = change.CabinIndex, PaxIndex = change.PaxIndex, FieldName = change.FieldName});
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

		async Task<BookingCabinWithPax[]> GetCabinsForBooking(SqlConnection db, Guid bookingId)
		{
			var result = await db.QueryAsync<BookingCabinWithPax>("select * from [BookingCabin] where [BookingId] = @BookingId order by [Order]",
				new {BookingId = bookingId});

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
}
