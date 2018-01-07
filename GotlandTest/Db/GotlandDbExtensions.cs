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
			db.Execute("delete from [Trip]");
			db.Execute("delete from [CabinClass]");

			_eventId = db.ExecuteScalar<Guid>("insert into [Event] ([Name], [IsActive]) output inserted.[Id] values ('Test', 1)");
		}
	}
}
