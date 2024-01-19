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
	internal sealed class OkEtagResult<T> : OkNegotiatedContentResult<T>
	{
		readonly string _etag;

		public OkEtagResult(T content, string etag, ApiController controller) : base(content, controller)
		{
			_etag = etag;
		}

		public OkEtagResult(T content, string etag, IContentNegotiator contentNegotiator, HttpRequestMessage request, IEnumerable<MediaTypeFormatter> formatters)
			: base(content, contentNegotiator, request, formatters)
		{
			_etag = etag;
		}

		public override async Task<HttpResponseMessage> ExecuteAsync(CancellationToken cancellationToken)
		{
			var response = await base.ExecuteAsync(cancellationToken);
			response.Headers.ETag = new EntityTagHeaderValue(_etag);
			return response;
		}
	}
}