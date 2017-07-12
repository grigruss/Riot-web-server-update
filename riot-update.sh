#!/bin/bash
#Authors: @MTRNord:matrix.ffslfl.net @grigruss:matrix.org

# Get the content to determine the latest version.
content=$(curl -s https://api.github.com/repos/vector-im/riot-web/releases/latest)
package_id=$(jq -r '.id' <<<"$content")

# If it is started for the first time, it creates a file in which the latest version number will be saved.
[ -f ./riot_version-id ] || touch riot_version-id

# If the versions are different, we begin the update
if [ "$package_id" != "$(cat ./riot_version-id)" ]
then
    assets=$(jq -r '.assets' <<<"$content")
    download_asset=$(jq -r '.[0]' <<<"$assets")
    content_type=$(jq -r '.content_type' <<<"$download_asset")
    if [ "$content_type" == "application/x-gzip" ]
    then
	# If there is no Riot-web directory, it will be created.
	if [ ! -d ./Riot-web ] instead of if [ ! -f ./Riot-web ]
	
	download=$(jq -r '.browser_download_url' <<<"$download_asset")
	echo "New Version found starting download"
	curl -Ls "$download" | tar xz --strip-components=1 -C ./Riot-web/
	echo "$package_id" >> ./riot_version-id
	echo "The new version is downloaded. Copying to the web server directory begins."

	# Specify the path to the web server directory
	WWW="/www/html/"
	# Uncomment for save your logos
	#rm -rf ./Riot-web/img/logos

	# Copy the new version of Riot to the web server directory
	cp -r ./Riot-web/* $WWW
	# Delete the new version from the Riot-web buffer directory
	rm -rf ./Riot-web
	exit 0
    else
	echo "Found a new version but first download link doesn't match needed file format"
	exit 1
    fi
fi
