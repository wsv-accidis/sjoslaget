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
	sealed class OkNoCacheResult<T> : OkNegotiatedContentResult<T>
	{
		public OkNoCacheResult(T content, ApiController controller) : base(content, controller)
		{
		}

		public OkNoCacheResult(T content, IContentNegotiator contentNegotiator, HttpRequestMessage request, IEnumerable<MediaTypeFormatter> formatters)
			: base(content, contentNegotiator, request, formatters)
		{
		}

		public override async Task<HttpResponseMessage> ExecuteAsync(CancellationToken cancellationToken)
		{
			HttpResponseMessage response = await base.ExecuteAsync(cancellationToken);
			response.Headers.CacheControl = new CacheControlHeaderValue {NoCache = true};
			return response;
		}
	}
}
