[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [String]
    $IssueBody
)

process {
    $hashtable = @{}

    # Regex pattern to capture all headings and values
    $regex = "(?m)^###\s+(.+?)\n\s*\n\s*([^\n]+)"

    # Use [regex]::Matches to find all matches in the issue body
    $matches = [regex]::Matches($IssueBody, $regex)

    foreach ($match in $matches) {
        $key = $match.Groups[1].Value -replace "\s+", ""  # Remove spaces for the hashtable key
        $value = $match.Groups[2].Value.Trim()           # Trim extra spaces/newlines
        $hashtable[$key] = "$value"
    }

    # Output the hashtable
    $hashtable.GetEnumerator() | ForEach-Object {
        $string = '{0}={1}' -f $_.Key, "$($_.Value)"
        Write-Output $string >> $Env:GITHUB_OUTPUT
    }
}