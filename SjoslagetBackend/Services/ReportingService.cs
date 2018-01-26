using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.WebServices.Db;
using Dapper;
using NLog;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class ReportingService
	{
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
