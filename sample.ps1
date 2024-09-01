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

DownloadFolder -sessionOptions $sourceSessionOptions -localPath ".\" -remotePath "/" -cleanupSourceFolder $true

UploadFolder -sessionOptions $destinationSessionOptions -localPath ".\" -remotePath "/" -cleanupSourceFolder $true

