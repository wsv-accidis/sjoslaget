using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Auth;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Dapper;
using NLog;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class BookingsController : ApiController
	{
		readonly BookingRepository _bookingRepository;
		readonly CruiseRepository _cruiseRepository;
		readonly Logger _log = LogManager.GetLogger(typeof(BookingsController).Name);
		readonly PaymentRepository _paymentRepository;

		public BookingsController(BookingRepository bookingRepository, CruiseRepository cruiseRepository, PaymentRepository paymentRepository)
		{
			_bookingRepository = bookingRepository;
			_cruiseRepository = cruiseRepository;
			_paymentRepository = paymentRepository;
		}

		[HttpPost]
		public async Task<IHttpActionResult> CreateOrUpdate(BookingSource bookingSource)
		{
			try
			{
				Cruise activeCruise = await _cruiseRepository.GetActiveAsync();
				if(null == activeCruise)
					return NotFound();

				if(!String.IsNullOrEmpty(bookingSource.Reference))
				{
					if(!AuthContext.IsAdmin && !String.Equals(AuthContext.UserName, bookingSource.Reference, StringComparison.InvariantCultureIgnoreCase))
						return BadRequest("Request is unauthorized, or not logged in as the booking it's trying to update.");

					BookingResult result = await _bookingRepository.UpdateAsync(activeCruise.Id, bookingSource);
					_log.Info("Updated booking {0}.", result.Reference);
					return Ok(result);
				}
				else
				{
					BookingResult result = await _bookingRepository.CreateAsync(activeCruise.Id, bookingSource);
					_log.Info("Created booking {0}.", result.Reference);

					await SendBookingCreatedMailAsync(bookingSource, result);
					return Ok(result);
				}
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
				PaymentSummary payment = await _paymentRepository.GetSumOfPaymentsByBookingAsync(booking);

				return Ok(BookingSource.FromBooking(booking, cabins, payment));
			}
			catch(Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while getting the booking with reference {reference}.");
				throw;
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> RecentlyUpdated(int limit = 20)
		{
			var activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return NotFound();

			using(var db = SjoslagetDb.Open())
			{
				var items = await db.QueryAsync<BookingDashboardItem>("select top (@Limit) [Id], [Reference], [FirstName], [LastName], [Updated], " +
																	  "(select count(*) from [BookingCabin] BC where BC.[BookingId] = B.[Id]) as NumberOfCabins, " +
																	  "(select count(*) from [BookingPax] BP where BP.[BookingCabinId] in (select[Id] from [BookingCabin] BC where BC.[BookingId] = B.[Id])) as NumberOfPax " +
																	  "from [Booking] B where [CruiseId] = @CruiseId " +
																	  "order by [Updated] asc",
					new {CruiseId = activeCruise.Id, Limit = limit});

				BookingDashboardItem[] result = items.ToArray();
				return Ok(result);
			}
		}

		[Authorize]
		[HttpPost]
		public async Task<IHttpActionResult> Pay(string reference, PaymentSource payment)
		{
			Booking booking = await _bookingRepository.FindByReferenceAsync(reference);
			if (null == booking)
				return NotFound();

			try
			{
				await _paymentRepository.CreateAsync(booking, payment.Amount);
			}
			catch(Exception ex)
			{
				_log.Error(ex, $"An unexpected exception occurred while creating a paymenty for the booking with reference {reference}.");
				throw;
			}

			var summary = await _paymentRepository.GetSumOfPaymentsByBookingAsync(booking);
			return Ok(summary);
		}

		async Task SendBookingCreatedMailAsync(BookingSource bookingSource, BookingResult result)
		{
			try
			{
				using(var emailSender = new EmailSender())
					await emailSender.SendBookingCreatedMailAsync(bookingSource.Email, result.Reference, result.Password);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "Failed to send e-mail on created booking, although the booking was created without error.");
			}
		}
	}
}
