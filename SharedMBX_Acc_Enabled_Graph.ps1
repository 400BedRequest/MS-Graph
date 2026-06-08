############################################################################
# script to take csv list of shared mailboxes (column name "ObjectKey"     #
# you can chacnge this name in the $mail) and show if account is           #
# enabled (source MS Entra).                                               #
# you need Microsoft.Graph.Users module to run this, and also              #
# connect to MS Graph API.                                                 #
############################################################################

$csv = Import-Csv "sharedmbx.csv"

$result = foreach ($row in $csv) {
    $mail = $row.ObjectKey

    $user = Get-MgUser `
        -Filter "proxyAddresses/any(x:x eq 'SMTP:$mail')" `
        -ConsistencyLevel eventual `
        -Property DisplayName,Mail,UserPrincipalName,AccountEnabled

    if ($user) {
        foreach ($u in $user) {
            [PSCustomObject]@{
                Mail = $mail
                DisplayName = $u.DisplayName
                UserPrincipalName = $u.UserPrincipalName
                AccountEnabled = $u.AccountEnabled
            }
        }
    }
    else {
        [PSCustomObject]@{
            Mail = $mail
            DisplayName = "NOT FOUND"
            UserPrincipalName = ""
            AccountEnabled = "N/A"
        }
    }
}

$result | Export-Csv "output.csv" -NoTypeInformation