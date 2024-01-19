using System;

namespace Accidis.WebServices.Models
{
	public sealed class Post
	{
		public Guid Id { get; set; }

		public string Content { get; set; }

		public string ContentHtml { get; set; }

		public DateTime Created { get; set; }

		public DateTime Updated { get; set; }

		public Guid[] Images { get; set; }
	}
}