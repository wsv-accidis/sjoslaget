using System;
using System.Data.SqlClient;
using System.Linq;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class Cruise
	{
		public Guid Id { get; set; }
		public string Name { get; set; }
		public bool IsActive { get; set; }

		public static Cruise Active(SqlConnection connection)
		{
			return connection.Query<Cruise>("select top 1 * from Cruise where IsActive = @IsActive", new {IsActive = true}).FirstOrDefault();
		}
	}
}