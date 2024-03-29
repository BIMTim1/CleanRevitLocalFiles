#get user information
$user_file = $env:USERNAME
Write-Host "You are logged on as: $user_file"
$pathMain = "C:\Users\$user_file\AppData\Local\Autodesk\Revit"
$pathTemp = "C:\Users\$user_file\AppData\Local\Temp"
$revFolders = Get-ChildItem -Path "$pathMain"

#get Revit process in background
$rev = "Revit"
$rev_process = Get-Process -Name $rev -ErrorAction SilentlyContinue
#check if Revit process is running
if ($rev_process) {
	$userInput = Read-Host "A Revit process is still running.`nType Y to close Revit. Type N to cancel tool."
	if ("Y" -eq $userInput) {
		$rev_process.CloseMainWindow()
		#pause while Revit closes
		Start-Sleep -Seconds 10
		
		foreach ($folder in $revFolders)
		{
			$fName = $folder.Name
			if($fName.Contains("Revit"))
			{
				Get-ChildItem -Path "$pathMain\$fName\CollaborationCache" -Recurse | ForEach-Object {Remove-Item -Recurse -Path $_.FullName}
				Get-ChildItem -Path "$pathMain\$fName\Journals" -Recurse | ForEach-Object {Remove-Item -Recurse -Path $_.FullName}
			}
		}

		Get-ChildItem -Path $pathTemp -Recurse | ForEach-Object {Remove-Item -Recurse -Path $_.FullName -ErrorAction SilentlyContinue}

		Get-ChildItem -Path "C:\`$Recycle.Bin" -Force | Remove-Item -Recurse -ErrorAction SilentlyContinue

		Write-Host "All local Revit content has been removed from $user_file."

		Read-Host -Prompt "Press Enter to continue"
	}
}
else {
	foreach ($folder in $revFolders) {
		$fName = $folder.Name
		if($fName.Contains("Revit")) {
			Get-ChildItem -Path "$pathMain\$fName\CollaborationCache" -Recurse | ForEach-Object {Remove-Item -Recurse -Path $_.FullName}
			Get-ChildItem -Path "$pathMain\$fName\Journals" -Recurse | ForEach-Object {Remove-Item -Recurse -Path $_.FullName}
		}
	}

	Get-ChildItem -Path $pathTemp -Recurse | ForEach-Object {Remove-Item -Recurse -Path $_.FullName -ErrorAction SilentlyContinue}

	Get-ChildItem -Path "C:\`$Recycle.Bin" -Force | Remove-Item -Recurse -ErrorAction SilentlyContinue

	Write-Host "All local Revit content has been removed from $user_file."

	Read-Host -Prompt "Press Enter to continue"
}
