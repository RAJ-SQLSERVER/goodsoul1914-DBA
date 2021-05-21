CREATE INDEX [BVS_20200127_fldDocumentVersionID_fldValidInvitation] 
ON [iProva_Core_1].[iDocument].[tbdDocumentVersionGuestEditor] ([fldDocumentVersionID], [fldValidInvitation])  
WITH (FILLFACTOR=100);

CREATE INDEX [BVS_20200127_fldMetaFieldListOptionID_Includes] 
ON [iProva_Core_1].[iDocument].[tbdMetaFieldValueListValue] ([fldMetaFieldListOptionID])  
INCLUDE ([fldMetaFieldValueID]) WITH (FILLFACTOR=100);

CREATE INDEX [BVS_20200127_fldDocumentTypeID_fldCurrent_fldState_Includes] 
ON [iProva_Core_1].[iDocument].[tbdDocumentVersion] ([fldDocumentTypeID], [fldCurrent], [fldState])  
INCLUDE ([fldDocumentID]) WITH (FILLFACTOR=100);

CREATE INDEX [BVS_20200127_fldActive_Includes] ON [iProva_Core_1].[iDocument].[tbdDocument] ([fldActive])  
INCLUDE ([fldDocumentID], [fldFolderID]) 
WITH (FILLFACTOR=100);

CREATE INDEX [BVS_20200127_fldRoleType_Includes] ON [iProva_Core_1].[iCheck].[tbdQuestionListPermission] ([fldRoleType])  
INCLUDE ([fldUserOrUserGroupID]) 
WITH (FILLFACTOR=100);

CREATE INDEX [BVS_20200127_ContentTypeID_ShowOnManagementInfoPage_Includes] ON [iProva_Core_1].[iPortal5].[ContentItem] ([ContentTypeID], [ShowOnManagementInfoPage])  
INCLUDE ([ContentItemID]) 
WITH (FILLFACTOR=100);

CREATE INDEX [BVS_20200127_ShowOnManagementInfoPage_Includes] ON [iProva_Core_1].[iPortal5].[ContentItem] ([ShowOnManagementInfoPage])  
INCLUDE ([ContentItemID], [ContentTypeID]) 
WITH (FILLFACTOR=100);

CREATE INDEX [BVS_20200127_SearchQuery_Includes] ON [iProva_Core_1].[iPortal5].[SearchRequestHistoryQuery] ([SearchQuery])  
INCLUDE ([SearchRequestHistoryQueryID]) 
WITH (FILLFACTOR=100);