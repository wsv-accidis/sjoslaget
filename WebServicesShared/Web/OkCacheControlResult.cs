using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Net.Http.Headers;
using System.Threading;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.Results;

namespace Accidis.WebServices.Web
{
	sealed class OkCacheControlResult<T> : OkNegotiatedContentResult<T>
	{
		public OkCacheControlResult(T content, ApiController controller) : base(content, controller)
		{
		}

		public OkCacheControlResult(T content, IContentNegotiator contentNegotiator, HttpRequestMessage request, IEnumerable<MediaTypeFormatter> formatters)
			: base(content, contentNegotiator, request, formatters)
		{
		}

		public TimeSpan MaxAge { get; set; }

		public override async Task<HttpResponseMessage> ExecuteAsync(CancellationToken cancellationToken)
		{
			HttpResponseMessage response = await base.ExecuteAsync(cancellationToken);
			response.Headers.CacheControl = new CacheControlHeaderValue {Private = true, MaxAge = MaxAge};
			return response;
		}
	}
}
