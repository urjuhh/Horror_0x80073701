# Horror_0x80073701
Fixing 0x80073701 with an axe - if you swing it, you are responsible for results... Verify, do not trust. 

BACKUP, BACKUP, BACKUP.

C:\Windows\Logs\CBS\CBS.log tells you, whats wrong. For example:
2025-08-29 09:45:14, Info CBS Failed to pin deployment while resolving Update: Microsoft-Windows-Bitlocker-Network-Unlock-Package~31bf3856ad364e35~amd64~~10.0.20348.2652.BitLocker-NetworkUnlock from file: (null) [HRESULT = 0x80073701 - ERROR_SXS_ASSEMBLY_MISSING]
Thats a reference to already superseded component, that wasn't cleaned up properly. Registry entry exists, related file(s) deleted. Cleanup process was terminated or something, hell if i know. Sadly, you get only one package per update try...

HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\
Each component has entry for each version, some "components" are collections/depend on other components.
```
Microsoft-Windows-Bitlocker-Network-Unlock-Package~31bf3856ad364e35~amd64~~10.0.20348.2652
Microsoft-Windows-Bitlocker-Network-Unlock-Package~31bf3856ad364e35~amd64~~10.0.20348.3451
```
Get rid of the old, try to update... get new borked component...

So after deleting many keys manually, a pattern emerged. So i had a heart to heart with copilot and came up with a dirty script that looked for superseded component entries in registry.
That's the superseded_list.ps1 that creates two text files for keys and values to be removed.
And superseded_delete.ps1 then deletes the registry keys and values.

