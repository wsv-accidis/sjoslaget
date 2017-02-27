using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Accidis.Sjoslaget.Test.Db;
using Accidis.Sjoslaget.WebService.Auth;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Microsoft.AspNet.Identity;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;

namespace Accidis.Sjoslaget.Test.Services
{
	[TestClass]
	[DeploymentItem("DbTest.config")]
	public class BookingRepositoryTest
	{
		static readonly SjoslagetDbTestConfig Config = SjoslagetDbTestConfig.Default;

		[ClassInitialize]
		public static void ClassInitialize(TestContext context)
		{
			SjoslagetDbExtensions.InitializeForTest();
		}

		[TestMethod]
		public async Task GivenValidBookingSource_ShouldCreateBooking()
		{
			var source = new BookingSource
			{
				FirstName = "Wilhelm",
				LastName = "Svenselius",
				Email = "test@sjoslaget.se",
				PhoneNo = "0000-123 456",
				Cabins = new List<BookingSource.Cabin>
				{
					new BookingSource.Cabin
					{
						TypeId = SjoslagetDbExtensions.CabinTypeId,
						Pax = new List<BookingSource.Pax>
						{
							new BookingSource.Pax {FirstName = "Ett", LastName = "Ettson"},
							new BookingSource.Pax {FirstName = "Två", LastName = "Tvåson"},
							new BookingSource.Pax {FirstName = "Tre", LastName = "Treson"},
							new BookingSource.Pax {FirstName = "Fyr", LastName = "Fyrson"}
						}
					}
				}
			};

			var userManagerMock = new Mock<SjoslagetUserManager>();
			userManagerMock.Setup(m => m.CreateAsync(It.IsAny<User>(), It.IsAny<string>())).Returns(Task.FromResult<IdentityResult>(null));

			var sut = new BookingRepository(new RandomKeyGenerator(), userManagerMock.Object);
			var result = await sut.CreateAsync(new Cruise {Id = SjoslagetDbExtensions.CruiseId}, source);

			Assert.IsNotNull(result.Reference);
			Assert.IsNotNull(result.Password);
		}
	}
}
