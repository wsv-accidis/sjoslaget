using System;

namespace Accidis.WebServices.Models
{
	public sealed class PostResult
	{
		public PostResult(Guid id)
		{
			Id = id;
		}

		public Guid Id { get; }
	}
}