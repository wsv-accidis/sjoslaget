﻿using System;
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

		[Ignore]
		[TestMethod]
		[DeploymentItem(ScriptsFolder + @"\CreateDatabase.sql", ScriptsFolder), DeploymentItem(ScriptsFolder + @"\DropAllTables.sql", ScriptsFolder)]
		public void Maintenance_DropAndRecreateTestingDb()
		{
			/*
			 * To generate a new CreateDatabase script:
			 * 1. In Management Studio, right click database -> Tasks -> Generate Scripts...
			 * 2. Select specific database objects, check Tables only in the list. Next.
			 * 3. Set the following options in Advanced:
			 *		Schema qualify object names = False
			 *		Include Descriptive Headers = False
			 *		Script USE DATABASE = False
			 *		Script Indexes = True
			 * 4. Continue until finished.
			 * 5. Unignore this test and off you go!
			 */
			using (var db = DbUtil.Open())
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
