using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Auth;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Accidis.Sjoslaget.WebService.Web;
using Accidis.WebServices.Db;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class CabinsController : ApiController
	{
		readonly CabinRepository _cabinRepository;
		readonly CruiseRepository _cruiseRepository;

		public CabinsController(CabinRepository cabinRepository, CruiseRepository cruiseRepository)
		{
			_cabinRepository = cabinRepository;
			_cruiseRepository = cruiseRepository;
		}

		[HttpGet]
		public async Task<IHttpActionResult> Active()
		{
			var activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return NotFound();

			return this.OkCacheControl(await _cabinRepository.GetActiveAsync(activeCruise), WebConfig.StaticDataMaxAge);
		}

		[HttpGet]
		public async Task<IHttpActionResult> All()
		{
			return this.OkCacheControl(await _cabinRepository.GetAllAsync(), WebConfig.StaticDataMaxAge);
		}

		[HttpGet]
		public async Task<IHttpActionResult> Availability()
		{
			var activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return NotFound();

			CruiseCabinAvailability[] availabilities = await _cabinRepository.GetAvailabilityAsync(activeCruise);
			return this.OkCacheControl(availabilities.ToDictionary(a => a.CabinTypeId, a => a.Available), WebConfig.DynamicDataMaxAge);
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		public async Task<IHttpActionResult> CreateOrUpdate(CruiseCabinSource cruiseCabin)
		{
			var activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return NotFound();

			using(var db = DbUtil.Open())
			{
				try
				{
					await db.ExecuteAsync("merge [CruiseCabin] CC " +
										  "using (select @CruiseId [CruiseId], @CabinTypeId [CabinTypeId]) SRC " +
										  "on CC.[CruiseId] = SRC.CruiseId and CC.[CabinTypeId] = SRC.CabinTypeId " +
										  "when matched then update set CC.[Count] = @Count, CC.[PricePerPax] = @PricePerPax " +
										  "when not matched then insert ([CruiseId], [CabinTypeId], [Count], [PricePerPax]) values (@CruiseId, @CabinTypeId, @Count, @PricePerPax);",
						new {CruiseId = activeCruise.Id, CabinTypeId = cruiseCabin.TypeId, Count = cruiseCabin.Count, PricePerPax = cruiseCabin.PricePerPax});

					// TODO Must update every booking's price total when doing this
				}
				catch(SqlException ex)
				{
					if(ex.IsForeignKeyViolation())
						return BadRequest("Id must refer to an existing CabinType.");
				}

				return Ok();
			}
		}
	}
}
