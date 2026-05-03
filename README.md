# JAMF - Adobe Control

## Summary: 
  Script handles uninstalling/installing Adobe Applications. If application is already installed moves forward onto the next etc.

## Requirments:
  * Policies setup for each Adobe application and a unique event ID that is scoped to all computers
  * MDM needs to support individual calls (events) for each policy. This is based on using JAMF
  * Adobe's Uninstaller executable which provides key information on installed applications and is used for removals
  ** URL: https://helpx.adobe.com/creative-cloud/apps/manage-apps/creative-cloud-desktop-app/uninstall-creative-cloud-desktop-app.html
  * Run as zsh


