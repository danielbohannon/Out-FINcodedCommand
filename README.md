Out-FINcodedCommand v1.0
===============

![Out-FINcodedCommand Screenshot 1](https://github.com/danielbohannon/danielbohannon.github.io/blob/master/Out-FINcodedCommand%20Screenshot%201.png)

Introduction
------------
Out-FINcodedCommand is a PowerShell v2.0+ compatible PowerShell POC script designed 
to highlight several obfuscation techniques used by FIN threat actors. The primary
obfuscation techniques highlighted in this tool are:
1) cmd.exe's variable char/string replacement functionality
2) cmd.exe and powershell.exe's StdIn command invocation capabilities
3) environment variable substring functionality to obfuscate "cmd" and "powershell"

Installation
------------
The source code Out-FINcodedCommand is hosted at Github, and you may
download, fork and review it from this repository
(https://github.com/danielbohannon/Out-FINcodedCommand). Please report issues
or feature requests through Github's bug tracker associated with this project.
(Not really -- this is a simple POC, not a Cadillac with a warranty.)

To install:

	Invoke-Expression (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/danielbohannon/Out-FINcodedCommand/master/Out-FINcodedCommand.ps1')

Usage
-----
This is a simple POC so `Out-FINcodedCommand` is the only function that currently
exists. Use `Get-Help Out-FINcodedCommand` to see available parameters.

You can approach this tool's obfuscation capabilities from the perspective of
"blending in" a command to appear like a less conspicious "netstat -ano" or
"ping 8.8.8.8" (like in the example screenshot above).

You can also take another approach to simply cram in as many confusing char/string
substitutions as possible to make our jobs as Defenders more challenging.

![Out-FINcodedCommand Screenshot 2](https://github.com/danielbohannon/danielbohannon.github.io/blob/master/Out-FINcodedCommand%20Screenshot%202.png)

Lastly, there is not support for CLI. Why? I'm too busy working on fun detection
projects to spend on this. This tool is meant for education and not weaponization.

DISCLAIMER: Do not use this tool for evil. Please use this tool and its output
responsibly and only on systems on which you have explicit permission to access
and run obfuscated code.

License
-------
Out-FINcodedCommand is released under the Apache 2.0 license.

Release Notes
-------------
v1.0 - 2017-07-02