#!/bin/bash
# Author: Robert Henderson
# Date: 03-20-2026
#
## Adobe Control Script version 3.0
##

## Updated handling to compute the base version. Using adobeuninstaller --list output to get this value.

## Description:
#   Script will handle uninstalling Adobe Applications and also reinstalling based on what is "called".
#   Control will be handle from JAMF Pro using scripti variables.
## Variable 4: Action variable (i.e. Uninstall or Install)
## Variable 5: Year Version (i.e. 2024 or 2025 etc..)
## Variable 6: All or Specific Suites (i.e. Photo, Video, Design, All)

#### Variables ####
actionVar="${4}"
appYear="${5}"
appList=($6 $7 $8 $9 ${10} ${11})

appPath=""      # Holds path of app we are working on
appSAPcode=""   # Holds Adobe SAP Code for application  
appEventID=""   # Holds event ID for specific app
appMajorVer=""  # Holds major version with correct number of minor digits
appBaseVersion="" # Holds base version for app selected

#### FUNCTIONS ####

appSelector() {
    local appSelected="${1}"

    case ${appSelected} in
        "acrobat")
            echo "App choosen: acrobat"
            appPath="/Applications/Adobe Acrobat DC/Adobe Acrobat.app"
            appSAPcode="APRO"
            appEventID="rit_adobeacrobatsdl"
            ;;
        "aftereffects")
            echo "App choosen: after effects"
            appPath="/Applications/Adobe After Effects ${appYear}/Adobe After Effects ${appYear}.app"
            appSAPcode="AEFT"
            appEventID="rit_adobeaftereffectssdl"
            ;;
        "animate")
            echo "App choosen: animate"
            appPath="/Applications/Adobe Animate 2024/Adobe Animate 2024.app"
            appSAPcode="FLPR"
            appEventID="rit_adobeanimatesdl"
            ;;    
        "audition")
            echo "App choosen: audition"
            appPath="/Applications/Adobe Audition ${appYear}/Adobe Audition ${appYear}.app"
            appSAPcode="AUDT"
            appEventID="rit_adobeauditionsdl"
            ;;
        "bridge")
            echo "App choosen: bridge"
            appPath="/Applications/Adobe Bridge ${appYear}/Adobe Bridge ${appYear}.app"
            appSAPcode="KBRG"
            appEventID="rit_adobebridgesdl"
            ;;
        "character")
            echo "App choosen: character"
            appPath="/Applications/Adobe Character Animator ${appYear}/Adobe Character Animator ${appYear}.app"
            appSAPcode="CHAR"
            appEventID="rit_adobecharacteranimator"
            ;;
        "dimension")
            echo "App choosen: dimension"
            appPath="/Applications/Adobe Dimension/Adobe Dimension.app"
            appSAPcode="ESHR"
            appEventID="rit_adobedimension"
            ;;
        "dreamweaver")
            echo "App choosen: dreamweaver"
            appPath="/Applications/Adobe Dreamweaver 2021/Adobe Dreamweaver 2021.app"
            appSAPcode="DRWV"
            appEventID="rit_adobedreamweaversdl"
            ;;
        "illustrator")
            echo "App choosen: illustrator"
            appPath="/Applications/Adobe Illustrator ${appYear}/Adobe Illustrator.app"
            appSAPcode="ILST"
            appEventID="rit_adobeillustratorsdl"
            ;;
        "incopy")
            echo "App choosen: incopy"
            appPath="/Applications/Adobe InCopy ${appYear}/Adobe InCopy ${appYear}.app"
            appSAPcode="AICY"
            appEventID="rit_adobeincopysdl"
            ;;
        "indesign")
            echo "App choosen: indesign"
            appPath="/Applications/Adobe InDesign ${appYear}/Adobe InDesign ${appYear}.app"
            appSAPcode="IDSN"
            appEventID="rit_adobeindesignsdl"
            ;;
        "lightroomclassic")
            echo "App choosen: lightroomclassic"
            appPath="/Applications/Adobe Lightroom Classic/Adobe Lightroom Classic.app"
            appSAPcode="LTRM"
            appEventID="rit_adobelightroomclassicsdl"
            ;;
        "mediaencoder")
            echo "App choosen: media encoder"
            appPath="/Applications/Adobe Media Encoder ${appYear}/Adobe Media Encoder ${appYear}.app"
            appSAPcode="AME"
            appEventID="rit_adobemediaencoder"
            ;;
        "photoshop")
            echo "App choosen: photoshop"
            appPath="/Applications/Adobe Photoshop ${appYear}/Adobe Photoshop ${appYear}.app"
            appSAPcode="PHSP"
            appEventID="rit_adobephotoshopsdl"
            ;;
        "premierepro")
            echo "App choosen: premiere pro"
            appPath="/Applications/Adobe Premiere Pro ${appYear}/Adobe Premiere Pro ${appYear}.app"
            appSAPcode="PPRO"
            appEventID="rit_adobepremiereprosdl"
            ;;
        "premiererush")
            echo "App choosen: premiere rush"
            appPath="/Applications/Adobe Premiere Rush 2.0/Adobe Premiere Rush.app"
            appSAPcode="RUSH"
            appEventID="rit_adobepremiererushsdl"
            ;;
        *)
            echo "App selected was not found in selector."
            ;;
    esac

}

appUninstall() {
    # Check to see if the Application is still present
    if [ -d "${appPath}" ]; then
        
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
        # If you input 26.11.4, this converts it to 26.11
        MAJOR_MINOR=$(echo "$appVersion" | sed -E 's/^([0-9]+\.[0-9]+).*$/\1/')

        # Parse the variable using macOS-compatible BSD sed and a Here String (<<<) using data stored from uninstaller command
        appBaseVersion=$(sed -n -E "s/^.*[[:space:]]${TARGET_SAPCODE}[[:space:]]+([^[:space:]]+)[[:space:]]+${MAJOR_MINOR}(\.[^[:space:]]+)?[[:space:]]*$/\1/p" <<< "${adobeUninstallerInfo}")

         # Output base version found for logging in JAMF
        echo "Base Version: ${appBaseVersion}"

        # Make sure we have data in both variables
        if [[ -n "${appSAPcode}" && -n "${appBaseVersion}" ]] ; then

            # Run the Adobe uninstall command
            /usr/local/adobe/AdobeUninstaller --products="${appSAPcode}"#"${appBaseVersion}"

            # Verify app is removed
            if [ -d "${appPath}" ]; then
                # Uninstall failed
                echo "Application is still present. Uninstall failed"
            else
                echo "Uninstall successful"
            fi
        else
            # Stop here, we do not have both variables. Something happened.
            echo "Missing variable. SAP Code: ${appSAPcode} or Base Version: ${appBaseVersion}"
            exit 1
        fi
    else
        # Echo not present
        echo "Product ${appPath} was not present"
    fi

}

appInstall() {
    # Check to see if the Application is still present
    if [ ! -d "${appPath}" ]; then
        
        echo "Event ID: ${appEventID}"
    	echo "Product Path: ${appPath}"
        echo "Installing..."
        echo ""
       
       	# Application is missing, let's reinstall
        /usr/local/bin/jamf policy -event ${appEventID}

        # Recheck path for successful install
         if [ ! -d "${appPath}" ]; then
            echo "Application failed to install"
        else
            echo "Application installed successfully"
        fi
    else
        # Application path already present
        echo "Application ${appChoosen} already installed"
    fi
}

#### MAIN SCRIPT ####

## Checks and balances ##

## Stop here if no applications listed
if [ -z "${appList}" ]; then
    echo "Application list is missing. End of line"
    exit 1
fi

## Stop here if no action defined
if [ -z "${actionVar}" ]; then
    echo "Action variable not set. Stopping"
    exit 1
fi

## Stop here if no year defined
if [ -z "${appYear}" ]; then
    echo "Application year not set. Stopping"
    exit 1
fi

## Action Items below ##

## Handle if all apps should be worked with
# Get app list item count
appListCount=${#appList[@]}
if [ "${appListCount}" == 1 ]; then
    ## See if count for app list is 1 and if so see if set to all
    if [ "${appList[0]}" == "all" ]; then
        # If app list is set to just word all, fill in all apps here
        appList=("acrobat" "aftereffects" "animate" "audition" "bridge" "character" "dimension" "dreamweaver" "illustrator" "incopy" "indesign" "lightroomclassic" "mediaencoder" "photoshop" "premierepro" "premiererush")
    fi
fi


## Determine what is in variable 4

case ${actionVar} in
    "Uninstall")
        for i in "${appList[@]}"
        do
            appSelector "${i}"
            appUninstall
        done
        ;;
    "Install")
        for i in "${appList[@]}"
        do
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
