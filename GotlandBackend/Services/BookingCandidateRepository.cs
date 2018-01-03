using System;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using Accidis.Gotland.WebService.Models;
using Accidis.WebServices.Db;
using Dapper;

namespace Accidis.Gotland.WebService.Services
{
	public sealed class BookingCandidateRepository
	{
		const int ActiveTresholdMinutes = 10;

		public async Task<Guid> CreateAsync(BookingCandidate candidate)
		{
			BookingCandidate.Validate(candidate);

			using(var db = DbUtil.Open())
			{
				Guid id = await db.ExecuteScalarAsync<Guid>("insert into [BookingCandidate] ([FirstName], [LastName], [Email], [PhoneNo], [TeamName], [TeamSize]) output inserted.[Id] values (@FirstName, @LastName, @Email, @PhoneNo, @TeamName, @TeamSize)",
					new {FirstName = candidate.FirstName, LastName = candidate.LastName, Email = candidate.Email, PhoneNo = candidate.PhoneNo, TeamName = candidate.TeamName, TeamSize = candidate.TeamSize});

				return id;
			}
		}

		public async Task DeleteAllAsync()
		{
			using(var db = DbUtil.Open())
			{
				await db.ExecuteAsync("delete from [BookingQueue]");
				await db.ExecuteAsync("dbcc checkident ('[BookingQueue]', reseed, 0)");
				await db.ExecuteAsync("delete from [BookingCandidate]");
			}
		}

		public async Task<int> EnqueueAsync(Guid candidateId)
		{
			using(var db = DbUtil.Open())
			{
				try
				{
					int no = await FindPlaceInQueueAsync(db, candidateId);
					if(no != 0) // shortcut in case the endpoint gets spammed
						return no;

					no = await db.ExecuteScalarAsync<int>("insert into [BookingQueue] ([CandidateId]) output inserted.No values (@Id)",
						new {Id = candidateId});

					await db.ExecuteAsync("update [BookingCandidate] set [DeleteProtected] = 1 where [Id] = @Id",
						new {Id = candidateId});

					return no;
				}
				catch(SqlException ex)
				{
					if(ex.IsForeignKeyViolation())
						throw new Exception("Candidate does not exist."); // TODO Use exception type
					if(ex.IsUniqueKeyViolation()) // race condition
						return await FindPlaceInQueueAsync(db, candidateId);

					throw;
				}
			}
		}

		public async Task<BookingCandidate> FindByIdAsync(SqlConnection db, Guid id)
		{
			var result = await db.QueryAsync<BookingCandidate>("select * from [BookingCandidate] where [Id] = @Id", new {Id = id});
			return result.FirstOrDefault();
		}

		public async Task<int> FindPlaceInQueueAsync(SqlConnection db, Guid candidateId)
		{
			return await db.QueryFirstOrDefaultAsync<int>("select [No] from [BookingQueue] where [CandidateId] = @Id",
				new {Id = candidateId});
		}

		public async Task<int> GetNumberOfActiveAsync()
		{
			using(var db = DbUtil.Open())
			{
				return await db.ExecuteScalarAsync<int>("select count(*) from [BookingCandidate] where [KeepAlive] > dateadd(minute, @Treshold, getdate())",
					new {Treshold = -ActiveTresholdMinutes});
			}
		}

		public async Task<bool> KeepAliveAsync(Guid candidateId)
		{
			using(var db = DbUtil.Open())
			{
				int didUpdate = await db.ExecuteScalarAsync<int>("update [BookingCandidate] set [KeepAlive] = sysdatetime() output 1 where [Id] = @Id",
					new {Id = candidateId});
				return didUpdate != 0;
			}
		}
	}
}
