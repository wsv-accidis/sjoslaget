using System;

namespace Accidis.WebServices.Models
{
	public sealed class PostImage
	{
		public Guid Id { get; set; }

		public Guid PostId { get; set; }

		public byte[] Data { get; set; }

		public string MediaType { get; set; }

		public DateTime Created { get; set; }

		public bool HasData => null != Data && Data.Length > 0;
	}
}