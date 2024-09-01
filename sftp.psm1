# adapted from https://winscp.net/eng/docs/library_example_delete_after_successful_download

function DownloadFolder (
    [WinSCP.SessionOptions]$sessionOptions,
    [string]$localPath,
    [string]$remotePath,
    [bool]$cleanupSourceFolder=$false
)
    {
    try
    {
        # Load WinSCP .NET assembly
        Add-Type -Path "WinSCPnet.dll"
    
        $session = New-Object WinSCP.Session
    
        try
        {
            # Connect
            $session.Open($sessionOptions)
    
            # Synchronize files to local directory, collect results
            $synchronizationResult = $session.SynchronizeDirectories(
                [WinSCP.SynchronizationMode]::Local, $localPath, $remotePath, $False)
    
            # Deliberately not calling $synchronizationResult.Check
            # as that would abort our script on any error.
            # We will find any error in the loop below
            # (note that $synchronizationResult.Downloads is the only operation
            # collection of SynchronizationResult that can contain any items,
            # as we are not removing nor uploading anything)
    
            # Iterate over every download
            foreach ($download in $synchronizationResult.Downloads)
            {
                # Success or error?
                if ($Null -eq $download.Error)
                {
                    if ($cleanupSourceFolder) {
                        Write-Host "Download of $($download.FileName) succeeded, removing from source"
                        # Download succeeded, remove file from source
                        $filename = [WinSCP.RemotePath]::EscapeFileMask($download.FileName)
                        $removalResult = $session.RemoveFiles($filename)
        
                        if ($removalResult.IsSuccess)
                        {
                            Write-Host "Removing of file $($download.FileName) succeeded"
                        }
                        else
                        {
                            Write-Host "Removing of file $($download.FileName) failed"
                        }
    
                    }
                    else
                    {
                        Write-Host "Download of $($download.FileName) succeeded"
                    }
                }
                else
                {
                    Write-Host (
                        "Download of $($download.FileName) failed: $($download.Error.Message)")
                }
            }
        }
        finally
        {
            # Disconnect, clean up
            $session.Dispose()
        }
    
        exit 0
    }
    catch
    {
        Write-Host "Error: $($_.Exception.Message)"
        exit 1
    }
}


function UploadFolder (
    [WinSCP.SessionOptions]$sessionOptions,
    [string]$localPath,
    [string]$remotePath,
    [bool]$cleanupSourceFolder=$false
)
    {
    try
    {
        # Load WinSCP .NET assembly
        Add-Type -Path "WinSCPnet.dll"
    
        $session = New-Object WinSCP.Session
    
        try
        {
            # Connect
            $session.Open($sessionOptions)

            # Synchronize files from local directory, collect results
            $synchronizationResult = $session.SynchronizeDirectories(
                [WinSCP.SynchronizationMode]::Remote, $localPath, $remotePath, $False)

            # Deliberately not calling $synchronizationResult.Check
            # as that would abort our script on any error.
            # We will find any error in the loop below
            # (note that $synchronizationResult.Downloads is the only operation
            # collection of SynchronizationResult that can contain any items,
            # as we are not removing nor uploading anything)
    
            # Iterate over every download
            foreach ($upload in $synchronizationResult.Uploads)
            {
                # Success or error?
                if ($Null -eq $upload.Error)
                {
                    if ($cleanupSourceFolder) {
                        Write-Host "Upload of $($upload.FileName) succeeded, removing from source"
                        # Upload succeeded, remove file from source
                        $filename = [WinSCP.RemotePath]::EscapeFileMask($upload.FileName)
                        $removalResult = $session.RemoveFiles($filename)
        
                        if ($removalResult.IsSuccess)
                        {
                            Write-Host "Removing of file $($upload.FileName) succeeded"
                        }
                        else
                        {
                            Write-Host "Removing of file $($upload.FileName) failed"
                        }
    
                    }
                    else
                    {
                        Write-Host "Upload of $($upload.FileName) succeeded"
                    }
                }
                else
                {
                    Write-Host (
                        "Upload of $($upload.FileName) failed: $($upload.Error.Message)")
                }
            }
        }
        finally
        {
            # Disconnect, clean up
            $session.Dispose()
        }
    
        exit 0
    }
    catch
    {
        Write-Host "Error: $($_.Exception.Message)"
        exit 1
    }
}
