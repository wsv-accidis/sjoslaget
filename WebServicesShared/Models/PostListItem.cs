using System;

namespace Accidis.WebServices.Models
{
	public sealed class PostListItem
	{
		public Guid Id { get; set; }

		public string ContentPreview { get; set; }

		public DateTime Created { get; set; }

		public DateTime Updated { get; set; }
	}
}