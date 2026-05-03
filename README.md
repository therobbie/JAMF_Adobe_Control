# JAMF - Adobe Control

## Summary: 
  Script handles uninstalling/installing Adobe Applications. If application is already installed moves forward onto the next etc.

## Requirements:
  * Policies setup for each Adobe application and a unique event ID that is scoped to all computers
  * MDM needs to support individual calls (events) for each policy. This is based on using JAMF
  * Adobe's Uninstaller executable which provides key information on installed applications and is used for removals
  * * https://helpx.adobe.com/creative-cloud/apps/manage-apps/creative-cloud-desktop-app/uninstall-creative-cloud-desktop-app.html
  * Run as zsh

## Setup

With-In JAMF create a new script and paste in script as set. You can update the event IDs to match your environment. Under Options you will set the following parameters.
* Parameter 4: Action: Install or Uninstall
* Parameter 5: Application Year (i.e. 2024 or 2025)
* Parameter 6: Application list ( i.e. "acrobat" "aftereffects" "animate" "audition" "bridge" "character" "dimension" "dreamweaver" "illustrator" "incopy" "indesign" "lightroomclassic" "mediaencoder" "photoshop" "premierepro" "premiererush" or "all")
* Parameter 7 through 11: Application list ( see parameter 6 )

Save the new script then head over to policies.

Create a new policy, set the name etc and then add the script you just created.
Set the options via the parameters for the script to function and click save. Test your deployment.
