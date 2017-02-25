using System;
using System.Linq;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Db;
using Accidis.Sjoslaget.WebService.Models;
using Dapper;
using Microsoft.AspNet.Identity;

namespace Accidis.Sjoslaget.WebService.Auth
{
	sealed class UserStore : IUserPasswordStore<User, Guid>, IUserSecurityStampStore<User, Guid>
	{
		public Task CreateAsync(User user)
		{
			using(var db = SqlDb.Open())
				db.Execute("insert into [User] ([UserName], [PasswordHash], [SecurityStamp]) values (@UserName, @PasswordHash, @SecurityStamp)",
					new {UserName = user.UserName, PasswordHash = user.PasswordHash, SecurityStamp = user.SecurityStamp});

			return Task.CompletedTask;
		}

		public static UserManager<User, Guid> CreateManager()
		{
			return new UserManager<User, Guid>(new UserStore());
		}

		public Task DeleteAsync(User user)
		{
			using(var db = SqlDb.Open())
				db.Execute("delete from [User] where [Id] = @Id", new {Id = user.Id});

			return Task.CompletedTask;
		}

		public void Dispose()
		{
		}

		public Task<User> FindByIdAsync(Guid userId)
		{
			using(var db = SqlDb.Open())
			{
				var result = db.Query<User>("select * from [User] where [Id] = @Id", new {Id = userId});
				return Task.FromResult(result.FirstOrDefault());
			}
		}

		public Task<User> FindByNameAsync(string userName)
		{
			using(var db = SqlDb.Open())
			{
				var result = db.Query<User>("select * from [User] where [UserName] = @UserName", new {UserName = userName});
				return Task.FromResult(result.FirstOrDefault());
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
			return Task.FromResult((!string.IsNullOrEmpty(user.PasswordHash)));
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

		public Task UpdateAsync(User user)
		{
			using(var db = SqlDb.Open())
				db.Execute("update [User] set [UserName] = @UserName, [PasswordHash] = @PasswordHash, SecurityStamp = @SecurityStamp where [Id] = @Id",
					new {Id = user.Id, UserName = user.UserName, PasswordHash = user.PasswordHash, SecurityStamp = user.SecurityStamp});

			return Task.CompletedTask;
		}
	}
}
