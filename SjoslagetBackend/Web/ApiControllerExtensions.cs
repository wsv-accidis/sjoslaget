﻿using System;
using System.Web.Http;

namespace Accidis.Sjoslaget.WebService.Web
{
	public static class ApiControllerExtensions
	{
		public static IHttpActionResult OkCacheControl<T>(this ApiController controller, T content, TimeSpan maxAge)
		{
			return new OkCacheControlResult<T>(content, controller) {MaxAge = maxAge};
		}

		public static IHttpActionResult OkNoCache<T>(this ApiController controller, T content)
		{
			return new OkNoCacheResult<T>(content, controller);
		}
	}
}
