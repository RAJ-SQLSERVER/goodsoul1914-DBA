SELECT DISTINCT tg.Name, FullDomainName, ct.IPAddress, LastSyncTime, LastSyncResult, ctd.*
FROM tbComputerTarget ct
JOIN tbComputerTargetDetail ctd ON ctd.TargetID = ct.TargetID
JOIN tbTargetInTargetGroup titg ON titg.TargetID = ct.TargetID
JOIN tbTargetGroup tg ON tg.TargetGroupID = titg.TargetGroupID
ORDER BY FullDomainName