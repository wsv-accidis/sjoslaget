Sjöslaget
=========

_This application is directed exclusively at a Swedish audience. International visitors, please
contact me if you have any questions._

Det här är den officiella webbplatsen för [Sjöslaget](https://sjoslaget.se) och [Absolut Gotland](https://absolutgotland.se). 
Sjöslaget och Absolut Gotland är årliga festevenemang som riktar sig til högskole- och universitetsstudenter.

## Status
Webbplatsen är under aktiv utveckling. Den är i skarp drift på [sjoslaget.se](https://sjoslaget.se) respektive
[absolutgotland.se](https://absolutgotland.se) men koden som körs där är inte nödvändigtvis i synk med detta repo.

## Teknik och tillkännagivanden
Serversidan utvecklas i [ASP.NET Web API](https://dotnet.microsoft.com/en-us/apps/aspnet/apis). Webbplatsen hostas på [IIS](https://www.iis.net/) i Windows-miljö med
databas i [SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-2016). Den använder följande bibliotek och ramverk:

* [Dapper](https://github.com/StackExchange/Dapper)
* [DryIoC](https://bitbucket.org/dadhi/dryioc)
* [NLog](http://nlog-project.org/)
* [MarkDig](https://github.com/xoofx/markdig)
* [Moq](https://github.com/moq/moq4)
* [OAuth 2](https://oauth.net/2/)
* [OWIN](http://owin.org/)
* [Simplexcel](https://github.com/mstum/Simplexcel)
* [SkiaSharp](https://github.com/mono/SkiaSharp)

Klientsidan utvecklas i [Dart](https://webdev.dartlang.org/). Den använder följande bibliotek och ramverk:

* [AngularDart](https://webdev.dartlang.org/angular)
* [ChartJS.dart](https://github.com/google/chartjs.dart)
* [Corsac JWT](https://github.com/corsac-dart/jwt)
* [Dart Decimals](https://pub.dartlang.org/packages/decimal)
* [Material Design components for AngularDart](https://github.com/dart-lang/angular_components)
* [Quiver](https://github.com/google/quiver-dart)

## Äldre version av Dart

Klientsidan använder en äldre version av Dart som inte längre stöds. En ny sajt är under utveckling. För att arbeta med de gamla sidorna, använd Dart v2.13 och Dart-plugin till VSCode v3.98.1.

## Licensiering
Koden distribueras i enlighet med licensvillkoren i **Apache License version 2.0**.
