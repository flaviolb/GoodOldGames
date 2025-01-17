MEmu := "AppleWin"
MEmuV := "v1.24.0.0"
MURL := ["http://applewin.berlios.de/"]
MAuthor := ["faahrev","wahoobrian","brolly"]
MVersion := "1.6.2"
MCRC := "96BE44D3"
iCRC := "BB9B27F9"
MID := "635403945717531776"
MSystem := ["Apple II"]
;----------------------------------------------------------------------------
; Notes:
; v1.24.0.0 or greater is required as it adds a CLI switch to prevent the printscreen key error from appearing
; No bezel support (yet)
;
; Settings in RocketLauncherUI:
; - Fullscreen
; per ROM:
; - Option to choose the type of AppleII
; - Option to load the second disc in floppy station 1 at boot (first disc in station 0 is default)
; - Option to configure in which floppy station discs should be changed (0 or 1)
;----------------------------------------------------------------------------
StartModule()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)					; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle(,"APPLE2FRAME"))	; instantiate primary emulator window object
emuOpenWindow := new Window(new WindowTitle(,"#32770"))
emuSelectWindow := new Window(new WindowTitle("Select Disk Image For Drive 1","#32770"))

eamonProDOSBoot   := "Eamon ProDOS Boot Disk (USA).dsk"
eamonAdv001ProDOS := "Eamon 001 - Main Hall & Beginners Cave (USA) (Unl) (ProDOS).dsk"
eamonAdv001DOS33  := "Eamon 001 - Main Hall & Beginners Cave (USA) (Unl) (DOS3.3).dsk"

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
bezelRightOffset := moduleIni.Read("Settings", "bezelRightOffset","50",,1)
DiskSwapKey := moduleIni.Read("Settings", "DiskSwapKey","F5",,1)
RotateMethod := moduleIni.Read("Settings", "RotateMethod",rotateMethod,,1)
DualDiskLoad := moduleIni.Read(romName, "DualDiskLoad","true",,1)
MultipleDiskSlot := moduleIni.Read(romName, "MultipleDiskSlot","0",,1)
SystemType := moduleIni.Read(romName, "SystemType","17",,1)
VideoMode := moduleIni.Read(romName, "VideoMode","1",,1)
Command := moduleIni.Read(romName, "Command",,,1)
SendCommandDelay := moduleIni.Read(romName, "SendCommandDelay", "2000",,1)
RotateDisplay := moduleIni.Read(romName, "RotateDisplay", "0",,1)
ReadOnlyDisk := moduleIni.Read(romName, "ReadOnlyDisk", "false",,1)
Drive2Disk := moduleIni.Read(romName, "Drive2Disk",,,1)

If (ReadOnlyDisk = "true") {
	;check file attribute of rom to make sure it is read only, error out If it isn't
	FileGetAttrib, attributes, %romPath%\%romName%%romExtension%
	If !StringUtils.Contains(attributes,"R")
		ScriptError("The file " . romPath . "\" . romName .  romExtension " must be read-only.  Please change windows attributes to make file read-only.")
}

If !StringUtils.Contains(SystemType,"0|1|16|17")
	ScriptError("The system type " . SystemType . " is not one of the known supported systems for this module: " . moduleName . ". Please use the option to configure the type of system needed (Default is Enhanced AppleII/e) through RocketLauncherUI.")
Else
	Registry.Write("REG_SZ", "HKCU", "Software\AppleWin\CurrentVersion\Configuration", "Apple2 Type", SystemType)

If !StringUtils.Contains(VideoMode,"1|4|5|6")
	ScriptError("The video mode " . VideoMode . " is not a valid for this module: " . moduleName . ". Please use the option to configure the type of system needed (Default is Enhanced AppleII/e) through RocketLauncherUI.")
Else
	Registry.Write("REG_SZ", "HKCU", "Software\AppleWin\CurrentVersion\Configuration", "Video Emulation", VideoMode)
	
; Ejecting discs
Registry.Write("REG_SZ", "HKCU", "Software\AppleWin\CurrentVersion\Preferences", "Last Disk Image 1", "")
Registry.Write("REG_SZ", "HKCU", "Software\AppleWin\CurrentVersion\Preferences", "Last Disk Image 2", "")

DiskSwapKey := xHotKeyVarEdit(DiskSwapKey,"DiskSwapKey","~","Add")
xHotKeywrapper(DiskSwapKey,"DiskSwap")

hideEmuObj := Object(emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

If (RotateDisplay > 0)
	Rotate(rotateMethod, RotateDisplay)

BezelStart("FixResMode")
fullscreen := If fullscreen = "true" ? " -f" : ""
params := " -noreg -no-printscreen-dlg"

HideAppStart(hideEmuObj,hideEmu)

If StringUtils.Contains(romName,"Eamon") {
	;-----------------------------------------------------------------------------------------------------------------
	;Special handling required for booting Eamon Adventure games.
	;Most Eamon Adventures use the DOS3.3 formatted disks, but some use ProDOS.  The booting of the machine in preparation
	;for loading each differs.  ProDOS versions require the emulator to boot standalone, then load and start the appropriate	
	;Eamon disks.  The DOS3.3 formatted adventure disks can be booted using the Eamon Master Diskette (Eamon #001).
	;-----------------------------------------------------------------------------------------------------------------
	EamonAdventureDOS := moduleIni.Read(romName, "EamonAdventureDOS","1",,1)
	
	If StringUtils.Contains(romName,"SoftDisk") {
		;-----------------------------------------------------------------------------------------------------------------
		;Eamon SoftDisk Booting.
		;	1.  Boot using generic ProDOS diskette in Drive 1.
		;	2.  Put initial adventure disk in Drive 2.
		;   3.  Once machine booted, swaps disks and run startup command
		;-----------------------------------------------------------------------------------------------------------------
		disc1 := " -d1 """ . romPath . "\" . eamonProDOSBoot . """"
		disc2 := " -d2 """ . romPath . "\" . romName . romExtension . """"
		primaryExe.Run(fullscreen . params . disc1 . disc2, "UseErrorLevel")
		TimerUtils.Sleep(2000)	; allow time for emulator to boot ProDOS
		emuPrimaryWindow.Wait()
		emuPrimaryWindow.WaitActive()

		KeyUtils.SendCommand(Command, SendCommandDelay)
	} Else If (EamonAdventureDOS = "ProDOS") {
		;-----------------------------------------------------------------------------------------------------------------
		;Eamon ProDOS Booting.
		;	1.  Boot using generic ProDOS diskette in Drive 1.
		;	2.  Put initial adventure disk in Drive 2.
		;   3.  Once machine booted, replace ProDOS diskette in Drive one with the ProDOS Eamon Master Disk (Eamon #001).
		;   4.  Issue "RUN STARTUP" command to start Adventure.
		;   5.  When prompted to load adventure of choice, using the swap disk key will place the adventure disk in Drive 1.
		;-----------------------------------------------------------------------------------------------------------------

		disc1 := " -d1 """ . romPath . "\" . eamonProDOSBoot . """"
		disc2 := " -d2 """ . romPath . "\" . romName . romExtension . """"
		primaryExe.Run(fullscreen . params . disc1 . disc2, "UseErrorLevel")

		TimerUtils.Sleep(2000)	; allow time for emulator to boot ProDOS
		emuPrimaryWindow.Wait()
		emuPrimaryWindow.WaitActive()
		KeyUtils.Send("F3")	; Open Disk Select Dialog
	
		emuSelectWindow.OpenROM(romPath . "\" . eamonAdv001ProDOS)
		emuPrimaryWindow.Wait()
		emuPrimaryWindow.WaitActive()

		KeyUtils.SendCommand(Command, SendCommandDelay)
	} Else {
		;-----------------------------------------------------------------------------------------------------------------
		;Eamon DOS3.3 Booting.
		;	1.  Boot using DOS3.3 Eamon Master Disk (Eamon #001) in Drive 1.
		;	2.  Put initial adventure disk in Drive 2.
		;   3.  When prompted to load adventure of choice, using the swap disk key will place the adventure disk in Drive 1.
		;-----------------------------------------------------------------------------------------------------------------
		disc1 := " -d1 """ . romPath . "\" . eamonAdv001DOS33 . """"
		Eamon001Rom := StringUtils.TrimRight(eamonAdv001DOS33,4)		; Remove extension from literal value
		If (romName != Eamon001Rom)
			disc2 := " -d2 """ . romPath . "\" . romName . romExtension . """"
		Else
			disc2 := ""
		primaryExe.Run(fullscreen . params . disc1 . disc2, "UseErrorLevel")
		emuPrimaryWindow.Wait()
		emuPrimaryWindow.WaitActive()
	}	
} Else {
	;-----------------------------------------------------------------------------------------------------------------
	;All other games
	;-----------------------------------------------------------------------------------------------------------------
	disc1 := " -d1 """ . romPath . "\" . romName . romExtension . """"

	; Opening second disc If game exists of two discs only and DualDiskLoad is true
	TimerUtils.Sleep(50)	;	Needs to stay in for romTable.MaxIndex() to work.
	If (Drive2Disk != "")
		disc2 := " -d2 """ . romTable[Drive2Disk,1] . """"
	Else If (DualDiskLoad = "true" And romTable.MaxIndex() = 2)
		disc2 := " -d2 """ . romTable[2,1] . """"
	
	primaryExe.Run(fullscreen . params . disc1 . disc2, "UseErrorLevel")
	emuPrimaryWindow.Wait()
	emuPrimaryWindow.WaitActive()

	KeyUtils.SendCommand(Command, SendCommandDelay)
}

BezelDraw()
HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()
primaryExe.Process("WaitClose")

; Switching orientation back to normal
If (RotateDisplay > 0)
	Rotate(rotateMethod, 0)

7zCleanUp()
BezelExit()
FadeOutExit()
ExitModule()


DiskSwap:
	KeyUtils.Send("F5")
Return

HaltEmu:
	XHotKeywrapper(DiskSwapKey,"DiskSwap","OFF")
Return

MultiGame:
	KeyUtils.Send(If MultipleDiskSlot = "1" ? "F4" : "F3")
	emuOpenWindow.OpenROM(selectedRom)
	emuPrimaryWindow.Activate()
	KeyUtils.Send("{Enter}")
Return

RestoreEmu:
	XHotKeywrapper(DiskSwapKey,"DiskSwap","ON")
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
Return
