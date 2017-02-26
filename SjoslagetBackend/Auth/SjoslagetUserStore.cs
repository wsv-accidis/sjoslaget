using System;
using System.Linq;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Dapper;
using Microsoft.AspNet.Identity;

namespace Accidis.Sjoslaget.WebService.Auth
{
	sealed class SjoslagetUserStore : IUserPasswordStore<User, Guid>, IUserSecurityStampStore<User, Guid>
	{
		public async Task CreateAsync(User user)
		{
			using(var db = SjoslagetDb.Open())
				await db.ExecuteAsync("insert into [User] ([UserName], [PasswordHash], [SecurityStamp], [IsBooking]) values (@UserName, @PasswordHash, @SecurityStamp, @IsBooking)",
					new {UserName = user.UserName, PasswordHash = user.PasswordHash, SecurityStamp = user.SecurityStamp, IsBooking = user.IsBooking});
		}

		public async Task DeleteAsync(User user)
		{
			using(var db = SjoslagetDb.Open())
				await db.ExecuteAsync("delete from [User] where [Id] = @Id", new {Id = user.Id});
		}

		public void Dispose()
		{
		}

		public async Task<User> FindByIdAsync(Guid userId)
		{
			using(var db = SjoslagetDb.Open())
			{
				var result = await db.QueryAsync<User>("select * from [User] where [Id] = @Id", new {Id = userId});
				return result.FirstOrDefault();
			}
		}

		public async Task<User> FindByNameAsync(string userName)
		{
			using(var db = SjoslagetDb.Open())
			{
				var result = await db.QueryAsync<User>("select * from [User] where [UserName] = @UserName", new {UserName = userName});
				return result.FirstOrDefault();
			}
		}

		public Task<string> GetPasswordHashAsync(User user)
		{
			return Task.FromResult(user.PasswordHash);
		}

		public Task<string> GetSecurityStampAsync(User user)
		{
			return Task.FromResult(user.SecurityStamp);
		}

		public Task<bool> HasPasswordAsync(User user)
		{
			return Task.FromResult(!string.IsNullOrEmpty(user.PasswordHash));
		}

		public async Task<bool> IsUserStoreEmptyAsync()
		{
			using(var db = SjoslagetDb.Open())
			{
				int count = await db.ExecuteScalarAsync<int>("select count(*) from [User]");
				return 0 == count;
			}
		}

		public Task SetPasswordHashAsync(User user, string passwordHash)
		{
			user.PasswordHash = passwordHash;
			return Task.CompletedTask;
		}

		public Task SetSecurityStampAsync(User user, string stamp)
		{
			user.SecurityStamp = stamp;
			return Task.CompletedTask;
		}

		public async Task UpdateAsync(User user)
		{
			using(var db = SjoslagetDb.Open())
				await db.ExecuteAsync("update [User] set [UserName] = @UserName, [PasswordHash] = @PasswordHash, SecurityStamp = @SecurityStamp, IsBooking = @IsBooking where [Id] = @Id",
					new {Id = user.Id, UserName = user.UserName, PasswordHash = user.PasswordHash, SecurityStamp = user.SecurityStamp, IsBooking = user.IsBooking});
		}
	}
}
