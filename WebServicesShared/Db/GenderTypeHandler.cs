using System.Data;
using Accidis.WebServices.Models;
using Dapper;

namespace Accidis.WebServices.Db
{
	sealed class GenderTypeHandler : SqlMapper.TypeHandler<Gender>
	{
		public override Gender Parse(object value)
		{
			return Gender.FromString(value as string);
		}

		public override void SetValue(IDbDataParameter parameter, Gender value)
		{
			parameter.Value = value.ToString();
		}
	}
}
