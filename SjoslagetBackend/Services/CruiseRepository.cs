using System;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Services
{
	public sealed class CruiseRepository
	{
		public async Task<Cruise> CreateActiveAsync(string name)
		{
			using(var db = SjoslagetDb.Open())
			{
				await db.ExecuteAsync("update [Cruise] set [IsActive] = 0");

				Guid id = await db.ExecuteScalarAsync<Guid>("insert into [Cruise] ([Name], [IsActive]) values (@Name, @IsActive)",
					new {Name = name, IsActive = true});

				return new Cruise {Id = id, IsActive = true, Name = name};
			}
		}

		public async Task<Cruise> FindByIdAsync(SqlConnection db, Guid id)
		{
			var result = await db.QueryAsync<Cruise>("select * from [Cruise] where [Id] = @Id", new {Id = id});
			return result.FirstOrDefault();
		}

		public async Task<Cruise> GetActiveAsync()
		{
			using(var db = SjoslagetDb.Open())
			{
				var result = await db.QueryAsync<Cruise>("select top 1 * from [Cruise] where [IsActive] = @IsActive", new {IsActive = true});
				return result.FirstOrDefault();
			}
		}

		public async Task UpdateMetadataAsync(Cruise cruise)
		{
			using(var db = SjoslagetDb.Open())
			{
				await db.ExecuteAsync("update [Cruise] set [IsActive] = @IsActive, [IsLocked] = @IsLocked where [Id] = @Id",
					new {Id = cruise.Id, IsActive = cruise.IsActive, IsLocked = cruise.IsLocked});
			}
		}
	}
}
