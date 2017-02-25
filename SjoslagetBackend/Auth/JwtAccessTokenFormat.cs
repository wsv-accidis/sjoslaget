using System;
using System.IdentityModel.Tokens;
using Microsoft.Owin.Security;

namespace Accidis.Sjoslaget.WebService.Auth
{
	sealed class JwtAccessTokenFormat : ISecureDataFormat<AuthenticationTicket>
	{
		const string DigestAlgorithm = "http://www.w3.org/2001/04/xmlenc#sha512";
		const string SignatureAlgorithm = "http://www.w3.org/2001/04/xmldsig-more#hmac-sha512";

		public string Protect(AuthenticationTicket data)
		{
			var keyBytes = Convert.FromBase64String(AuthConfig.AudienceSecret);
			var signingCredentials = new SigningCredentials(new InMemorySymmetricSecurityKey(keyBytes), SignatureAlgorithm, DigestAlgorithm);

			var token = new JwtSecurityToken(
				issuer: AuthConfig.Issuer,
				audience: AuthConfig.Audience,
				claims: data.Identity.Claims,
				notBefore: data.Properties.IssuedUtc?.UtcDateTime,
				expires: data.Properties.ExpiresUtc?.UtcDateTime,
				signingCredentials: signingCredentials
			);

			var handler = new JwtSecurityTokenHandler();
			return handler.WriteToken(token);
		}

		public AuthenticationTicket Unprotect(string protectedText)
		{
			throw new NotImplementedException();
		}
	}
}
