using System;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Models;
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

			CruiseProductWithType[] products = await _productRepository.GetActiveAsync(activeCruise.Id);

			// Give relative URLs for images to make life easier on frontend
			foreach(CruiseProductWithType product in products)
				if(!String.IsNullOrEmpty(product.Image))
					product.Image = string.Concat("/gfx/products/", product.Image);

			return Ok(products);
		}

		[HttpGet]
		public async Task<IHttpActionResult> All()
		{
			return Ok(await _productRepository.GetAllAsync());
		}
	}
}
