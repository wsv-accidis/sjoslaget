using System;
using System.IdentityModel.Tokens;
using Microsoft.Owin.Security;

namespace Accidis.WebServices.Auth
{
	public sealed class JwtAccessTokenFormat : ISecureDataFormat<AuthenticationTicket>
	{
		readonly string _audience;
		readonly byte[] _keyBytes;
		readonly string _issuer;

		public JwtAccessTokenFormat(string audienceSecret, string audience, string issuer)
		{
			_keyBytes = Convert.FromBase64String(audienceSecret);
			_audience = audience;
			_issuer = issuer;
		}

		public string Protect(AuthenticationTicket data)
		{
			var signingCredentials = new SigningCredentials(new InMemorySymmetricSecurityKey(_keyBytes), SecurityAlgorithms.HmacSha256Signature, SecurityAlgorithms.Sha256Digest);

			var token = new JwtSecurityToken(
				issuer: _issuer,
				audience: _audience,
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
