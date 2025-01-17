MEmu := "Fusion"
MEmuV := "v3.64"
MURL := ["http://www.eidolons-inn.net/tiki-index.php?page=Kega","http://www.carpeludum.com/kega-fusion/"]
MAuthor := ["djvj","bleasby"]
MVersion := "2.1.4"
MCRC := "9403178D"
iCRC := "C6C5F2F5"
MID := "635038268893895568"
MSystem := ["Othello Multivision","Samsung Gam Boy","Sega 32X","Sega CD","Sega Game Gear","Sega Genesis","Sega Master System","Sega Mega Drive","Sega Mega-CD","Sega Pico","Sega SC-3000","Sega SG-1000"]
;----------------------------------------------------------------------------
; Notes:
; Don't forget to setup your bios or you might just get a black screen.
; Set your fullscreen resolution by going to Video->Full Screen Resolution
; Fusion only supports 4 different windowed resolutions. If you don't use fullscreen, set the one you want by going to Video->Window Size
; Esc is Fusion's default key to go Fullscreen/Windowed mode. This cannot be changed, but this module will still close if you use Esc to exit. You may see the emu leave fullscreen first though.
; Esc can also cause Fusion to change its fullscreen mode on exit, causing it to lockup for 5-10 seconds. The only fix for this is to not use Esc as your exit key.
; For Sega CD, make sure your cues are correctly pointing to all the tracks or else you will not get sound. Also turn off auto-play for CDs
;
; Sega CD:
; Configure your Sega CD bios first by going to Options -> Set Config -> Sega CD
; Set the scsi drive you want to use manually by going to Options -> CD Drive and seleting the one that corresponds to your scsi drive in DT. A dt drive is not supported by the emu, it must be scsi.
;
; Defining per-game controller types:
; In the module ini, set Controller_Reassigning_Enabled to true
; Default_P1_Controller and Default_P2_Controller should be set to the controller type you normally use for games not listed in the ini
; Make a new ini section with the name of your rom in your database, for example [Super Scope 6 (USA)]
; Under this section you can have 2 keys, P1_Controller and P2_Controller
; For P1_Controller - 0=None, 1=Gamepad, 2=Multitap, 3=Mouse, 4=Serial USART
; For P2_Controller - 0=None, 1=Gamepad, 2=Multitap, 3=Mouse, 4=Super Scope, 5=Justifier, 6=Dual Justifiers, 7=Serial USART
;
; Some games will not work if you have Teamplayer or 4way play active all the time, so you can set the MultiTapType for those problematic games in the module settings for each of these games.
;
; Sega Pico:
; Fusion has very limited support for Sega Pico since it doesn't support the storyware overlays. This module offers support to add the storyware overlays by displaying the images 
; on top of the emulator and having some controls to switch pages.
; This isn't perfect and it's very easy to get the page currently viewed in Fusion to get out of sync with the one visible on-screen.
; Overlays should be placed in your emulator folder in a sub-folder named \Overlays\%RomName%
; Suggested name for each page is: "Overlay x - %RomName%.png" where x is the number of the storyware book page
; You should map the Previous and Next Page commands to the ones you are using in Fusion, but make sure you only press them when Fusion is in the Storyware and not in the trackpad
; Otherwise everything will go out of sync since the module cannot detect if Storyware mode is active or not so it will always change page whereas Fusion won't
;
; Mouse is required Pico, along with the following controls (using a Genesis Gamepad): START switches between StoryWare and Trackpad, B is the pico red button, A and C turn pages, and U/D/L/R are, well, U/D/L/R. 
;
; Windows 8 and 8.1 users:
; You may experience an issue with Fusion never getting higher than 33.5fps. Use Ctrl+F to bring up the FPS counter in Fusion to check if you are affected. This is caused by some compatibility changes Microsoft made for DirectDraw applications. There are two ways of fixing this issue:
; 1) Apply a compatibility patch for the Fusion executable using the Microsoft Application Compatibility Toolkit
; 2) Copy a prepatched ddraw.dll into the Fusion directory.
; Using the Microsoft Application Compatibility Toolkit is a cleaner fix but takes a few minutes to go through the steps to apply. Using the prepatched ddraw.dll file is quick and simple but may break the right-click menus when in full-screen mode, requiring you to make all configuration changes with the emulator windowed.
; Both methods are fully detailed with downloads, instructions and screenshots at http://www.blitzbasic.com/Community/post.php?topic=99477&post=1202630
;----------------------------------------------------------------------------
StartModule()
If StringUtils.Contains(systemName,"Pico")
	StorywaveOverlayGUI()
BezelGUI()
FadeInStart()

primaryExe := new Emulator(emuPath . "\" . executable)			; instantiate emulator executable object
emuPrimaryWindow := new Window(new WindowTitle("Fusion","KegaClass"))	; instantiate primary emulator window object
emuLoadRamCartWindow := new Window(new WindowTitle("Load RAM Cart","#32770"))
emuCreateRamCartWindow := new Window(new WindowTitle("Create RAM Cart","#32770"))
emuSelectRamCartWindow := new Window(new WindowTitle("Select RAM Cart Size","#32770"))

; The object controls how the module reacts to different systems. Fusion can play a lot of systems, but changes itself slightly so this module has to adapt 
mType := Object("Othello Multivision","sms","Samsung Gam Boy","sms","Sega 32X","32X","Sega CD","scd","Sega Mega-CD","scd","Sega Game Gear","gg","Sega Genesis","gen","Sega Mega Drive","gen","Sega Master System","sms","Sega Pico","gen","Sega SC-3000","sms","Sega SG-1000","sms")
ident := mType[systemName]	; search 1st array for the systemName identifier mednafen uses
If !ident
	ScriptError("Your systemName is: " . systemName . "`nIt is not one of the known supported systems for this Fusion module: " . moduleName)

fullscreen := moduleIni.Read("Settings", "Fullscreen","true",,1)
forceFullScreen32 := moduleIni.Read("Settings", "ForceFullScreen32","true",,1)
hideTitleBar := moduleIni.Read("Settings", "hideTitleBar","true",,1)	; Removes the border, titlebar, menubar, and centers the emu on your screen. Only need this if fullscreen is false
useRamCarts := moduleIni.Read("Settings", "UseRamCarts","true",,1)
controllerReassigningEnabled := moduleIni.Read("Settings", "Controller_Reassigning_Enabled","false",,1)
multiTapType := moduleIni.Read(romName . "|Settings", "MultiTapType",0,,1)
perfectSync := moduleIni.Read(romName . "|Settings", "PerfectSync","false",,1)
DTWaitTime := moduleIni.Read(systemName, "DTWaitTime","0",,1)
fluxAudioCD := moduleIni.Read(systemName, "FluxAudioCD",,,1)	; audio CD for use when Flux is ran
fluxAudioCD := GetFullName(fluxAudioCD)	; convert relative path to absolute
genP1Controller := moduleIni.Read(romName . "|Controllers", "Genesis_P1_Controller",2,,1)
genP1bController := moduleIni.Read(romName . "|Controllers", "Genesis_P1b_Controller",2,,1)
genP1cController := moduleIni.Read(romName . "|Controllers", "Genesis_P1c_Controller",2,,1)
genP1dController := moduleIni.Read(romName . "|Controllers", "Genesis_P1d_Controller",2,,1)
genP2Controller := moduleIni.Read(romName . "|Controllers", "Genesis_P2_Controller",2,,1)
genP2bController := moduleIni.Read(romName . "|Controllers", "Genesis_P2b_Controller",2,,1)
genP2cController := moduleIni.Read(romName . "|Controllers", "Genesis_P2c_Controller",2,,1)
genP2dController := moduleIni.Read(romName . "|Controllers", "Genesis_P2d_Controller",2,,1)
smsP1Controller := moduleIni.Read(romName . "|Controllers", "SMS_P1_Controller",1,,1)
smsP2Controller := moduleIni.Read(romName . "|Controllers", "SMS_P2_Controller",1,,1)
genP1Use := moduleIni.Read(romName . "|Controllers", "Genesis_P1_Use",1,,1)
genP1bUse := moduleIni.Read(romName . "|Controllers", "Genesis_P1b_Use",1,,1)
genP1cUse := moduleIni.Read(romName . "|Controllers", "Genesis_P1c_Use",1,,1)
genP1dUse := moduleIni.Read(romName . "|Controllers", "Genesis_P1d_Use",1,,1)
genP2Use := moduleIni.Read(romName . "|Controllers", "Genesis_P2_Use",1,,1)
genP2bUse := moduleIni.Read(romName . "|Controllers", "Genesis_P2b_Use",1,,1)
genP2cUse := moduleIni.Read(romName . "|Controllers", "Genesis_P2c_Use",1,,1)
genP2dUse := moduleIni.Read(romName . "|Controllers", "Genesis_P2d_Use",1,,1)
smsP1Use := moduleIni.Read(romName . "|Controllers", "SMS_P1_Use",1,,1)
smsP2Use := moduleIni.Read(romName . "|Controllers", "SMS_P2_Use",1,,1)

StorywaveOverlayPath := moduleIni.Read("Settings", "Storywave_Overlay_Path",emuPath . "\Overlays\" . dbName,,1)
toggleStorywaveOverlayKey := moduleIni.Read("Settings", "Toggle_Storywave_Overlay_Visibility_Key","X",,1) ; Show Overlay
downStorywaveOverlayKey := moduleIni.Read("Settings", "Storywave_Overlay_Page_Down_Key","Z",,1)  ; Previous Page
upStorywaveOverlayKey := moduleIni.Read("Settings", "Storywave_Overlay_Page_Up_Key","C",,1)   ; Next Page
resetStorywaveOverlayKey := moduleIni.Read("Settings", "Storywave_Overlay_Reset_Page_Key","R",,1)   ; Reset Storywave to Initial Page
StorywaveOverlayTransparency := moduleIni.Read("Settings", "Storywave_Overlay_Transparency","50",,1) ; Overlay Transparency

BezelStart()

fusionFile := new PropertiesFile(emuPath . "\fusion.ini")
If fusionFile.Exist() {
	fusionFile.LoadProperties()	; load the config into memory
	currentFullScreen := fusionFile.ReadProperty("FullScreen")	; read current fullscreen state
	currentForceFullScreen32 := fusionFile.ReadProperty("forceFullScreen32")	; read current ForceFullScreen32 state
	currentPerfectSync := fusionFile.ReadProperty("PerfectSync")	; read current PerfectSync state
} Else
	RLLog.Warning("Module - Fusion.ini was not found at " . fusionFile.FileFullPath . ". Emulator was probably never ran before.")

hideEmuObj := Object(emuLoadRamCartWindow,0,emuCreateRamCartWindow,0,emuSelectRamCartWindow,0,emuPrimaryWindow,1)
7z(romPath, romName, romExtension, sevenZExtractPath)

If StringUtils.Contains(romExtension,"\.7z|\.rar")
	ScriptError(MEmu . " only supports uncompressed or zip compressed roms. Please enable 7z support in RocketLauncherUI to use this module/emu for this extension: """ . romExtension . """")

If (Fullscreen != "true" And currentFullScreen = "1")
	fusionFile.WriteProperty("FullScreen",0)
Else If (Fullscreen = "true" And currentFullScreen = "0")
	fusionFile.WriteProperty("FullScreen",1)

If (forceFullScreen32 != "true" And currentForceFullScreen32 = "1")
	fusionFile.WriteProperty("ForceFullScreen32",0)
Else If (forceFullScreen32 = "true" And currentForceFullScreen32 = "0")
	fusionFile.WriteProperty("ForceFullScreen32",1)

If (perfectSync != "true" And currentPerfectSync = "1")
	fusionFile.WriteProperty("PerfectSync",0)
Else If (perfectSync = "true" And currentPerfectSync = "0")
	fusionFile.WriteProperty("PerfectSync",1)


hideEmu := If Fullscreen = "true" ? "Hide" : ""
fullscreen := If Fullscreen = "true" ? " -fullscreen" : ""

If bezelPath ; Setting windowed mode resolution
	fusionFile.WriteProperty("GameGearZoom",1) ; disabling emulator default bezel

 ; Allows you to set on a per-rom basis the controller type plugged into controller ports 1 and 2
If (controllerReassigningEnabled = "true")
{	RLLog.Info("Module - Started reassigning Fusion's ini controls")
	fusionFile.WriteProperty("MultiTapType", multiTapType)	; sets MultiTap
	fusionFile.WriteProperty("Joystick1Type", genP1Controller)	; sets controls for P1
	fusionFile.WriteProperty("Joystick1bType", genP1bController)	; sets controls for P1b
	fusionFile.WriteProperty("Joystick1cType", genP1cController)	; sets controls for P1c
	fusionFile.WriteProperty("Joystick1dType", genP1dController)	; sets controls for P1d
	fusionFile.WriteProperty("Joystick2Type", genP2Controller)	; sets controls for P2
	fusionFile.WriteProperty("Joystick2bType", genP2bController)	; sets controls for P2b
	fusionFile.WriteProperty("Joystick2cType", genP2cController)	; sets controls for P2c
	fusionFile.WriteProperty("Joystick2dType", genP2dController)	; sets controls for P2d
	fusionFile.WriteProperty("Joystick1MSType", smsP1Controller)	; sets controls for sms P1
	fusionFile.WriteProperty("Joystick2MSType", smsP2Controller)	; sets controls for sms P2
	fusionFile.WriteProperty("Joystick1Using", genP1Use)	; sets controls for P1
	fusionFile.WriteProperty("Joystick1bUsing", genP1bUse)	; sets controls for P1b
	fusionFile.WriteProperty("Joystick1cUsing", genP1cUse)	; sets controls for P1c
	fusionFile.WriteProperty("Joystick1dUsing", genP1dUse)	; sets controls for P1d
	fusionFile.WriteProperty("Joystick2Using", genP2Use)	; sets controls for P2
	fusionFile.WriteProperty("Joystick2bUsing", genP2bUse)	; sets controls for P2b
	fusionFile.WriteProperty("Joystick2cUsing", genP2cUse)	; sets controls for P2c
	fusionFile.WriteProperty("Joystick2dUsing", genP2dUse)	; sets controls for P2d
	fusionFile.WriteProperty("Joystick1MSUsing", smsP1Use)	; sets controls for sms P1
	fusionFile.WriteProperty("Joystick2MSUsing", smsP2Use)	; sets controls for sms P2
	RLLog.Info("Module - Finished reassigning Fusion's ini controls")
}

fusionFile.SaveProperties()	; save changes to Fusion.ini

fluxRom := StringUtils.Contains(romName,"flux")	; test if this game is Flux, a special case game that requires an Audio CD to be mounted
If fluxRom {
	RLLog.Info("Module - Mounting the Audio CD because """ . romName . """ requires one to function.")
	ident := "gen"	; change ident to gen because Flux has to be mounted as a Genesis rom
	VirtualDrive("mount", fluxAudioCD)	; mount the Audio CD the user has set in the module settings
}

scdExtension := StringUtils.Contains(romExtension, "\.ccd|\.cue|\.bin|\.iso")	; the sega cd extensions supported by fusion

HideAppStart(hideEmuObj,hideEmu)

If (ident = "scd" && vdEnabled = "true" && scdExtension) {
	If (vdUseSCSI = "false")
		RLLog.Warning("Module - Daemon Tools drive type is set to ""dt"" but only ""scsi"" is supported for Fusion. Forcing scsi drive.")
	VirtualDrive("mount", romPath . "\" . romName . romExtension, (If vdUseSCSI = "false" ? "scsi" : ""))
	TimerUtils.Sleep(DTWaitTime)
	PrimaryExe.Run(" -auto -" . ident . " " . fullscreen, hideEmu)
} Else {
	If (ident = "scd" && vdEnabled = "true" && !scdExtension)
		RLLog.Warning("Module - " . romExtension . " is not a supported cd image extension for Fusion. Launching Fusion without DT support.")
	PrimaryExe.Run(" -auto -" . ident . fullscreen . " """ . romPath . "\" . romName . romExtension . """", hideEmu)
}

emuPrimaryWindow.Wait()
emuPrimaryWindow.WaitActive()

If fluxRom
	emuPrimaryWindow.PostMessage(0x111,40009)		; Runs the Boot Sega-CD command to load the Audio CD that should be mounted in DT already

If (ident = "scd" && useRamCarts = "true")	; Sega CD or Mega CD only
{	brmPath := ReadProperty(fusionIni,"BRMFiles")		; read BRM path
	ramCartFile := New File(brmPath . "\" . romName . ".crm")
	If !ramCartFile.Exist("folder")	; if folder doesn't exist
		ramCartFile.CreateDir()	; create brmPath if it does not exist
	; Create New Ram Cart if it doesn't exist already
	If !ramCartFile.Exist()
	{	emuPrimaryWindow.PostMessage(0x111,40036)		; Open Create New Ram Cart Window
		emuSelectRamCartWindow.Wait()
		emuSelectRamCartWindow.Set("Transparent","On")
		emuSelectRamCartWindow.CreateControl("Button7")		; instantiate new control for Button7
		emuSelectRamCartWindow.CreateControl("Button1")		; instantiate new control for Button1
		emuSelectRamCartWindow.GetControl("Button7").Control("Check")	; check control Button7
		emuSelectRamCartWindow.GetControl("Button1").Send("{Enter}")	; Send Enter to control Button1
		emuCreateRamCartWindow.OpenROM(ramCartFile.FileFullPath)
	}
	; Now load the Ram Cart
	emuPrimaryWindow.PostMessage(0x111,40035)		; Open Load Ram Cart Window
	emuLoadRamCartWindow.OpenROM(ramCartFile.FileFullPath)
}

emuPrimaryWindow.WaitActive()

Loop { ; looping until Fusion is done loading game
	TimerUtils.Sleep(200)
	winTitle := emuPrimaryWindow.GetTitle(0)	; do not store
	winTextSplit := StringUtils.Split(winTitle, A_Space)
	If (winTextSplit[3] = "-")
		Break
	If (A_Index > 75) {
		RLLog.Error("Module - Timed out detecting that a game was loaded in Fusion. There may be a problem with the emu loading your game." . (If ident = "scd" ? "You need to make sure you select the proper CD drive manually in Fusion first by going to Options -> CD Drive":""))
		Break
	}
}

If (hideTitleBar = "true")
{	emuPrimaryWindow.RemoveBorder()
	emuPrimaryWindow.RemoveTitleBar()
	emuPrimaryWindow.RemoveMenubar()
	If (bezelEnabled != "true")
		emuPrimaryWindow.Center()
}

BezelDraw()

If StringUtils.Contains(systemName,"Pico")
	StorywaveOverlayLoad()

HideAppEnd(hideEmuObj,hideEmu)
FadeInExit()

If StringUtils.Contains(systemName,"Pico")
	emuPrimaryWindow.PostMessage(0x111,40183)		; tell Kega Fusion to capture mouse input

primaryExe.Process("WaitClose")

If (fluxRom || (ident = "scd" && vdEnabled = "true" && scdExtension))
	VirtualDrive("unmount")

7zCleanUp()
StorywaveOverlayExit()
BezelExit()
FadeOutExit()
ExitModule()


MultiGame:
	; msgbox % "selectedRom = " . selectedRom . "`nselected game = " . currentButton . "`nmgRomPath = " . mgRomPath . "`nmgRomExt = " . mgRomExt . "`nmgRomName = "  . mgRomName
	; Unmount the CD from Virtual Drive
	If (scdExtension && vdEnabled = "true")
		VirtualDrive("unmount")
	TimerUtils.Sleep(500)	; Required to prevent your Virtual Drive from bugging
	; Mount the CD using Virtual Drive
	If (scdExtension && vdEnabled = "true")
		VirtualDrive("mount", selectedRom)
Return

CloseProcess:
	FadeOutStart()
	emuPrimaryWindow.Close()
	; emuPrimaryWindow.PostMessage(0x111,40039)	; Tells Fusion to Power Off
	; TimerUtils.Sleep(100)						; Giving time for Fusion to unload rom
	; emuPrimaryWindow.PostMessage(0x111,40005)	; Tells Fusion to exit
Return



;_______________Storywave Overlay__________________________

StorywaveOverlayGUI(){
	Global
	If !pToken
		pToken := Gdip_Startup()
	Gui, StorywaveOverlay_GUI: +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop
	Gui, StorywaveOverlay_GUI: Margin,0,0
	Gui, StorywaveOverlay_GUI: Show,, StorywaveOverlay_Layer
	StorywaveOverlay_hwnd := WinExist()
	StorywaveOverlay_hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
	StorywaveOverlay_hdc := CreateCompatibleDC()
	StorywaveOverlay_obm := SelectObject(StorywaveOverlay_hdc, StorywaveOverlay_hbm)
	StorywaveOverlay_G := Gdip_GraphicsFromhdc(StorywaveOverlay_hdc)
	Gdip_SetSmoothingMode(StorywaveOverlay_G, 4)
	Return
}

StorywaveOverlayLoad(){
	Global
	StorywaveOverlayArray := []
	Loop, % StorywaveOverlayPath . "\*.png"
		StorywaveOverlayArray.Insert(A_LoopFileFullPath)
	if (StorywaveOverlayArray.MaxIndex() > 0)
	{
		WinGet emulatorID, ID, A
		WinGetPos, emuX, emuY, emuW, emuH, ahk_id %emulatorID%
		currentStorywaveOverlay := 1
		StorywaveOverlayDraw := false
		XHotKeywrapper(toggleStorywaveOverlayKey,"toggleStorywaveOverlay","ON") 
		XHotKeywrapper(upStorywaveOverlayKey,"upStorywaveOverlay","ON")
		XHotKeywrapper(downStorywaveOverlayKey,"downStorywaveOverlay","ON")
		XHotKeywrapper(resetStorywaveOverlayKey,"resetStorywaveOverlay","ON")
	}
	Return
}

StorywaveOverlayExit(){
	Global
	SelectObject(StorywaveOverlay_hdc,StorywaveOverlay_obm)
	DeleteObject(StorywaveOverlay_hbm)
	DeleteDC(StorywaveOverlay_hdc)
	Gdip_DeleteGraphics(StorywaveOverlay_G)
	Gui, StorywaveOverlay_GUI: Destroy
	Gdip_DisposeImage(StorywaveOverlayBitmap)
	Return
}

StorywaveOverlayHide(){
	Global
	Gdip_GraphicsClear(StorywaveOverlay_G)
	UpdateLayeredWindow(StorywaveOverlay_hwnd, StorywaveOverlay_hdc,emuX,emuY, emuW, emuH)
	StorywaveOverlayDraw := false
	Return
}

StorywaveOverlayShow(){
	Global
	Tooltip, "Current Page " %currentStorywaveOverlay%
	settimer,EndofCurrentPageToolTipDelay, -2000  
	Gdip_GraphicsClear(StorywaveOverlay_G)
	StorywaveOverlayBitmap := Gdip_CreateBitmapFromFile(StorywaveOverlayArray[currentStorywaveOverlay])
	Gdip_DrawImage(StorywaveOverlay_G, StorywaveOverlayBitmap, 0, 0,emuW,emuH)
	UpdateLayeredWindow(StorywaveOverlay_hwnd, StorywaveOverlay_hdc,emuX,emuY, emuW, emuH,StorywaveOverlayTransparency)
	StorywaveOverlayDraw := true
	Return
}

EndofCurrentPageToolTipDelay:
	ToolTip
Return

toggleStorywaveOverlay:
	If StorywaveOverlayDraw
		StorywaveOverlayHide()
	Else
		StorywaveOverlayShow()
Return

upStorywaveOverlay:
	currentStorywaveOverlay++
	If (currentStorywaveOverlay > StorywaveOverlayArray.MaxIndex())
		currentStorywaveOverlay--
	StorywaveOverlayShow()
Return

downStorywaveOverlay:
	currentStorywaveOverlay--
	If (currentStorywaveOverlay < 1)	; This variable cannot be lower than 1 (first page)
		currentStorywaveOverlay := 1
	StorywaveOverlayShow()
Return

resetStorywaveOverlay:
	currentStorywaveOverlay := 1
	StorywaveOverlayShow()
Return
