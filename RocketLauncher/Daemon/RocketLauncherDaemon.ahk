;-----------------------------------------------------------------------------------------------------------------------------------------
; RocketLauncher Daemon V1.0.0
; By brolly
;
; Command Line Arguments accepted by the daemon are:
; 1 --> Front-End Start
; 2 --> Front-End Stop
; 3 "Game_Name" "System_Name" --> Game Start
; 4 --> Game Stop
; 7 "System_Name" --> Entering System
; 8 --> Back to Main Menu/System Change
; 9 "Game_Name" --> Selecting Game
; 90 "System_Name" --> Selecting Name (This command doesn't exist in LEDBlinky!)
;
; Configure the path to RocketLauncher.exe in RocketLauncherDaemon.ini and also LedWiz.exe if you need it. Relative paths are accepted
; If you have LedBlinky.exe configured all command line arguments received by the daemon will also be forwarded to LedBlinky.exe
;-----------------------------------------------------------------------------------------------------------------------------------------

#SingleInstance Off
#Persistent
#NoEnv
;#NoTrayIcon

SetWorkingDir % A_ScriptDir

SetTitleMatchMode 2	; required for PostMessage to work
DetectHiddenWindows On	; required for PostMessage to work

RocketLauncherDaemonIni = %A_ScriptDir%\RocketLauncherDaemon.ini

NumberOfParameters = 0
Loop, %0%
{
	NumberOfParameters := A_Index
	If (A_Index = 1)
	{
		mode := %A_Index%
		Params .= %A_Index% . A_Space
	}
	Else If (A_Index = 2)
	{
		param1 := %A_Index%
		Params .= """" . %A_Index% . """" . A_Space
	}
	Else
		Params .= """" . %A_Index% . """" . A_Space
}
Params = %Params% ; remove whitespace

If (NumberOfParameters < 1)
	ExitApp

propagateToLedBlinky := "true"

If (mode = "1") ;Frontend Started
{
	;Test if process is already started and if so exit
	WinGet, InstanceID, List, %A_ScriptName%
	Loop %InstanceID%
	{
		If A_Index <> 1 ;RocketLauncher Daemon is already running so don't launch it again
			ExitApp
	}

	;Read ini settings
	IniRead, RocketLauncherPath, %RocketLauncherDaemonIni%, Settings, RocketLauncher_Path, ..\RocketLauncher.exe

	If (!RocketLauncherPath)
	{
		MsgBox, You need to set the path to RocketLauncher
		ExitApp
	}
	RocketLauncherPath := GetFullName(RocketLauncherPath)
	IfNotExist, %RocketLauncherPath%
	{
		MsgBox, The file %RocketLauncherPath% doesn't exist
		ExitApp
	}
	Else
		SplitPath, RocketLauncherPath, RocketLauncherExe, RocketLauncherFolder

	IniRead, PauseKey, %RocketLauncherFolder%\Settings\RocketLauncher.ini, Pause, Pause_Key

	PauseKey := xHotKeyVarEdit(PauseKey,"PauseKey","~","Add")
	xHotKeywrapper(PauseKey,"LaunchPause")

	CurrentSystem := ""
	CurrentGame := ""
	OnMessage(0x4a, "ReceivedMessage")
}
Else If (mode = "2") ;Exiting Frontend
{
	NotifyDaemon(2)
}
Else If (mode = "7") ;Entering System
{
	If (NumberOfParameters > 1)
	{
		NotifyDaemon(7,param1)
	}
}
Else If (mode = "9") ;Selecting Game
{
	If (NumberOfParameters > 1)
	{
		NotifyDaemon(9,param1)
	}
}
Else If (mode = "90") ;Selecting System (Fake code, doesn't exist in LEDBlinky)
{
	propagateToLedBlinky := "false"
	If (NumberOfParameters > 1)
	{
		NotifyDaemon(90,param1)
	}
}
Else If (mode = "8") ;Back to Main Menu
{
	NotifyDaemon(8)
}
Else If (mode = "3")
{
	;Launching Game
}
;mode=4 (game stop) is ignored because HyperSpin keeps sending this over and over everytime it's window is active and we don't want to be sending messages on every single event

;Dispatch command line to LedBlinky as well if needed
IniRead, LedBlinky_Enable, %RocketLauncherDaemonIni%, Settings, LedBlinky_Enable
If (LedBlinky_Enable = "true" && propagateToLedBlinky = "true")
{
	IniRead, LedBlinkyPath, %RocketLauncherDaemonIni%, Settings, LedBlinky_Path
	If (LedBlinkyPath)
	{
		LedBlinkyPath := GetFullName(LedBlinkyPath)
		IfNotExist, %LedBlinkyPath%
			LedBlinkyPath := ""
		Else
		{
			SplitPath, LedBlinkyPath, LedBlinkyExe, LedBlinkyFolder
			Run, %LedBlinkyExe% %Params%, %LedBlinkyFolder%
		}
	}
}

If (mode != "1")
	ExitApp

MainLoop:
	While (!Exited) 
	{
		;ToolTip, %A_Index% in test Loop
		Sleep, 100	; so we don't eat up cpu cycles
	}
Return

NotifyDaemon(wparam="",lparam="")
{
	;0x4a is WM_COPYDATA, this message MUST be used in order to send Strings instead of Numbers

	VarSetCapacity(CopyDataStruct, 12, 0)  ; Set up the structure's memory area.
    ; First set the structure's cbData member to the size of the string, including its zero terminator:
    NumPut(StrLen(lparam) + 1, CopyDataStruct, 4)  ; OS requires that this be done.
    NumPut(&lparam, CopyDataStruct, 8)  ; Set lpData to point to the string itself.

	WinGet, InstanceID, List, %A_ScriptName%
	Loop %InstanceID%
	{
		If A_Index <> 1
			SendMessage, 0x4a, %wparam%, &CopyDataStruct, , % "ahk_id " InstanceID%A_Index%
	}
}

ReceivedMessage(wParam, lParam)
{
    StringAddress := NumGet(lParam + 8)  ; lParam+8 is the address of CopyDataStruct's lpData member.
    StringLength := DllCall("lstrlen", UInt, StringAddress)
    If StringLength <= 0
	{
        ;MsgBox, %A_ScriptName%`nA blank string was received or there was an error.
	}
    Else
    {
        VarSetCapacity(CopyOfData, StringLength)
        DllCall("lstrcpy", "str", CopyOfData, "uint", StringAddress)  ; Copy the string out of the structure.
        ;MsgBox, %A_ScriptName%`nReceived the following string:`n%CopyOfData%
    }

	If (wParam = 2)
	{
		ExitFrontend()
	}
	Else If (wParam = 7 And CopyOfData)
	{
		EnteredSystem(CopyOfData)
	}
	Else If (wParam = 8)
	{
		ExitedToMainMenu()
	}
	Else If (wParam = 9 And CopyOfData)
	{
		SelectingGame(CopyOfData)
	}
	Else If (wParam = 90 And CopyOfData)
	{
		SelectingSystem(CopyOfData)
	}
	return true  ; Returning 1 (true) is the traditional way to acknowledge this message.
}

ExitFrontend()
{
	Global CurrentSystem, CurrentGame

	;MsgBox, Exiting Frontend
	CurrentSystem := ""
	CurrentGame := ""
	Exited := 1
	ExitApp
}
EnteredSystem(systemName)
{
	Global CurrentSystem, CurrentGame

	CurrentSystem := systemName
	;MsgBox, Entered System %CurrentSystem%
}
SelectingSystem(systemName)
{
	Global CurrentSystem, CurrentGame

	CurrentSystem := systemName
	CurrentGame := ""
	;MsgBox, Selected Game %CurrentSystem% -  %CurrentGame%
}
SelectingGame(gameName)
{
	Global CurrentSystem, CurrentGame

	CurrentGame := gameName
	;MsgBox, Selected Game %CurrentSystem% -  %CurrentGame%
}
ExitedToMainMenu()
{
	Global CurrentSystem, CurrentGame

	;MsgBox, Exiting Main Menu
	CurrentSystem := ""
	CurrentGame := ""
}

LaunchPause:
	Global CurrentSystem, CurrentGame, RocketLauncherFolder, RocketLauncherExe

	Process, Exist, %RocketLauncherExe%
	RocketLauncherPID := ErrorLevel
	If !RocketLauncherPID ;Only Start if RocketLauncher isn't running already
	{
		If (CurrentSystem And CurrentGame)
			Run, %RocketLauncherExe% "%CurrentSystem%" "%CurrentGame%" -m pause, %RocketLauncherFolder%
		;Else
			;MsgBox, No Game is Selected.
	}
Return

; This function converts a relative path to absolute
GetFullName( fn ) 
{
	; http://msdn.microsoft.com/en-us/library/Aa364963
	Static buf
	i := VarSetCapacity(buf, 512)
	DllCall("GetFullPathNameA", "str", fn, "uint", 512, "str", buf, "str*", 0)
	Return buf
}

#Include XHotkey.ahk
