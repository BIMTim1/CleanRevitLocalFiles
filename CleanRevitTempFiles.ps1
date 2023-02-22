#get user information
$user_file = $env:USERNAME
Write-Host "You are logged on as: $user_file"
$pathMain = "C:\Users\$user_file\AppData\Local\Autodesk\Revit"
$pathTemp = "C:\Users\$user_file\AppData\Local\Temp"
$revFolders = Get-ChildItem -Path "$pathMain"

#create function to delete local Revit content
function Remove-RevitLocals($RevitFolders, $MainPath, $TempFilePath, $UserName) {
	#iterate through list of local folders
	foreach ($folder in $RevitFolders) {
		#get folder name
		$fName = $folder.Name
		if ($fName.Contains("Revit")) {
			#delete all files in the CollaborationCache folder
			Get-ChildItem -Path "$MainPath\$fName\CollaborationCache" -Recurse | ForEach-Object {Remove-Item -Recurse -Path $_.FullName}
			#delete all files in the Journals folder
			Get-ChildItem -Path "$MainPath\$fName\Journals" -Recurse | ForEach-Object {Remove-Item -Recurse -Path $_.FullName}
		}
	}

	Get-ChildItem -Path $TempFilePath -Recurse | ForEach-Object {Remove-Item -Recurse -Path $_.FullName -ErrorAction SilentlyContinue}

	Get-ChildItem -Path "C:\`$Recycle.Bin" -Force | Remove-Item -Recurse -ErrorAction SilentlyContinue
}
#get Revit process in background
$rev = "Revit"
$rev_process = Get-Process -Name $rev -ErrorAction SilentlyContinue
#check if Revit process is running
if ($rev_process) {
	$userInput = Read-Host "A Revit process is still running.`nType Y to close Revit. Type N to cancel tool."
	if ("Y" -eq $userInput) {
		#close all Revit processes if accepted by user
		$rev_process.CloseMainWindow()
		
		#pause for 10 seconds while Revit closes
		Start-Sleep -Seconds 10

		#create function to delete local Revit content after Revit has closed
		Remove-RevitLocals -RevitFolders $revFolders -MainPath $pathMain -TempFilePath $pathTemp -UserName $user_file
		#notify user function is complete
		Write-Host "All local Revit content has been removed from $UserName."
		#prompt user to close PowerShell
		Read-Host -Prompt "Press Enter to continue"
	}
}
else {
	#create function to delete local Revit content
	Remove-RevitLocals -RevitFolders $revFolders -MainPath $pathMain -TempFilePath $pathTemp -UserName $user_file
	#notify user function is complete
	Write-Host "All local Revit content has been removed from $UserName."
	#prompt user to close PowerShell
	Read-Host -Prompt "Press Enter to continue"
}
