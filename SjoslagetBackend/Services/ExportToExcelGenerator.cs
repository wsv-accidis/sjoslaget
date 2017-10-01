using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Dapper;
using Simplexcel;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class ExportToExcelGenerator
	{
		const string DobFormat = "dd.MM.yyyy";

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

		public async Task<Workbook> ExportToWorkbook(Cruise cruise, bool onlyFullyPaid, DateTime? updatedSince)
		{
			_cruise = cruise;
			_onlyFullyPaid = onlyFullyPaid;
			_updatedSince = updatedSince;

			using(var db = SjoslagetDb.Open())
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
				sheet[row, 8] = CreateHeaderCell("Uppdaterad");
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
			bool isUpdated
		)
		{
			sheet[row, 0] = cabinNo;
			sheet[row, 1] = cabinTypeName;
			sheet[row, 2] = lastName;
			sheet[row, 3] = firstName;
			sheet[row, 4] = dob.Format(DobFormat);
			sheet[row, 5] = gender.ToString().ToUpperInvariant();
			sheet[row, 6] = nationality.ToUpperInvariant();
			sheet[row, 7] = reference;

			if(_updatedSince.HasValue && (isCreated || isUpdated))
				sheet[row, 8] = isCreated ? "NY" : "ÄNDRAD";
		}

		void CreateRowsForBooking(Worksheet sheet, BookingDbRow booking, PaxDbRow[] paxInBooking,
			Dictionary<Guid, string> cabinTypes)
		{
			Guid cabinId = Guid.Empty;
			string cabinTypeName = String.Empty;

			foreach(PaxDbRow pax in paxInBooking)
			{
				if(!cabinId.Equals(pax.CabinId))
				{
					cabinId = pax.CabinId;
					cabinTypeName = cabinTypes[pax.CabinTypeId];
					_cabinNo++;
					_rowNo++; // inserts a blank row into the sheet
				}

				CreateRow(
					sheet,
					_rowNo++,
					_cabinNo,
					cabinTypeName,
					pax.LastName,
					pax.FirstName,
					pax.Dob,
					pax.Gender,
					pax.Nationality,
					booking.Reference,
					booking.IsCreated,
					booking.IsUpdated
				);
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
																   "iif([Created] > @UpdatedSince, 1, 0) IsCreated, iif([Updated] > @UpdatedSince, 1, 0) IsUpdated " +
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

			Dictionary<Guid, string> cabinTypes = (await _cabinRepository.GetAllAsync(db)).ToDictionary(c => c.Id, c => c.Name);
			foreach(BookingDbRow booking in allBookings)
			{
				var paxResult = await db.QueryAsync<PaxDbRow>("select BP.[FirstName], BP.[LastName], BP.[Gender], BP.[Dob], BP.[Nationality], BP.[Years], BC.[Id] CabinId, BC.[CabinTypeId] " +
															  "from [BookingPax] BP " +
															  "left join [BookingCabin] BC on BP.[BookingCabinId] = BC.[Id] " +
															  "where BC.[BookingId] = @BookingId " +
															  "order by BC.[Order], BP.[Order]",
					new {BookingId = booking.Id});

				CreateRowsForBooking(sheet, booking, paxResult.ToArray(), cabinTypes);
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

		// ReSharper disable UnusedAutoPropertyAccessor.Local, ClassNeverInstantiated.Local, MemberCanBePrivate.Local
		sealed class BookingDbRow
		{
			public Guid Id { get; set; }
			public string Reference { get; set; }
			public decimal TotalPrice { get; set; }
			public decimal AmountPaid { get; set; }
			public bool IsCreated { get; set; }
			public bool IsUpdated { get; set; }
			public bool IsFullyPaid => AmountPaid >= TotalPrice;
		}

		sealed class PaxDbRow
		{
			public string FirstName { get; set; }
			public string LastName { get; set; }
			public Gender Gender { get; set; }
			public DateOfBirth Dob { get; set; }
			public string Nationality { get; set; }
			public Guid CabinId { get; set; }
			public Guid CabinTypeId { get; set; }
		}
		// ReSharper restore UnusedAutoPropertyAccessor.Local, ClassNeverInstantiated.Local, MemberCanBePrivate.Local
	}
}
