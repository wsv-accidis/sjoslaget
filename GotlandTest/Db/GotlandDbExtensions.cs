using System;
using System.Data.SqlClient;
using Accidis.WebServices.Db;
using Dapper;

namespace Accidis.Gotland.Test.Db
{
	static class GotlandDbExtensions
	{
		static Guid _eventId;
		static Guid _inTripId;
		static Guid _outTripId;

		public static Guid EventId => _eventId;
		public static Guid InboundTripId => _inTripId;
		public static Guid OutboundTripId => _outTripId;

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
			db.Execute("delete from [Trip]");
			db.Execute("delete from [CabinClass]");

			_eventId = db.ExecuteScalar<Guid>("insert into [Event] ([Name], [IsActive]) output inserted.[Id] values ('Test', 1)");
			_outTripId = db.ExecuteScalar<Guid>("insert into [Trip] ([EventId], [Name], [IsInbound], [Departure], [Price]) output inserted.[Id] values (@Id, 'Test Outbound', 0, '2018-01-01', 0)",
				new {Id = _eventId});
			_inTripId = db.ExecuteScalar<Guid>("insert into [Trip] ([EventId], [Name], [IsInbound], [Departure], [Price]) output inserted.[Id] values (@Id, 'Test Inbound', 1, '2018-01-02', 0)",
				new { Id = _eventId });

			db.Execute("insert into [CabinClass] ([No], [Name], [Description], [Price]) values (0, 'Camping', '', 1199), (1, 'Logipaket 1', '', 1349), (2, 'Logipaket 2', '', 1449), (3, 'Logipaket 3', '', 1549)");
		}
	}
}
