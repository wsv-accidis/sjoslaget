using System.Data.SqlClient;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Auth;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class CabinsController : ApiController
	{
		[HttpGet]
		public IHttpActionResult Active()
		{
			using(var db = SjoslagetDb.Open())
			{
				var activeCruise = Cruise.Active(db);
				if(null == activeCruise)
					return NotFound();

				var result = db.Query<CruiseCabin>("select CT.*, CC.* from [CruiseCabin] CC join [CabinType] CT on CC.[CabinTypeId] = CT.[Id] where CC.[CruiseId] = @Id order by CT.[Order]",
					new {Id = activeCruise.Id});

				return Ok(result);
			}
		}

		[HttpGet]
		public IHttpActionResult All()
		{
			using(var db = SjoslagetDb.Open())
			{
				var result = db.Query<CabinType>("select * from [CabinType] order by [Order]");
				return Ok(result);
			}
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPost]
		public IHttpActionResult CreateOrUpdate(CruiseCabin cruiseCabin)
		{
			using(var db = SjoslagetDb.Open())
			{
				var activeCruise = Cruise.Active(db);
				if(null == activeCruise)
					return NotFound();

				try
				{
					db.Execute("merge [CruiseCabin] CC " +
									   "using (select @CruiseId [CruiseId], @CabinTypeId [CabinTypeId]) SRC " +
									   "on CC.[CruiseId] = SRC.CruiseId and CC.[CabinTypeId] = SRC.CabinTypeId " +
									   "when matched then update set CC.[Count] = @Count, CC.[PricePerPax] = @PricePerPax " +
									   "when not matched then insert ([CruiseId], [CabinTypeId], [Count], [PricePerPax]) values (@CruiseId, @CabinTypeId, @Count, @PricePerPax);",
						new {CruiseId = activeCruise.Id, CabinTypeId = cruiseCabin.Id, Count = cruiseCabin.Count, PricePerPax = cruiseCabin.PricePerPax});
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
