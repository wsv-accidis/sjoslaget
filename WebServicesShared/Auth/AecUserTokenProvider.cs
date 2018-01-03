using System;
using System.Threading.Tasks;
using Accidis.WebServices.Models;
using Microsoft.AspNet.Identity;

namespace Accidis.WebServices.Auth
{
	public sealed class AecUserTokenProvider : IUserTokenProvider<AecUser, Guid>
	{
		public async Task<string> GenerateAsync(string purpose, UserManager<AecUser, Guid> manager, AecUser user)
		{
			user.ResetToken = Guid.NewGuid().ToString();
			await manager.UpdateAsync(user);
			return user.ResetToken;
		}

		public Task<bool> IsValidProviderForUserAsync(UserManager<AecUser, Guid> manager, AecUser user)
		{
			return Task.FromResult(true);
		}

		public Task NotifyAsync(string token, UserManager<AecUser, Guid> manager, AecUser user)
		{
			return Task.FromResult(0);
		}

		public Task<bool> ValidateAsync(string purpose, string token, UserManager<AecUser, Guid> manager, AecUser user)
		{
			bool isValid = string.Equals(token, user.ResetToken, StringComparison.Ordinal);
			return Task.FromResult(isValid);
		}
	}
}
