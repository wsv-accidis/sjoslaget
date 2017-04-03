using System.Linq;
using System.Security.Claims;
using System.Security.Principal;
using System.Web;

namespace Accidis.Sjoslaget.WebService.Auth
{
	public static class AuthContext
	{
		public static IIdentity Identity => HttpContext.Current?.User?.Identity;

		public static bool IsAdmin => Roles.Admin.Equals(Role);

		public static string Role
		{
			get
			{
				var identity = Identity as ClaimsIdentity;
				return identity?.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role)?.Value;
			}
		}

		public static string UserName
		{
			get
			{
				IIdentity identity = Identity;
				return null != identity && identity.IsAuthenticated ? identity.Name : null;
			}
		}
	}
}
