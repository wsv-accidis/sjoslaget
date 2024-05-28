using System.Data.SqlClient;
using System.Threading.Tasks;
using Accidis.Gotland.WebService.Models;
using Accidis.WebServices.Db;
using Dapper;
using Simplexcel;

namespace Accidis.Gotland.WebService.Services
{
	public sealed class ExportToExcelGenerator
	{
		public async Task<Workbook> ExportBookingsToWorkbookAsync(Event evnt)
		{
			using(var db = DbUtil.Open())
			{
				var sheet = CreateBookingsWorksheet();
				CreateBookingsHeaderRow(sheet);
				await FetchAndCreateRowsForBookings(db, evnt, sheet);
				return CreateWorkbook(sheet);
			}
		}

		public async Task<Workbook> ExportDayBookingsToWorkbookAsync(Event evnt)
		{
			using(var db = DbUtil.Open())
			{
				var sheet = CreateDayBookingsWorksheet();
				CreateDayBookingsHeaderRow(sheet);
				await FetchAndCreateRowsForDayBookings(db, evnt, sheet);
				return CreateWorkbook(sheet);
			}
		}

		void CreateBookingsHeaderRow(Worksheet sheet)
		{
			sheet[0, 0] = CreateHeaderCell("Boende");
			sheet[0, 1] = CreateHeaderCell("Anmärkning");
			sheet[0, 2] = CreateHeaderCell("Bokningsref.");
			sheet[0, 3] = CreateHeaderCell("Förnamn");
			sheet[0, 4] = CreateHeaderCell("Efternamn");
			sheet[0, 5] = CreateHeaderCell("Telefon");
			sheet[0, 6] = CreateHeaderCell("E-post");
			sheet[0, 7] = CreateHeaderCell("Ant. i boende");
			sheet[0, 8] = CreateHeaderCell("Tot. i bokning");
			sheet[0, 9] = CreateHeaderCell("Varav kött");
			sheet[0, 10] = CreateHeaderCell("Varav veg");
		}

		Worksheet CreateBookingsWorksheet()
		{
			var sheet = new Worksheet("Bokningar");
			sheet.PageSetup.Orientation = Orientation.Landscape;

			sheet.ColumnWidths[0] = 16;
			sheet.ColumnWidths[1] = 20;
			sheet.ColumnWidths[2] = 12;
			sheet.ColumnWidths[3] = 20;
			sheet.ColumnWidths[4] = 20;
			sheet.ColumnWidths[5] = 14;
			sheet.ColumnWidths[6] = 30;
			sheet.ColumnWidths[7] = 14;
			sheet.ColumnWidths[8] = 14;
			sheet.ColumnWidths[9] = 14;
			sheet.ColumnWidths[10] = 14;
			return sheet;
		}

		void CreateDayBookingsHeaderRow(Worksheet sheet)
		{
			sheet[0, 0] = CreateHeaderCell("Förnamn");
			sheet[0, 1] = CreateHeaderCell("Efternamn");
			sheet[0, 2] = CreateHeaderCell("Födelsed.");
			sheet[0, 3] = CreateHeaderCell("Betald");
			sheet[0, 4] = CreateHeaderCell("Typ");
			sheet[0, 5] = CreateHeaderCell("Kost");
		}

		Worksheet CreateDayBookingsWorksheet()
		{
			var sheet = new Worksheet("Dagbiljetter");
			sheet.PageSetup.Orientation = Orientation.Portrait;

			sheet.ColumnWidths[0] = 20;
			sheet.ColumnWidths[1] = 20;
			sheet.ColumnWidths[2] = 10;
			sheet.ColumnWidths[3] = 10;
			sheet.ColumnWidths[4] = 16;
			sheet.ColumnWidths[5] = 16;
			return sheet;
		}

		static Cell CreateHeaderCell(string text)
		{
			return new Cell(CellType.Text)
			{
				Bold = true,
				Border = CellBorder.Bottom,
				Value = text
			};
		}

		static Workbook CreateWorkbook(params Worksheet[] sheets)
		{
			var workbook = new Workbook();
			foreach(var sheet in sheets)
				workbook.Add(sheet);
			return workbook;
		}

		async Task FetchAndCreateRowsForBookings(SqlConnection db, Event evnt, Worksheet sheet)
		{
			var result = await db.QueryAsync<BookingDbRow>(
				"select C.[No], A.[Note], B.[Reference], B.[FirstName], B.[LastName], B.[PhoneNo], B.[Email], A.[NumberOfPax] [PaxInCabin], " +
				"(select COUNT(*) from [BookingPax] P where P.[BookingId] = B.[Id]) [PaxInBooking], " +
				"(select COUNT(*) from [BookingPax] P where P.[BookingId] = B.[Id] and P.[Food] = 'm') [PaxFoodMeat], " +
				"(select COUNT(*) from [BookingPax] P where P.[BookingId] = B.[Id] and P.[Food] = 'v') [PaxFoodVeg] " +
				"from [BookingAllocation] A " +
				"left join [Booking] B on A.[BookingId] = B.[Id] " +
				"left join [EventCabinClassDetail] C on A.[CabinId] = C.[Id] " +
				"where B.[EventId] = @EventId " +
				"order by B.[Reference], C.[No], A.[Note], B.[FirstName], B.[LastName]", new { EventId = evnt.Id });

			var rowNo = 1;
			foreach(var row in result)
			{
				// TODO: The logic here is based on my usual style when writing notes, fragile if someone uses a different format
				sheet[rowNo, 0] = GetMainInfoFromNote(row.Note);
				sheet[rowNo, 1] = GetExtraInfoFromNote(row.Note);

				sheet[rowNo, 2] = row.Reference;
				sheet[rowNo, 3] = row.FirstName;
				sheet[rowNo, 4] = row.LastName;
				sheet[rowNo, 5] = row.PhoneNo;
				sheet[rowNo, 6] = row.Email;
				sheet[rowNo, 7] = row.PaxInCabin;
				sheet[rowNo, 8] = row.PaxInBooking;
				sheet[rowNo, 9] = row.PaxFoodMeat;
				sheet[rowNo, 10] = row.PaxFoodVeg;
				rowNo++;
			}
		}

		async Task FetchAndCreateRowsForDayBookings(SqlConnection db, Event evnt, Worksheet sheet)
		{
			var result = await db.QueryAsync<DayBookingDbRow>(
				"select [FirstName], [LastName], [Dob], [PaymentConfirmed], T.[Title] [Type], [Food] " +
				"from [DayBooking] B " +
				"left join [DayBookingType] T on B.[TypeId] = T.[Id] " +
				"where [EventId] = @EventId " +
				"order by [FirstName], [LastName]", new { EventId = evnt.Id });

			var rowNo = 1;
			foreach(var row in result)
			{
				sheet[rowNo, 0] = row.FirstName;
				sheet[rowNo, 1] = row.LastName;
				sheet[rowNo, 2] = row.Dob;
				sheet[rowNo, 3] = GetPaymentConfirmedDisplayName(row.PaymentConfirmed);
				sheet[rowNo, 4] = row.Type;
				sheet[rowNo, 5] = GetFoodDisplayName(row.Food);
				rowNo++;
			}
		}

		static string GetFoodDisplayName(string food)
		{
			switch(food)
			{
				case "m": return "Kött";
				case "v": return "Vegan";
				default: return string.Empty;
			}
		}

		static string GetMainInfoFromNote(string note)
		{
			if(string.IsNullOrWhiteSpace(note))
				return "Camping";

			var bracketIdx = note.IndexOf('(');
			if(-1 != bracketIdx)
				return note.Substring(0, bracketIdx).TrimEnd();

			return note.TrimEnd();
		}

		static string GetExtraInfoFromNote(string note)
		{
			var beginBracketIdx = note.IndexOf('(');
			var endBracketIdx = note.LastIndexOf(')');

			// Beginning bracket must come before ending bracket and have at least one character between them
			if(-1 != beginBracketIdx && endBracketIdx > beginBracketIdx + 1)
			{
				var inner = note.Substring(beginBracketIdx + 1, endBracketIdx - beginBracketIdx - 1);
				return char.ToUpperInvariant(inner[0]) + inner.Substring(1);
			}

			return string.Empty;
		}

		static string GetPaymentConfirmedDisplayName(bool paymentConfirmed)
		{
			return paymentConfirmed ? string.Empty : "EJ BETALD";
		}

		sealed class BookingDbRow
		{
			public int No { get; set; }
			public string Note { get; set; }
			public string Reference { get; set; }
			public string FirstName { get; set; }
			public string LastName { get; set; }
			public string PhoneNo { get; set; }
			public string Email { get; set; }
			public int PaxInCabin { get; set; }
			public int PaxInBooking { get; set; }
			public int PaxFoodMeat { get; set; }
			public int PaxFoodVeg { get; set; }
		}

		sealed class DayBookingDbRow
		{
			public string FirstName { get; set; }
			public string LastName { get; set; }
			public string Dob { get; set; }
			public bool PaymentConfirmed { get; set; }
			public string Type { get; set; }
			public string Food { get; set; }
		}
	}
}