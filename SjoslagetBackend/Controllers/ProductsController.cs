using System;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Http;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Accidis.WebServices.Auth;
using Accidis.WebServices.Web;

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

			CruiseProductWithType[] products = await _productRepository.GetActiveAsync(activeCruise);

			// Give relative URLs for images to make life easier on frontend
			foreach(CruiseProductWithType product in products)
				if(!String.IsNullOrEmpty(product.Image))
					product.Image = string.Concat("/gfx/products/", product.Image);

			return this.OkCacheControl(products, WebConfig.StaticDataMaxAge);
		}

		[HttpGet]
		public async Task<IHttpActionResult> All()
		{
			return this.OkCacheControl(await _productRepository.GetAllAsync(), WebConfig.StaticDataMaxAge);
		}

		[HttpGet]
		public async Task<IHttpActionResult> Availability()
		{
			var activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return NotFound();

			CruiseProductAvailability[] availabilities = await _productRepository.GetAvailabilityAsync(activeCruise);
			return this.OkNoCache(availabilities.ToDictionary(
				a => a.ProductTypeId,
				a => a.Availability));
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> Quantity()
		{
			var activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return NotFound();

			CruiseProductAvailability[] availabilities = await _productRepository.GetAvailabilityAsync(activeCruise);
			return this.OkNoCache(availabilities.ToDictionary(
				a => a.ProductTypeId,
				a => a.TotalQuantity));
		}
	}
}
