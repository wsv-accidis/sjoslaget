using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Transactions;
using Accidis.Gotland.WebService.Models;
using Accidis.WebServices.Db;
using Dapper;

namespace Accidis.Gotland.WebService.Services
{
	public sealed class AllocationRepository
	{
		const string LockResource = "Allocation";
		const int LockTimeout = 10000;

		public async Task<BookingAllocation[]> GetByBookingAsync(Booking booking)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<BookingAllocation>(
					"select * from [BookingAllocation] where [BookingId] = @BookingId",
					new {BookingId = booking.Id});
				return result.ToArray();
			}
		}

		public async Task<AllocationListItem[]> GetListAsync(Event evnt)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<AllocationListItem>(
					"select A.[CabinId], B.[Reference], B.[TeamName], A.[NumberOfPax], A.[Note], " +
					"(select count(*) from [BookingPax] where [BookingId] = A.[BookingId]) [TotalPax] " +
					"from [BookingAllocation] A " +
					"left join [Booking] B on A.[BookingId] = B.[Id] " +
					"where B.[EventId] = @EventId",
					new {EventId = evnt.Id});
				return result.ToArray();
			}
		}

		public async Task UpdateAsync(Booking booking, List<BookingAllocation> allocation)
		{
			var tranOptions = new TransactionOptions {IsolationLevel = IsolationLevel.ReadUncommitted};
			using(var tran = new TransactionScope(TransactionScopeOption.Required, tranOptions, TransactionScopeAsyncFlowOption.Enabled))
			using(var db = DbUtil.Open())
			{
				await db.GetAppLockAsync(LockResource, LockTimeout);
				await DeleteAllocation(db, booking);
				await CreateAllocation(db, booking, allocation);

				tran.Complete();
			}
		}

		async Task CreateAllocation(SqlConnection db, Booking booking, List<BookingAllocation> allocations)
		{
			foreach(BookingAllocation alloc in allocations)
			{
				await db.ExecuteAsync("insert into [BookingAllocation] ([BookingId], [CabinId], [NumberOfPax], [Note]) " +
				                      "values (@BookingId, @CabinId, @NumberOfPax, @Note)",
					new
					{
						BookingId = booking.Id,
						CabinId = alloc.CabinId,
						NumberOfPax = alloc.NumberOfPax,
						Note = alloc.Note ?? String.Empty
					});
			}
		}

		async Task DeleteAllocation(SqlConnection db, Booking booking)
		{
			await db.ExecuteAsync("delete from [BookingAllocation] where [BookingId] = @BookingId", new {BookingId = booking.Id});
		}
	}
}
