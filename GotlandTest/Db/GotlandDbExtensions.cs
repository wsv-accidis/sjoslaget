using System;
using System.Data.SqlClient;
using Accidis.WebServices.Db;
using Dapper;

namespace Accidis.Gotland.Test.Db
{
	internal static class GotlandDbExtensions
	{
		public static Guid EventId { get; private set; }

		// Use from [TestInitialize] or [ClassInitialize]
		public static void InitializeForTest()
		{
			using(var db = DbUtil.Open())
				db.InitializeForTest();
		}

		// Use from [TestInitialize] or [ClassInitialize]
		public static void InitializeForTest(this SqlConnection db)
		{
			db.Execute("delete from [BookingQueue]");
			db.Execute("delete from [BookingCandidate]");
			db.Execute("delete from [Event]");
			db.Execute("delete from [CabinClass]");
			db.Execute("delete from [Challenge]");

			EventId = db.ExecuteScalar<Guid>("insert into [Event] ([Name], [IsActive]) output inserted.[Id] values ('Test', 1)");

			db.Execute("insert into [CabinClass] ([No], [Name], [Description]) values (0, 'Camping', ''), (1, 'Logipaket 1', ''), (2, 'Logipaket 2', ''), (3, 'Logipaket 3', '')");
			db.Execute("insert into [EventCabinClass] ([No], [EventId], [PricePerPax]) values (0, @Id, 1199), (1, @Id, 1349), (2, @Id, 1449), (3, @Id, 1549)",
				new { Id = EventId });
			db.Execute("insert into [Challenge] ([Challenge], [Response]) values ('1 + 1 = ?', '2')");
		}
	}
}
