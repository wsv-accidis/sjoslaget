﻿using System;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using Accidis.Gotland.WebService.Models;
using Accidis.WebServices.Db;
using Accidis.WebServices.Exceptions;
using Dapper;

namespace Accidis.Gotland.WebService.Services
{
	public sealed class BookingCandidateRepository
	{
		const int ActiveTresholdMinutes = 5;

		public async Task<Guid> CreateAsync(BookingCandidate candidate)
		{
			BookingCandidate.Validate(candidate);

			using(var db = DbUtil.Open())
			{
				var id = await db.ExecuteScalarAsync<Guid>(
					"insert into [BookingCandidate] ([FirstName], [LastName], [Email], [PhoneNo], [TeamName], [TeamSize], [GroupName]) output inserted.[Id] values (@FirstName, @LastName, @Email, @PhoneNo, @TeamName, @TeamSize, @GroupName)",
					new
					{
						candidate.FirstName,
						candidate.LastName,
						candidate.Email,
						candidate.PhoneNo,
						candidate.TeamName,
						candidate.TeamSize,
						GroupName = candidate.GroupName ?? string.Empty
					});

				await db.ExecuteAsync(
					"insert into [BookingCandidateChallenge] ([CandidateId], [ChallengeId]) values (@Id, (select top 1 [Id] from [Challenge] order by newid()))",
					new { Id = id });

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
				try
				{
					var no = await FindPlaceInQueueAsync(db, candidateId);
					if(no != 0) // shortcut in case the endpoint gets spammed
						return no;

					no = await db.ExecuteScalarAsync<int>("insert into [BookingQueue] ([CandidateId]) output inserted.No values (@Id)",
						new { Id = candidateId });

					await db.ExecuteAsync("update [BookingCandidate] set [DeleteProtected] = 1 where [Id] = @Id",
						new { Id = candidateId });

					return no;
				}
				catch(SqlException ex)
				{
					if(ex.IsForeignKeyViolation())
						throw new NotFoundException();
					if(ex.IsUniqueKeyViolation()) // race condition
						return await FindPlaceInQueueAsync(db, candidateId);

					throw;
				}
		}

		public async Task<ChallengeResponse> FindChallengeByIdAsync(Guid id)
		{
			using(var db = DbUtil.Open())
				return await db.QuerySingleAsync<ChallengeResponse>(
					"select [Challenge], [Response] from [Challenge] where [Id] = (select top 1 [ChallengeId] from [BookingCandidateChallenge] where [CandidateId] = @CandidateId)",
					new { CandidateId = id });
		}

		public async Task<BookingCandidate> FindByIdAsync(Guid id)
		{
			using(var db = DbUtil.Open())
				return await FindByIdAsync(db, id);
		}

		public async Task<BookingCandidate> FindByIdAsync(SqlConnection db, Guid id)
		{
			var result = await db.QueryAsync<BookingCandidate>("select * from [BookingCandidate] where [Id] = @Id", new { Id = id });
			return result.FirstOrDefault();
		}

		public async Task<int> FindPlaceInQueueAsync(SqlConnection db, Guid candidateId)
		{
			return await db.QueryFirstOrDefaultAsync<int>("select [No] from [BookingQueue] where [CandidateId] = @Id",
				new { Id = candidateId });
		}

		public async Task<int> GetNumberOfActiveAsync()
		{
			using(var db = DbUtil.Open())
				return await db.ExecuteScalarAsync<int>("select count(*) from [BookingCandidate] where [KeepAlive] > dateadd(minute, @Treshold, getdate())",
					new { Treshold = -ActiveTresholdMinutes });
		}

		public async Task<QueueDashboardItem[]> GetQueueAsync(DateTime? eventOpening)
		{
			using(var db = DbUtil.Open())
			{
				var items = await db.QueryAsync<QueueDashboardRow>(
					"select BC.[FirstName], BC.[LastName], BC.[TeamName], BC.[TeamSize], BC.[Created], [No], BQ.[Created] [Queued], B.[Reference], " +
					"(select count(*) from [BookingPax] P where P.[BookingId] = B.[Id]) [NumberOfPax] " +
					"from [BookingCandidate] BC " +
					"left join [BookingQueue] BQ on BC.[Id] = BQ.[CandidateId] " +
					"left join [Booking] B on BC.[Id] = B.[CandidateId] " +
					"where BC.[DeleteProtected] = 1 or BC.[KeepAlive] > dateadd(minute, @Treshold, getdate()) " +
					"order by ISNULL(BQ.[No], 999999), BC.[Created]",
					new { Treshold = -ActiveTresholdMinutes });

				return items.Select(row => new QueueDashboardItem
				{
					FirstName = row.FirstName,
					LastName = row.LastName,
					TeamName = row.TeamName,
					TeamSize = row.TeamSize,
					NumberOfPax = row.NumberOfPax,
					Created = row.Created,
					Queued = row.Queued,
					QueueNo = row.No.GetValueOrDefault(-1),
					QueueLatencyMs = QueueDashboardItem.TryCalculateQueueLatencyMs(eventOpening, row.Queued),
					Reference = row.Reference
				}).ToArray();
			}
		}

		public async Task<bool> KeepAliveAsync(Guid candidateId)
		{
			using(var db = DbUtil.Open())
			{
				var didUpdate = await db.ExecuteScalarAsync<int>("update [BookingCandidate] set [KeepAlive] = sysdatetime() output 1 where [Id] = @Id",
					new { Id = candidateId });
				return didUpdate != 0;
			}
		}

		sealed class QueueDashboardRow
		{
			public string FirstName { get; set; }
			public string LastName { get; set; }
			public string TeamName { get; set; }
			public int TeamSize { get; set; }
			public int NumberOfPax { get; set; }
			public DateTime Created { get; set; }
			public int? No { get; set; }
			public DateTime? Queued { get; set; }
			public string Reference { get; set; }
		}
	}
}