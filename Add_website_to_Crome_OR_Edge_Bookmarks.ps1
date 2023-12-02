
# Create a PowerShell function to add a bookmark entry to the Bookmarks file
function Add-Bookmark {
    param (
        [string]$Url,
        [string]$Name,
        [string]$ParentId,
        [string]$BrowserName
    )
    if($BrowserName -eq "Chrome"){
        $BookmarksPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"
    }
    elseif($BrowserName -eq "Edge"){
        $BookmarksPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
    }
    if(Test-Path $BookmarksPath){
        if(!(Test-Path "$BookmarksPath\Bookmarks")){
            Write-Host "Creating Bookmarks file..."
            $emptyBookmarksContent = @"
    {
        "checksum": "",
        "roots": {
            "bookmark_bar": {
                "children": [],
                "date_added": "2000-01-01T00:00:00.000Z",
                "date_modified": "2000-01-01T00:00:00.000Z",
                "id": "1",
                "name": "Bookmarks bar"
            },
            "other": {
                "children": [],
                "date_added": "2000-01-01T00:00:00.000Z",
                "date_modified": "2000-01-01T00:00:00.000Z",
                "id": "2",
                "name": "Other bookmarks"
            },
            "synced": {
                "children": [],
                "date_added": "2000-01-01T00:00:00.000Z",
                "date_modified": "2000-01-01T00:00:00.000Z",
                "id": "3",
                "name": "Mobile bookmarks"
            }
        },
        "version": 1
    }
"@
            $emptyBookmarksContent | Out-File -FilePath "$BookmarksPath\Bookmarks" -Encoding utf8
        }
        $BookmarksPath = "$BookmarksPath\Bookmarks"
    
        # Function to check if a bookmark with the specified URL exists
        function Check-BookmarkExists {
        param (
            [string]$Url,
            [string]$BookmarksFilePath
        )

        # Read the existing bookmarks from the 'Bookmarks' file
        $BookmarksContent = Get-Content -Path $BookmarksFilePath -Raw | ConvertFrom-Json

        # Check if a bookmark with the given URL already exists
        foreach ($bookmark in $BookmarksContent.roots.bookmark_bar.children) {
            if ($bookmark.type -eq "url" -and ($bookmark.url -eq $Url -or $bookmark.url -eq "$Url/")) {
                return $true
            }
        }
        return $false
    }

        # Check if the bookmark already exists
        $BookmarkExists = Check-BookmarkExists -Url $Url -BookmarksFilePath $BookmarksPath

        # If the bookmark doesn't exist, add it
        if (-not $BookmarkExists) {
            # Generate a unique ID for the bookmark
            $Id = [guid]::NewGuid().ToString("D")

            # Create the bookmark object
            $Bookmark = @{
                type = "url"
                id = $Id
                name = $Name
                url = $Url
            }

            # Add the bookmark to the Bookmarks JSON structure
            $NewBookmark = ConvertTo-Json -InputObject $Bookmark -Compress
            $NewBookmarkEntry = '{"date_added":"' + (Get-Date -UFormat "%FT%T.%3NZ") + '","guid":"' + $Id + '","name":"' + $Name + '","type":"url","url":"' + $Url + '"}'

            # Insert the new bookmark entry into the Bookmarks file
            $BookmarksContent = Get-Content -Path $BookmarksPath -Raw | ConvertFrom-Json
            $BookmarksContent.roots.bookmark_bar.children += ($NewBookmark | ConvertFrom-Json)
            $BookmarksContent | ConvertTo-Json -Depth 10 | Set-Content -Path $BookmarksPath -Encoding UTF8

            Write-Host "$Name has been added to bookmarks."
        } else {
            Write-Host "$Name already exists in bookmarks. At $BookmarksPath"
        }
    }
    elseif(Test-Path $BookmarksPath){
        Write-Host "$BookmarksPath not found"
    }
}



# Call the function to add Netflix as a bookmark in Chrome
Add-Bookmark -Url "https://www.netflix.com" -Name "Netflix" -ParentId "bookmark_bar" -BrowserName "Edge"
