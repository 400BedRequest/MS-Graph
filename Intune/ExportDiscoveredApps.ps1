# Script to export discovered apps from all Windows devices from Intune

# Authenticate with Graph
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

# Get all managed Windows devices
$devices = Get-MgDeviceManagementManagedDevice -Filter "operatingSystem eq 'Windows'" -All

# Prepare results array
$results = @()

foreach ($device in $devices) {
    Write-Host "Getting apps for device: $($device.DeviceName)"
    
    # Raw Graph API call
    $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($device.Id)/detectedApps"

    try {
        $response = Invoke-MgGraphRequest -Method GET -Uri $uri
        $apps = $response.value

        foreach ($app in $apps) {
            $results += [PSCustomObject]@{
                DeviceName = $device.DeviceName
                DeviceId = $device.Id
                UserPrincipalName = $device.UserPrincipalName
                AppName = $app.displayName
                Publisher = $app.publisher
                Version = $app.version
                SizeInKB = [math]::Round($app.sizeInByte / 1KB)
            }
        }
    } catch {
        Write-Warning "Error retrieving apps for $($device.DeviceName): $_"
    }
}

# Export to CSV
$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$csvPath = "<Local Path>.csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Host "Export complete: $csvPath"
