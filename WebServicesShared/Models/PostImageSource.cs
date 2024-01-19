using System;

namespace Accidis.WebServices.Models
{
	public sealed class PostImageSource
	{
		public Guid PostId { get; set; }

		public string ImageBytes { get; set; }
	}
}