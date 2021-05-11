USE [DBA]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SqlInstances](
	[Timestamp] [datetime2](7) NULL,
	[ComputerName] [nvarchar](255) NULL,
	[SqlInstance] [nvarchar](255) NULL,
	[SqlVersion] [nvarchar](255) NULL,
	[Scan] [bit] NULL
) ON [PRIMARY]
GO

INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T11:59:29.5504271' AS DateTime2), N'BPHIXPANIC02', N'BPHIXPANIC02', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:00:11.7049653' AS DateTime2), N'GABEAUFORT01', N'GABEAUFORT01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:00:11.7362192' AS DateTime2), N'GABVSDWH01', N'GABVSDWH01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:00:11.7674731' AS DateTime2), N'GAENDOBASE01', N'GAENDOBASE01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:00:11.8299761' AS DateTime2), N'GAHIXAS01', N'GAHIXAS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:00:53.9103582' AS DateTime2), N'GAREMISOL01', N'GAREMISOL01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:00:53.9572381' AS DateTime2), N'GASQL01', N'GASQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:00:53.9884882' AS DateTime2), N'GPAX4HKUBUS01', N'GPAX4HKUBUS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-29T15:35:30.5534145' AS DateTime2), N'GAERGO02', N'GAERGO02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:00:54.0353682' AS DateTime2), N'GPBACNET01', N'GPBACNET01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:00:54.0666203' AS DateTime2), N'GPBARTENDER02', N'GPBARTENDER02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:00:54.0978684' AS DateTime2), N'GPBGAPI01', N'GPBGAPI01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:15.1473564' AS DateTime2), N'GPCHIPTEX01', N'GPCHIPTEX01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:15.1786093' AS DateTime2), N'GPDAKO02', N'GPDAKO02', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:15.2098610' AS DateTime2), N'GPDIAMANT01', N'GPDIAMANT01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:15.2723636' AS DateTime2), N'GPENDOBASE02', N'GPENDOBASE02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:16.3932718' AS DateTime2), N'GPHIXAS01', N'GPHIXAS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:16.4089004' AS DateTime2), N'GPHIXAS02', N'GPHIXAS02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:16.4401537' AS DateTime2), N'GPHIXLS02', N'GPHIXLS02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:16.4714014' AS DateTime2), N'GPIG01', N'GPIG01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:17.5808393' AS DateTime2), N'GPMVISION01', N'GPMVISION01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:17.6120950' AS DateTime2), N'GPOBTVEXT01', N'GPOBTVEXT01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:17.6433372' AS DateTime2), N'GPPCSQL01', N'GPPCSQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:17.6745889' AS DateTime2), N'GPPIICIXADT01', N'GPPIICIXADT01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:17.6902152' AS DateTime2), N'GPPIICIXIBE01', N'GPPIICIXIBE01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:17.7214689' AS DateTime2), N'GPPIICIXPHY01', N'GPPIICIXPHY01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:17.7527186' AS DateTime2), N'GPPIICIXSQL01', N'GPPIICIXSQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:17.7839699' AS DateTime2), N'GPPIICXAPM01', N'GPPIICXAPM01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:17.7995974' AS DateTime2), N'GPREMISOL01', N'GPREMISOL01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:17.8308499' AS DateTime2), N'GPSIDEXIS01', N'GPSIDEXIS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:17.8620996' AS DateTime2), N'GPSPREPORTSQL01', N'GPSPREPORTSQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:17.8933509' AS DateTime2), N'GPSQL01', N'GPSQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:17.9246022' AS DateTime2), N'GPSYNAPSYS01', N'GPSYNAPSYS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:17.9402309' AS DateTime2), N'GPSYSMEX01', N'GPSYSMEX01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:17.9714798' AS DateTime2), N'GPVIVISOL01', N'GPVIVISOL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:18.0027319' AS DateTime2), N'GPWOSQL01', N'GPWOSQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:18.0183578' AS DateTime2), N'GPWSUS01', N'GPWSUS01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:18.0496119' AS DateTime2), N'GPWUG02', N'GPWUG02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:20.3858201' AS DateTime2), N'GTULTIMO01', N'GTULTIMO01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:01:20.4014467' AS DateTime2), N'RPHIXPANIC02', N'RPHIXPANIC02', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:09:12.7466667' AS DateTime2), N'BPHIXLS01', N'BPHIXLS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:10:45.1600000' AS DateTime2), N'GAAX4HKUBUS01', N'GAAX4HKUBUS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:11:32.2900000' AS DateTime2), N'GAAX4HSQL01', N'GAAX4HSQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:11:56.6866667' AS DateTime2), N'GADIAMANT01', N'GADIAMANT01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:12:21.2400000' AS DateTime2), N'GAHIXAS02', N'GAHIXAS02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:12:34.4600000' AS DateTime2), N'GAHIXDWH02', N'GAHIXDWH02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:12:42.3133333' AS DateTime2), N'GAHIXDWHLS01', N'GAHIXDWHLS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:12:49.1866667' AS DateTime2), N'GAHIXDWHSAS01', N'GAHIXDWHSAS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:12:58.5866667' AS DateTime2), N'GAHIXDWHSQL01', N'GAHIXDWHSQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:13:05.2733333' AS DateTime2), N'GAHIXDWHSRS01', N'GAHIXDWHSRS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:13:13.8566667' AS DateTime2), N'GAHIXSQL01', N'GAHIXSQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:13:20.3166667' AS DateTime2), N'GAHIXSQL02', N'GAHIXSQL02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:13:27.9166667' AS DateTime2), N'GAODS01', N'GAODS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:13:35.0833333' AS DateTime2), N'GAQMATIC01', N'GAQMATIC01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:13:52.3933333' AS DateTime2), N'GASPREPORT02', N'GASPREPORT02\MBV', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:14:02.2200000' AS DateTime2), N'GASPREPORT02', N'GASPREPORT02\PAT', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:14:18.9200000' AS DateTime2), N'GATRODIS01', N'GATRODIS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:14:25.3866667' AS DateTime2), N'GAULTIMOSQL01', N'GAULTIMOSQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:14:34.9100000' AS DateTime2), N'GOHIXSQL01', N'GOHIXSQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:14:39.1333333' AS DateTime2), N'GOHIXSQL02', N'GOHIXSQL02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:14:48.0933333' AS DateTime2), N'GPADMIG01', N'GPADMIG01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:15:18.1033333' AS DateTime2), N'GPAX4HHIS01', N'GPAX4HHIS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:15:32.1766667' AS DateTime2), N'GPAX4HSQL01', N'GPAX4HSQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:15:35.4300000' AS DateTime2), N'GPAX4HSQL02', N'GPAX4HSQL02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:15:52.4833333' AS DateTime2), N'GPBARTENDER01', N'GPBARTENDER01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:16:07.2833333' AS DateTime2), N'GPBEAUFORT01', N'GPBEAUFORT01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:16:19.3133333' AS DateTime2), N'GPBVSDWH01', N'GPBVSDWH01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:16:34.1300000' AS DateTime2), N'GPBVSDWH02', N'GPBVSDWH02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:17:06.5433333' AS DateTime2), N'GPEBI01', N'GPEBI01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:17:14.0866667' AS DateTime2), N'GPELISQL01', N'GPELISQL01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:17:39.0633333' AS DateTime2), N'GPERGO02', N'GPERGO02', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:18:00.0800000' AS DateTime2), N'GPFIN01', N'GPFIN01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:18:10.3700000' AS DateTime2), N'GPGBSTC01', N'GPGBSTC01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:18:13.3300000' AS DateTime2), N'GPGBSTC02', N'GPGBSTC02', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:18:33.3766667' AS DateTime2), N'GPHIXCONV01', N'GPHIXCONV01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:18:43.9733333' AS DateTime2), N'GPHIXDWH02', N'GPHIXDWH02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:18:54.5000000' AS DateTime2), N'GPHIXDWHLS01', N'GPHIXDWHLS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:19:03.0833333' AS DateTime2), N'GPHIXDWHSAS01', N'GPHIXDWHSAS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:19:07.5766667' AS DateTime2), N'GPHIXDWHSQL01', N'GPHIXDWHSQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:19:11.2700000' AS DateTime2), N'GPHIXDWHSRS01', N'GPHIXDWHSRS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:19:25.6800000' AS DateTime2), N'GPHIXOPLSQL01', N'GPHIXOPLSQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:19:34.2100000' AS DateTime2), N'GPICESQL01', N'GPICESQL01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:19:53.5200000' AS DateTime2), N'GPIMS01', N'GPIMS01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:20:00.6866667' AS DateTime2), N'GPINTRASENSE01', N'GPINTRASENSE01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:20:13.6966667' AS DateTime2), N'GPKNFEEG01', N'GPKNFEEG01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:20:21.6766667' AS DateTime2), N'GPKNOGW01', N'GPKNOGW01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:22:06.2000000' AS DateTime2), N'GPOCTVIEW01', N'GPOCTVIEW01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:22:15.2833333' AS DateTime2), N'GPODS01', N'GPODS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:23:01.4233333' AS DateTime2), N'GPPHONEXSQL01', N'GPPHONEXSQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:23:20.1933333' AS DateTime2), N'GPQMATIC01', N'GPQMATIC01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:24:02.5700000' AS DateTime2), N'GPSENTRYS01', N'GPSENTRYS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:24:11.8833333' AS DateTime2), N'GPSLTN01', N'GPSLTN01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:24:18.7433333' AS DateTime2), N'GPSMARTSQL01', N'GPSMARTSQL01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:24:33.6700000' AS DateTime2), N'GPSMILE01', N'GPSMILE01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:24:50.5833333' AS DateTime2), N'GPSPREPORTSQL02', N'GPSPREPORTSQL02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:25:01.6233333' AS DateTime2), N'GPSQL02', N'GPSQL02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:25:29.4900000' AS DateTime2), N'GPTMAPEXONE01', N'GPTMAPEXONE01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:25:38.6066667' AS DateTime2), N'GPTMDSMGMT01', N'GPTMDSMGMT01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:25:52.7700000' AS DateTime2), N'GPTRODIS01', N'GPTRODIS01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:25:56.2400000' AS DateTime2), N'GPTRODIS03', N'GPTRODIS03', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:26:16.9000000' AS DateTime2), N'GPULTIMOSQL01', N'GPULTIMOSQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:26:27.7933333' AS DateTime2), N'GPUNIFLOWIWMC01', N'GPUNIFLOWIWMC01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:26:40.7366667' AS DateTime2), N'GPWOSQL02', N'GPWOSQL02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:26:47.9800000' AS DateTime2), N'GPWOTMSQL01', N'GPWOTMSQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:26:51.0733333' AS DateTime2), N'GPWOTMSQL02', N'GPWOTMSQL02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:27:06.4400000' AS DateTime2), N'GTAX4HSQL01', N'GTAX4HSQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:27:15.5833333' AS DateTime2), N'GTHIXSQL02', N'GTHIXSQL02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:27:18.9400000' AS DateTime2), N'GTHIXSQL03', N'GTHIXSQL03', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:27:28.4466667' AS DateTime2), N'GTIDSPACS01', N'GTIDSPACS01\WISE', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:27:34.1600000' AS DateTime2), N'GTIDSPACS01', N'GTIDSPACS01\SHDB1', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:27:45.5300000' AS DateTime2), N'GTNETAUD01', N'GTNETAUD01', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:27:54.8600000' AS DateTime2), N'GTSQL01', N'GTSQL01', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:28:01.0366667' AS DateTime2), N'GZHIXSQL02', N'GZHIXSQL02', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T14:03:10.8966667' AS DateTime2), N'GPSENTRYS01', N'GPSENTRYS01\SENTRYSUITE', NULL, NULL)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-19T12:34:05.7333333' AS DateTime2), N'RPHIXPANIC02', N'RPHIXPANIC02', NULL, 0)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-20T09:10:34.2666667' AS DateTime2), N'GPIDSSHDB01', N'GPIDSSHDB01\SHDB1', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-20T09:10:39.3166667' AS DateTime2), N'GPIDSWISEDB01', N'GPIDSWISEDB01\WISE', NULL, 1)
GO
INSERT [dbo].[SqlInstances] ([Timestamp], [ComputerName], [SqlInstance], [SqlVersion], [Scan]) VALUES (CAST(N'2021-04-20T10:41:43.1600000' AS DateTime2), N'GPHIXSQL02', N'GPHIXSQL02', NULL, 1)
GO

ALTER TABLE [dbo].[SqlInstances] ADD  CONSTRAINT [DF_SqlInstances_Timestamp]  DEFAULT (getdate()) FOR [Timestamp]
GO
