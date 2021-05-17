using System.Data;
using Accidis.Sjoslaget.WebService.Models;
using Dapper;

namespace Accidis.Sjoslaget.WebService.Db
{
	sealed class SubCruiseCodeTypeHandler : SqlMapper.TypeHandler<SubCruiseCode>
	{
		public override SubCruiseCode Parse(object value)
		{
			return SubCruiseCode.FromString(value as string);
		}

		public override void SetValue(IDbDataParameter parameter, SubCruiseCode value)
		{
			parameter.Value = value.ToString();
		}
	}
}
