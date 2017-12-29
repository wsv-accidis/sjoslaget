using System.Data;
using Accidis.WebServices.Models;
using Dapper;

namespace Accidis.WebServices.Db
{
	sealed class DateOfBirthTypeHandler : SqlMapper.TypeHandler<DateOfBirth>
	{
		public override DateOfBirth Parse(object value)
		{
			return new DateOfBirth(value as string);
		}

		public override void SetValue(IDbDataParameter parameter, DateOfBirth value)
		{
			parameter.Value = value.ToString();
		}
	}
}
