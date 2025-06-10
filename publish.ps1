[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [String]
    $TempDir,

    [Parameter(Mandatory)]
    [Alias('Source')]
    [String]
    $RepositoryUrl,

    [Parameter(Mandatory)]
    [String]
    $ApiKey
)

end {
    if (-not (Test-Path $TempDir)) {
        throw "$TempDir does not exist! I fear catastrophe has struck!"
    }

    $choco = (Get-Command choco).Source

    if (-not $choco) {
        throw 'Ruh-roh, raggy! Chocolatey CLI is required, but was not found!'
    }

    $nupkg = (Get-ChildItem $TempDir -Filter '*.nupkg' -Recurse).FullName

    $chocoArgs = @('push', $nupkg, "--source='$RepositoryUrl'", "--api-key='$ApiKey'")

    & choco @chocoArgs

    if ($LASTEXITCODE -eq 0) {
        Remove-Item $TempDir -Recurse -Force
    }
}