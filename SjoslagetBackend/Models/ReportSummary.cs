using System;
using System.Collections.Generic;
using System.Linq;

namespace Accidis.Sjoslaget.WebService.Models
{
	public sealed class ReportSummary
	{
		public ReportSummary()
		{
			Labels = new List<string>();
			BookingsCreated = new List<int>();
			BookingsTotal = new List<int>();
			CabinsTotal = new List<int>();
			PaxTotal = new List<int>();
			CapacityTotal = new List<int>();
		}

		public List<string> Labels { get; }
		public List<int> BookingsCreated { get; }
		public List<int> BookingsTotal { get; }
		public List<int> CabinsTotal { get; }
		public List<int> PaxTotal { get; }
		public List<int> CapacityTotal { get; }

		public static ReportSummary FromReports(Report[] reports)
		{
			ReportSummary summary = new ReportSummary();
			if(null == reports || 0 == reports.Length)
				return summary;

			DateTime startDate = reports.First().Date.AddDays(-1);
			DateTime endDate = DateTime.Now.Date;
			var reportsMap = reports.ToDictionary(r => DateToString(r.Date));
			Report previous = new Report();

			for(var currentDate = startDate; currentDate <= endDate; currentDate = currentDate.AddDays(1))
			{
				if(!reportsMap.TryGetValue(DateToString(currentDate), out Report report))
				{
					report = previous;

					// Zero any non-accumulating values
					report.BookingsCreated = 0;
				}

				summary.Labels.Add(DateToString(currentDate));
				summary.BookingsCreated.Add(report.BookingsCreated);
				summary.BookingsTotal.Add(report.BookingsTotal);
				summary.CabinsTotal.Add(report.CabinsTotal);
				summary.PaxTotal.Add(report.PaxTotal);
				summary.CapacityTotal.Add(report.CapacityTotal);

				previous = report;
			}

			return summary;
		}

		static string DateToString(DateTime d) => d.ToString("yyyy-MM-dd");
	}
}
