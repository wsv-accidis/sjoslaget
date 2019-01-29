using System;

namespace Accidis.Gotland.WebService.Services
{
	public static class IntervalCalculator
	{
		public static long CalculateInterval(DateTime? start, DateTime? end, long defaultValue = -1)
		{
			if(start.HasValue && end.HasValue)
				return Convert.ToInt64((end.Value - start.Value).TotalMilliseconds);

			return defaultValue;
		}
	}
}
