using System;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using Accidis.Gotland.WebService.Models;
using Accidis.WebServices.Db;
using Dapper;

namespace Accidis.Gotland.WebService.Services
{
	public sealed class EventRepository
	{
		public async Task<Event> CreateActiveAsync(string name)
		{
			using(var db = DbUtil.Open())
			{
				await db.ExecuteAsync("update [Event] set [IsActive] = 0");

				var id = await db.ExecuteScalarAsync<Guid>("insert into [Event] ([Name], [IsActive]) values (@Name, @IsActive)",
					new { Name = name, IsActive = true });

				return new Event { Id = id, IsActive = true, Name = name };
			}
		}

		public async Task<Event> FindByIdAsync(SqlConnection db, Guid id)
		{
			var result = await db.QueryAsync<Event>("select * from [Event] where [Id] = @Id", new { Id = id });
			return result.FirstOrDefault();
		}

		public async Task<Event> GetActiveAsync()
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<Event>("select top 1 * from [Event] where [IsActive] = @IsActive", new { IsActive = true });
				return result.FirstOrDefault();
			}
		}

		public async Task UpdateMetadataAsync(Event evnt)
		{
			using(var db = DbUtil.Open())
				await db.ExecuteAsync("update [Event] set [IsActive] = @IsActive, [IsLocked] = @IsLocked, [Opening] = @Opening, [Capacity] = @Capacity where [Id] = @Id",
					new { evnt.Id, evnt.IsActive, evnt.IsLocked, evnt.Opening, evnt.Capacity });
		}
	}
}