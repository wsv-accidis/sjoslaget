namespace Accidis.Sjoslaget.Test.Db
{
	sealed class SjoslagetDbTestConfig
	{
		public int NumberOfCabins { get; set; }
		public int PricePerPax { get; set; }

		public static SjoslagetDbTestConfig Default => new SjoslagetDbTestConfig
		{
			NumberOfCabins = 10,
			PricePerPax = 100
		};
	}
}
