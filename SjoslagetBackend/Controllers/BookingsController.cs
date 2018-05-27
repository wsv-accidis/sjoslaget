using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Hosting;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Db;
using Accidis.WebServices.Models;
using Accidis.WebServices.Web;
using Dapper;
using NLog;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class BookingsController : ApiController
	{
		readonly BookingRepository _bookingRepository;
		readonly CruiseRepository _cruiseRepository;
		readonly DeletedBookingRepository _deletedBookingRepository;
		readonly Logger _log = LogManager.GetLogger(typeof(BookingsController).Name);
		readonly PaymentRepository _paymentRepository;
		readonly ProductRepository _productRepository;
		readonly ReportingService _reportingService;

		public BookingsController(
			BookingRepository bookingRepository,
			CruiseRepository cruiseRepository,
			DeletedBookingRepository deletedBookingRepository,
			PaymentRepository paymentRepository,
			ProductRepository productRepository,
			ReportingService reportingService)
		{
			_bookingRepository = bookingRepository;
			_cruiseRepository = cruiseRepository;
			_deletedBookingRepository = deletedBookingRepository;
			_paymentRepository = paymentRepository;
			_productRepository = productRepository;
			_reportingService = reportingService;
		}

		[HttpPost]
		public async Task<IHttpActionResult> CreateOrUpdate(BookingSource bookingSource)
		{
			try
			{
				Cruise activeCruise = await _cruiseRepository.GetActiveAsync();
				if(null == activeCruise)
					return NotFound();

				BookingResult result;
				if(!String.IsNullOrEmpty(bookingSource.Reference))
				{
					if(!AuthContext.IsAdmin && !String.Equals(AuthContext.UserName, bookingSource.Reference, StringComparison.InvariantCultureIgnoreCase))
						return BadRequest("Request is unauthorized, or not logged in as the booking it's trying to update.");

					result = await _bookingRepository.UpdateAsync(activeCruise, bookingSource, allowUpdateDetails: AuthContext.IsAdmin, allowUpdateIfLocked: AuthContext.IsAdmin);
					_log.Info("Updated booking {0}.", result.Reference);
				}
				else
				{
					result = await _bookingRepository.CreateAsync(activeCruise, bookingSource, allowCreateIfLocked: AuthContext.IsAdmin);
					_log.Info("Created booking {0}.", result.Reference);

					await SendBookingCreatedMailAsync(activeCruise, bookingSource, result);
				}

				// Ensure we update reporting after each change
				HostingEnvironment.QueueBackgroundWorkItem(ct => _reportingService.GenerateReportsAsync());

				return Ok(result);
			}
			catch(AvailabilityException ex)
			{
				_log.Info(ex, "Lack of availability prevented a booking from being created.");
				return Conflict();
			}
			catch(BookingException ex)
			{
				_log.Warn(ex, "A validation error occurred while creating the booking.");
				return BadRequest(ex.Message);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while creating the booking.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpDelete]
		public async Task<IHttpActionResult> Delete(string reference)
		{
			Booking booking = await TryFindBookingInActiveCruiseByReference(reference);
			if(null == booking)
				return NotFound();

			try
			{
				await _bookingRepository.DeleteAsync(booking);
				_log.Info("Deleted booking {0}.", booking.Reference);

				// Ensure we update reporting after each change
				HostingEnvironment.QueueBackgroundWorkItem(ct => _reportingService.GenerateReportsAsync());

				return Ok();
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while deleting the booking.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> Deleted()
		{
			Cruise activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return NotFound();

			DeletedBooking[] result = await _deletedBookingRepository.GetAllAsync(activeCruise);
			return this.OkNoCache(result);
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		public async Task<IHttpActionResult> Discount(string reference, PaymentSource discount)
		{
			Booking booking = await TryFindBookingInActiveCruiseByReference(reference);
			if(null == booking)
				return NotFound();

			try
			{
				int amount = Convert.ToInt32(discount.Amount);
				amount = Math.Max(Math.Min(amount, 100), 0);

				if(amount != booking.Discount)
				{
					booking.Discount = amount;
					await _bookingRepository.UpdateDiscountAsync(booking);
					_log.Info("Set discount to {0}% for booking {1}.", amount, booking.Reference);
				}

				return Ok();
			}
			catch(Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while updating the discount for the booking with reference {reference}.");
				throw;
			}
		}

		[Authorize]
		[HttpGet]
		public async Task<IHttpActionResult> Get(string reference)
		{
			try
			{
				if(!AuthContext.IsAdmin && !String.Equals(AuthContext.UserName, reference, StringComparison.InvariantCultureIgnoreCase))
					return BadRequest("Request is unauthorized, or not logged in as the booking it's trying to read.");

				Booking booking = await _bookingRepository.FindByReferenceAsync(reference);
				if(null == booking)
					return NotFound();

				Cruise activeCruise = await _cruiseRepository.GetActiveAsync();
				if(!AuthContext.IsAdmin && !booking.CruiseId.Equals(activeCruise?.Id))
					return BadRequest("Request is unauthorized, or booking belongs to an inactive cruise.");

				BookingCabinWithPax[] cabins = await _bookingRepository.GetCabinsForBookingAsync(booking);
				BookingProduct[] products = await _productRepository.GetProductsForBookingAsync(booking);
				PaymentSummary payment = await _paymentRepository.GetSumOfPaymentsByBookingAsync(booking);

				return this.OkNoCache(BookingSource.FromBooking(booking, cabins, products, payment));
			}
			catch(Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while getting the booking with reference {reference}.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPut]
		public async Task<IHttpActionResult> Lock(string reference)
		{
			Booking booking = await TryFindBookingInActiveCruiseByReference(reference);
			if(null == booking)
				return NotFound();

			try
			{
				booking.IsLocked = !booking.IsLocked;
				await _bookingRepository.UpdateIsLockedAsync(booking);
				_log.Info("{0}ocked booking {1}.", booking.IsLocked ? "L" : "Unl", booking.Reference);

				return Ok(IsLockedResult.FromBooking(booking));
			}
			catch(Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while locking/unlocking the booking with reference {reference}.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> Overview()
		{
			var activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return NotFound();

			using(var db = DbUtil.Open())
			{
				var items = await db.QueryAsync<BookingOverviewItem>("select [Id], [Reference], [FirstName], [LastName], [Lunch], [TotalPrice], [IsLocked], [Updated], " +
																	 "(select count(*) from [BookingCabin] BC where BC.[BookingId] = B.[Id]) as NumberOfCabins, " +
																	 "(select sum([Amount]) from [BookingPayment] BP where BP.[BookingId] = B.[Id] group by [BookingId]) as AmountPaid " +
																	 "from [Booking] B where [CruiseId] = @CruiseId",
					new {CruiseId = activeCruise.Id});

				BookingOverviewItem[] result = items.ToArray();
				return this.OkNoCache(result);
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> Pax()
		{
			var activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return NotFound();

			using(var db = DbUtil.Open())
			{
				var items = await db.QueryAsync<BookingPaxItem>("select BP.[Id], BP.[Group], BP.[FirstName], BP.[LastName], BP.[Gender], BP.[Dob], BP.[Nationality], BP.[Years], BC.[CabinTypeId], B.[Reference] " +
																"from [BookingPax] BP " +
																"left join [BookingCabin] BC on BP.[BookingCabinId] = BC.[Id] " +
																"left join [Booking] B on BC.[BookingId] = B.[Id] " +
																"where B.[CruiseId] = @CruiseId",
					new {CruiseId = activeCruise.Id});

				BookingPaxItem[] result = items.ToArray();
				return this.OkNoCache(result);
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		public async Task<IHttpActionResult> Pay(string reference, PaymentSource payment)
		{
			Booking booking = await TryFindBookingInActiveCruiseByReference(reference);
			if(null == booking)
				return NotFound();

			try
			{
				if(payment.Amount != 0)
				{
					await _paymentRepository.CreateAsync(booking, payment.Amount);
					_log.Info("Registered payment of {0} kr for booking {1}.", payment.Amount, booking.Reference);
				}
			}
			catch(Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while creating a payment for the booking with reference {reference}.");
				throw;
			}

			var summary = await _paymentRepository.GetSumOfPaymentsByBookingAsync(booking);
			return Ok(summary);
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> RecentlyUpdated(int limit = 20)
		{
			var activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return NotFound();

			using(var db = DbUtil.Open())
			{
				var items = await db.QueryAsync<BookingDashboardItem>("select top (@Limit) [Id], [Reference], [FirstName], [LastName], [Created], [Updated], " +
																	  "(select count(*) from [BookingCabin] BC where BC.[BookingId] = B.[Id]) as NumberOfCabins, " +
																	  "(select count(*) from [BookingPax] BP where BP.[BookingCabinId] in (select [Id] from [BookingCabin] BC where BC.[BookingId] = B.[Id])) as NumberOfPax " +
																	  "from [Booking] B where [CruiseId] = @CruiseId " +
																	  "order by [Updated] desc",
					new {CruiseId = activeCruise.Id, Limit = limit});

				BookingDashboardItem[] result = items.ToArray();
				return this.OkNoCache(result);
			}
		}

		async Task SendBookingCreatedMailAsync(Cruise cruise, BookingSource bookingSource, BookingResult result)
		{
			try
			{
				using(var emailSender = new EmailSender())
					await emailSender.SendBookingCreatedMailAsync(cruise.Name, bookingSource.Email, result.Reference, result.Password);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "Failed to send e-mail on created booking, although the booking was created without error.");
			}
		}

		async Task<Booking> TryFindBookingInActiveCruiseByReference(string reference)
		{
			Cruise activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return null;

			Booking booking = await _bookingRepository.FindByReferenceAsync(reference);
			if(null == booking || booking.CruiseId != activeCruise.Id)
				return null;

			return booking;
		}
	}
}
