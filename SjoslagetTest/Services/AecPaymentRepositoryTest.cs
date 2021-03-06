﻿using System;
using System.Threading.Tasks;
using Accidis.Sjoslaget.Test.Db;
using Accidis.WebServices.Models;
using Accidis.WebServices.Services;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Accidis.Sjoslaget.Test.Services
{
	[TestClass]
	[DeploymentItem("DbTest.config")]
	public class AecPaymentRepositoryTest
	{
		[TestMethod]
		public async Task GivenBooking_WhenPaymentsRegistered_ShouldCalculateCorrectSummary()
		{
			var booking = await BookingRepositoryTest.GetNewlyCreatedBookingForTestAsync();
			var repository = GetPaymentRepositoryForTest();

			decimal amount1 = 409.27m, amount2 = 15000m, amount3 = -927.44m;

			await repository.CreateAsync(booking, amount1);
			await repository.CreateAsync(booking, amount2);
			await repository.CreateAsync(booking, amount3);

			PaymentSummary summary = await repository.GetSumOfPaymentsByBookingAsync(booking);
			Assert.AreEqual(amount1 + amount2 + amount3, summary.Total);
			Assert.AreNotEqual(DateTime.MinValue, summary.Latest);
		}

		[TestInitialize]
		public void Initialize()
		{
			SjoslagetDbExtensions.InitializeForTest();
		}

		internal static AecPaymentRepository GetPaymentRepositoryForTest()
		{
			return new AecPaymentRepository();
		}
	}
}
