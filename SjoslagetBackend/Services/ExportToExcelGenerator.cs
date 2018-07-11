using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.WebServices.Db;
using Accidis.WebServices.Models;
using Dapper;
using Simplexcel;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class ExportToExcelGenerator
	{
		const string DobFormat = "dd.MM.yyyy";

		static readonly string[] ExportedFields = new[]
		{
			nameof(BookingPax.LastName),
			nameof(BookingPax.FirstName),
			nameof(BookingPax.Dob),
			nameof(BookingPax.Gender),
			nameof(BookingPax.Nationality)
		};

		readonly CabinRepository _cabinRepository;
		readonly ProductRepository _productRepository;
		int _cabinNo;

		Cruise _cruise;
		bool _onlyFullyPaid;
		int _rowNo;
		DateTime? _updatedSince;

		public ExportToExcelGenerator(CabinRepository cabinRepository, ProductRepository productRepository)
		{
			_cabinRepository = cabinRepository;
			_productRepository = productRepository;
		}

		public async Task<Workbook> ExportToWorkbookAsync(Cruise cruise, bool onlyFullyPaid, DateTime? updatedSince)
		{
			_cruise = cruise;
			_onlyFullyPaid = onlyFullyPaid;
			_updatedSince = updatedSince;

			using(var db = DbUtil.Open())
			{
				Worksheet cabinsSheet = CreateCabinsWorksheet();
				CreateCabinsHeaderRow(cabinsSheet);
				await FetchAndCreateRowsForBookings(db, cabinsSheet);

				Worksheet productsSheet = CreateProductsWorksheet();
				CreateProductsHeaderRow(productsSheet);
				await FetchAndCreateRowsForProducts(db, productsSheet);

				return CreateWorkbook(cabinsSheet, productsSheet);
			}
		}

		void CreateCabinsHeaderRow(Worksheet sheet, int row = 0)
		{
			sheet[row, 0] = CreateHeaderCell("Hyttnr");
			sheet[row, 1] = CreateHeaderCell("Hyttkategori");
			sheet[row, 2] = CreateHeaderCell("Efternamn");
			sheet[row, 3] = CreateHeaderCell("Förnamn");
			sheet[row, 4] = CreateHeaderCell("Födelsedatum");
			sheet[row, 5] = CreateHeaderCell("Kön");
			sheet[row, 6] = CreateHeaderCell("Nationalitet");
			sheet[row, 7] = CreateHeaderCell("Bokningsref");

			if(_updatedSince.HasValue)
				sheet[row, 8] = CreateHeaderCell("Ändrad");
		}

		static Worksheet CreateCabinsWorksheet()
		{
			var sheet = new Worksheet("Passagerare");
			sheet.PageSetup.Orientation = Orientation.Landscape;

			sheet.ColumnWidths[0] = 6;
			sheet.ColumnWidths[1] = 12;
			sheet.ColumnWidths[2] = 25;
			sheet.ColumnWidths[3] = 20;
			sheet.ColumnWidths[4] = 14;
			sheet.ColumnWidths[5] = 4;
			sheet.ColumnWidths[6] = 12;
			sheet.ColumnWidths[7] = 12;
			sheet.ColumnWidths[8] = 12;

			return sheet;
		}

		static Cell CreateHeaderCell(String text)
		{
			return new Cell(CellType.Text)
			{
				Bold = true,
				Border = CellBorder.Bottom,
				Value = text
			};
		}

		static void CreateProductsHeaderRow(Worksheet sheet, int row = 0)
		{
			sheet[row, 0] = CreateHeaderCell("Namn");
			sheet[row, 1] = CreateHeaderCell("Antal");
			sheet[row, 2] = CreateHeaderCell("Innehåll");
		}

		static Worksheet CreateProductsWorksheet()
		{
			var sheet = new Worksheet("Paket");
			sheet.PageSetup.Orientation = Orientation.Landscape;

			sheet.ColumnWidths[0] = 30;
			sheet.ColumnWidths[1] = 8;
			sheet.ColumnWidths[2] = 80;

			return sheet;
		}

		void CreateRow(
			Worksheet sheet,
			int row,
			int cabinNo,
			string cabinTypeName,
			string lastName,
			string firstName,
			DateOfBirth dob,
			Gender gender,
			string nationality,
			string reference,
			bool isCreated,
			string[] changes
		)
		{
			SetCell(sheet, row, 0, cabinNo.ToString(), null, isCreated, changes);
			SetCell(sheet, row, 1, cabinTypeName, null, isCreated, changes);
			SetCell(sheet, row, 2, lastName, nameof(BookingPax.LastName), isCreated, changes);
			SetCell(sheet, row, 3, firstName, nameof(BookingPax.FirstName), isCreated, changes);
			SetCell(sheet, row, 4, dob.Format(DobFormat), nameof(BookingPax.Dob), isCreated, changes);
			SetCell(sheet, row, 5, gender.ToString().ToUpperInvariant(), nameof(BookingPax.Gender), isCreated, changes);
			SetCell(sheet, row, 6, nationality.ToUpperInvariant(), nameof(BookingPax.Nationality), isCreated, changes);
			SetCell(sheet, row, 7, reference, null, isCreated, changes);

			if(_updatedSince.HasValue && (isCreated || changes.Any(IsExportedField)))
				SetCell(sheet, row, 8, isCreated ? "Ny" : "Ändrad", null, true, null);
		}

		void CreateRowForRemovedPax(Worksheet sheet, int row, int cabinNo, string cabinTypeName, string reference)
		{
			SetCell(sheet, row, 0, cabinNo.ToString(), null, true, null);
			SetCell(sheet, row, 1, cabinTypeName, null, true, null);
			SetCell(sheet, row, 2, String.Empty, null, true, null);
			SetCell(sheet, row, 3, String.Empty, null, true, null);
			SetCell(sheet, row, 4, String.Empty, null, true, null);
			SetCell(sheet, row, 5, String.Empty, null, true, null);
			SetCell(sheet, row, 6, String.Empty, null, true, null);
			SetCell(sheet, row, 7, reference, null, true, null);

			if(_updatedSince.HasValue)
				SetCell(sheet, row, 8, "Borttagen", null, true, null);
		}

		void CreateRowsForBooking(Worksheet sheet, BookingDbRow booking, PaxDbRow[] paxInBooking,
			Dictionary<Guid, CabinType> cabinTypes, ChangeDbRow[] changes)
		{
			var cabins = paxInBooking.GroupBy(g => g.CabinIndex).OrderBy(g => g.Key);
			foreach(IGrouping<int, PaxDbRow> cabin in cabins)
			{
				_rowNo++; // insert a blank row
				_cabinNo++; // holds the cabin index within the whole sheet

				CabinType cabinType = cabinTypes[cabin.First().CabinTypeId];

				foreach(PaxDbRow pax in cabin.OrderBy(g => g.PaxIndex))
				{
					string[] changesInThisRow = changes.Where(c => c.CabinIndex == cabin.Key && c.PaxIndex == pax.PaxIndex).Select(c => c.FieldName).ToArray();

					CreateRow(
						sheet,
						_rowNo++,
						_cabinNo,
						cabinType.Name,
						pax.LastName,
						pax.FirstName,
						pax.Dob,
						pax.Gender,
						pax.Nationality,
						booking.Reference,
						booking.IsCreated,
						changesInThisRow
					);
				}

				// Add empty highlighted rows for pax who were removed (but not if they were also added in the same timespan)
				for(int emptyPaxIdx = cabin.Count(); emptyPaxIdx < cabinType.Capacity; emptyPaxIdx++)
				{
					string[] changesInThisRow = changes.Where(c => c.CabinIndex == cabin.Key && c.PaxIndex == emptyPaxIdx).Select(c => c.FieldName).ToArray();
					if(changesInThisRow.Contains(BookingChange.Removed, StringComparer.Ordinal) && !changesInThisRow.Contains(BookingChange.Added, StringComparer.Ordinal))
						CreateRowForRemovedPax(sheet, _rowNo++, _cabinNo, cabinType.Name, booking.Reference);
				}
			}
		}

		static Workbook CreateWorkbook(params Worksheet[] sheets)
		{
			var workbook = new Workbook();
			foreach(Worksheet sheet in sheets)
				workbook.Add(sheet);
			return workbook;
		}

		async Task FetchAndCreateRowsForBookings(SqlConnection db, Worksheet sheet)
		{
			_cabinNo = 0;
			_rowNo = 0;

			var bookingsResult = await db.QueryAsync<BookingDbRow>("select [Id], [Reference], [TotalPrice], " +
																   "(select sum([Amount]) from [BookingPayment] BP where BP.[BookingId] = B.[Id] group by [BookingId]) as AmountPaid, " +
																   "iif([Created] > @UpdatedSince, 1, 0) IsCreated " +
																   "from [Booking] B where [CruiseId] = @CruiseId " +
																   "order by [Reference]",
				new
				{
					CruiseId = _cruise.Id,
					UpdatedSince = _updatedSince
				});

			BookingDbRow[] allBookings = _onlyFullyPaid
				? bookingsResult.Where(b => b.IsFullyPaid).ToArray()
				: bookingsResult.ToArray();

			Dictionary<Guid, CabinType> cabinTypes = (await _cabinRepository.GetAllAsync(db)).ToDictionary(c => c.Id, c => c);
			foreach(BookingDbRow booking in allBookings)
			{
				var paxResult = await db.QueryAsync<PaxDbRow>("select BC.[Order] [CabinIndex], BP.[Order] [PaxIndex], BP.[FirstName], BP.[LastName], BP.[Gender], BP.[Dob], BP.[Nationality], BP.[Years], BC.[Id] CabinId, BC.[CabinTypeId] " +
															  "from [BookingPax] BP " +
															  "left join [BookingCabin] BC on BP.[BookingCabinId] = BC.[Id] " +
															  "where BC.[BookingId] = @BookingId " +
															  "order by BC.[Order], BP.[Order]",
					new {BookingId = booking.Id});

				ChangeDbRow[] bookingChanges;
				if(_updatedSince.HasValue)
				{
					var bookingChangesResult = await db.QueryAsync<ChangeDbRow>("select [CabinIndex], [PaxIndex], [FieldName] from [BookingChange] " +
																				"where [BookingId] = @BookingId and [Updated] > @UpdatedSince",
						new
						{
							BookingId = booking.Id,
							UpdatedSince = _updatedSince
						});
					bookingChanges = bookingChangesResult.ToArray();
				}
				else
					bookingChanges = new ChangeDbRow[0];

				CreateRowsForBooking(sheet, booking, paxResult.ToArray(), cabinTypes, bookingChanges);
			}
		}

		async Task FetchAndCreateRowsForProducts(SqlConnection db, Worksheet sheet)
		{
			_rowNo = 1;

			CruiseProductWithType[] productTypes = await _productRepository.GetActiveAsync(db, _cruise);
			ProductCount[] productCounts = await _productRepository.GetSumOfOrdersByProductAsync(db, _cruise, _onlyFullyPaid);

			foreach(CruiseProductWithType type in productTypes)
			{
				int row = _rowNo++;
				sheet[row, 0] = type.Name;
				sheet[row, 1] = productCounts.FirstOrDefault(c => c.TypeId == type.Id)?.Count ?? 0;
				sheet[row, 2] = type.Description;
			}
		}

		static bool IsExportedField(string fieldName) => ExportedFields.Contains(fieldName);

		static void SetCell(Worksheet sheet, int row, int col, string content, string fieldName, bool mustHighlight, string[] changedFields)
		{
			sheet[row, col] = content;
			if(mustHighlight || changedFields.Contains(BookingChange.Added, StringComparer.Ordinal) || changedFields.Contains(fieldName, StringComparer.Ordinal))
				sheet[row, col].Fill.BackgroundColor = Color.Yellow;
		}

		// ReSharper disable UnusedAutoPropertyAccessor.Local, ClassNeverInstantiated.Local, MemberCanBePrivate.Local
		sealed class BookingDbRow
		{
			public Guid Id { get; set; }
			public string Reference { get; set; }
			public decimal TotalPrice { get; set; }
			public decimal AmountPaid { get; set; }
			public bool IsCreated { get; set; }
			public bool IsFullyPaid => AmountPaid >= TotalPrice;
		}

		sealed class ChangeDbRow
		{
			public int CabinIndex { get; set; }
			public int PaxIndex { get; set; }
			public string FieldName { get; set; }
		}

		sealed class PaxDbRow
		{
			public int CabinIndex { get; set; }
			public int PaxIndex { get; set; }
			public string FirstName { get; set; }
			public string LastName { get; set; }
			public Gender Gender { get; set; }
			public DateOfBirth Dob { get; set; }
			public string Nationality { get; set; }
			public Guid CabinTypeId { get; set; }
		}
		// ReSharper restore UnusedAutoPropertyAccessor.Local, ClassNeverInstantiated.Local, MemberCanBePrivate.Local
	}
}
