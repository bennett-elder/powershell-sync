import-module .\file.psm1
import-module .\sftp.psm1

# SyncFolders -LeftFolder .\test_folders\a -RightFolder .\test_folders\b -AlsoCopyDestToSource $false

Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

# Setup session options
$sourceSessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Sftp
    HostName = "example.com"
    UserName = "user"
    # Password = "mypassword"
    # SshPrivateKeyPath = ""
    # SshHostKeyFingerprint = "ssh-rsa 2048 xxxxxxxxxxx..."
}

$destinationSessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Sftp
    HostName = "example.com"
    UserName = "user"
    # Password = "mypassword"
    # SshPrivateKeyPath = ""
    # SshHostKeyFingerprint = "ssh-rsa 2048 xxxxxxxxxxx..."
}


# WinSCP.SessionOptions:
# use Password or SshPrivateKeyPath
# SshHostKeyFingerprint required

$result = DownloadFolder -sessionOptions $sourceSessionOptions -localPath ".\" -remotePath "/" -cleanupSourceFolder $true

if ($result[0] -eq 1)
{
    exit 1
}

$successful = $result[1]
$failed = $result[2]

$emailReport = [System.Text.StringBuilder]::new()
[void]$emailReport.AppendLine( 'Files successfully transferred:' )
foreach ($file in $successful) {
    [void]$emailReport.AppendLine($file)
}
[void]$emailReport.AppendLine( 'Files where transfer failed:' )
foreach ($file in $failed) {
    [void]$emailReport.AppendLine($file)
}

$emailReport.ToString()

$result = UploadFolder -sessionOptions $destinationSessionOptions -localPath ".\" -remotePath "/" -cleanupSourceFolder $true

if ($result[0] -eq 1)
{
    exit 1
}