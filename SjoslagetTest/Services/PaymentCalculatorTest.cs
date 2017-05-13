using System;
using System.Collections.Generic;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Accidis.Sjoslaget.Test.Services
{
	[TestClass]
	public class PaymentCalculatorTest
	{
		const int CapacityA = 2;
		const int CapacityB = 4;
		const int CapacityC = 8;
		const decimal PriceA = 460m;
		const decimal PriceB = 620m;
		const decimal PriceC = 900m;
		static readonly Guid TypeA = Guid.NewGuid();
		static readonly Guid TypeB = Guid.NewGuid();
		static readonly Guid TypeC = Guid.NewGuid();

		[TestMethod]
		public void GivenEmptyList_WhenPriceCalculated_ShouldReturnZero()
		{
			var priceCalculator = new PriceCalculator();
			var result = priceCalculator.CalculatePrice(new List<BookingSource.Cabin>(), 0, GetCruiseCabinsForTesting());
			Assert.AreEqual(0m, result);
		}

		[TestMethod]
		public void GivenListOfCabins_WhenDiscountIsApplied_ShouldReturnCorrectPrice()
		{
			var cabins = new List<BookingSource.Cabin>
			{
				new BookingSource.Cabin {TypeId = TypeB},
				new BookingSource.Cabin {TypeId = TypeB},
				new BookingSource.Cabin {TypeId = TypeB},
				new BookingSource.Cabin {TypeId = TypeB},
			};

			var priceCalculator = new PriceCalculator();
			var result = priceCalculator.CalculatePrice(cabins, 16, GetCruiseCabinsForTesting());
			var correctResult = 0.84m * 4 * CapacityB * PriceB;
			Assert.AreEqual(correctResult, result);
		}

		[TestMethod]
		public void GivenListOfCabins_WhenPriceCalculated_ShouldReturnCorrectPrice()
		{
			var cabins = new List<BookingSource.Cabin>
			{
				new BookingSource.Cabin {TypeId = TypeA},
				new BookingSource.Cabin {TypeId = TypeA},
				new BookingSource.Cabin {TypeId = TypeB},
				new BookingSource.Cabin {TypeId = TypeC}
			};

			var priceCalculator = new PriceCalculator();
			var result = priceCalculator.CalculatePrice(cabins, 0, GetCruiseCabinsForTesting());
			var correctResult = 2 * CapacityA * PriceA + CapacityB * PriceB + CapacityC * PriceC;
			Assert.AreEqual(correctResult, result);
		}

		IEnumerable<CruiseCabinWithType> GetCruiseCabinsForTesting()
		{
			return new List<CruiseCabinWithType>
			{
				new CruiseCabinWithType {Id = TypeA, Capacity = CapacityA, PricePerPax = PriceA},
				new CruiseCabinWithType {Id = TypeB, Capacity = CapacityB, PricePerPax = PriceB},
				new CruiseCabinWithType {Id = TypeC, Capacity = CapacityC, PricePerPax = PriceC},
			};
		}
	}
}
