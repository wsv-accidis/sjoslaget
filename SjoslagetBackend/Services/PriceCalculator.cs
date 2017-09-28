using System;
using System.Collections.Generic;
using System.Linq;
using Accidis.Sjoslaget.WebService.Models;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class PriceCalculator
	{
		public decimal CalculatePrice(List<BookingSource.Cabin> bookingCabins, List<BookingSource.Product> bookingProducts, 
			int discount, IEnumerable<CruiseCabinWithType> cruiseCabins, IEnumerable<CruiseProductWithType> cruiseProducts)
		{
			if(!bookingCabins.Any() || discount >= 100)
				return 0m;

			Dictionary<Guid, CruiseCabinWithType> cabinTypeDict = cruiseCabins.ToDictionary(c => c.Id);
			Dictionary<Guid, CruiseProductWithType> productTypeDict = cruiseProducts.ToDictionary(c => c.Id);

			// Cabins
			decimal cabinsPrice = bookingCabins.Sum(bookingCabin =>
			{
				CruiseCabinWithType cruiseCabin;
				if(!cabinTypeDict.TryGetValue(bookingCabin.TypeId, out cruiseCabin))
					throw new BookingException($"Cabin type \"{bookingCabin.TypeId}\" does not refer to an existing type.");

				return cruiseCabin.PricePerPax * cruiseCabin.Capacity;
			});

			// Discount (only applies to price of cabins)
			if(discount > 0)
			{
				decimal discountPrice = cabinsPrice * (discount / 100m);
				cabinsPrice -= discountPrice;
			}

			// Products
			decimal productsPrice = bookingProducts.Sum(bookingProduct =>
			{
				CruiseProductWithType cruiseProduct;
				if(!productTypeDict.TryGetValue(bookingProduct.TypeId, out cruiseProduct))
					throw new BookingException($"Product type \"{bookingProduct.TypeId}\" does not refer to an existing type.");

				return cruiseProduct.Price * bookingProduct.Quantity;
			});

			return cabinsPrice + productsPrice;
		}
	}
}
