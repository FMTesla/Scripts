<#

		Description: Script to pull a list of PCs from a file and
        add a specified Local Admin account to it.

#>

$Username = "(LocalAdmin)"
$Password = "(Password)"
$Computers = Get-Content C:\Temp\Computers.txt
Foreach ($computer in $Computers) {
   $users = $null
   $computerObj = [ADSI]"WinNT://$computer"
   Try {
      $users = $computerObj.psbase.children | select -expand name  
      if ($users -like $username) {
         Write-Host "$username already exists"
      } Else {
         $user_obj = $computerObj.Create("user", "$username")
         $user_obj.SetPassword($password)
         $user_obj.SetInfo()
         $user_obj.Put("description", "$username")
         $user_obj.SetInfo()
         $user_obj.psbase.invokeset("AccountDisabled", "False")
         $user_obj.SetInfo()
         $user_obj.UserFlags = 65536 # PASSWD_NEVER_EXPIRE
         $User_obj.SetInfo()
         $users = $computerObj.psbase.children | select -expand name
         if ($users -like $username) {
            Write-Host "$username has been created on $computer"
         } Else {
            Write-Host "$username has not been created on $computer"
         }
      }
   } Catch {
      Write-Host "Error creating $username on $($computerObj.path):  $($Error[0].Exception.Message)"
   }

   If ($users -like $username) {
       Try {
            $group = [ADSI]"WinNT://$computer/Administrators,group" 
            $group.psbase.Invoke("Add",([ADSI]"WinNT://$computer/$username,user").path)
            Write-Host "$username added to Local Admins on $computer"
        }
        Catch {
            Write-Host "Error creating $username on $($computerObj.path):  $($Error[0].Exception.Message)"
        }
   }
}