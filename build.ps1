[CmdletBinding()]
Param(

    [Parameter(Mandatory)]
    [String]
    $PackageId,

    [Parameter(Mandatory)]
    [String]
    $PackageVersion,

    [Parameter(Mandatory)]
    [String]
    $Url,

    [Parameter(Mandatory)]
    [String]
    $SoftwareName,

    [Parameter(Mandatory)]
    [String]
    $SilentArgs,

    [Parameter(Mandatory)]
    [String]
    $ValidExitCodes,

    [Parameter(Mandatory)]
    [String]
    $Author,

    [Parameter(Mandatory)]
    [String]
    $InstallerType,

    [Parameter(Mandatory)]
    [String]
    $Description

)

end {
    $tempDir = Join-Path $env:TEMP -ChildPath (New-Guid).Guid

    # Create our temp dir
    if (-not (Test-Path $tempDir)) {
        $null = New-Item $tempDir -ItemType Directory
    }

    # Checksum our file
    $file = Split-path $Url -Leaf
    
    $download = Join-Path $tempDir -ChildPath $file
    Write-Output "Preparing to download $file from $url to $download"
    [System.Net.WebClient]::new().DownloadFile($Url, $download)

    $checksum = (Get-FileHash $download -Algorithm SHA256).Hash
    
    if ($checksum) {
        Remove-item $download -Force
    }

    # Get path to choco.exe
    $choco = (Get-Command choco).source

    if (-not $choco) {
        throw "Chocolatey CLI is required but not found!"
    }

    # Make our package from a template
    choco new $PackageId --version="$PackageVersion" --template='webinar' Url="$Url" SoftwareName="$SoftwareName" silentArgs="$SilentArgs" validExitCodes="$ValidExitCodes" Checksum="$checksum" Author="$Author" InstallerType="$InstallerType" Summary="$Summary" Description="$Description" --output-directory="$tempDir" --build-package
    $nuspec = (Get-ChildItem $tempDir -Recurse -Filter '*.nuspec').FullName

    # Pack the bitch
    choco pack $nuspec --output-directory="$tempDir"
    # Output our temp dir for the publish step
    Write-Output "TempDir=$($tempDir)" >> $Env:GITHUB_OUTPUT

    return $Env:GITHUB_OUTPUT
}