# SharepointTools

--- Import Terms and Synonyms ---
Powershell script that imports Terms and Other Labels (Synonyms) from a CSV file to Sharepoint Online. Try the 'No Delay' version of the script first, if there are errors try the delayed version as it works more reliably but slower.<b> CSV formatting is shown in the GUI </b>- you must follow this formatting exactly for the script to work. You can have an unlimited amount of L1Ts and Other Labels. <b>RUN IN ISE </b>

--- Update List Item ---
Powershell script that adds 1 minute to the modified date of each item in a list. This is useful for when you want to trigger a workflow on each list item when the workflow is set to 'Run when list item is changed'. Ensure that the workflow doesn't spam emails when the script runs by temporarly disabling any automated email alerts.

--- Automatically associate all sites with a single hub site ---
Powershell script that iterates through each site, removes any existing hub site association and then adds the association defined in the parameters.

--- Set Welcome Page ---
Powershell script that sets Welcome/Landing page for when the root URL is entered (e.g what shows when you type http://<tenant>.sharepoint.com/ into URL bar)
  
--- Fully remove all deleted sites ---
Powershell script that fully (and permenantly) deletes previously deleted sites so the URL can be used again on new sites. There is no confirmation when this is ran and it wil delete ALL previously deleted sites. No active sites will be deleted by this script. Once this script is ran you will not be able to recover any sites that were deleted prior to using this script.

--- Add user as owner of all groups ---
Adds users (such as admins) to the Owners list off all Office 365 groups. Useful for giving admins control of modern experience team sites. Change [user1] and [user2] in the script.

--- List all checked out files and check in files checked out to a specific user ---
Powershell script that iterates through each site, subsite, and library in a site collection and looks for all checked out files. A report will be created that contains information about checked out files across the whole site collection. The script also has the capability to check in files from a specific user. If you do not want this functionality, add some nonsense or an unused user claims to the variable

--- Restore Items From Recycle Bin ---
Powershell script that iterates through the recycle bin looking for items that match a specific criteria (in this example, 'deleted by' email address) and restores the item.
