Sjöslaget
=========

_This application is directed exclusively at a Swedish audience. International visitors, please
contact me if you have any questions._

Det här är den officiella webbplatsen för [Sjöslaget](http://www.sjoslaget.se). Sjöslaget 
är en årlig kryssning för i huvudsak universitets- och högskolestudenter.

## Status
Webbplatsen är under aktiv utveckling. Den är i skarp drift på [www.sjoslaget.se](http://www.sjoslaget.se)
men koden som körs där är inte nödvändigtvis i synk med detta repo.

## Teknik och tillkännagivanden
Serversidan utvecklas i [ASP.NET Web API](https://www.asp.net/web-api). Webbplatsen hostas på [IIS](https://www.iis.net/) i Windows-miljö med
databas i [SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-2016). Den använder följande bibliotek och ramverk:

* [Dapper](https://github.com/StackExchange/Dapper)
* [DryIoC](https://bitbucket.org/dadhi/dryioc)
* [NLog](http://nlog-project.org/)
* [Moq](https://github.com/moq/moq4)
* [OAuth 2](https://oauth.net/2/)
* [OWIN](http://owin.org/)
* [Simplexcel](https://github.com/mstum/Simplexcel)

Klientsidan utvecklas i [Dart](https://webdev.dartlang.org/). Den använder följande bibliotek och ramverk:

* [AngularDart](https://webdev.dartlang.org/angular)
* [ChartJS.dart](https://github.com/google/chartjs.dart)
* [Corsac JWT](https://github.com/corsac-dart/jwt)
* [Dart Decimals](https://pub.dartlang.org/packages/decimal)
* [Material Design components for AngularDart](https://github.com/dart-lang/angular_components)
* [Quiver](https://github.com/google/quiver-dart)

## Licensiering
Koden distribueras i enlighet med licensvillkoren i **Apache License version 2.0**.
