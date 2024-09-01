########
# adapted from https://gist.github.com/lafleurh/a3877a8604758892637c3612f76bc0e3
########

function CreateFolderStructure([string]$Path)
{
    if (-not [string]::IsNullOrWhiteSpace($Path))
    {
        if (-not (Test-Path $Path))
        {
            $ParentPath = Split-Path $Path -Parent
            CreateFolderStructure -Path $ParentPath    
            New-Item -Path $Path -ItemType Directory
        }
    }
}

function SyncFoldersUsingFullName([string]$FldrL, [string]$FldrR, [bool]$AlsoCopyDestToSource=$false)
{
    Write-Host "Preparing to copy $($FldrL) to $($FldrR)"
    $LeftItems = Get-ChildItem -Recurse -Path $FldrL
    $RightItems = Get-ChildItem -Recurse -Path $FldrR

    $Result = Compare-Object -ReferenceObject $LeftItems -DifferenceObject $RightItems -IncludeEqual

    foreach ($Folder in $Result) {
        $CopyFile = $false
	$CopyLeft = $false
	$CopyRight = $false
        if ($Folder.SideIndicator -eq "==")
        {
            $LeftPath = $Folder.InputObject.FullName
            $RightPath = $Folder.InputObject.FullName.Replace($FldrL, $FldrR)
          
            if (Test-Path $LeftPath)
            {
                if (Test-Path $RightPath)
                {

                    $LeftDate = [datetime](Get-ItemProperty -Path $LeftPath -Name LastWriteTime).LastWriteTime
	            $RightDate = [datetime](Get-ItemProperty -Path $RightPath -Name LastWriteTime).LastWriteTime

                    if ((Get-Item $LeftPath).GetType().Name -eq "FileInfo")
                    {
                        if ($LeftDate -gt $RightDate)
            	        {
                            $SourcePath = $LeftPath
                            $TargetPath = $RightPath
                            $CopyFile = $true
                        }
                        if ($RightDate -gt $LeftDate)
                        {
                            $SourcePath = $RightPath
                            $TargetPath = $LeftPath
                            $CopyFile = $true
                        }
                    }
                } else {
                    $CopyLeft = $true
                }
            } else {
                if (Test-Path $RightPath)
                {
                    $CopyRight = $true
                }
           }
        }
        if ($Folder.SideIndicator -eq "<=" -or $CopyLeft) {
            $SourcePath = $Folder.InputObject.FullName
            $TargetPath = $Folder.InputObject.FullName.Replace($FldrL, $FldrR)
            $CopyFile = $true
        }
        if ($Folder.SideIndicator -eq "=>" -or $CopyRight) {
            $SourcePath = $Folder.InputObject.FullName
            $TargetPath = $Folder.InputObject.FullName.Replace($FldrR, $FldrL)
            $CopyFile = $true -and $AlsoCopyDestToSource
        }

        if ($CopyFile -And (Test-Path $SourcePath))
        {
            Write-Host "$($Folder.SideIndicator) Copying $($SourcePath) to $($TargetPath)"
            $ParentPath = Split-Path $TargetPath -Parent
            CreateFolderStructure -Path $ParentPath
            if ((Get-Item $SourcePath).GetType().Name -eq "DirectoryInfo")
            {
                New-Item -Path $TargetPath -ItemType Directory
            }
            else
            {
                Copy-Item -Path $SourcePath -Destination $TargetPath
            }
        }
    }
}

function SyncFolders([string]$LeftFolder, [string]$RightFolder, [bool]$AlsoCopyDestToSource=$false)
{
    SyncFoldersUsingFullName -FldrL (Get-Item -Path $LeftFolder).FullName -FldrR (Get-Item -Path $RightFolder).FullName -AlsoCopyDestToSource $AlsoCopyDestToSource
}

########
# end from https://gist.github.com/lafleurh/a3877a8604758892637c3612f76bc0e3
########
