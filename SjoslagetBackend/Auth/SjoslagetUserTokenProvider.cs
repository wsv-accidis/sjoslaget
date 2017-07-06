using System;
using System.Threading.Tasks;
using Accidis.Sjoslaget.WebService.Models;
using Microsoft.AspNet.Identity;

namespace Accidis.Sjoslaget.WebService.Auth
{
	public sealed class SjoslagetUserTokenProvider : IUserTokenProvider<User, Guid>
	{
		public async Task<string> GenerateAsync(string purpose, UserManager<User, Guid> manager, User user)
		{
			user.ResetToken = Guid.NewGuid().ToString();
			await manager.UpdateAsync(user);
			return user.ResetToken;
		}

		public Task<bool> IsValidProviderForUserAsync(UserManager<User, Guid> manager, User user)
		{
			return Task.FromResult(true);
		}

		public Task NotifyAsync(string token, UserManager<User, Guid> manager, User user)
		{
			return Task.FromResult(0);
		}

		public Task<bool> ValidateAsync(string purpose, string token, UserManager<User, Guid> manager, User user)
		{
			bool isValid = string.Equals(token, user.ResetToken, StringComparison.Ordinal);
			return Task.FromResult(isValid);
		}
	}
}
