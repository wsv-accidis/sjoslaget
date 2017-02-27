using System.Data.SqlClient;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Auth;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class CabinsController : ApiController
	{
		readonly CabinTypeRepository _cabinTypeRepository;
		readonly CruiseRepository _cruiseRepository;

		public CabinsController(CabinTypeRepository cabinTypeRepository, CruiseRepository cruiseRepository)
		{
			_cabinTypeRepository = cabinTypeRepository;
			_cruiseRepository = cruiseRepository;
		}

		[HttpGet]
		public async Task<IHttpActionResult> Active()
		{
			var activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return NotFound();

			using(var db = SjoslagetDb.Open())
			{
				var result = await db.QueryAsync<CruiseCabinResult>("select CT.*, CC.* from [CruiseCabin] CC join [CabinType] CT on CC.[CabinTypeId] = CT.[Id] where CC.[CruiseId] = @Id order by CT.[Order]",
					new {Id = activeCruise.Id});

				return Ok(result);
			}
		}

		[HttpGet]
		public async Task<IHttpActionResult> All()
		{
			return Ok(await _cabinTypeRepository.GetAllAsync());
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		public async Task<IHttpActionResult> CreateOrUpdate(CruiseCabinSource cruiseCabin)
		{
			var activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return NotFound();

			using(var db = SjoslagetDb.Open())
			{
				try
				{
					await db.ExecuteAsync("merge [CruiseCabin] CC " +
										  "using (select @CruiseId [CruiseId], @CabinTypeId [CabinTypeId]) SRC " +
										  "on CC.[CruiseId] = SRC.CruiseId and CC.[CabinTypeId] = SRC.CabinTypeId " +
										  "when matched then update set CC.[Count] = @Count, CC.[PricePerPax] = @PricePerPax " +
										  "when not matched then insert ([CruiseId], [CabinTypeId], [Count], [PricePerPax]) values (@CruiseId, @CabinTypeId, @Count, @PricePerPax);",
						new {CruiseId = activeCruise.Id, CabinTypeId = cruiseCabin.TypeId, Count = cruiseCabin.Count, PricePerPax = cruiseCabin.PricePerPax});
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
