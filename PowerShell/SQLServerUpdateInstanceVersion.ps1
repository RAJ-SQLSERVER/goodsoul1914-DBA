$managementServer = "GTSQL01"
$managentDatabase = "DBA"

$SqlInstances = (Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase `
    -Query "SELECT SqlInstance FROM DBA.dbo.SqlInstances WHERE Scan = 1 ORDER BY SqlInstance;").SqlInstance

$ComputerNames = (Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase `
    -Query "SELECT DISTINCT ComputerName FROM dbo.SqlInstances ORDER BY ComputerName;").ComputerName

# Update version field of instance records
foreach ($instance in $SqlInstances) {    
    $infoObj = Get-DbaInstanceProperty -SqlInstance $instance

    $version = ($infoObj | where {$_.Name -eq "VersionString"}).Value
    $edition = ($infoObj | where {$_.Name -eq "Edition"}).Value

    Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase `
        -Query "UPDATE dbo.SqlInstances SET Timestamp = GETDATE(), SqlVersion = '$version', SqlEdition = '$edition' WHERE SqlInstance = '$instance';"
}

foreach ($computer in $ComputerNames) {    
    $infoObj = Get-DbaComputerSystem -ComputerName $computer

    $cpuPhysicalCount = $infoObj.NumberProcessors
    $cpuLogicalCount = $infoObj.NumberLogicalProcessors
    $memPhysical = $infoObj.TotalPhysicalMemory

    Invoke-DbaQuery -SqlInstance $managementServer -Database $managentDatabase `
        -Query "UPDATE dbo.SqlInstances SET Timestamp = GETDATE(), ProcessorInfo = '$cpuPhysicalCount / $cpuLogicalCount', PhysicalMemory = '$memPhysical' WHERE ComputerName = '$computer';"
}