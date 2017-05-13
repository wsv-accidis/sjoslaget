using System;
using System.Collections.Generic;
using System.Linq;
using Accidis.Sjoslaget.WebService.Models;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class PriceCalculator
	{
		public decimal CalculatePrice(List<BookingSource.Cabin> bookingCabins, int discount, IEnumerable<CruiseCabinWithType> cruiseCabins)
		{
			if(!bookingCabins.Any() || discount >= 100)
				return 0m;

			Dictionary<Guid, CruiseCabinWithType> typeDict = cruiseCabins.ToDictionary(c => c.Id, c => c);

			decimal price = bookingCabins.Sum(bookingCabin =>
			{
				CruiseCabinWithType cruiseCabin;
				if(!typeDict.TryGetValue(bookingCabin.TypeId, out cruiseCabin))
					throw new BookingException($"Cabin type \"{bookingCabin.TypeId}\" does not refer to an existing type.");

				return cruiseCabin.PricePerPax * cruiseCabin.Capacity;
			});

			if(discount > 0)
			{
				decimal discountPrice = price * (discount / 100m);
				return price - discountPrice;
			}

			return price;
		}
	}
}
