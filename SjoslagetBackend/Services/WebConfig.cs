using System;

namespace Accidis.Sjoslaget.WebService.Services
{
	public static class WebConfig
	{
		public static TimeSpan DynamicDataMaxAge => new TimeSpan(0, 1, 0);

		public static TimeSpan StaticDataMaxAge => new TimeSpan(24, 0, 0);
	}
}
