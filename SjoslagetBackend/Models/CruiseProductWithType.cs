namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class CruiseProductWithType : ProductType
	{
		public string Description { get; set; }
		public int Count { get; set; }
		public decimal Price { get; set; }
	}
}
