using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class CruiseProductWithType : ProductType
	{
		public string Description { get; set; }
		public decimal Price { get; set; }
	}
}
