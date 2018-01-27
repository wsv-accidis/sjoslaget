using System.Linq;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.WebServices.Db;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class ReportRepository
	{
		public async Task CreateOrUpdateAsync(Report report)
		{
			using(var db = DbUtil.Open())
			{
				await db.ExecuteAsync("delete from [Report] where [CruiseId] = @CruiseId and [Date] = cast(@Date as date)",
					new {CruiseId = report.CruiseId, Date = report.Date});

				await db.ExecuteAsync("insert into [Report] ([CruiseId], [Date], [BookingsCreated], [BookingsTotal], [CabinsTotal], [PaxTotal], [CapacityTotal]) values (@CruiseId, @Date, @BookingsCreated, @BookingsTotal, @CabinsTotal, @PaxTotal, @CapacityTotal)",
					new {report.CruiseId, report.Date, report.BookingsCreated, report.BookingsTotal, report.CabinsTotal, report.PaxTotal, report.CapacityTotal});
			}
		}

		public async Task<Report[]> GetActiveAsync(Cruise cruise)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<Report>("select * from [Report] where [CruiseId] = @Id order by [Date]",
					new {Id = cruise.Id});
				return result.ToArray();
			}
		}
	}
}
