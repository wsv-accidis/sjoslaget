using System;
using System.Linq;
using System.Threading.Tasks;
using Accidis.WebServices.Db;
using Accidis.WebServices.Models;
using Dapper;
using Microsoft.AspNet.Identity;

namespace Accidis.WebServices.Auth
{
	public sealed class AecUserStore : IUserPasswordStore<AecUser, Guid>, IUserSecurityStampStore<AecUser, Guid>
	{
		public async Task CreateAsync(AecUser user)
		{
			using(var db = DbUtil.Open())
				await db.ExecuteAsync("insert into [User] ([UserName], [PasswordHash], [SecurityStamp], [ResetToken], [IsBooking]) values (@UserName, @PasswordHash, @SecurityStamp, @ResetToken, @IsBooking)",
					new {UserName = user.UserName, PasswordHash = user.PasswordHash, SecurityStamp = user.SecurityStamp, ResetToken = user.ResetToken, IsBooking = user.IsBooking});
		}

		public async Task DeleteAsync(AecUser user)
		{
			using(var db = DbUtil.Open())
				await db.ExecuteAsync("delete from [User] where [Id] = @Id", new {Id = user.Id});
		}

		public void Dispose()
		{
		}

		public async Task<AecUser> FindByIdAsync(Guid userId)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<AecUser>("select * from [User] where [Id] = @Id", new {Id = userId});
				return result.FirstOrDefault();
			}
		}

		public async Task<AecUser> FindByNameAsync(string userName)
		{
			using(var db = DbUtil.Open())
			{
				var result = await db.QueryAsync<AecUser>("select * from [User] where [UserName] = @UserName", new {UserName = userName});
				return result.FirstOrDefault();
			}
		}

		public Task<string> GetPasswordHashAsync(AecUser user)
		{
			return Task.FromResult(user.PasswordHash);
		}

		public Task<string> GetSecurityStampAsync(AecUser user)
		{
			return Task.FromResult(user.SecurityStamp);
		}

		public Task<bool> HasPasswordAsync(AecUser user)
		{
			return Task.FromResult(!string.IsNullOrEmpty(user.PasswordHash));
		}

		public async Task<bool> IsUserStoreEmptyAsync()
		{
			using(var db = DbUtil.Open())
			{
				int count = await db.ExecuteScalarAsync<int>("select count(*) from [User]");
				return 0 == count;
			}
		}

		public Task SetPasswordHashAsync(AecUser user, string passwordHash)
		{
			user.PasswordHash = passwordHash;
			return Task.CompletedTask;
		}

		public Task SetSecurityStampAsync(AecUser user, string stamp)
		{
			user.SecurityStamp = stamp;
			return Task.CompletedTask;
		}

		public async Task UpdateAsync(AecUser user)
		{
			using(var db = DbUtil.Open())
				await db.ExecuteAsync("update [User] set [UserName] = @UserName, [PasswordHash] = @PasswordHash, [ResetToken] = @ResetToken, [SecurityStamp] = @SecurityStamp, [IsBooking] = @IsBooking where [Id] = @Id",
					new {Id = user.Id, UserName = user.UserName, PasswordHash = user.PasswordHash, ResetToken = user.ResetToken, SecurityStamp = user.SecurityStamp, IsBooking = user.IsBooking});
		}
	}
}
