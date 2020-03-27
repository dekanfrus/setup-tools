#Log PowerShell Commands & Output
Start-Transcript -OutputDirectory "C:\Logs\PowerShell" -NoClobber -IncludeInvocationHeader

$modulePath = [Environment]::GetEnvironmentVariable('PSModulePath')
$modulePath += ';C:\Tools\PowerShell\WindowsPowerShell\Modules'
[Environment]::SetEnvironmentVariable('PSModulePath', $modulePath)

# Ensure that Get-ChildItemColor is loaded
Import-Module Get-ChildItemColor

# Set l and ls alias to use the new Get-ChildItemColor cmdlets
Set-Alias ls Get-ChildItemColor -Option AllScope
Set-Alias l Get-ChildItemColorFormatWide -Option AllScope

# Helper function to change directory to my development workspace
# Change c:\ws to your usual workspace and everytime you type
# in cws from PowerShell it will take you directly there.
function cws { Set-Location c:\Tools }

# Helper function to set location to the User Profile directory
function cuserprofile { Set-Location ~ }
Set-Alias ~ cuserprofile -Option AllScope

# Helper function to show Unicode character
function U
{
    param
    (
        [int] $Code
    )
 
    if ((0 -le $Code) -and ($Code -le 0xFFFF))
    {
        return [char] $Code
    }
 
    if ((0x10000 -le $Code) -and ($Code -le 0x10FFFF))
    {
        return [char]::ConvertFromUtf32($Code)
    }
 
    throw "Invalid character code $Code"
}

# Ensure posh-git is loaded
Import-Module -Name posh-git

# Start SshAgent if not already
# Need this if you are using github as your remote git repository
if (! (ps | ? { $_.Name -eq 'ssh-agent'})) {
    Start-SshAgent
}

# Ensure oh-my-posh is loaded
Import-Module -Name oh-my-posh

# Default the prompt to sorin oh-my-posh theme
Set-Theme Sorin