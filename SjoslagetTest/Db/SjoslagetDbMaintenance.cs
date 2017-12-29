using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using Accidis.WebServices.Db;
using Dapper;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Accidis.Sjoslaget.Test.Db
{
	[TestClass]
	[DeploymentItem("DbTest.config")]
	public sealed class SjoslagetDbMaintenance
	{
		const string ScriptsFolder = "Scripts";
		const string TestDbName = "db-jv3test";
		const string TestDbSchema = "dbu-jv3test";

		[Ignore]
		[TestMethod]
		[DeploymentItem(ScriptsFolder + @"\CreateDatabase.sql", ScriptsFolder), DeploymentItem(ScriptsFolder + @"\DropAllTables.sql", ScriptsFolder)]
		public void Maintenance_DropAndRecreateTestingDb()
		{
			/*
			 * To generate a new CreateDatabase script:
			 * 1. In Management Studio, right click database -> Tasks -> Generate Scripts...
			 * 2. Select specific database objects, check Tables only in the list. Next.
			 * 3. Leave options as default and choose the output file. Finish.
			 * 4. Replace all instances of the database name in brackets with __DATABASE__ and all instances of the schema name in brackets with __SCHEMA__. 
			 * 5. Unignore this test and off you go!
			 */
			using(var db = DbUtil.Open())
			{
				ExecuteScript(db, "DropAllTables.sql");
				ExecuteScript(db, "CreateDatabase.sql");
			}
		}

		static void ExecuteScript(SqlConnection db, string fileName)
		{
			foreach(string script in GetScript(fileName))
				db.Execute(script);
		}

		static IEnumerable<string> GetScript(string fileName)
		{
			string script = File.ReadAllText(ScriptsFolder + '\\' + fileName);
			script = script.Replace("__DATABASE__", '[' + TestDbName + ']');
			script = script.Replace("__SCHEMA__", '[' + TestDbSchema + ']');

			bool finished = false;
			do
			{
				int indexOfGo = script.IndexOf("GO", StringComparison.Ordinal);
				string scriptPart;
				if(-1 == indexOfGo)
				{
					scriptPart = script.Trim();
					finished = true;
				}
				else
				{
					scriptPart = script.Substring(0, indexOfGo).Trim();
					script = script.Substring(indexOfGo + 2);
				}

				if(!string.IsNullOrEmpty(scriptPart))
					yield return scriptPart;
			} while(!finished);
		}
	}
}
