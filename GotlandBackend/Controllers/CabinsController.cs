using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Gotland.WebService.Services;
using Accidis.WebServices.Web;

namespace Accidis.Gotland.WebService.Controllers
{
	public sealed class CabinsController : ApiController
	{
		readonly CabinRepository _cabinRepository;

		public CabinsController(CabinRepository cabinRepository)
		{
			_cabinRepository = cabinRepository;
		}

		[HttpGet]
		public async Task<IHttpActionResult> Classes()
		{
			return this.OkCacheControl(await _cabinRepository.GetAllClasses(), WebConfig.StaticDataMaxAge);
		}
	}
}
