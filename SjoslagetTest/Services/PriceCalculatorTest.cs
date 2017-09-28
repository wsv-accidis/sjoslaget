using System;
using System.Collections.Generic;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Accidis.Sjoslaget.Test.Services
{
	[TestClass]
	public class PriceCalculatorTest
	{
		const int CapacityA = 2;
		const int CapacityB = 4;
		const int CapacityC = 8;
		const decimal PriceA = 460m;
		const decimal PriceB = 620m;
		const decimal PriceC = 900m;
		const decimal ProductPriceA = 110m;
		static readonly Guid TypeA = Guid.NewGuid();
		static readonly Guid TypeB = Guid.NewGuid();
		static readonly Guid TypeC = Guid.NewGuid();

		static IEnumerable<CruiseCabinWithType> CruiseCabinsForTesting => new List<CruiseCabinWithType>
		{
			new CruiseCabinWithType {Id = TypeA, Capacity = CapacityA, PricePerPax = PriceA},
			new CruiseCabinWithType {Id = TypeB, Capacity = CapacityB, PricePerPax = PriceB},
			new CruiseCabinWithType {Id = TypeC, Capacity = CapacityC, PricePerPax = PriceC},
		};

		static IEnumerable<CruiseProductWithType> CruiseProductsForTesting => new List<CruiseProductWithType>
		{
			new CruiseProductWithType {Id = TypeA, Price = PriceA}
		};

		static List<BookingSource.Cabin> NoCabins => new List<BookingSource.Cabin>(0);

		static List<BookingSource.Product> NoProducts => new List<BookingSource.Product>(0);

		public void GivenBooking_WithProducts_WhenDiscountIsApplied_ShouldReturnCorrectPrice()
		{
			var cabins = new List<BookingSource.Cabin>
			{
				new BookingSource.Cabin {TypeId = TypeB},
				new BookingSource.Cabin {TypeId = TypeC}
			};

			var products = new List<BookingSource.Product>
			{
				new BookingSource.Product {TypeId = TypeA, Quantity = 2}
			};

			var priceCalculator = new PriceCalculator();
			var result = priceCalculator.CalculatePrice(cabins, products, 5, CruiseCabinsForTesting, CruiseProductsForTesting);
			var correctResult = 0.95m * (PriceB + PriceC) + 2 * ProductPriceA;
			Assert.AreEqual(correctResult, result);
		}

		public void GivenBooking_WithProducts_WhenPriceCalculated_ShouldReturnCorrectPrice()
		{
			var cabins = new List<BookingSource.Cabin>
			{
				new BookingSource.Cabin {TypeId = TypeA}
			};

			var products = new List<BookingSource.Product>
			{
				new BookingSource.Product {TypeId = TypeA, Quantity = 5}
			};

			var priceCalculator = new PriceCalculator();
			var result = priceCalculator.CalculatePrice(cabins, products, 0, CruiseCabinsForTesting, CruiseProductsForTesting);
			var correctResult = PriceA + 5 * ProductPriceA;
			Assert.AreEqual(correctResult, result);
		}

		[TestMethod]
		public void GivenEmptyList_WhenPriceCalculated_ShouldReturnZero()
		{
			var priceCalculator = new PriceCalculator();
			var result = priceCalculator.CalculatePrice(NoCabins, NoProducts, 0, CruiseCabinsForTesting, CruiseProductsForTesting);
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
			var result = priceCalculator.CalculatePrice(cabins, NoProducts, 16, CruiseCabinsForTesting, CruiseProductsForTesting);
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
			var result = priceCalculator.CalculatePrice(cabins, NoProducts, 0, CruiseCabinsForTesting, CruiseProductsForTesting);
			var correctResult = 2 * CapacityA * PriceA + CapacityB * PriceB + CapacityC * PriceC;
			Assert.AreEqual(correctResult, result);
		}
	}
}
