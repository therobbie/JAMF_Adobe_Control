#!/bin/zsh
# Author: Robert Henderson
# Date: 04-23-2026
#
## Adobe Control Script version 3.2
## Converted to zsh
##
## Updated handling to compute the base version. Using adobeuninstaller --list output to get this value.

## Description:
#   Script will handle uninstalling Adobe Applications and also reinstalling based on what is "called".
#   Control will be handled from JAMF Pro using script variables.
## Variable 4: Action variable (i.e. Uninstall or Install)
## Variable 5: Year Version (i.e. 2024 or 2025 etc..)
## Variable 6: All or Specific Suites (i.e. Photo, Video, Design, All)

#### Variables ####
actionVar="${4}"
appYear="${5}"
# Create an array of the JAMF variables. Zsh handles unquoted variables safely here.
appList=(${=6} ${=7} ${=8} ${=9} ${=10} ${=11})

appPath=""      # Holds path of app we are working on
appSAPcode=""   # Holds Adobe SAP Code for application  
appEventID=""   # Holds event ID for specific app
appMajorVer=""  # Holds major version with correct number of minor digits
appBaseVersion="" # Holds base version for app selected

#### FUNCTIONS ####

# Usage: find_base <SapCode> <Version>
find_base() {
    local target_sap=$1
    local target_ver=$2

    # Loop through the DATA string line-by-line
    # read -rA splits each line by whitespace into an array called 'words'
    while read -rA words; do
        # Skip empty lines or header lines (lines with less than 3 words, or starting with Name/---)
        if [[ ${#words[@]} -lt 3 || "${words[1]}" == "Name" || "${words[1]}" == \-* ]]; then
            continue
        fi

        # Zsh supports negative indexing to grab items from the end of an array
        local row_ver=${words[-1]}
        local row_base=${words[-2]}
        local row_sap=${words[-3]}

        # Check for a match
        if [[ "$row_sap" == "$target_sap" && "$row_ver" == "$target_ver"* ]]; then
            echo "$row_base"
            return 0 # Exit function successfully
        fi
    done <<< "$adobeUninstallerInfo"

    # If the loop finishes without returning, the item wasn't found
    echo "Not Found"
}

appSelector() {
    local appSelected="${1}"

    case ${appSelected} in
        "acrobat")
            echo "App chosen: acrobat"
            appPath="/Applications/Adobe Acrobat DC/Adobe Acrobat.app"
            appSAPcode="APRO"
            appEventID="adobeacrobat"
            ;;
        "aftereffects")
            echo "App chosen: after effects"
            appPath="/Applications/Adobe After Effects ${appYear}/Adobe After Effects ${appYear}.app"
            appSAPcode="AEFT"
            appEventID="adobeaftereffects"
            ;;
        "animate")
            echo "App chosen: animate"
            appPath="/Applications/Adobe Animate 2024/Adobe Animate 2024.app"
            appSAPcode="FLPR"
            appEventID="adobeanimate"
            ;;    
        "audition")
            echo "App chosen: audition"
            appPath="/Applications/Adobe Audition ${appYear}/Adobe Audition ${appYear}.app"
            appSAPcode="AUDT"
            appEventID="adobeaudition"
            ;;
        "bridge")
            echo "App chosen: bridge"
            appPath="/Applications/Adobe Bridge ${appYear}/Adobe Bridge ${appYear}.app"
            appSAPcode="KBRG"
            appEventID="adobebridge"
            ;;
        "character")
            echo "App chosen: character"
            appPath="/Applications/Adobe Character Animator ${appYear}/Adobe Character Animator ${appYear}.app"
            appSAPcode="CHAR"
            appEventID="adobecharacteranimator"
            ;;
        "dimension")
            echo "App chosen: dimension"
            appPath="/Applications/Adobe Dimension/Adobe Dimension.app"
            appSAPcode="ESHR"
            appEventID="adobedimension"
            ;;
        "dreamweaver")
            echo "App chosen: dreamweaver"
            appPath="/Applications/Adobe Dreamweaver 2021/Adobe Dreamweaver 2021.app"
            appSAPcode="DRWV"
            appEventID="rit_adobedreamweaversdl"
            ;;
        "illustrator")
            echo "App chosen: illustrator"
            appPath="/Applications/Adobe Illustrator ${appYear}/Adobe Illustrator.app"
            appSAPcode="ILST"
            appEventID="adobeillustrator"
            ;;
        "incopy")
            echo "App chosen: incopy"
            appPath="/Applications/Adobe InCopy ${appYear}/Adobe InCopy ${appYear}.app"
            appSAPcode="AICY"
            appEventID="adobeincopy"
            ;;
        "indesign")
            echo "App chosen: indesign"
            appPath="/Applications/Adobe InDesign ${appYear}/Adobe InDesign ${appYear}.app"
            appSAPcode="IDSN"
            appEventID="adobeindesign"
            ;;
        "lightroomclassic")
            echo "App chosen: lightroomclassic"
            appPath="/Applications/Adobe Lightroom Classic/Adobe Lightroom Classic.app"
            appSAPcode="LTRM"
            appEventID="adobelightroomclassic"
            ;;
        "mediaencoder")
            echo "App chosen: media encoder"
            appPath="/Applications/Adobe Media Encoder ${appYear}/Adobe Media Encoder ${appYear}.app"
            appSAPcode="AME"
            appEventID="adobemediaencoder"
            ;;
        "photoshop")
            echo "App chosen: photoshop"
            appPath="/Applications/Adobe Photoshop ${appYear}/Adobe Photoshop ${appYear}.app"
            appSAPcode="PHSP"
            appEventID="adobephotoshop"
            ;;
        "premierepro")
            echo "App chosen: premiere pro"
            appPath="/Applications/Adobe Premiere Pro ${appYear}/Adobe Premiere Pro ${appYear}.app"
            appSAPcode="PPRO"
            appEventID="adobepremierepro"
            ;;
        "premiererush")
            echo "App chosen: premiere rush"
            appPath="/Applications/Adobe Premiere Rush 2.0/Adobe Premiere Rush.app"
            appSAPcode="RUSH"
            appEventID="adobepremiererush"
            ;;
        *)
            echo "App selected was not found in selector."
            ;;
    esac
}

appUninstall() {
    # Check to see if the Application is still present
    if [[ -d "${appPath}" ]]; then
        
        echo ""
        echo "Product Key: ${appSAPcode}"
        echo "Product Path: ${appPath}"
        
        # Get the Base Version from the application that is installed
        appVersion=$(defaults read "${appPath}/Contents/Info.plist" CFBundleShortVersionString)

        echo "Uninstall SAP Code: ${appSAPcode}"
        echo "Version: ${appVersion}"

        # New method to get the correct base version for the currently selected app
        adobeUninstallerInfo=$(/usr/local/adobe/AdobeUninstaller --list)

        # Extract only the major and minor numbers (xx.xx) from the user's input
        MAJOR_MINOR=$(echo "$appVersion" | sed -E 's/^([0-9]+\.[0-9]+).*$/\1/')

        appBaseVersion=$(find_base "${appSAPcode}" "${MAJOR_MINOR}")

        # Output base version found for logging in JAMF
        echo "Base Version: ${appBaseVersion}"

        # Make sure we have data in both variables
        if [[ -n "${appSAPcode}" && -n "${appBaseVersion}" ]] ; then

            # Run the Adobe uninstall command
            /usr/local/adobe/AdobeUninstaller --products="${appSAPcode}#${appBaseVersion}"

            # Verify app is removed
            if [[ -d "${appPath}" ]]; then
                echo "Application is still present. Uninstall failed"
            else
                echo "Uninstall successful"
            fi
        else
            echo "Missing variable. SAP Code: ${appSAPcode} or Base Version: ${appBaseVersion}"
            exit 1
        fi
    else
        echo "Product ${appPath} was not present"
    fi
}

appInstall() {
    # Check to see if the Application is still present
    if [[ ! -d "${appPath}" ]]; then
        
        echo "Event ID: ${appEventID}"
        echo "Product Path: ${appPath}"
        echo "Installing..."
        echo ""
       
        # Application is missing, let's reinstall
        /usr/local/bin/jamf policy -event ${appEventID}

        # Recheck path for successful install
        if [[ ! -d "${appPath}" ]]; then
            echo "Application failed to install"
        else
            echo "Application installed successfully"
        fi
    else
        echo "Application ${appSelected} already installed"
    fi
}

#### MAIN SCRIPT ####

## Checks and balances ##

# Check array length instead of just the string to handle Jamf arguments better
if (( ${#appList[@]} == 0 )); then
    echo "Application list is missing. End of line"
    exit 1
fi

if [[ -z "${actionVar}" ]]; then
    echo "Action variable not set. Stopping"
    exit 1
fi

if [[ -z "${appYear}" ]]; then
    echo "Application year not set. Stopping"
    exit 1
fi

## Action Items below ##

## Handle if all apps should be worked with
appListCount=${#appList[@]}
if [[ ${appListCount} -eq 1 ]]; then
    ## Zsh arrays are 1-indexed (unlike Bash which is 0-indexed)
    if [[ "${appList[1]}" == "all" ]]; then
        # If app list is set to just word all, fill in all apps here
        appList=("acrobat" "aftereffects" "animate" "audition" "bridge" "character" "dimension" "dreamweaver" "illustrator" "incopy" "indesign" "lightroomclassic" "mediaencoder" "photoshop" "premierepro" "premiererush")
    fi
fi

## Determine what is in variable 4
case ${actionVar} in
    "Uninstall")
        for i in "${appList[@]}"; do
            appSelector "${i}"
            appUninstall
        done
        ;;
    "Install")
        for i in "${appList[@]}"; do
            appSelector "${i}"
            appInstall
        done
        ;;
    *)
        echo "End of line"
        exit 1
        ;;
esac

### End of line ###
exit 0
