using NLog;
using NLog.Config;
using NLog.Targets;

namespace Accidis.WebServices.Services
{
	public static class AecLoggingConfiguration
	{
		public static LoggingConfiguration CreateForDatabase(string connectionString, LogLevel logLevel)
		{
			var config = new LoggingConfiguration();
			var target = new DatabaseTarget
			{
				Name = "db",
				ConnectionString = connectionString,
				CommandText = "insert into [Log] ([Timestamp], [Level], [Logger], [Message], [Callsite], [Exception], [UserName], [Method], [Url], [RemoteAddress], [LocalAddress]) " +
							  "values (@Timestamp, @Level, @Logger, @Message, @Callsite, @Exception, @UserName, @Method, @Url, @RemoteAddress, @LocalAddress)",
				Parameters =
				{
					new DatabaseParameterInfo("@Timestamp", "${date:universalTime=true}"),
					new DatabaseParameterInfo("@Level", "${level}"),
					new DatabaseParameterInfo("@Logger", "${logger}"),
					new DatabaseParameterInfo("@Message", "${message}"),
					new DatabaseParameterInfo("@Callsite", "${callsite}"),
					new DatabaseParameterInfo("@Exception", "${exception:format=tostring:maxInnerExceptionLevel=2}"),
					new DatabaseParameterInfo("@UserName", "${aspnet-User-Identity}"),
					new DatabaseParameterInfo("@Method", "${aspnet-Request-Method}"),
					new DatabaseParameterInfo("@Url", "${aspnet-Request:serverVariable=HTTP_URL}"),
					new DatabaseParameterInfo("@RemoteAddress", "${aspnet-Request:serverVariable=REMOTE_ADDR}"),
					new DatabaseParameterInfo("@LocalAddress", "${aspnet-Request:serverVariable=LOCAL_ADDR}")
				}
			};

			config.AddTarget(target);
			config.LoggingRules.Add(new LoggingRule("*", logLevel, target));
			return config;
		}

		public static LoggingConfiguration CreateForDebug(LogLevel logLevel)
		{
			var config = new LoggingConfiguration();
			var target = new DebuggerTarget {Name = "debug"};
			config.AddTarget(target);
			config.LoggingRules.Add(new LoggingRule("*", logLevel, target));
			return config;
		}
	}
}
