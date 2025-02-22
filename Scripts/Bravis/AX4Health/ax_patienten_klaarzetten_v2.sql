/****** Script for SelectTopNRows command from SSMS  ******/
USE [avanade]
GO

/* drop and create table */
DROP TABLE [dbo].[AHC_HL7Journal]
GO
CREATE TABLE [dbo].[AHC_HL7Journal](
	[IN1InsuranceCompanyId] [varchar](50) NULL,
	[IN1InsuranceId] [varchar](50) NULL,
	[IN1InsuranceStartDate] [varchar](50) NULL,
	[PIDBirthDate] [varchar](50) NULL,
	[PIDBSN] [varchar](50) NULL,
	[PIDBSN1] [varchar](50) NULL,
	[PIDCity] [varchar](50) NULL,
	[PIDCountryRegionId] [varchar](50) NULL,
	[PIDCustGroup] [varchar](50) NULL,
	[PIDFirstName] [varchar](50) NULL,
	[PIDGender] [varchar](50) NULL,
	[PIDLastName] [varchar](50) NULL,
	[PIDMaritalStatus] [varchar](50) NULL,
	[PIDMiddleName] [varchar](50) NULL,
	[PIDPartnerLastName] [varchar](50) NULL,
	[PIDPartnerMiddleName] [varchar](50) NULL,
	[PIDPatientId] [varchar](50) NULL,
	[PIDPhone] [varchar](50) NULL,
	[PIDPhone2] [varchar](50) NULL,
	[PIDPrefix] [varchar](50) NULL,
	[PIDStreet] [varchar](50) NULL,
	[PIDZipCodeId] [varchar](50) NULL,
	[PreferredName] [varchar](50) NULL,
	[LogText] [varchar](50) NULL
) ON [PRIMARY]
GO

/* Insert from patiënt into avanade */
INSERT INTO [avanade].[dbo].[AHC_HL7Journal]
SELECT
	[PARTVERZ] AS 'IN1InsuranceCompanyId'
	,[NRPARTVERZ] AS 'IN1InsuranceId'
	,convert(VARCHAR, [INGANGSDAT], 105) AS 'IN1InsuranceStartDate'
	,convert(VARCHAR, [GEBDAT], 105) AS 'PIDBirthDate'
	,[BSN] AS 'PIDBSN'
	,'' AS 'PIDBSN1'
	,[WOONPLAATS] AS 'PIDCity'
	,[LAND] AS 'PIDCountryRegionId'
	,'PA' AS 'PIDCustGroup'
	,CASE WHEN [GESLACHT] = 'M' THEN [VOORLETTER] ELSE [VOORLETTER] END AS 'PIDFirstName'
    ,[GESLACHT] AS 'PIDGender'
	,CASE WHEN [GESLACHT] = 'M' THEN [ACHTERNAAM] ELSE [MEISJESNAA] END AS 'PIDLastName'
    ,[BURGSTAAT] AS 'PIDMaritalStatus'
	,CASE WHEN [GESLACHT] = 'M' THEN [VOORVOEGA] ELSE [VOORVOEGM] END AS 'PIDMiddleName'
	,CASE WHEN [GESLACHT] = 'V' THEN [ACHTERNAAM] ELSE [MEISJESNAA] END AS 'PIDPartnerLastName'
	,CASE WHEN [GESLACHT] = 'V' THEN [VOORVOEGA] ELSE [VOORVOEGM] END AS 'PIDPartnerMiddleName'
    ,[PATIENTNR] AS 'PIDPatientId'
    ,[TELEFOON1] AS 'PIDPhone'
    ,[TELEFOON2] AS 'PIDPhone2'
    ,'' AS 'PIDPrefix'
    ,([ADRES] + ' ' + [HUISNR]) collate database_default AS 'PIDStreet'
    ,[POSTCODE] AS 'PIDZipCodeId'
    ,'' AS 'PreferredName'
    ,'Initial Patient load 07-1-2015' AS 'LogText'
FROM [GAHIXSQL01.ZKH.LOCAL].[HIX_ACCEPTATIE].[dbo].PATIENT_PATIENT
ORDER BY PATIENTNR DESC;

/* haal alle verzekeraars op */
/* drop and create table */
DROP TABLE [dbo].[CSZISLIB_TBI]
GO
CREATE TABLE [dbo].[CSZISLIB_TBI](
	[TBICODE] [nvarchar](6) NULL,
	[ZOEKCODE] [nvarchar](6) NULL,
	[INSTCODE] [nvarchar](4) NULL,
	[ZORGVSOORT] [nvarchar](2) NULL,
	[ZORGVCODE] [nvarchar](6) NULL,
	[SIGCODE] [nvarchar](5) NULL,
	[TBITYPE] [nvarchar](1) NULL,
	[VERZVORM] [nvarchar](1) NULL,
	[TBIGROEP] [nvarchar](6) NULL,
	[PARTINST] [nvarchar](6) NULL,
	[AWBZINST] [nvarchar](6) NULL,
	[AFKORTING] [nvarchar](20) NULL,
	[NAAM] [nvarchar](60) NULL,
	[T_A_V] [nvarchar](50) NULL,
	[ADRES] [nvarchar](35) NULL,
	[HUISNR] [nvarchar](10) NULL,
	[POSTCODE] [nvarchar](7) NULL,
	[WOONPLAATS] [nvarchar](40) NULL,
	[LAND] [nvarchar](3) NULL,
	[TELEFOON1] [nvarchar](20) NULL,
	[TYPETEL1] [nvarchar](1) NULL,
	[TELEFOON2] [nvarchar](20) NULL,
	[TYPETEL2] [nvarchar](1) NULL,
	[POLISCHECK] [nvarchar](5) NULL,
	[MACHTIGING] [bit] NOT NULL,
	[MACHTCHECK] [nvarchar](5) NULL,
	[MACHTDUUR] [int] NULL,
	[VERWKAART] [bit] NOT NULL,
	[AANLVORM] [nvarchar](1) NULL,
	[LAYOUT] [nvarchar](4) NULL,
	[ENVELOP] [nvarchar](1) NULL,
	[BORDEREL] [nvarchar](1) NULL,
	[FACTPATK] [bit] NOT NULL,
	[FACTPATP] [bit] NOT NULL,
	[FACTPATD] [bit] NOT NULL,
	[BETINST] [bit] NOT NULL,
	[ISAWBZ] [bit] NOT NULL,
	[DEBITEURNR] [nvarchar](13) NULL,
	[REKCODE] [nvarchar](10) NULL,
	[VERVALLEN] [bit] NOT NULL,
	[BEGINDAT] [datetime] NULL,
	[EINDEDAT] [datetime] NULL,
	[FAKTOPNDAG] [int] NULL,
	[BTW] [nvarchar](1) NULL,
	[STDLAYOUT] [nvarchar](1) NULL,
	[SegmentA] [nvarchar](1) NULL,
	[SegmentB] [nvarchar](1) NULL,
	[SegmentAO] [nvarchar](1) NULL,
	[SegmentBO] [nvarchar](1) NULL,
	[COVOPTION] [nvarchar](1) NULL,
	[BSNNIETVER] [bit] NOT NULL,
	[VEKTHERDECL] [bit] NOT NULL,
	[VEKTHERTERMIJN] [int] NULL,
	[LABELCODE] [nvarchar](10) NULL,
	[URANUMBER] [nvarchar](8) NULL,
	[APPID] [nvarchar](8) NULL
) ON [PRIMARY]
GO

/* insert data */
INSERT INTO [avanade].[dbo].[CSZISLIB_TBI] SELECT * FROM [GAHIXSQL01.ZKH.LOCAL].[HIX_ACCEPTATIE].[dbo].[CSZISLIB_TBI];


/* update verzekeraars */
UPDATE [avanade].[dbo].[AHC_HL7Journal] 
	SET [IN1InsuranceCompanyId] = [avanade].[dbo].[CSZISLIB_TBI].[INSTCODE]
    FROM [avanade].[dbo].[AHC_HL7Journal] 
    INNER JOIN [avanade].[dbo].[CSZISLIB_TBI]
    ON [avanade].[dbo].[AHC_HL7Journal].[IN1InsuranceCompanyId] = [avanade].[dbo].[CSZISLIB_TBI].[TBICODE];


/* update PIDCountryRegionId */	
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'NLD' WHERE [PIDCountryRegionId] = '';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'ANT' WHERE [PIDCountryRegionId] = 'AN';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'AUT' WHERE [PIDCountryRegionId] = 'AT';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'ABW' WHERE [PIDCountryRegionId] = 'AW';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'BEL' WHERE [PIDCountryRegionId] = 'BE';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'BGR' WHERE [PIDCountryRegionId] = 'BG';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'BRA' WHERE [PIDCountryRegionId] = 'BR';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'CAN' WHERE [PIDCountryRegionId] = 'CA';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'CHE' WHERE [PIDCountryRegionId] = 'CH';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'CXR' WHERE [PIDCountryRegionId] = 'CX';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'CZE' WHERE [PIDCountryRegionId] = 'CZ';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'DEU' WHERE [PIDCountryRegionId] = 'DE';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'DNK' WHERE [PIDCountryRegionId] = 'DK';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'EST' WHERE [PIDCountryRegionId] = 'EE';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = '' WHERE [PIDCountryRegionId] = 'EH';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'ESP' WHERE [PIDCountryRegionId] = 'ES';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'ETH' WHERE [PIDCountryRegionId] = 'ET';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'FIN' WHERE [PIDCountryRegionId] = 'FI';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'FRA' WHERE [PIDCountryRegionId] = 'FR';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'GBR' WHERE [PIDCountryRegionId] = 'GB';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'GRC' WHERE [PIDCountryRegionId] = 'GR';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'HUN' WHERE [PIDCountryRegionId] = 'HU';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'IRL' WHERE [PIDCountryRegionId] = 'IE';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'ITA' WHERE [PIDCountryRegionId] = 'IT';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'LTU' WHERE [PIDCountryRegionId] = 'LT';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'LUX' WHERE [PIDCountryRegionId] = 'LU';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'MAR' WHERE [PIDCountryRegionId] = 'MA';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'NLD' WHERE [PIDCountryRegionId] = 'NL';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'NOR' WHERE [PIDCountryRegionId] = 'NO';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'POL' WHERE [PIDCountryRegionId] = 'PL';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'PRT' WHERE [PIDCountryRegionId] = 'PT';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'ROU' WHERE [PIDCountryRegionId] = 'RO';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'SRB' WHERE [PIDCountryRegionId] = 'RS';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'RUS' WHERE [PIDCountryRegionId] = 'RU';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'SWE' WHERE [PIDCountryRegionId] = 'SE';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'SGP' WHERE [PIDCountryRegionId] = 'SG';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'SVN' WHERE [PIDCountryRegionId] = 'SI';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDCountryRegionId] = 'USA' WHERE [PIDCountryRegionId] = 'US';

/* update telnummers */
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET PIDPhone = PIDPhone2, PIDPhone2 = '' WHERE [PIDPhone] = '' AND PIDPhone2 != '';

/* update PreferredName */
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PreferredName] = ''
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PreferredName] = [PIDLastName]																	WHERE [PIDMiddleName] = '' ;
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PreferredName] = CONCAT([PIDMiddleName],' ',[PIDLastName])										WHERE [PIDMiddleName] != '';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PreferredName] = CONCAT([PIDPartnerLastName],'-',[PreferredName])								WHERE [PIDPartnerLastName] != '' AND [PIDPartnerMiddleName] = '';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PreferredName] = CONCAT([PIDPartnerMiddleName],' ',[PIDPartnerLastName], '-', [PreferredName])	WHERE [PIDPartnerLastName] != '' AND [PIDPartnerMiddleName] != '';

/* Update gender */
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDGender] = 0	WHERE [PIDGender] = '' OR  [PIDGender] = 'O';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDGender] = 1	WHERE [PIDGender] = 'M' ;
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDGender] = 2	WHERE [PIDGender] = 'V' ;

/* Update Maritalstatus */
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDMaritalStatus] = 0	WHERE [PIDMaritalStatus] = '' OR [PIDMaritalStatus] = 'S';
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDMaritalStatus] = 1	WHERE [PIDMaritalStatus] = 'O' ;
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDMaritalStatus] = 2	WHERE [PIDMaritalStatus] = 'G' ;
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDMaritalStatus] = 4	WHERE [PIDMaritalStatus] = 'W' ;

/* Update FirstName */
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'A','A.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'B','B.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'C','C.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'D','D.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'E','E.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'F','F.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'G','G.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'H','H.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'I','I.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'J','J.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'K','K.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'L','L.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'M','M.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'N','N.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'O','O.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'P','P.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'Q','Q.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'R','R.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'S','S.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'T','T.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'U','U.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'V','V.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'W','W.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'X','X.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'Y','Y.');
UPDATE [avanade].[dbo].[AHC_HL7Journal] SET [PIDFirstName] = REPLACE([PIDFirstName],'Z','Z.');


/* Upload naar AX4H server */
/*
INSERT INTO [FZR-AX4HDB-02\AX4HEALTH_ACC].[FZR_AANLEVERING].[dbo].[AHC_HL7Journal]
SELECT * FROM [avanade].[dbo].[AHC_HL7Journal];
*/

/* Upload naar AX4H server LZB */
/*
INSERT INTO [AAX4HDB01\AX4HEALTH_ACC].[AX4HealthR2].[dbo].[AHC_HL7Journal]
SELECT * FROM [avanade].[dbo].[AHC_HL7Journal];
*/