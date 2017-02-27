using System;
using System.Data.SqlClient;
using Accidis.Sjoslaget.WebService.Db;
using Dapper;

namespace Accidis.Sjoslaget.Test.Db
{
	static class SjoslagetDbExtensions
	{
		static Guid _cabinTypeId;
		static Guid _cruiseId;

		public static Guid CabinTypeId => _cabinTypeId;
		public static Guid CruiseId => _cruiseId;

		// Use from [TestInitialize] or [ClassInitialize]
		public static void InitializeForTest(SjoslagetDbTestConfig config = null)
		{
			using(var db = SjoslagetDb.Open())
				db.InitializeForTest(config);
		}

		// Use from [TestInitialize] or [ClassInitialize]
		public static void InitializeForTest(this SqlConnection db, SjoslagetDbTestConfig config = null)
		{
			if(null == config)
				config = SjoslagetDbTestConfig.Default;

			db.Execute("delete from [Cruise]");
			db.Execute("delete from [CabinType]");

			_cabinTypeId = db.ExecuteScalar<Guid>("insert into [CabinType] ([Name], [Description], [Capacity], [Order]) output inserted.[Id] values ('A4', '', 4, 0)");
			_cruiseId = db.ExecuteScalar<Guid>("insert into [Cruise] ([Name], [IsActive]) output inserted.[Id] values ('Test', 1)");

			db.Execute("insert into [CruiseCabin] ([CruiseId], [CabinTypeId], [Count], [PricePerPax]) values (@CruiseId, @CabinTypeId, @NumberOfCabins, @PricePerPax)",
				new {CruiseId = _cruiseId, CabinTypeId = _cabinTypeId, NumberOfCabins = config.NumberOfCabins, PricePerPax = config.PricePerPax});
		}
	}
}
