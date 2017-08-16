#!/bin/bash

# Authors: @MTRNord:matrix.ffslfl.net @grigruss:matrix.org

# Specify the path to the web server directory
WWW="./riot-web"

# Get the content to determine the latest version.
content=$(curl -s https://api.github.com/repos/vector-im/riot-web/releases/latest)
package_id=$(jq -r '.id' <<<"$content")

# If it is started for the first time, it creates a file in which the latest version number will be saved.
[ -f ./riot_version-id ] || touch riot_version-id

# Ensure existens of the WWW directory
if [ ! -d $WWW ]
then
    mkdir $WWW
fi

# If the versions are different, we begin the update
if [ "$package_id" != "$(cat ./riot_version-id)" ]
then
    download_url=$(jq -r '.assets[] | select(.content_type == "application/x-gzip") | .browser_download_url' <<<"$content")
    if [ $download_url != "" ]
    then
        # If there is no Riot-web directory, it will be created.
        if [ ! -d ./Riot-web ]
        then
            mkdir Riot-web
        fi

        echo "New Version found starting download"
        curl -Ls "$download_url" | tar xz --strip-components=1 -C ./Riot-web/
        echo "$package_id" >> ./riot_version-id
        echo "The new version is downloaded. Copying to the web server directory begins."

        # Uncomment for save your logos
        # rm -rf ./Riot-web/img/logos

        # Copy the new version of Riot to the web server directory
        cp -r ./Riot-web/* $WWW
        # Delete the new version from the Riot-web buffer directory
        rm -rf ./Riot-web
        echo "Copying to the web server directory finished. Exiting..."
        exit 0
    else
        echo "New version doesn't conatin needed archive. Aborting..."
        exit 1
    fi
fi
