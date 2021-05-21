USE HIX_ZANDBAK;
GO
EXEC sp_change_users_login @Action='update_one', @UserNamePattern='chipsoftwinzis', @LoginName='chipsoftwinzis';
GO