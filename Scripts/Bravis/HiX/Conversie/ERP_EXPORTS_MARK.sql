/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [DisplayProductNumber]
      ,[InventTable_Description]
      ,[InventTableModuleInvent_Price]
      ,[InventTableModuleInvent_PriceQty]
      ,[InventTableModuleInvent_PriceUnit]
      ,[InventTableModuleInvent_UnitId]
      ,[InventTableModulePurch_Price]
      ,[InventTableModulePurch_PriceQty]
      ,[InventTableModulePurch_PriceUnit]
      ,[InventTableModulePurch_UnitId]
      ,[InventTableModuleSales_Price]
      ,[InventTableModuleSales_PriceQty]
      ,[InventTableModuleSales_PriceUnitId]
      ,[InventTableModuleSales_UnitId]
      ,[ItemBuyerGroupId]
      ,[ItemGroupId]
      ,[ItemId]
      ,[ItemType]
      ,[AHCItemType]
      ,[LowestQty]
      ,[MatchingPolicy]
      ,[ModelGroupId]
      ,[NameAlias]
      ,[NetWeight]
      ,[OrigCountryRegionId]
      ,[PrimaryVendorId]
      ,[ProductSubType]
      ,[PurchModel]
      ,[ReqGroupId]
      ,[SalesContributionRatio]
      ,[SalesModel]
      ,[SalesPercentMarkup]
      ,[SalesPriceModelBasic]
      ,[SearchName]
      ,[UseAltItemId]
      ,[Width]
      ,[ExternalItemNumber]
      ,[Steriel]
      ,[Gevaarlijke_stof]
      ,[Diepvries]
      ,[Gekoeld]
      ,[Min_niveau_magazijn]
      ,[Allergie_informatie]
      ,[Magazijn]
      ,[Locatie_binnen_magazijn]
      ,[Max_niveau_magazijn]
      ,[ECOResCategoryName_old]
      ,[InventItemGroupId]
      ,[ProductType]
      ,[ReleaseProductCompany]
      ,[InventSiteId]
      ,[SalesInventLocationId]
      ,[PurchInventLocationId]
      ,[ItemInventLocationId]
      ,[ECOResCategoryName]
      ,[ReqPOTypeActive]
      ,[InventLocationIdReqMain]
      ,[ReqPOType]
      ,[DefaultDimension]
      ,[MinInventOnHand]
      ,[MaxInventOnHand]
  FROM [FZR_AANLEVERING].[dbo].[InventTable_fzr]
  WHERE ECOResCategoryName = 'Implantaten' AND AHCItemType = 'Koopartikel'
  
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [DisplayProductNumber]
      ,[InventTable_Description]
      ,[InventTableModuleInvent_Price]
      ,[InventTableModuleInvent_PriceQty]
      ,[InventTableModuleInvent_PriceUnit]
      ,[InventTableModuleInvent_UnitId]
      ,[InventTableModulePurch_Price]
      ,[InventTableModulePurch_PriceQty]
      ,[InventTableModulePurch_PriceUnit]
      ,[InventTableModulePurch_UnitId]
      ,[InventTableModuleSales_Price]
      ,[InventTableModuleSales_PriceQty]
      ,[InventTableModuleSales_PriceUnitId]
      ,[InventTableModuleSales_UnitId]
      ,[ItemBuyerGroupId]
      ,[ItemGroupId]
      ,IT.[ItemId]
      ,[ItemType]
      ,[AHCItemType]
      ,[LowestQty]
      ,[MatchingPolicy]
      ,[ModelGroupId]
      ,[NameAlias]
      ,[NetWeight]
      ,[OrigCountryRegionId]
      ,[PrimaryVendorId]
      ,[ProductSubType]
      ,[PurchModel]
      ,[ReqGroupId]
      ,[SalesContributionRatio]
      ,[SalesModel]
      ,[SalesPercentMarkup]
      ,[SalesPriceModelBasic]
      ,[SearchName]
      ,[UseAltItemId]
      ,[Width]
      ,[ExternalItemNumber]
      ,[Steriel]
      ,[Gevaarlijke_stof]
      ,[Diepvries]
      ,[Gekoeld]
      ,[Min_niveau_magazijn]
      ,[Allergie_informatie]
      ,[Magazijn]
      ,[Locatie_binnen_magazijn]
      ,[Max_niveau_magazijn]
      ,[ECOResCategoryName_old]
      ,[InventItemGroupId]
      ,[ProductType]
      ,[ReleaseProductCompany]
      ,IT.[InventSiteId]
      ,[SalesInventLocationId]
      ,[PurchInventLocationId]
      ,[ItemInventLocationId]
      ,[ECOResCategoryName]
      ,[ReqPOTypeActive]
      ,[InventLocationIdReqMain]
      ,[ReqPOType]
      ,[DefaultDimension]
      ,[MinInventOnHand]
      ,[MaxInventOnHand]
      ,[InventLocationId]
      ,[wMSLocationId]
      ,[Qty]
  FROM [FZR_AANLEVERING].[dbo].[InventTable_fzr] AS IT
  LEFT JOIN [FZR_AANLEVERING].[dbo].[InventJournalTrans_fzr] AS IJT ON IT.ItemId = IJT.ItemId