using System;
using System.Collections.Generic;
using Accidis.Sjoslaget.WebService.Models;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class BookingCabinsComparer
	{
		static readonly FieldComparer[] FieldComparers = new[]
		{
			new FieldComparer(nameof(BookingPax.Group), p => p.Group, p => p.Group),
			new FieldComparer(nameof(BookingPax.FirstName), p => p.FirstName, p => p.FirstName),
			new FieldComparer(nameof(BookingPax.LastName), p => p.LastName, p => p.LastName),
			new FieldComparer(nameof(BookingPax.Gender), p => p.Gender?.ToString(), p => p.Gender),
			new FieldComparer(nameof(BookingPax.Dob), p => p.Dob?.ToString(), p => p.Dob),
			new FieldComparer(nameof(BookingPax.Nationality), p => p.Nationality, p => p.Nationality),
			new FieldComparer(nameof(BookingPax.Years), p => p.Years.ToString(), p => p.Years.ToString())
		};

		public IEnumerable<BookingChange> FindChanges(List<BookingCabinWithPax> originalCabins, List<BookingSource.Cabin> updatedCabins)
		{
			for(int cabinIdx = 0; cabinIdx < originalCabins.Count; cabinIdx++)
			{
				// Updated cabin contains fewer cabins
				if(cabinIdx >= updatedCabins.Count)
				{
					yield return new BookingChange {FieldName = BookingChange.Removed, CabinIndex = cabinIdx, PaxIndex = BookingChange.IndexWholeCabin};
					continue;
				}

				List<BookingPax> originalPax = originalCabins[cabinIdx].Pax;
				List<BookingSource.Pax> updatedPax = updatedCabins[cabinIdx].Pax;

				for(int paxIdx = 0; paxIdx < originalPax.Count; paxIdx++)
				{
					// Updated cabin contains fewer pax
					if(paxIdx >= updatedPax.Count)
					{
						yield return new BookingChange {FieldName = BookingChange.Removed, CabinIndex = cabinIdx, PaxIndex = paxIdx};
						continue;
					}

					foreach(FieldComparer comparer in FieldComparers)
						if(!comparer.AreFieldsEqual(originalPax[paxIdx], updatedPax[paxIdx]))
							yield return new BookingChange {FieldName = comparer.FieldName, CabinIndex = cabinIdx, PaxIndex = paxIdx};
				}

				// Updated cabin contains additional pax
				for(int newPaxIdx = originalPax.Count; newPaxIdx < updatedPax.Count; newPaxIdx++)
					yield return new BookingChange {FieldName = BookingChange.Added, CabinIndex = cabinIdx, PaxIndex = newPaxIdx};
			}

			// Updated booking contains additional cabins
			for(int newCabinIdx = originalCabins.Count; newCabinIdx < updatedCabins.Count; newCabinIdx++)
				yield return new BookingChange {FieldName = BookingChange.Added, CabinIndex = newCabinIdx, PaxIndex = BookingChange.IndexWholeCabin};
		}

		sealed class FieldComparer
		{
			public FieldComparer(string fieldName, Func<BookingPax, string> original, Func<BookingSource.Pax, string> updated)
			{
				FieldName = fieldName;
				OriginalField = original;
				UpdatedField = updated;
			}

			public string FieldName { get; }

			Func<BookingPax, string> OriginalField { get; }
			Func<BookingSource.Pax, string> UpdatedField { get; }

			public bool AreFieldsEqual(BookingPax original, BookingSource.Pax updated)
			{
				// Coalesce nulls and trim whitespace when comparing
				string originalValue = OriginalField(original)?.Trim() ?? String.Empty;
				string updatedValue = UpdatedField(updated)?.Trim() ?? String.Empty;

				return String.Equals(originalValue, updatedValue, StringComparison.InvariantCultureIgnoreCase);
			}
		}
	}
}
