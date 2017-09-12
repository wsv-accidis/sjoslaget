using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Services;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class ProductsController : ApiController
	{
		readonly CruiseRepository _cruiseRepository;
		readonly ProductRepository _productRepository;

		public ProductsController(CruiseRepository cruiseRepository, ProductRepository productRepository)
		{
			_cruiseRepository = cruiseRepository;
			_productRepository = productRepository;
		}

		[HttpGet]
		public async Task<IHttpActionResult> Active()
		{
			var activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return NotFound();

			return Ok(await _productRepository.GetActiveAsync(activeCruise.Id));
		}

		[HttpGet]
		public async Task<IHttpActionResult> All()
		{
			return Ok(await _productRepository.GetAllAsync());
		}
	}
}
