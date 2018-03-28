using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.WebServices.Db;
using Dapper;
using NLog;
using KeyValuePair = System.Collections.Generic.KeyValuePair<string, int>;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class ReportingService
	{
		const int HighestAgeTreshold = 85;

		readonly CruiseRepository _cruiseRepository;
		readonly Logger _log = LogManager.GetLogger(typeof(ReportingService).Name);
		readonly ReportRepository _reportRepository;

		public ReportingService(CruiseRepository cruiseRepository, ReportRepository reportRepository)
		{
			_cruiseRepository = cruiseRepository;
			_reportRepository = reportRepository;
		}

		public async Task GenerateReportsAsync()
		{
			try
			{
				var cruise = await _cruiseRepository.GetActiveAsync();
				if(null == cruise || cruise.IsLocked)
					return; // nothing to do

				Report report = await CreateReportForDate(cruise, DateTime.Now);
				await _reportRepository.CreateOrUpdateAsync(report);
			}
			catch(Exception ex)
			{
				_log.Error(ex, "An unexpected exception occurred while generating a report.");
			}
		}

		public async Task<KeyValuePair[]> GetAgeDistribution(SqlConnection db, Cruise cruise)
		{
			// TODO This will no longer work once we start seeing participants born >99 and needs a refactor
			var result = await db.QueryAsync<KeyValuePair>("select substring([Dob], 1, 2) [Key], count(*) [Value] from [BookingPax] " +
														   "where [BookingCabinId] in (select [Id] from [BookingCabin] where [CruiseId] = @CruiseId) " +
														   "group by substring([Dob], 1, 2) " +
														   "order by substring([Dob], 1, 2)", new {CruiseId = cruise.Id});
			KeyValuePair[] sourceList = result.ToArray();
			if(!sourceList.Any())
				return new KeyValuePair[0];

			int thisYear = DateTime.Now.Year % 100;
			int maxYear = int.Parse(sourceList.Last().Key, NumberStyles.Integer);

			var buckets = new Dictionary<int, int>();
			for(int year = HighestAgeTreshold; year <= maxYear; year++)
				buckets[year] = 0;

			foreach(KeyValuePair pair in sourceList)
			{
				int year = int.Parse(pair.Key, NumberStyles.None);

				// Put everyone who is older than HighestAgeTreshold into one bucket
				if(year > thisYear && year <= HighestAgeTreshold)
					year = HighestAgeTreshold;

				// Don't crash if we encounter a year that is out of range
				if(!buckets.ContainsKey(year))
					continue;

				buckets[year] += pair.Value;
			}

			return buckets.Select(k => new KeyValuePair(
				k.Key == HighestAgeTreshold ? $"≤{HighestAgeTreshold}" : k.Key.ToString(),
				k.Value)).ToArray();
		}

		public async Task<KeyValuePair[]> GetGenders(SqlConnection db, Cruise cruise)
		{
			var result = await db.QueryAsync<KeyValuePair>("select BP.[Gender] [Key], COUNT(*) [Value] " +
														   "from [BookingPax] BP " +
														   "left join [BookingCabin] BC on BP.[BookingCabinId] = BC.[Id] " +
														   "where BC.[CruiseId] = @CruiseId " +
														   "group by BP.[Gender]", new {CruiseId = cruise.Id});
			return result.ToArray();
		}

		public async Task<KeyValuePair[]> GetNumberOfBookingsByPaymentStatus(SqlConnection db, Cruise cruise)
		{
			return new[]
			{
				new KeyValuePair("unpaid", await GetNumberOfBookingByPaymentStatus(db, cruise, "<")),
				new KeyValuePair("paid", await GetNumberOfBookingByPaymentStatus(db, cruise, ">="))
			};
		}

		public async Task<KeyValuePair[]> GetTopContacts(SqlConnection db, Cruise cruise, int top)
		{
			var result = await db.QueryAsync<KeyValuePair>("select top (@Top) concat(B.[FirstName], ' ', B.[LastName]) [Key], COUNT(*) [Value] " +
														   "from [BookingPax] BP " +
														   "left join [BookingCabin] BC on BP.[BookingCabinId] = BC.[Id] " +
														   "left join [Booking] B on BC.[BookingId] = B.[Id] " +
														   "where B.[CruiseId] = @CruiseId " +
														   "group by B.[FirstName], B.[LastName] " +
														   "order by COUNT(*) desc", new {Top = top, CruiseId = cruise.Id});
			return result.ToArray();
		}

		public async Task<KeyValuePair[]> GetTopGroups(SqlConnection db, Cruise cruise, int top)
		{
			var result = await db.QueryAsync<KeyValuePair>("select top (@Top) BP.[Group] [Key], COUNT(*) [Value] " +
														   "from [BookingPax] BP " +
														   "left join [BookingCabin] BC on BP.[BookingCabinId] = BC.[Id] " +
														   "where BC.[CruiseId] = @CruiseId " +
														   "group by BP.[Group] " +
														   "order by COUNT(*) desc", new {Top = top, CruiseId = cruise.Id});
			return result.ToArray();
		}

		async Task<Report> CreateReportForDate(Cruise cruise, DateTime today)
		{
			Report report = new Report {CruiseId = cruise.Id, Date = today.Date};

			using(var db = DbUtil.Open())
			{
				report.BookingsCreated = await GetCreatedBookings(db, cruise, today);
				report.BookingsTotal = await GetTotalBookings(db, cruise);
				report.CabinsTotal = await GetTotalCabins(db, cruise);
				report.PaxTotal = await GetTotalPax(db, cruise);
				report.CapacityTotal = await GetTotalCapacity(db, cruise);
			}

			return report;
		}

		async Task<int> GetCreatedBookings(SqlConnection db, Cruise cruise, DateTime date)
		{
			return await db.ExecuteScalarAsync<int>("select count(*) from [Booking] where [CruiseId] = @CruiseId and CAST([Created] as date) = CAST(@Date as date)",
				new {CruiseId = cruise.Id, Date = date.Date});
		}

		async Task<int> GetNumberOfBookingByPaymentStatus(SqlConnection db, Cruise cruise, string oper)
		{
			return await db.ExecuteScalarAsync<int>("select count(*) from [Booking] B where [CruiseId] = @CruiseId and " +
													$"isnull((select sum(BP.[Amount]) from [BookingPayment] BP where BP.[BookingId] = B.[Id]), 0) {oper} B.[TotalPrice]",
				new {CruiseId = cruise.Id});
		}

		async Task<int> GetTotalBookings(SqlConnection db, Cruise cruise)
		{
			return await db.ExecuteScalarAsync<int>("select count(*) from [Booking] where [CruiseId] = @CruiseId", new {CruiseId = cruise.Id});
		}

		async Task<int> GetTotalCabins(SqlConnection db, Cruise cruise)
		{
			return await db.ExecuteScalarAsync<int>("select count(*) from [BookingCabin] where [BookingId] in (select [Id] from [Booking] where [CruiseId] = @CruiseId)",
				new {CruiseId = cruise.Id});
		}

		async Task<int> GetTotalCapacity(SqlConnection db, Cruise cruise)
		{
			// This query gets a little more data than we need but can be reused if there is ever a need to get stats per cabin type
			IDataReader reader = await db.ExecuteReaderAsync("select [CabinTypeId], count(*), (select [Capacity] from [CabinType] where [Id] = [CabinTypeId]) " +
															 "from [BookingCabin] where [CruiseId] = @CruiseId " +
															 "group by [CabinTypeId]", new {CruiseId = cruise.Id});

			int sum = 0;
			while(reader.Read())
				sum += reader.GetInt32(1) * reader.GetInt32(2);
			reader.Close();

			return sum;
		}

		async Task<int> GetTotalPax(SqlConnection db, Cruise cruise)
		{
			return await db.ExecuteScalarAsync<int>("select count(*) from [BookingPax] where [BookingCabinId] in (select [Id] from [BookingCabin] where [CruiseId] = @CruiseId)",
				new {CruiseId = cruise.Id});
		}
	}
}
