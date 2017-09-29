using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.Results;
using Accidis.Sjoslaget.WebService.Auth;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Accidis.Sjoslaget.WebService.Services;
using Dapper;
using Simplexcel;

namespace Accidis.Sjoslaget.WebService.Controllers
{
	public sealed class ExportController : ApiController
	{
		const string FilenameFormat = "Export_{0:yyyyMMdd_HHmmss}.xlsx";
		const string DobFormat = "dd.MM.yyyy";

		readonly CabinRepository _cabinRepository;
		readonly CruiseRepository _cruiseRepository;
		readonly ProductRepository _productRepository;

		public ExportController(CabinRepository cabinRepository, CruiseRepository cruiseRepository, ProductRepository productRepository)
		{
			_cabinRepository = cabinRepository;
			_cruiseRepository = cruiseRepository;
			_productRepository = productRepository;
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet]
		public async Task<IHttpActionResult> Excel(bool onlyFullyPaid = false)
		{
			var activeCruise = await _cruiseRepository.GetActiveAsync();
			if(null == activeCruise)
				return NotFound();

			Worksheet sheet = WorkbookGenerator.CreateWorksheet();
			WorkbookGenerator.CreateHeaderRow(sheet, 0);

			Dictionary<Guid, string> cabinTypes = (await _cabinRepository.GetAllAsync()).ToDictionary(c => c.Id, c => c.Name);
			Dictionary<Guid, string> productTypes = (await _productRepository.GetAllAsync()).ToDictionary(c => c.Id, c => c.Name);

			using(var db = SjoslagetDb.Open())
			{
				var bookingsResult = await db.QueryAsync<Booking>("select [Id], [Reference], [TotalPrice], " +
																  "(select sum([Amount]) from [BookingPayment] BP where BP.[BookingId] = B.[Id] group by [BookingId]) as AmountPaid " +
																  "from [Booking] B where [CruiseId] = @CruiseId " +
																  "order by [Reference]",
					new {CruiseId = activeCruise.Id});

				Booking[] allBookings = onlyFullyPaid
					? bookingsResult.Where(b => b.IsFullyPaid).ToArray()
					: bookingsResult.ToArray();

				int cabinNo = 0, rowNo = 1;
				foreach(Booking booking in allBookings)
				{
					var paxResult = await db.QueryAsync<Pax>("select BP.[FirstName], BP.[LastName], BP.[Gender], BP.[Dob], BP.[Nationality], BP.[Years], BC.[Id] CabinId, BC.[CabinTypeId] " +
															 "from [BookingPax] BP " +
															 "left join [BookingCabin] BC on BP.[BookingCabinId] = BC.[Id] " +
															 "where BC.[BookingId] = @BookingId " +
															 "order by BC.[Order], BP.[Order]",
						new {BookingId = booking.Id});

					var productsResult = await db.QueryAsync<BookingProduct>("select [ProductTypeId], [Quantity] from [BookingProduct] where [BookingId] = @BookingId",
						new {BookingId = booking.Id});

					CreateRowsForBooking(db, sheet, booking, paxResult.ToArray(), productsResult.ToArray(), cabinTypes, productTypes, ref cabinNo, ref rowNo);
				}
			}

			var workbook = WorkbookGenerator.CreateWorkbook(sheet);
			return CreateHttpResponseMessage(workbook);
		}

		ResponseMessageResult CreateHttpResponseMessage(Workbook workbook)
		{
			var buffer = new MemoryStream();
			workbook.Save(buffer);

			var content = new StreamContent(buffer);
			content.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");
			content.Headers.ContentDisposition = new ContentDispositionHeaderValue("attachment")
			{
				FileName = String.Format(FilenameFormat, DateTime.Now)
			};

			var result = new HttpResponseMessage(HttpStatusCode.OK) {Content = content};
			// This is necessary so that the front-end can read the filename of the attachment
			result.Headers.Add("Access-Control-Expose-Headers", "Content-Disposition");
			result.Headers.CacheControl = new CacheControlHeaderValue { NoCache = true };
			return ResponseMessage(result);
		}

		static void CreateRowsForBooking(SqlConnection db, Worksheet sheet, Booking booking, Pax[] paxInBooking, BookingProduct[] productsInBooking, 
			Dictionary<Guid, string> cabinTypes, Dictionary<Guid, string> productTypes, ref int cabinNo, ref int rowNo)
		{
			Guid cabinId = Guid.Empty;
			string cabinTypeName = String.Empty;

			foreach(Pax pax in paxInBooking)
			{
				string products = CreateStringForProducts(productsInBooking, productTypes);

				if(!cabinId.Equals(pax.CabinId))
				{
					cabinId = pax.CabinId;
					cabinTypeName = cabinTypes[pax.CabinTypeId];
					cabinNo++;
					rowNo++; // inserts a blank row into the sheet
				}

				WorkbookGenerator.CreateRow(
					sheet,
					rowNo++,
					cabinNo,
					cabinTypeName,
					pax.LastName,
					pax.FirstName,
					pax.Dob,
					pax.Gender,
					pax.Nationality,
					booking.Reference,
					products
				);
			}
		}

		static string CreateStringForProducts(BookingProduct[] productsInBooking, Dictionary<Guid, string> productTypes)
		{
			var buffer = new StringBuilder();
			foreach(BookingProduct bookingProduct in productsInBooking)
			{
				if(buffer.Length > 0)
					buffer.Append(", ");
				buffer.AppendFormat("{0} x {1}", bookingProduct.Quantity, productTypes[bookingProduct.ProductTypeId]);
			}
			return buffer.ToString();
		}

		sealed class Booking
		{
			public Guid Id { get; set; }
			public string Reference { get; set; }
			public decimal TotalPrice { get; set; }
			public decimal AmountPaid { get; set; }
			public bool IsFullyPaid => AmountPaid >= TotalPrice;
		}

		sealed class Pax
		{
			public string FirstName { get; set; }
			public string LastName { get; set; }
			public Gender Gender { get; set; }
			public DateOfBirth Dob { get; set; }
			public string Nationality { get; set; }
			public Guid CabinId { get; set; }
			public Guid CabinTypeId { get; set; }
		}

		static class WorkbookGenerator
		{
			internal static void CreateHeaderRow(Worksheet sheet, int row)
			{
				sheet[row, 0] = CreateHeaderCell("Hyttnr");
				sheet[row, 1] = CreateHeaderCell("Hyttkategori");
				sheet[row, 2] = CreateHeaderCell("Efternamn");
				sheet[row, 3] = CreateHeaderCell("Förnamn");
				sheet[row, 4] = CreateHeaderCell("Födelsedatum");
				sheet[row, 5] = CreateHeaderCell("Kön");
				sheet[row, 6] = CreateHeaderCell("Nationalitet");
				sheet[row, 7] = CreateHeaderCell("Bokningsref");
				sheet[row, 8] = CreateHeaderCell("Beställningar");
			}

			internal static void CreateRow(
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
				string products
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
				sheet[row, 8] = products;
			}

			internal static Workbook CreateWorkbook(Worksheet sheet)
			{
				var workbook = new Workbook();
				workbook.Add(sheet);
				return workbook;
			}

			internal static Worksheet CreateWorksheet()
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
				sheet.ColumnWidths[8] = 30;

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
		}
	}
}
