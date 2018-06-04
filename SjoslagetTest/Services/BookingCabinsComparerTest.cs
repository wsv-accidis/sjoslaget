using System.Collections.Generic;
using System.Linq;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Accidis.WebServices.Models;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Accidis.Sjoslaget.Test.Services
{
	[TestClass]
	public class BookingCabinsComparerTest
	{
		readonly BookingCabinsComparer _sut = new BookingCabinsComparer();

		[TestMethod]
		public void GivenCabins_WithMultipleChanges_ShouldCorrectlyReportThem()
		{
			var originals = new List<BookingCabinWithPax>
			{
				CreateOriginalCabin(
					new BookingPax {Group = "AMEIT", FirstName = "Abraham", LastName = "Agatonsson", Gender = Gender.Male, Dob = new DateOfBirth("830412"), Nationality = "SE", Years = 1},
					new BookingPax {Group = "BMEIT", FirstName = "Adela", LastName = "Adamsson", Gender = Gender.Female, Dob = new DateOfBirth("830413"), Nationality = "NO", Years = 2},
					new BookingPax {Group = "CMEIT", FirstName = "Adolf", LastName = "Alexandersson", Gender = Gender.Male, Dob = new DateOfBirth("830414"), Nationality = "DK", Years = 3},
					new BookingPax {Group = "DMEIT", FirstName = "Anna", LastName = "Andersson", Gender = Gender.Female, Dob = new DateOfBirth("830415"), Nationality = "US", Years = 4}
				),
				CreateOriginalCabin(
					new BookingPax {Group = "EMEIT", FirstName = "Arvid", LastName = "Algotsson", Gender = Gender.Male, Dob = new DateOfBirth("840412"), Nationality = "FI", Years = 5},
					new BookingPax {Group = "FMEIT", FirstName = "Anette", LastName = "Alfredsson", Gender = Gender.Female, Dob = new DateOfBirth("820412"), Nationality = "SE", Years = 6},
					new BookingPax {Group = "GMEIT", FirstName = "Arthur", LastName = "Adolfsson", Gender = Gender.Male, Dob = new DateOfBirth("810412"), Nationality = "JP", Years = 7},
					new BookingPax {Group = "HMEIT", FirstName = "Amanda", LastName = "Astor", Gender = Gender.Female, Dob = new DateOfBirth("800412"), Nationality = "DE", Years = 8}
				)
			};

			var updateds = new List<BookingSource.Cabin>
			{
				CreateUpdatedCabin(
					new BookingSource.Pax {Group = "QMISK", FirstName = "Abraham", LastName = "Agatonsson", Gender = "m", Dob = "790412", Nationality = "SE", Years = 1},
					new BookingSource.Pax {Group = "BMEIT", FirstName = "Adela", LastName = "Adamsson", Gender = "f", Dob = "830413", Nationality = "NO", Years = 2},
					new BookingSource.Pax {Group = "CMEIT", FirstName = "Adolf", LastName = "Alexandersson", Gender = "m", Dob = "830414", Nationality = "DK", Years = 3}
				),
				CreateUpdatedCabin(
					new BookingSource.Pax {Group = "EMEIT", FirstName = "Arvid", LastName = "Algotsson", Gender = "m", Dob = "840412", Nationality = "FI", Years = 5},
					new BookingSource.Pax {Group = "FMEIT", FirstName = "Anette", LastName = "Alfredsson", Gender = "f", Dob = "820412", Nationality = "SE", Years = 6},
					new BookingSource.Pax {Group = "GMEIT", FirstName = "Arthur", LastName = "Adolfsson", Gender = "m", Dob = "810412", Nationality = "CH", Years = 2},
					new BookingSource.Pax {Group = "HMEIT", FirstName = "Amanda", LastName = "Astor", Gender = "x", Dob = "800412", Nationality = "DE", Years = 8}
				)
			};

			var changes = _sut.FindChanges(originals, updateds).ToArray();

			Assert.AreEqual(6, changes.Length);

			Assert.AreEqual(nameof(BookingPax.Group), changes[0].FieldName);
			Assert.AreEqual(0, changes[0].CabinIndex);
			Assert.AreEqual(0, changes[0].PaxIndex);

			Assert.AreEqual(nameof(BookingPax.Dob), changes[1].FieldName);
			Assert.AreEqual(0, changes[1].CabinIndex);
			Assert.AreEqual(0, changes[1].PaxIndex);

			Assert.AreEqual(BookingChange.Removed, changes[2].FieldName);
			Assert.AreEqual(0, changes[2].CabinIndex);
			Assert.AreEqual(3, changes[2].PaxIndex);

			Assert.AreEqual(nameof(BookingPax.Nationality), changes[3].FieldName);
			Assert.AreEqual(1, changes[3].CabinIndex);
			Assert.AreEqual(2, changes[3].PaxIndex);

			Assert.AreEqual(nameof(BookingPax.Years), changes[4].FieldName);
			Assert.AreEqual(1, changes[4].CabinIndex);
			Assert.AreEqual(2, changes[4].PaxIndex);

			Assert.AreEqual(nameof(BookingPax.Gender), changes[5].FieldName);
			Assert.AreEqual(1, changes[5].CabinIndex);
			Assert.AreEqual(3, changes[5].PaxIndex);
		}

		[TestMethod]
		public void GivenCabins_WithTrivialChanges_ShouldCorrectlyReportThem()
		{
			var original = CreateOriginalCabinWithOnePax("Kalle", "Kula");
			var updated = CreateUpdatedCabinWithOnePax("Karl", "Kula");

			var changes = _sut.FindChanges(new List<BookingCabinWithPax> {original}, new List<BookingSource.Cabin> {updated}).ToArray();

			Assert.AreEqual(1, changes.Length);
			Assert.AreEqual(nameof(BookingPax.FirstName), changes[0].FieldName);
			Assert.AreEqual(0, changes[0].CabinIndex);
			Assert.AreEqual(0, changes[0].PaxIndex);
		}

		[TestMethod]
		public void GivenCabins_WithOneNewCabin_ShouldCorrectlyReportIt()
		{
			var original = CreateOriginalCabinWithOnePax("A", "B");
			var updated0 = CreateUpdatedCabinWithOnePax("A", "B");
			var updated1 = CreateUpdatedCabinWithOnePax("C", "D");

			var changes = _sut.FindChanges(new List<BookingCabinWithPax> {original}, new List<BookingSource.Cabin> {updated0, updated1}).ToArray();

			Assert.AreEqual(1, changes.Length);
			Assert.AreEqual(BookingChange.Added, changes[0].FieldName);
			Assert.AreEqual(1, changes[0].CabinIndex);
			Assert.AreEqual(BookingChange.IndexWholeCabin, changes[0].PaxIndex);
		}

		[TestMethod]
		public void GivenCabins_WithOneRemovedCabin_ShouldCorrectlyReportIt()
		{
			var original0 = CreateOriginalCabinWithOnePax("A", "B");
			var original1 = CreateOriginalCabinWithOnePax("D", "C");
			var updated = CreateUpdatedCabinWithOnePax("A", "B");

			var changes = _sut.FindChanges(new List<BookingCabinWithPax> {original0, original1}, new List<BookingSource.Cabin> {updated}).ToArray();

			Assert.AreEqual(1, changes.Length);
			Assert.AreEqual(BookingChange.Removed, changes[0].FieldName);
			Assert.AreEqual(1, changes[0].CabinIndex);
			Assert.AreEqual(BookingChange.IndexWholeCabin, changes[0].PaxIndex);
		}

		static BookingCabinWithPax CreateOriginalCabin(params BookingPax[] pax)
		{
			var original = new BookingCabinWithPax();
			original.Pax.AddRange(pax);
			return original;
		}

		static BookingCabinWithPax CreateOriginalCabinWithOnePax(string firstName, string lastName)
		{
			var original = new BookingCabinWithPax();
			original.Pax.Add(new BookingPax
			{
				FirstName = firstName,
				LastName = lastName
			});

			return original;
		}

		static BookingSource.Cabin CreateUpdatedCabin(params BookingSource.Pax[] pax)
		{
			var updated = new BookingSource.Cabin {Pax = new List<BookingSource.Pax>(pax.Length)};
			updated.Pax.AddRange(pax);
			return updated;
		}

		static BookingSource.Cabin CreateUpdatedCabinWithOnePax(string firstName, string lastName)
		{
			var updated = new BookingSource.Cabin
			{
				Pax = new List<BookingSource.Pax>
				{
					new BookingSource.Pax
					{
						FirstName = firstName,
						LastName = lastName
					}
				}
			};

			return updated;
		}
	}
}
