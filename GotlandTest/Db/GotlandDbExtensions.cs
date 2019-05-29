using System;
using System.Data.SqlClient;
using Accidis.WebServices.Db;
using Dapper;

namespace Accidis.Gotland.Test.Db
{
	static class GotlandDbExtensions
	{
		static Guid _eventId;

		public static Guid EventId => _eventId;

		// Use from [TestInitialize] or [ClassInitialize]
		public static void InitializeForTest(GotlandDbTestConfig config = null)
		{
			using(var db = DbUtil.Open())
				db.InitializeForTest(config);
		}

		// Use from [TestInitialize] or [ClassInitialize]
		public static void InitializeForTest(this SqlConnection db, GotlandDbTestConfig config = null)
		{
			//if(null == config)
			//config = GotlandDbTestConfig.Default;

			db.Execute("delete from [BookingQueue]");
			db.Execute("delete from [BookingCandidate]");
			db.Execute("delete from [Event]");
			db.Execute("delete from [CabinClass]");

			_eventId = db.ExecuteScalar<Guid>("insert into [Event] ([Name], [IsActive]) output inserted.[Id] values ('Test', 1)");

			db.Execute("insert into [CabinClass] ([No], [Name], [Description]) values (0, 'Camping', ''), (1, 'Logipaket 1', ''), (2, 'Logipaket 2', ''), (3, 'Logipaket 3', '')");
			db.Execute("insert into [EventCabinClass] ([No], [EventId], [PricePerPax]) values (0, @Id, 1199), (1, @Id, 1349), (2, @Id, 1449), (3, @Id, 1549)",
				new {Id = _eventId});
		}
	}
}
