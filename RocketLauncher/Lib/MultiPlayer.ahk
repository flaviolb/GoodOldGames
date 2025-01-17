MCRC := "6F98BF9"
MVersion := "1.0.9"

;MultiPLayer Menu function
;Inputs:
;   lastIP, default IP
;   lastPort, default port
;   networkType
;   networkPlayers, max number of game multiplayers
;   setupNetwork, shows a screen so the user can choose if the game requires a setup after the multiplayer menu selection (only shows in client or server mode)
;   keyboardControl, enables default keyboard IP and port selection keys
;   severUseNetworkIP, true or false, if true server will use the public IP of his machine, if false server will use the local IP of his machine
;   disableSeverInfoMenu, true or false, displays a message describing instructions to the server user to send to their multiplayer clients 
;   textMessage, text message to be draw instead of multiplayer menu  
;   localLink, adds locallink option to multiplayer menu
;   serverMode, portOnly shows the screen to choose the port number, IPandPort shows the screen to choose the IP and port

;Outputs:
;   ByRef networkType, false = single player, server = user choose to be the server , client = user choose to be the client,  localLink = user choose to localLink multiplayers
;   ByRef networkPlayers, number of players selected
;   networkSession, true or false, true if user choose a multiplayer game
;   networkIP, returns selected IP number on client, returns local (severUseNetworkIP=false) or public IP on server mode (severUseNetworkIP=true)  
;   networkPort, returns selected port on client and server mode  
;   localIP, return local IP on server mode
;   publicIP, return public IP on server mode 
;   networkRequiresSetup, true or false, true if user selected that game requires a user intervention to enable multiplayer   

MultiPlayerMenu(lastIP:=false, lastPort:=false, ByRef networkType:=false, ByRef networkPlayers:=0, setupNetwork:=false, keyboardControl:=true, severUseNetworkIP:=true, disableSeverInfoMenu:=false, textMessage:=false,localLink:=false, serverMode:="portOnly")
{
	RLLog.Info(A_ThisFunc . " - Started")
	Global networkSession,networkIP,networkPort,localIP,publicIP,networkRequiresSetup
	Global screenRotationAngle,baseScreenWidth,baseScreenHeight,xTranslation,yTranslation, RLMediaPath
	Global navSelectKey,navUpKey,navDownKey,navLeftKey,navRightKey,navP2SelectKey,navP2UpKey,navP2DownKey,navP2LeftKey,navP2RightKey,exitEmulatorKey,exitEmulatorKey
	Global keymapper,keymapperEnabled,keymapperRocketLauncherProfileEnabled
	XHotKeywrapper(exitEmulatorKey,"CloseProcess","OFF")
	If !pToken
		pToken := Gdip_Startup()
	Gdip_Alt_GetRotatedDimensions(A_ScreenWidth, A_ScreenHeight, screenRotationAngle, baseScreenWidth, baseScreenHeight)
	Gdip_GetRotatedTranslation(baseScreenWidth, baseScreenHeight, screenRotationAngle, xTranslation, yTranslation)
	xTranslation:=round(xTranslation), yTranslation:=round(yTranslation)
	Loop, 4 {
		Gui, multiplayerMenu_GUI%A_Index%: +Disabled -Caption +E0x80000 +OwnDialogs +LastFound +ToolWindow +AlwaysOnTop 
		Gui, multiplayerMenu_GUI%A_Index%: Margin,0,0
		Gui, multiplayerMenu_GUI%A_Index%: Show,, multiplayerMenuLayer%A_Index%
		multiplayerMenu_hwnd%A_Index% := WinExist()
		multiplayerMenu_hbm%A_Index% := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
		multiplayerMenu_hdc%A_Index% := CreateCompatibleDC()
		multiplayerMenu_obm%A_Index% := SelectObject(multiplayerMenu_hdc%A_Index%, multiplayerMenu_hbm%A_Index%)
		multiplayerMenu_G%A_Index% := Gdip_GraphicsFromhdc(multiplayerMenu_hdc%A_Index%)
		Gdip_SetSmoothingMode(multiplayerMenu_G%A_Index%, 4)
		Gdip_TranslateWorldTransform(multiplayerMenu_G%A_Index%, xTranslation, yTranslation)
		Gdip_RotateWorldTransform(multiplayerMenu_G%A_Index%, screenRotationAngle)
	}
	;Initializing visual parameters
	multiplayerMenuBackgroundColor := "CC000000"
	multiplayerMenuTextFont := "Bebas Neue" 
	CheckFont(multiplayerMenuTextFont)
	multiplayerMenuSelectedTextSize := 35
	multiplayerMenuSelectedTextColor := "FFFFFFFF"
	multiplayerMenuDisabledTextColor := "FFAAAAAA"
	multiplayerMenuDisabledTextSize := 30
	multiplayerMenuSelectedImageWidth := 256
	multiplayerMenuDisabledImageWidth := 200
	multiplayerMenuSelectedContourColor := "33ffff00"
	multiplayerMenuDisabledContourColor := "33AAAAAA"
	multiplayerMenuSelectedContourPenW := 7
	multiplayerMenuSelectedContourMargin := 20
	multiplayerMenuDisabledContourMargin := 5
	multiplayerMenuMarginBetweenImageandText := 10
	multiplayerMenuContourCornerRadius := 10
	multiplayerMenuMargin := 50
	multiplayerMenuDistanceBetweenOptions := 50
	multiplayerMenuCornerRadius := 10
	IPDistanceBetweenImages := 30
	IPSlotTextFont := "Bebas Neue" 
	CheckFont(IPSlotTextFont)
	IPSlotSelectedTextSize := 30
	IPSlotSelectedTextColor := "FF000000"
	IPSlotDisabledTextColor := "DD555555"
	IPSlotSecondaryTextColor := "DD222222"
	IPSlotDisabledTextSize := 30	
	IPMenuTextFont := "Bebas Neue" 
	CheckFont(IPMenuTextFont)
	IPMenuTextSize := 30
	IPMenuTextColor := "DDAAAAAA"
	PlayerSelectionMenuMarginBetweenNumberAndText := 40
	PlayerSelectionMenuMarginBetweenNumberAndImage := 240
	PlayerSelectionMenuSlotTextSize := 30
	PlayerSelectionMenuSlotTextColor := "FF000000"
	PlayerSelectionMenuSlotSecondaryTextColor := "DD222222"
	PlayerSelectionMenuSlotTextFont := "Bebas Neue" 
	CheckFont(PlayerSelectionMenuSlotTextFont)
	PlayerSelectionMenuTextSize := 40
	PlayerSelectionMenuTextColor := "DD999999"
	PlayerSelectionMenuTextFont := "Bebas Neue" 
	serverPortSlotTextFont := "Bebas Neue" 
	CheckFont(serverPortSlotTextFont)
	serverPortSlotSelectedTextSize := 30
	serverPortSlotSelectedTextColor := "FF000000"
	serverPortSlotDisabledTextColor := "DD555555"
	serverPortSlotSecondaryTextColor := "DD222222"
	serverPortSlotDisabledTextSize := 30	
	serverPortMenuTextFont := "Bebas Neue" 
	CheckFont(serverPortMenuTextFont)
	serverPortMenuTextSize := 30
	serverPortMenuTextColor := "DDAAAAAA"
	serverPortDistanceBetweenImageAndText := 30
	serverInfoMenuTextFont := "Bebas Neue" 
	CheckFont(serverInfoMenuTextFont)
	serverInfoMenuTextSize := 25
	serverInfoMenuTextColor := "DDAAAAAA"
	errorTextFont := "Bebas Neue" 
		CheckFont(errorTextFont)
	errorTextSize := 20
	errorTextColor := "DDffff00"
	errorShowTime := 3000
	SetupNetworkMenuMarginBetweenOptionAndText := 40
	SetupNetworkMenuSlotTextSize := 30
	SetupNetworkMenuSlotYesTextColor := "FF009900"
	SetupNetworkMenuSlotNoTextColor := "FF990000"
	SetupNetworkMenuSlotTextFont := "Bebas Neue" 
	CheckFont(PlayerSelectionMenuSlotTextFont)
	SetupNetworkMenuTextSize := 30
	SetupNetworkMenuTextColor := "DD999999"
	SetupNetworkMenuTextFont := "Bebas Neue"
	CheckFont(SetupNetworkMenuTextFont)
	IPSlotSelectedPenWidth := 2
	;menu scalling factor
	XBaseRes := 1920, YBaseRes := 1080
    If (((A_screenWidth < A_screenHeight) and ((screenRotationAngle=0) or (screenRotationAngle=180))) or ((A_screenWidth > A_screenHeight) and ((screenRotationAngle=90) or (screenRotationAngle=270))))
        XBaseRes := 1080, YBaseRes := 1920
    If !multiplayerMenuXScale 
		multiplayerMenuXScale := baseScreenWidth/XBaseRes
    If !multiplayerMenuYScale
		multiplayerMenuYScale := baseScreenHeight/YBaseRes
	OptionScale(multiplayerMenuSelectedTextSize, multiplayerMenuYScale)
	OptionScale(multiplayerMenuDisabledTextSize, multiplayerMenuYScale)
	OptionScale(multiplayerMenuSelectedImageWidth, multiplayerMenuXScale)
	OptionScale(multiplayerMenuDisabledImageWidth, multiplayerMenuXScale)	
	OptionScale(multiplayerMenuMargin, multiplayerMenuXScale)
	OptionScale(multiplayerMenuDistanceBetweenOptions, multiplayerMenuYScale)
	OptionScale(multiplayerMenuContourCornerRadius, multiplayerMenuXScale)	
	OptionScale(multiplayerMenuCornerRadius, multiplayerMenuXScale)	
	OptionScale(multiplayerMenuMarginBetweenImageandText, multiplayerMenuXScale)	
	OptionScale(SelectedContourPenW, multiplayerMenuXScale)
	OptionScale(multiplayerMenuSelectedContourMargin, multiplayerMenuXScale)
	OptionScale(multiplayerMenuDisabledContourMargin, multiplayerMenuXScale)
	OptionScale(IPDistanceBetweenImages, multiplayerMenuXScale)
	OptionScale(IPSlotSelectedTextSize, multiplayerMenuYScale)
	OptionScale(IPSlotDisabledTextSize, multiplayerMenuYScale)
	OptionScale(IPMenuTextSize, multiplayerMenuYScale)
	OptionScale(PlayerSelectionMenuMarginBetweenNumberAndText, multiplayerMenuXScale)
	OptionScale(PlayerSelectionMenuMarginBetweenNumberAndImage, multiplayerMenuXScale)
	OptionScale(PlayerSelectionMenuSlotTextSize, multiplayerMenuYScale)
	OptionScale(PlayerSelectionMenuTextSize, multiplayerMenuYScale)
	OptionScale(serverPortSlotSelectedTextSize, multiplayerMenuYScale)
	OptionScale(serverPortSlotDisabledTextSize, multiplayerMenuYScale)
	OptionScale(serverPortMenuTextSize, multiplayerMenuYScale)
	OptionScale(serverPortDistanceBetweenImageAndText, multiplayerMenuXScale)
	OptionScale(serverInfoMenuTextSize, multiplayerMenuYScale)
	OptionScale(errorTextSize, multiplayerMenuYScale)
	OptionScale(SetupNetworkMenuMarginBetweenOptionAndText, multiplayerMenuXScale)
	OptionScale(SetupNetworkMenuSlotTextSize, multiplayerMenuYScale)
	OptionScale(SetupNetworkMenuTextSize, multiplayerMenuYScale)
	OptionScale(IPSlotSelectedPenWidth, multiplayerMenuXScale)
	IPSlotSelectedPenWidth := (IPSlotSelectedPenWidth<1) ? 1 : IPSlotSelectedPenWidth
	;Create Pens
	multiplayerMenuContourSelectedPen := Gdip_CreatePen("0x" . multiplayerMenuSelectedContourColor, multiplayerMenuSelectedContourPenW)
	multiplayerMenuContourDisabledPen := Gdip_CreatePen("0x" . multiplayerMenuDisabledContourColor, multiplayerMenuSelectedContourPenW) 
	IPSlotSelectedPen := Gdip_CreatePen("0x" . multiplayerMenuSelectedContourColor, IPSlotSelectedPenWidth)
	;Initializing menu parameters
	SelectedMultiPlayerOption := 1
	multiplayerMenulevel:=0
	previousMultiplayerMenu := []
	MultiPlayerOption := []
	MultiPlayerOption[1,"text"] := "Single Player"
	MultiPlayerOption[2,"text"] := "MultiPlayer Server"
	MultiPlayerOption[3,"text"] := "MultiPlayer Client"
	MultiPlayerOption[4,"text"] := "Local Link"
	MultiPlayerOption[1,"networkType"] := false
	MultiPlayerOption[2,"networkType"] := "server"
	MultiPlayerOption[3,"networkType"] := "client"
	MultiPlayerOption[4,"networkType"] := "localLink"
	;Loading images
	mpSinglePlayerImage := CheckFile(RLMediaPath . "\Menu Images\RocketLauncher\Single Player.png")
	mpMultiPlayerServerImage := CheckFile(RLMediaPath . "\Menu Images\RocketLauncher\Multiplayer Server.png")
	mpMultiPlayerClientImage := CheckFile(RLMediaPath . "\Menu Images\RocketLauncher\Multiplayer Client.png")
	mpMultiPlayerLocalLinkImage := CheckFile(RLMediaPath . "\Menu Images\RocketLauncher\Multiplayer Local Link.png")
	MultiPlayerOption[1,"bitmap"] := Gdip_CreateBitmapFromFile(mpSinglePlayerImage)
	MultiPlayerOption[2,"bitmap"] := Gdip_CreateBitmapFromFile(mpMultiPlayerServerImage)
	MultiPlayerOption[3,"bitmap"] := Gdip_CreateBitmapFromFile(mpMultiPlayerClientImage)
	MultiPlayerOption[4,"bitmap"] := Gdip_CreateBitmapFromFile(mpMultiPlayerLocalLinkImage)
	MultiPlayerOption[1,"bitmapH"] := Gdip_GetImageHeight(MultiPlayerOption[1,"bitmap"]), MultiPlayerOption[1,"bitmapW"] := Gdip_GetImageWidth(MultiPlayerOption[1,"bitmap"])
	MultiPlayerOption[2,"bitmapH"] := Gdip_GetImageHeight(MultiPlayerOption[2,"bitmap"]), MultiPlayerOption[2,"bitmapW"] := Gdip_GetImageWidth(MultiPlayerOption[2,"bitmap"])
	MultiPlayerOption[3,"bitmapH"] := Gdip_GetImageHeight(MultiPlayerOption[3,"bitmap"]), MultiPlayerOption[3,"bitmapW"] := Gdip_GetImageWidth(MultiPlayerOption[3,"bitmap"])
	MultiPlayerOption[4,"bitmapH"] := Gdip_GetImageHeight(MultiPlayerOption[4,"bitmap"]), MultiPlayerOption[4,"bitmapW"] := Gdip_GetImageWidth(MultiPlayerOption[4,"bitmap"])
	;Defining Menu Size
	maxImageH := % If ((MultiPlayerOption[1,"bitmapH"]*multiplayerMenuSelectedImageWidth/MultiPlayerOption[1,"bitmapW"])>(MultiPlayerOption[2,"bitmapH"]*multiplayerMenuSelectedImageWidth/MultiPlayerOption[2,"bitmapW"])) ? (MultiPlayerOption[1,"bitmapH"]*multiplayerMenuSelectedImageWidth/MultiPlayerOption[1,"bitmapW"]) : If ((MultiPlayerOption[2,"bitmapH"]*multiplayerMenuSelectedImageWidth/MultiPlayerOption[2,"bitmapW"])>(MultiPlayerOption[3,"bitmapH"]*multiplayerMenuSelectedImageWidth/MultiPlayerOption[3,"bitmapW"])) ? (MultiPlayerOption[2,"bitmapH"]*multiplayerMenuSelectedImageWidth/MultiPlayerOption[2,"bitmapW"]) : (MultiPlayerOption[3,"bitmapH"]*multiplayerMenuSelectedImageWidth/MultiPlayerOption[3,"bitmapW"])
	if (localLink)
		maxImageH := % If ((MultiPlayerOption[4,"bitmapH"]*multiplayerMenuSelectedImageWidth/MultiPlayerOption[4,"bitmapW"])>maxImageH) ? (MultiPlayerOption[4,"bitmapH"]*multiplayerMenuSelectedImageWidth/MultiPlayerOption[4,"bitmapW"]) : maxImageH
	multiplayerMenuW := Round(2*multiplayerMenuMargin + 2*multiplayerMenuDistanceBetweenOptions + 3*multiplayerMenuSelectedImageWidth)
	if (localLink)
		multiplayerMenuW := Round(2*multiplayerMenuMargin + 3*multiplayerMenuDistanceBetweenOptions + 4*multiplayerMenuSelectedImageWidth)
	multiplayerMenuH := Round(2*multiplayerMenuMargin + maxImageH + multiplayerMenuMarginBetweenImageandText + multiplayerMenuSelectedTextSize)
	multiplayerMenuX := (baseScreenWidth-multiplayerMenuW)//2
	multiplayerMenuY := (baseScreenHeight-multiplayerMenuH)//2
	multiplayerMenuBackgroundBrush := Gdip_BrushCreateSolid("0x" . multiplayerMenuBackgroundColor)
	pGraphUpd(multiplayerMenu_G1,multiplayerMenuW,multiplayerMenuH)
	pGraphUpd(multiplayerMenu_G2,multiplayerMenuW,multiplayerMenuH)
	pGraphUpd(multiplayerMenu_G4,multiplayerMenuW,multiplayerMenuH)
	;Drawing Background
	Gdip_Alt_FillRoundedRectangle(multiplayerMenu_G1, multiplayerMenuBackgroundBrush, 0, 0, multiplayerMenuW, multiplayerMenuH,multiplayerMenuCornerRadius)
	Alt_UpdateLayeredWindow(multiplayerMenu_hwnd1, multiplayerMenu_hdc1, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
	;Drawing Images and Texts
	If textMessage ; Drawing simple text message
		Gosub, DrawMultiPlayerTextMessage
	Else ; Drawing Menu
		Gosub, DrawMultiPlayerSelectionMenu
	;Enabling Menu Navigation Keys
	If (keymapperEnabled = "true") and (keymapperRocketLauncherProfileEnabled = "true")
		RunKeymapper%zz%("menu",keymapper)
	If keymapperAHKMethod = External
		RunAHKKeymapper%zz%("menu")
	LEDBlinky("RL")	; trigger ledblinky profile change if enabled
	KeymapperProfileSelect("RL", keyboardEncoderEnabled, winIPACFullPath, "ipc", "keyboard")
	KeymapperProfileSelect("RL", "UltraMap", ultraMapFullPath, "ugc")
	;Waiting for menu to exit
	Loop
	{	If multiplayerMenuExit
			Break
		Sleep, 100
	}
	If (currentNumberOfPlayers){
		networkPlayers := currentNumberOfPlayers
		RLLog.Info(A_ThisFunc . " - User selected the number of players equal to: " . networkPlayers)
		if (networkPlayers>1)
			networkSession := true
		else
			networkSession := false
	}
	If (textMessage){
		Gosub, DisableMultiplayerTextMessageKeys
	} else 
		networkType := MultiPlayerOption[SelectedMultiPlayerOption,"networkType"]
	Gosub, CleanMultiplayerMenuMemory
	If (keymapperEnabled = "true") and (keymapperRocketLauncherProfileEnabled = "true")
		RunKeymapper%zz%("load", keymapper)
	If keymapperAHKMethod = External
		RunAHKKeymapper%zz%("load")
	multiplayerMenuExit := false
	LEDBlinky("ROM")	; trigger ledblinky profile change if enabled
	KeymapperProfileSelect("RESUME", keyboardEncoderEnabled, winIPACFullPath, "ipc", "keyboard")
	KeymapperProfileSelect("RESUME", "UltraMap", ultraMapFullPath, "ugc")
	RLLog.Info(A_ThisFunc . " - Ended")
	XHotKeywrapper(exitEmulatorKey,"CloseProcess","ON")
	Return
	;Multiplayer Selection Labels
	DrawMultiPlayerTextMessage:
		RLLog.Info(A_ThisFunc . " - Multiplayer Text Message.")
		InfoH := MeasureText(textMessage, "w" . multiplayerMenuW-2*multiplayerMenuMargin . " Center c" . serverInfoMenuTextColor . " r4 s" . serverInfoMenuTextSize . " Bold", serverInfoMenuTextFont,,,"H")
		Gdip_Alt_TextToGraphics(multiplayerMenu_G2, textMessage, "x" . multiplayerMenuMargin . " y" . (multiplayerMenuH-InfoH)//2 . "w" . multiplayerMenuW-2*multiplayerMenuMargin . " Center c" . serverInfoMenuTextColor . " r4 s" . serverInfoMenuTextSize . " Bold", serverInfoMenuTextFont)	
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd2, multiplayerMenu_hdc2, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
		XHotKeywrapper(exitEmulatorKey,"CloseMultiplayerMenu","ON")
		Gosub, EnableMultiplayerTextMessageKeys
	Return
	EnableMultiplayerTextMessageKeys:
		RLLog.Info(A_ThisFunc . " - EnableMultiplayerTextMessageKeys",5)
		XHotKeywrapper(navSelectKey,"MultiplayerTextMessageSelect","ON")  
		XHotKeywrapper(navP2SelectKey,"MultiplayerTextMessageSelect","ON") 
		XHotKeywrapper(exitEmulatorKey,"CloseMultiplayerTextMessage","ON")
	Return
	DisableMultiplayerTextMessageKeys:
		RLLog.Info(A_ThisFunc . " - EnableMultiplayerTextMessageKeys",5)
		XHotKeywrapper(navSelectKey,"MultiplayerTextMessageSelect","OFF")  
		XHotKeywrapper(navP2SelectKey,"MultiplayerTextMessageSelect","OFF") 
		XHotKeywrapper(exitEmulatorKey,"CloseMultiplayerTextMessage","OFF")
	Return
    CloseMultiplayerTextMessage:
        RLLog.Info(A_ThisFunc . " - User canceled the text message. Exiting RocketLauncher session.")
        ExitModule()
	Return	
    MultiplayerTextMessageSelect:
        RLLog.Info(A_ThisFunc . " - User accepted the text message.",5)
		multiplayerMenuExit := true
    Return
	DrawMultiPlayerSelectionMenu:
		RLLog.Info(A_ThisFunc . " - DrawMultiPlayerSelectionMenu was drawn",5)
		currentX := 0
		Gdip_GraphicsClear(multiplayerMenu_G2)
		multiPlayerSelectionMenuOptions := if (localLink) ? 4 : 3
		Loop, %multiPlayerSelectionMenuOptions%
		{
			If (a_index=SelectedMultiPlayerOption) {
				currentTextSize := multiplayerMenuSelectedTextSize
				currentTextColor := multiplayerMenuSelectedTextColor
				currentTextStyle := "bold"
				currentImageSize := multiplayerMenuSelectedImageWidth
				currentCountourPen := multiplayerMenuContourSelectedPen
				currentCountourMargin := multiplayerMenuSelectedContourMargin
			} Else {
				currentTextSize := multiplayerMenuDisabledTextSize
				currentTextColor := multiplayerMenuDisabledTextColor
				currentTextStyle := "normal"
				currentImageSize := multiplayerMenuDisabledImageWidth
				currentCountourPen := multiplayerMenuContourDisabledPen
				currentCountourMargin := multiplayerMenuDisabledContourMargin
				currentCountourIncrease := 5
			}			
			currentX := multiplayerMenuMargin + (a_index-1)*(multiplayerMenuSelectedImageWidth+multiplayerMenuDistanceBetweenOptions)
			Gdip_DrawImage(multiplayerMenu_G2,MultiPlayerOption[A_Index,"bitmap"], currentX+(multiplayerMenuSelectedImageWidth-currentImageSize)//2,multiplayerMenuMargin+(maxImageH-(MultiPlayerOption[A_Index,"bitmapH"]*currentImageSize/MultiPlayerOption[A_Index,"bitmapW"]))//2,currentImageSize,Round(MultiPlayerOption[A_Index,"bitmapH"]*currentImageSize/MultiPlayerOption[A_Index,"bitmapW"]))
			Gdip_Alt_TextToGraphics(multiplayerMenu_G2, MultiPlayerOption[A_Index,"text"], "x" . currentX + multiplayerMenuSelectedImageWidth//2 . " y" . multiplayerMenuMargin+maxImageH+multiplayerMenuMarginBetweenImageandText+(multiplayerMenuSelectedTextSize-currentTextSize)//2 . " Center c" . currentTextColor . " r4 s" . currentTextSize . " " . currentTextStyle, multiplayerMenuTextFont)
			Gdip_DrawRoundedRectangle(multiplayerMenu_G2, currentCountourPen, currentX-currentCountourMargin, multiplayerMenuMargin-currentCountourMargin, multiplayerMenuSelectedImageWidth+2*currentCountourMargin, maxImageH+multiplayerMenuMarginBetweenImageandText+multiplayerMenuSelectedTextSize+2*currentCountourMargin, multiplayerMenuContourCornerRadius)
		}
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd2, multiplayerMenu_hdc2, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
		Gosub, EnableMultiplayerMenuKeys
	Return
	EnableMultiplayerMenuKeys:
		RLLog.Debug(A_ThisFunc . " - EnableMultiplayerMenuKeys")
		XHotKeywrapper(navSelectKey,"MultiplayerMenuSelect","ON")  
		XHotKeywrapper(navUpKey,"MultiplayerMenuRight","ON")
		XHotKeywrapper(navDownKey,"MultiplayerMenuLeft","ON")
		XHotKeywrapper(navLeftKey,"MultiplayerMenuLeft","ON")
		XHotKeywrapper(navRightKey,"MultiplayerMenuRight","ON")
		XHotKeywrapper(navP2UpKey,"MultiplayerMenuRight","ON")
		XHotKeywrapper(navP2DownKey,"MultiplayerMenuLeft","ON")
		XHotKeywrapper(navP2LeftKey,"MultiplayerMenuLeft","ON")
		XHotKeywrapper(navP2RightKey,"MultiplayerMenuRight","ON")
		XHotKeywrapper(navP2SelectKey,"MultiplayerMenuSelect","ON") 
		XHotKeywrapper(exitEmulatorKey,"CloseMultiplayerMenu","ON")
	Return
	DisableMultiplayerMenuKeys:
		RLLog.Debug(A_ThisFunc . " - DisableMultiplayerMenuKeys")
		XHotKeywrapper(navSelectKey,"MultiplayerMenuSelect","OFF") 
		XHotKeywrapper(navUpKey,"MultiplayerMenuRight","OFF")
		XHotKeywrapper(navDownKey,"MultiplayerMenuLeft","OFF")
		XHotKeywrapper(navLeftKey,"MultiplayerMenuLeft","OFF")
		XHotKeywrapper(navRightKey,"MultiplayerMenuRight","OFF")
		XHotKeywrapper(navP2UpKey,"MultiplayerMenuRight","OFF")
		XHotKeywrapper(navP2DownKey,"MultiplayerMenuLeft","OFF")
		XHotKeywrapper(navP2LeftKey,"MultiplayerMenuLeft","OFF")
		XHotKeywrapper(navP2RightKey,"MultiplayerMenuRight","OFF")
		XHotKeywrapper(navP2SelectKey,"MultiplayerMenuSelect","OFF") 
		XHotKeywrapper(exitEmulatorKey,"CloseMultiplayerMenu","OFF")
	Return
	MultiplayerMenuLeft:
		SelectedMultiPlayerOption--
		If (SelectedMultiPlayerOption<1)
			SelectedMultiPlayerOption:=multiPlayerSelectionMenuOptions
		Gosub, DrawMultiPlayerSelectionMenu
	Return
	MultiplayerMenuRight:
		SelectedMultiPlayerOption++
		If (SelectedMultiPlayerOption>multiPlayerSelectionMenuOptions)
			SelectedMultiPlayerOption:=1
		Gosub, DrawMultiPlayerSelectionMenu
	Return
	CloseMultiplayerMenu:
		RLLog.Info(A_ThisFunc . " - User pressed exit key. Exiting RocketLauncher session.")
		Gosub, DisableMultiplayerMenuKeys
		Gosub, CleanMultiplayerMenuMemory
		ExitModule()
	Return
	MultiplayerMenuSelect:
		RLLog.Info(A_ThisFunc . " - Multiplayer option Selected: " . MultiPlayerOption[SelectedMultiPlayerOption,"text"])	
		multiplayerMenulevel++
		previousMultiplayerMenu[multiplayerMenulevel] := "MultiPlayerSelectionMenu"
		Gosub, DisableMultiplayerMenuKeys
		If (SelectedMultiPlayerOption=4){	; If user selected local link
			If (networkPlayers>1) 
				Gosub, DrawPlayerSelectionMenu	; choose the amount of players
			Else {
				multiplayerMenuExit := true
			}
		} Else If (SelectedMultiPlayerOption=3){	; If user selected client
			Gosub, DrawIPSelectionMenu
		} Else If (SelectedMultiPlayerOption=2) {	; If user selected server
			If (networkPlayers>1) 
				Gosub, DrawPlayerSelectionMenu	; choose the amount of players
			Else {
				if (serverMode="IPandPort")
					Gosub, DrawIPSelectionMenu
				else
					Gosub, DrawServerPortMenu
			}
		} Else {		; user selected single
			networkSession := false
			multiplayerMenuExit := true
		}
	Return
	CleanMultiplayerMenuMemory:
		RLLog.Debug(A_ThisFunc . " - CleanMultiplayerMenuMemory")
		Gdip_DeleteBrush(multiplayerMenuBackgroundBrush)
		Gdip_DeletePen(multiplayerMenuContourSelectedPen),Gdip_DeletePen(multiplayerMenuContourDisabledPen)
		Gdip_DisposeImage(MultiPlayerOption[1,"bitmap"]),Gdip_DisposeImage(MultiPlayerOption[2,"bitmap"]),Gdip_DisposeImage(MultiPlayerOption[3,"bitmap"])
		Loop, 4 {
			SelectObject(multiplayerMenu_hdc%A_Index%, multiplayerMenu_obm%A_Index%)
			DeleteObject(multiplayerMenu_hbm%A_Index%)
			DeleteDC(multiplayerMenu_hdc%A_Index%)
			Gdip_DeleteGraphics(multiplayerMenu_G%A_Index%)
			Gui, multiplayerMenu_GUI%A_Index%: Destroy
		}
	Return
	DrawIPSelectionMenu:
		RLLog.Debug(A_ThisFunc . " - DrawIPSelectionMenu was drawn")
		Gdip_GraphicsClear(multiplayerMenu_G2)
		Gdip_GraphicsClear(multiplayerMenu_G3)
		; Initializing Variables
		currentIPSlot := 1
		if !IPDigit
		{	IPDigit:=[]
			Loop, 17
				IPDigit[a_index] := -1
			If ValidIP(lastIP)
				{
				currentOctet:=0
				Loop, Parse, lastIP, .
					{
					currentOctet++
					If (A_LoopField>99){
						Loop, 3
							IPDigit[(currentOctet-1)*3+a_index]:=SubStr(A_LoopField,a_index, 1)
					} Else If (A_LoopField>9){
						Loop, 2
							IPDigit[(currentOctet-1)*3+a_index+1]:=SubStr(A_LoopField,a_index, 1)
					} Else
						IPDigit[(currentOctet-1)*3+3]:=A_LoopField
				}
			} Else
				RLLog.Info(A_ThisFunc . " - No IP number or Invalid address provided.")
			If lastPort
				{
				If (lastPort>9999){
					Loop, 5
						IPDigit[12+a_index]:=SubStr(lastPort,a_index, 1)
				} Else If (lastPort>999){
					Loop, 4
						IPDigit[12+a_index+1]:=SubStr(lastPort,a_index, 1)
				} Else If (lastPort>99){
					Loop, 3
						IPDigit[12+a_index+2]:=SubStr(lastPort,a_index, 1)
				} Else If (lastPort>9){
					Loop, 2
						IPDigit[12+a_index+3]:=SubStr(lastPort,a_index, 1)
				} Else
					IPDigit[17]:=lastPort
			}
		}
		; Loading IP Background Images
		mpIPSlotImage := CheckFile(RLMediaPath . "\Menu Images\RocketLauncher\IP Slot.png")
		mpPortSlotImage := CheckFile(RLMediaPath . "\Menu Images\RocketLauncher\Port Slot.png")
		IPBackgroundBitmap := Gdip_CreateBitmapFromFile(mpIPSlotImage)
		Gdip_GetDimensions(IPBackgroundBitmap,IPBackgroundBitmapW,IPBackgroundBitmapH)
		PortBackgroundBitmap := Gdip_CreateBitmapFromFile(mpPortSlotImage)
		Gdip_GetDimensions(PortBackgroundBitmap,PortBackgroundBitmapW,PortBackgroundBitmapH)
		IPSlotWidth := Round((multiplayerMenuW-2*multiplayerMenuMargin-4*IPDistanceBetweenImages)/17)
		IPImageWidth := (IPSlotWidth*3)
		PortImageWidth := (IPSlotWidth*5)
		Loop, 4
			{
			currentX := multiplayerMenuMargin + (a_index-1)*(IPImageWidth+IPDistanceBetweenImages)
			Gdip_DrawImage(multiplayerMenu_G2,IPBackgroundBitmap, currentX,(multiplayerMenuH-IPBackgroundBitmapH*IPImageWidth/IPBackgroundBitmapW)//2,IPImageWidth,Round(IPBackgroundBitmapH*IPImageWidth/IPBackgroundBitmapW))
		}
		Gdip_Alt_TextToGraphics(multiplayerMenu_G2, "IP Adress", "x" . multiplayerMenuMargin+(4*IPImageWidth+3*IPDistanceBetweenImages)//2 . " y" . (multiplayerMenuH-IPBackgroundBitmapH*IPImageWidth/IPBackgroundBitmapW)//2//2- currentTextSize//2 . " Center c" . IPMenuTextColor . " r4 s" . IPMenuTextSize . " Bold", IPMenuTextFont)	
		Gdip_DrawImage(multiplayerMenu_G2,PortBackgroundBitmap, currentX+(IPImageWidth+IPDistanceBetweenImages),(multiplayerMenuH-PortBackgroundBitmapH*PortImageWidth/PortBackgroundBitmapW)//2,PortImageWidth,Round(PortBackgroundBitmapH*PortImageWidth/PortBackgroundBitmapW))
		Gdip_Alt_TextToGraphics(multiplayerMenu_G2, "Port Number", "x" . currentX+(IPImageWidth+IPDistanceBetweenImages)+PortImageWidth . " y" . (multiplayerMenuH-IPBackgroundBitmapH*IPImageWidth/IPBackgroundBitmapW)//2//2- currentTextSize//2 . " Right c" . IPMenuTextColor . " r4 s" . IPMenuTextSize . " Bold", IPMenuTextFont)	
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd2, multiplayerMenu_hdc2, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
		; Drawing current IP number
		pGraphUpd(multiplayerMenu_G3,multiplayerMenuW-2*multiplayerMenuMargin, Round(IPBackgroundBitmapH*IPImageWidth/IPBackgroundBitmapW))
		Gosub, UpdateIPNumbers
		;Enabling Keys
		Gosub, EnableIPMenuKeys
	Return
	UpdateIPNumbers:
		Gdip_GraphicsClear(multiplayerMenu_G3)
		Loop, 17
			{
			If (a_index=currentIPSlot) {
				currentTextSize := IPSlotSelectedTextSize
				currentTextColor := IPSlotSelectedTextColor
				currentTextStyle := "bold"
				Gdip_Alt_DrawRectangle(multiplayerMenu_G3, IPSlotSelectedPen, (a_index-1)*IPSlotWidth + (Floor((a_index+2)/3)-1)*IPDistanceBetweenImages - Floor((a_index/16))*IPDistanceBetweenImages, 0, IPSlotWidth, Round(IPBackgroundBitmapH*IPImageWidth/IPBackgroundBitmapW))
			} Else {
				currentTextSize := IPSlotDisabledTextSize
				currentTextColor := IPSlotDisabledTextColor
				currentTextStyle := "normal"
			}
			currentX := (a_index-1)*IPSlotWidth + (Floor((a_index+2)/3)-1)*IPDistanceBetweenImages + IPSlotWidth//2 - Floor((a_index/16))*IPDistanceBetweenImages
			Gdip_Alt_TextToGraphics(multiplayerMenu_G3, If (IPDigit[a_index]=-1) ? "" : IPDigit[a_index], "x" . currentX . " y" . Round((IPBackgroundBitmapH*IPImageWidth/IPBackgroundBitmapW)/2-currentTextSize/2) . " Center c" . currentTextColor . " r4 s" . currentTextSize . " " . currentTextStyle, IPSlotTextFont)	
			;previous Number
			previousNumber := IPDigit[a_index]-1
			If ((!(Mod((a_index+2),3)) and (a_index<12)) and (previousNumber<-1))
				previousNumber:=2
			Else If (!(Mod((previousNumber+2),15)) and (previousNumber<-1))
				previousNumber:=6	
			Else If (previousNumber<-1)
				previousNumber:=9
			Gdip_Alt_TextToGraphics(multiplayerMenu_G3, If (previousNumber=-1) ? "" : previousNumber, "x" . currentX . " y" . Round((IPBackgroundBitmapH*IPImageWidth/IPBackgroundBitmapW)/2-currentTextSize/2)-Round((IPBackgroundBitmapH*IPImageWidth/IPBackgroundBitmapW))//2 . " Center c" . IPSlotSecondaryTextColor . " r4 s" . currentTextSize . " " . currentTextStyle, IPSlotTextFont)	
			;following Number
			followingNumber := IPDigit[a_index]+1
			If ((!(Mod((a_index+2),3)) and (a_index<12)) and (followingNumber>2))
				followingNumber:=-1
			Else If (!(Mod((followingNumber+2),15)) and (followingNumber>6))
				previousNumber:=-1
			Else If (followingNumber+1>9)
				followingNumber:=-1
			Gdip_Alt_TextToGraphics(multiplayerMenu_G3, If (followingNumber=-1) ? "" : followingNumber, "x" . currentX . " y" . Round((IPBackgroundBitmapH*IPImageWidth/IPBackgroundBitmapW)/2-currentTextSize/2)+Round((IPBackgroundBitmapH*IPImageWidth/IPBackgroundBitmapW))//2 . " Center c" . IPSlotSecondaryTextColor . " r4 s" . currentTextSize . " " . currentTextStyle, IPSlotTextFont)	
		}
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd3, multiplayerMenu_hdc3, multiplayerMenuX+multiplayerMenuMargin, multiplayerMenuY+(multiplayerMenuH-Round(IPBackgroundBitmapH*IPImageWidth/IPBackgroundBitmapW))//2, multiplayerMenuW-2*multiplayerMenuMargin, Round(IPBackgroundBitmapH*IPImageWidth/IPBackgroundBitmapW))
	Return
	EnableIPMenuKeys:
		RLLog.Debug(A_ThisFunc . " - EnableIPMenuKeys")
		XHotKeywrapper(navSelectKey,"IPMenuSelect","ON") 
		XHotKeywrapper(navUpKey,"IPMenuUP","ON")
		XHotKeywrapper(navDownKey,"IPMenuDown","ON")
		XHotKeywrapper(navLeftKey,"IPMenuLeft","ON")
		XHotKeywrapper(navRightKey,"IPMenuRight","ON")
		XHotKeywrapper(navP2UpKey,"IPMenuUP","ON")
		XHotKeywrapper(navP2DownKey,"IPMenuDown","ON")
		XHotKeywrapper(navP2LeftKey,"IPMenuLeft","ON")
		XHotKeywrapper(navP2RightKey,"IPMenuRight","ON")
		XHotKeywrapper(navP2SelectKey,"IPMenuSelect","ON") 
		XHotKeywrapper(exitEmulatorKey,"CloseIPMenu","ON")
		If keyboardControl
			{
			Loop, 10
				Hotkey, % a_index-1, % "IP" . a_index-1, on
			Hotkey, space, IPSpace, on
			Hotkey, Backspace, IPBackspace, on
			Hotkey, Delete, IPDelete, on	
		}
	Return
	DisableIPMenuKeys:
		RLLog.Debug(A_ThisFunc . " - DisableIPMenuKeys")
		XHotKeywrapper(navSelectKey,"IPMenuSelect","OFF") 
		XHotKeywrapper(navUpKey,"IPMenuUP","OFF")
		XHotKeywrapper(navDownKey,"IPMenuDown","OFF")
		XHotKeywrapper(navLeftKey,"IPMenuLeft","OFF")
		XHotKeywrapper(navRightKey,"IPMenuRight","OFF")
		XHotKeywrapper(navP2UpKey,"IPMenuUP","OFF")
		XHotKeywrapper(navP2DownKey,"IPMenuDown","OFF")
		XHotKeywrapper(navP2LeftKey,"IPMenuLeft","OFF")
		XHotKeywrapper(navP2RightKey,"IPMenuRight","OFF")
		XHotKeywrapper(navP2SelectKey,"IPMenuSelect","OFF") 
		XHotKeywrapper(exitEmulatorKey,"CloseIPMenu","OFF")
		If keyboardControl
			{
			Loop, 10
				Hotkey, % a_index-1, % "IP" . a_index-1, off
			Hotkey, space, IPSpace, off
			Hotkey, Backspace, IPBackspace, off
			Hotkey, Delete, IPDelete, off	
		}
	Return
	IPDelete:
	IPBackspace:
	IPSpace:
		IPDigit[currentIPSlot]:=-1
		If (A_ThisLabel="IPBackspace")
			Gosub, IPMenuLeft
		Else
			Gosub, IPMenuRight
		Gosub, UpdateIPNumbers
	Return
	IP1:
	IP2:
	IP3:
	IP4:
	IP5:
	IP6:
	IP7:
	IP8:
	IP9:
	IP0:
		StringRight, currentNumericKey, A_ThisLabel, 1
		IPDigit[currentIPSlot]:=currentNumericKey
		Gosub, IPMenuRight
		Gosub, UpdateIPNumbers
	Return
	IPMenuLeft:
		currentIPSlot--
		If (currentIPSlot<1)
			currentIPSlot:=17
		Gosub, UpdateIPNumbers
	Return
	IPMenuRight:
		currentIPSlot++
		If (currentIPSlot>17)
			currentIPSlot:=1
		Gosub, UpdateIPNumbers
	Return
	IPMenuDown:
		IPDigit[currentIPSlot]++
		If ((!(Mod((currentIPSlot+2),3)) and (currentIPSlot<12)) and (IPDigit[currentIPSlot]>2))
			IPDigit[currentIPSlot]:=-1
		Else If (!(Mod((currentIPSlot+2),15)) and (IPDigit[currentIPSlot]>6))
			IPDigit[currentIPSlot]:=-1
		Else If (IPDigit[currentIPSlot]>9)
			IPDigit[currentIPSlot]:=-1
		Gosub, UpdateIPNumbers
	Return
	IPMenuUp:
		IPDigit[currentIPSlot]--
		If ((!(Mod((currentIPSlot+2),3)) and (currentIPSlot<12)) and (IPDigit[currentIPSlot]<-1))
			IPDigit[currentIPSlot]:=2
		Else If (!(Mod((currentIPSlot+2),15)) and (IPDigit[currentIPSlot]<-1))
			IPDigit[currentIPSlot]:=6
		Else If (IPDigit[currentIPSlot]<-1)
			IPDigit[currentIPSlot]:=9
		Gosub, UpdateIPNumbers
	Return
	CloseIPMenu:
		Gdip_GraphicsClear(multiplayerMenu_G2)
		Gdip_GraphicsClear(multiplayerMenu_G3)
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd2, multiplayerMenu_hdc2, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd3, multiplayerMenu_hdc3, multiplayerMenuX+multiplayerMenuMargin, multiplayerMenuY+(multiplayerMenuH-Round(IPBackgroundBitmapH*IPImageWidth/IPBackgroundBitmapW))//2, multiplayerMenuW-2*multiplayerMenuMargin, Round(IPBackgroundBitmapH*IPImageWidth/IPBackgroundBitmapW))
		Gosub, DisableIPMenuKeys
		Gdip_DisposeImage(IPBackgroundBitmap),Gdip_DisposeImage(PortBackgroundBitmap)
		If (previousMultiplayerMenu[multiplayerMenulevel]="MultiPlayerSelectionMenu"){
			RLLog.Info(A_ThisFunc . " - User pressed the exit key to cancel the IP Selection Menu. Back to the Multi Player Selection Menu.")
			multiplayerMenulevel--
			Gosub, DrawMultiPlayerSelectionMenu
		} Else If (previousMultiplayerMenu[multiplayerMenulevel]="PlayerSelectionMenu"){
			RLLog.Info(A_ThisFunc . " - User pressed the exit key to cancel the IP Selection Menu. Back to the Number of Players Selection Menu.")
			multiplayerMenulevel--
			Gosub, DrawPlayerSelectionMenu
		} Else {
			RLLog.Info(A_ThisFunc . " - User pressed exit key. Exiting RocketLauncher session.")
			Gosub, CleanMultiplayerMenuMemory
			ExitModule()
		}
	Return
	IPMenuSelect:
		RLLog.Debug(A_ThisFunc . " - IPMenuSelect")
		multiplayerMenulevel++
		previousMultiplayerMenu[multiplayerMenulevel] := "IPSelectionMenu"
		IPSelectedDigit := []
		Loop, 17
			IPSelectedDigit[a_index] := If (IPDigit[a_index]=-1) ? "" : IPDigit[a_index]
		IPSelected := % IPSelectedDigit[1] . IPSelectedDigit[2] . IPSelectedDigit[3] . "." . IPSelectedDigit[4] . IPSelectedDigit[5] . IPSelectedDigit[6] . "." . IPSelectedDigit[7] . IPSelectedDigit[8] . IPSelectedDigit[9] . "." . IPSelectedDigit[10] . IPSelectedDigit[11] . IPSelectedDigit[12] 
		PortSelected := % IPSelectedDigit[13] . IPSelectedDigit[14] . IPSelectedDigit[15] . IPSelectedDigit[16] . IPSelectedDigit[17]
		If !(ValidIP(IPSelected)){
			RLLog.Warning(A_ThisFunc . " - CAREFUL WHEN POSTING THIS LOG PUBLICLY AS IT CONTAINS YOUR IP ON THE NEXT LINE")
			RLLog.Info(A_ThisFunc . " - Invalid IP Port Selected: " . IPSelected . ". Please try again.")
			Gdip_GraphicsClear(multiplayerMenu_G4)
			Gdip_Alt_TextToGraphics(multiplayerMenu_G4, "IP number must be lower or equal to 255.255.255.255. Please try again!", "x" . multiplayerMenuW-multiplayerMenuMargin . " y" . multiplayerMenuH-multiplayerMenuMargin . " Right c" . errorTextColor . " r4 s" . errorTextSize . " " . currentTextStyle, errorTextFont)	
			Alt_UpdateLayeredWindow(multiplayerMenu_hwnd4, multiplayerMenu_hdc4, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
			networkSession := false
			SetTimer, clearErrorMessage, %errorShowTime%
			Return
		} Else If !(ValidPort(PortSelected)){
			RLLog.Info(A_ThisFunc . " - Invalid Server Port Selected: " . PortSelected . ". Please try again.")
			Gdip_GraphicsClear(multiplayerMenu_G4)
			Gdip_Alt_TextToGraphics(multiplayerMenu_G4, "Port number must be lower or equal to 65535. Please try again!", "x" . multiplayerMenuW-multiplayerMenuMargin . " y" . multiplayerMenuH-multiplayerMenuMargin . " Right c" . errorTextColor . " r4 s" . errorTextSize . " " . currentTextStyle, errorTextFont)	
			Alt_UpdateLayeredWindow(multiplayerMenu_hwnd4, multiplayerMenu_hdc4, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
			networkSession := false
			SetTimer, clearErrorMessage, %errorShowTime%
			Return
		} Else {
			RLLog.Warning(A_ThisFunc . " - CAREFUL WHEN POSTING THIS LOG PUBLICLY AS IT CONTAINS YOUR IP ON THE NEXT LINE")
			RLLog.Info(A_ThisFunc . " - IP Selected: " . IPSelected . ". Port Selected: " . PortSelected)
			networkIP := IPSelected
			networkPort := PortSelected
			networkSession := true
		}
		Gosub, DisableIPMenuKeys
		Gdip_DisposeImage(IPBackgroundBitmap),Gdip_DisposeImage(PortBackgroundBitmap)
		
		if (networkType="server"){
			If !(disableSeverInfoMenu)
				Gosub, DrawServerInfoMenu
			Else If (setupNetwork)
				Gosub, DrawSetupNetworkMenu
			else
				multiplayerMenuExit := true	
		} else {
			Gosub, DrawSetupNetworkMenu
		}
	Return
	clearErrorMessage:
		Gdip_GraphicsClear(multiplayerMenu_G4)
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd4, multiplayerMenu_hdc4, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
	Return
	DrawPlayerSelectionMenu:
		RLLog.Debug(A_ThisFunc . " - Starting Player Selection Menu.")
		Gdip_GraphicsClear(multiplayerMenu_G2)
		; Initializing Variables
		currentNumberOfPlayers := currentNumberOfPlayers ? currentNumberOfPlayers : 1
		; Loading Players Background Image
		mpPlayerBackgroundImage := CheckFile(RLMediaPath . "\Menu Images\RocketLauncher\Player Slot.png")
		PlayerBackgroundBitmap := Gdip_CreateBitmapFromFile(mpPlayerBackgroundImage)
		Gdip_GetDimensions(PlayerBackgroundBitmap,PlayerBackgroundBitmapW,PlayerBackgroundBitmapH)
		NumberOfPlayers := []
		Loop, % networkPlayers
			{
			mpNumberOfPlayersImage := CheckFile(RLMediaPath . "\Menu Images\RocketLauncher\" . a_index . " Player.png")
			NumberOfPlayers[a_index,"Bitmap"] := Gdip_CreateBitmapFromFile(mpNumberOfPlayersImage)
			NumberOfPlayers[a_index,"BitmapH"] := Gdip_GetImageHeight(NumberOfPlayers[a_index,"Bitmap"])
			NumberOfPlayers[a_index,"BitmapW"] := Gdip_GetImageWidth(NumberOfPlayers[a_index,"Bitmap"])
			maxImageWidth := (NumberOfPlayers[a_index,"BitmapW"]>maxImageWidth) ? NumberOfPlayers[a_index,"BitmapW"] : maxImageWidth
		}
		PlayerSelectionMenuMargin := (multiplayerMenuW - PlayerBackgroundBitmapW - PlayerSelectionMenuMarginBetweenNumberAndImage - maxImageWidth)//2
		; Drawing current IP number
		pGraphUpd(multiplayerMenu_G3,PlayerBackgroundBitmapW, PlayerBackgroundBitmapH)		
		Gosub, UpdatePlayerNumber
		;Enabling Keys
		Gosub, EnablePlayerSelectionMenuKeys
	Return
	UpdatePlayerNumber:
		Gdip_GraphicsClear(multiplayerMenu_G2)
		Gdip_GraphicsClear(multiplayerMenu_G3)
		; Slot Background
		Gdip_DrawImage(multiplayerMenu_G2,PlayerBackgroundBitmap, PlayerSelectionMenuMargin,(multiplayerMenuH-PlayerBackgroundBitmapH)//2,PlayerBackgroundBitmapW,PlayerBackgroundBitmapH)
		; Player text
		Gdip_Alt_TextToGraphics(multiplayerMenu_G2, If (currentNumberOfPlayers=1) ? "Player" : "Players", "x" . PlayerSelectionMenuMargin+PlayerBackgroundBitmapW+PlayerSelectionMenuMarginBetweenNumberAndText . " y" . (multiplayerMenuH-PlayerSelectionMenuTextSize)//2 . " Left c" . PlayerSelectionMenuTextColor . " r4 s" . PlayerSelectionMenuTextSize . " Bold", PlayerSelectionMenuTextFont)	
		;Players Image
		Gdip_DrawImage(multiplayerMenu_G2,NumberOfPlayers[currentNumberOfPlayers,"Bitmap"], PlayerSelectionMenuMargin+PlayerBackgroundBitmapW+PlayerSelectionMenuMarginBetweenNumberAndImage,(multiplayerMenuH-NumberOfPlayers[currentNumberOfPlayers,"BitmapH"])//2,NumberOfPlayers[currentNumberOfPlayers,"BitmapW"],NumberOfPlayers[currentNumberOfPlayers,"BitmapH"])
		;Slot Number
		;previous
		If (currentNumberOfPlayers-1<1)
			previousNumber := networkPlayers-1
		Else
			previousNumber := currentNumberOfPlayers
		Gdip_Alt_TextToGraphics(multiplayerMenu_G3, previousNumber, "x" . PlayerBackgroundBitmapW//2 . " y" . PlayerSelectionMenuSlotTextSize//2 - PlayerBackgroundBitmapH//2 . " Center c" . PlayerSelectionMenuSlotSecondaryTextColor . " r4 s" . PlayerSelectionMenuSlotTextSize . " Bold", PlayerSelectionMenuSlotTextFont)	
		;current
		Gdip_Alt_TextToGraphics(multiplayerMenu_G3, currentNumberOfPlayers, "x" . PlayerBackgroundBitmapW//2 . " y" . PlayerSelectionMenuSlotTextSize//2 . " Center c" . PlayerSelectionMenuSlotTextColor . " r4 s" . PlayerSelectionMenuSlotTextSize . " Bold", PlayerSelectionMenuSlotTextFont)	
		;following
		If (currentNumberOfPlayers+1>networkPlayers)
			followingNumber := 1
		Else
			followingNumber := currentNumberOfPlayers+1
		Gdip_Alt_TextToGraphics(multiplayerMenu_G3, followingNumber, "x" . PlayerBackgroundBitmapW//2 . " y" . PlayerSelectionMenuSlotTextSize//2 + PlayerBackgroundBitmapH//2 . " Center c" . PlayerSelectionMenuSlotSecondaryTextColor . " r4 s" . PlayerSelectionMenuSlotTextSize . " Bold", PlayerSelectionMenuSlotTextFont)	
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd2, multiplayerMenu_hdc2, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd3, multiplayerMenu_hdc3, multiplayerMenuX+PlayerSelectionMenuMargin, multiplayerMenuY+(multiplayerMenuH-PlayerBackgroundBitmapH)//2, PlayerBackgroundBitmapW, PlayerBackgroundBitmapH)
	Return
	EnablePlayerSelectionMenuKeys:
		RLLog.Debug(A_ThisFunc . " - EnablePlayerSelectionMenuKeys")
		XHotKeywrapper(navSelectKey,"PlayerNumberMenuSelect","ON") 
		XHotKeywrapper(navUpKey,"PlayerNumberMenuUp","ON")
		XHotKeywrapper(navDownKey,"PlayerNumberMenuDown","ON")
		XHotKeywrapper(navLeftKey,"PlayerNumberMenuLeft","ON")
		XHotKeywrapper(navRightKey,"PlayerNumberMenuRight","ON")
		XHotKeywrapper(navP2UpKey,"PlayerNumberMenuUp","ON")
		XHotKeywrapper(navP2DownKey,"PlayerNumberMenuDown","ON")
		XHotKeywrapper(navP2LeftKey,"PlayerNumberMenuLeft","ON")
		XHotKeywrapper(navP2RightKey,"PlayerNumberMenuRight","ON")
		XHotKeywrapper(navP2SelectKey,"PlayerNumberMenuSelect","ON") 
		XHotKeywrapper(exitEmulatorKey,"ClosePlayerNumberMenu","ON")
		If keyboardControl
			Loop, 9
				Hotkey, % a_index, % "PlayerNumber" . a_index, On
	Return
	DisablePlayerSelectionMenuKeys:
		RLLog.Debug(A_ThisFunc . " - DisablePlayerSelectionMenuKeys")
		XHotKeywrapper(navSelectKey,"PlayerNumberMenuSelect","OFF") 
		XHotKeywrapper(navUpKey,"PlayerNumberMenuUp","OFF")
		XHotKeywrapper(navDownKey,"PlayerNumberMenuDown","OFF")
		XHotKeywrapper(navLeftKey,"PlayerNumberMenuLeft","OFF")
		XHotKeywrapper(navRightKey,"PlayerNumberMenuRight","OFF")
		XHotKeywrapper(navP2UpKey,"PlayerNumberMenuUp","OFF")
		XHotKeywrapper(navP2DownKey,"PlayerNumberMenuDown","OFF")
		XHotKeywrapper(navP2LeftKey,"PlayerNumberMenuLeft","OFF")
		XHotKeywrapper(navP2RightKey,"PlayerNumberMenuRight","OFF")
		XHotKeywrapper(navP2SelectKey,"PlayerNumberMenuSelect","OFF") 
		XHotKeywrapper(exitEmulatorKey,"ClosePlayerNumberMenu","OFF")
		If keyboardControl
			Loop, 9
				Hotkey, % a_index, % "PlayerNumber" . a_index, off
	Return
	PlayerNumber1:
	PlayerNumber2:
	PlayerNumber3:
	PlayerNumber4:
	PlayerNumber5:
	PlayerNumber6:
	PlayerNumber7:
	PlayerNumber8:
	PlayerNumber9:
		StringRight, currentNumericKey, A_ThisLabel, 1
		currentNumberOfPlayers:=currentNumericKey
		Gosub, UpdatePlayerNumber
	Return
	PlayerNumberMenuLeft:
	PlayerNumberMenuDown:
		currentNumberOfPlayers++
		If (currentNumberOfPlayers>networkPlayers)
			currentNumberOfPlayers:=1
		Gosub, UpdatePlayerNumber
	Return
	PlayerNumberMenuRight:
	PlayerNumberMenuUp:
		currentNumberOfPlayers--
		If (currentNumberOfPlayers<1)
			currentNumberOfPlayers:=networkPlayers
		Gosub, UpdatePlayerNumber
	Return
	ClosePlayerNumberMenu:
		Gdip_GraphicsClear(multiplayerMenu_G2)
		Gdip_GraphicsClear(multiplayerMenu_G3)
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd2, multiplayerMenu_hdc2, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd3, multiplayerMenu_hdc3, multiplayerMenuX+PlayerSelectionMenuMargin, multiplayerMenuY+(multiplayerMenuH-PlayerBackgroundBitmapH)//2, PlayerBackgroundBitmapW, PlayerBackgroundBitmapH)
		Gosub, DisablePlayerSelectionMenuKeys
		If (previousMultiplayerMenu[multiplayerMenulevel]="MultiPlayerSelectionMenu"){
			RLLog.Info(A_ThisFunc . " - User pressed the exit key to cancel the Number of Players Selection Menu. Back to the Multi Player Selection Menu.")
			multiplayerMenulevel--
			Gosub, DrawMultiPlayerSelectionMenu
		} Else {
			RLLog.Info(A_ThisFunc . " - User pressed exit key. Exiting RocketLauncher session.")
			Gosub, CleanMultiplayerMenuMemory
			ExitModule()
		}
	Return
	PlayerNumberMenuSelect:
		RLLog.Debug(A_ThisFunc . " - PlayerNumberMenuSelect")
		multiplayerMenulevel++
		previousMultiplayerMenu[multiplayerMenulevel] := "PlayerSelectionMenu"
		Gosub, DisablePlayerSelectionMenuKeys
		Gdip_DisposeImage(PlayerBackgroundBitmap)
		Loop, % networkPlayers
			Gdip_DisposeImage(NumberOfPlayers[a_index,"Bitmap"])
		If (SelectedMultiPlayerOption=4) {
			multiplayerMenuExit := true	
		} Else {
			if (serverMode="IPandPort")
				Gosub, DrawIPSelectionMenu
			else
				Gosub, DrawServerPortMenu
		}
	Return
	DrawServerPortMenu:
		RLLog.Debug(A_ThisFunc . " - Server Port Menu.")
		Gdip_GraphicsClear(multiplayerMenu_G2)
		Gdip_GraphicsClear(multiplayerMenu_G3)
		; Initializing Variables
		currentServerPortSlot := currentServerPortSlot ? currentServerPortSlot : 1
		if !ServerDigit
		{	ServerDigit:=[]
			Loop, 5
				ServerDigit[a_index] := -1
			If ValidPort(lastPort)
				{
				If (lastPort>9999){
					Loop, 5
						ServerDigit[a_index]:=SubStr(lastPort,a_index, 1)
				} Else If (lastPort>999){
					Loop, 4
						ServerDigit[a_index+1]:=SubStr(lastPort,a_index, 1)
				} Else If (lastPort>99){
					Loop, 3
						ServerDigit[a_index+2]:=SubStr(lastPort,a_index, 1)
				} Else If (lastPort>9){
					Loop, 2
						ServerDigit[a_index+3]:=SubStr(lastPort,a_index, 1)
				} Else
					ServerDigit[5]:=lastPort
			}
		}
		; Loading Server Background Images
		mpPortSlotImage := CheckFile(RLMediaPath . "\Menu Images\RocketLauncher\Port Slot.png")
		PortBackgroundBitmap := Gdip_CreateBitmapFromFile(mpPortSlotImage)
		Gdip_GetDimensions(PortBackgroundBitmap,PortBackgroundBitmapW,PortBackgroundBitmapH)
		PortSlotWidth := Round(PortBackgroundBitmapW/5)
		PortTitleW := MeasureText("Server Port Number"," Left c" . serverPortMenuTextColor . " r4 s" . serverPortMenuTextSize . " Bold",serverPortMenuTextFont)
		PortMargin := (multiplayerMenuW-PortBackgroundBitmapW-serverPortDistanceBetweenImageAndText-PortTitleW)//2
		Gdip_DrawImage(multiplayerMenu_G2,PortBackgroundBitmap, PortMargin,(multiplayerMenuH-PortBackgroundBitmapH)//2,PortBackgroundBitmapW,PortBackgroundBitmapH)
		Gdip_Alt_TextToGraphics(multiplayerMenu_G2, "Server Port Number", "x" . PortMargin+PortBackgroundBitmapW+serverPortDistanceBetweenImageAndText . " y" . (multiplayerMenuH)//2 - serverPortMenuTextSize//2 . " Left c" . serverPortMenuTextColor . " r4 s" . serverPortMenuTextSize . " Bold", serverPortMenuTextFont)	
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd2, multiplayerMenu_hdc2, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
		; Drawing current Port number
		pGraphUpd(multiplayerMenu_G3,multiplayerMenuW-2*multiplayerMenuMargin, PortBackgroundBitmapH)		
		Gosub, UpdateServerPortNumbers
		;Enabling Keys
		Gosub, EnableServerPortMenuKeys
	Return
	UpdateServerPortNumbers:
		Gdip_GraphicsClear(multiplayerMenu_G3)
		Loop, 5
			{
			If (a_index=currentServerPortSlot) {
				currentTextSize := serverPortSlotSelectedTextSize
				currentTextColor := serverPortSlotSelectedTextColor
				currentTextStyle := "bold"
				Gdip_Alt_DrawRectangle(multiplayerMenu_G3, IPSlotSelectedPen, (a_index-1)*PortSlotWidth, 0, PortSlotWidth, PortBackgroundBitmapH)
			} Else {
				currentTextSize := serverPortSlotDisabledTextSize
				currentTextColor := serverPortSlotDisabledTextColor
				currentTextStyle := "normal"
			}
			currentX := (a_index-1)*PortSlotWidth + PortSlotWidth//2
			Gdip_Alt_TextToGraphics(multiplayerMenu_G3, If (ServerDigit[a_index]=-1) ? "" : ServerDigit[a_index], "x" . currentX . " y" . Round((PortBackgroundBitmapH)/2-currentTextSize/2) . " Center c" . currentTextColor . " r4 s" . currentTextSize . " " . currentTextStyle, serverPortSlotTextFont)	
			;previous Number
			previousNumber := ServerDigit[a_index]-1
			If ((a_index=1) and (previousNumber<-1))
				previousNumber:=6	
			Else If (previousNumber<-1)
				previousNumber:=9
			Gdip_Alt_TextToGraphics(multiplayerMenu_G3, If (previousNumber=-1) ? "" : previousNumber, "x" . currentX . " y" . Round((PortBackgroundBitmapH)/2-currentTextSize/2)-Round((PortBackgroundBitmapH))//2 . " Center c" . serverPortSlotSecondaryTextColor . " r4 s" . currentTextSize . " " . currentTextStyle, serverPortSlotTextFont)	
			;following Number
			followingNumber := ServerDigit[a_index]+1
			If ((a_index=1) and (followingNumber>6))
				previousNumber:=-1
			Else If (followingNumber+1>9)
				followingNumber:=-1
			Gdip_Alt_TextToGraphics(multiplayerMenu_G3, If (followingNumber=-1) ? "" : followingNumber, "x" . currentX . " y" . Round((PortBackgroundBitmapH)/2-currentTextSize/2)+Round((PortBackgroundBitmapH))//2 . " Center c" . serverPortSlotSecondaryTextColor . " r4 s" . currentTextSize . " " . currentTextStyle, serverPortSlotTextFont)	
		}
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd3, multiplayerMenu_hdc3, multiplayerMenuX+PortMargin, multiplayerMenuY+(multiplayerMenuH-Round(PortBackgroundBitmapH))//2, multiplayerMenuW-2*multiplayerMenuMargin, PortBackgroundBitmapH)
	Return
	EnableServerPortMenuKeys:
		RLLog.Debug(A_ThisFunc . " - EnableServerPortMenuKeys")
		XHotKeywrapper(navSelectKey,"ServerPortMenuSelect","ON") 
		XHotKeywrapper(navUpKey,"ServerPortMenuUP","ON")
		XHotKeywrapper(navDownKey,"ServerPortMenuDown","ON")
		XHotKeywrapper(navLeftKey,"ServerPortMenuLeft","ON")
		XHotKeywrapper(navRightKey,"ServerPortMenuRight","ON")
		XHotKeywrapper(navP2UpKey,"ServerPortMenuUP","ON")
		XHotKeywrapper(navP2DownKey,"ServerPortMenuDown","ON")
		XHotKeywrapper(navP2LeftKey,"ServerPortMenuLeft","ON")
		XHotKeywrapper(navP2RightKey,"ServerPortMenuRight","ON")
		XHotKeywrapper(navP2SelectKey,"ServerPortMenuSelect","ON") 
		XHotKeywrapper(exitEmulatorKey,"CloseServerPortMenu","ON")
		If keyboardControl
			{
			Loop, 10
				Hotkey, % a_index-1, % "ServerPort" . a_index-1, On
			Hotkey, space, ServerPortSpace, On
			Hotkey, Backspace, ServerPortBackspace, On
			Hotkey, Delete, ServerPortDelete, On	
		}
	Return
	DisableServerPortMenuKeys:
		RLLog.Debug(A_ThisFunc . " - DisableServerPortMenuKeys")
		XHotKeywrapper(navSelectKey,"ServerPortMenuSelect","OFF") 
		XHotKeywrapper(navUpKey,"ServerPortMenuUP","OFF")
		XHotKeywrapper(navDownKey,"ServerPortMenuDown","OFF")
		XHotKeywrapper(navLeftKey,"ServerPortMenuLeft","OFF")
		XHotKeywrapper(navRightKey,"ServerPortMenuRight","OFF")
		XHotKeywrapper(navP2UpKey,"ServerPortMenuUP","OFF")
		XHotKeywrapper(navP2DownKey,"ServerPortMenuDown","OFF")
		XHotKeywrapper(navP2LeftKey,"ServerPortMenuLeft","OFF")
		XHotKeywrapper(navP2RightKey,"ServerPortMenuRight","OFF")
		XHotKeywrapper(navP2SelectKey,"ServerPortMenuSelect","OFF") 
		XHotKeywrapper(exitEmulatorKey,"CloseServerPortMenu","OFF")
		If keyboardControl
			{
			Loop, 10
				Hotkey, % a_index-1, % "ServerPort" . a_index-1, off
			Hotkey, space, ServerPortSpace, off
			Hotkey, Backspace, ServerPortBackspace, off
			Hotkey, Delete, ServerPortDelete, off	
		}
	Return
	ServerPortDelete:
	ServerPortBackspace:
	ServerPortSpace:
		ServerDigit[currentServerPortSlot]:=-1
		If (A_ThisLabel="ServerPortBackspace")
			Gosub, ServerPortMenuLeft
		Else
			Gosub, ServerPortMenuRight
		Gosub, UpdateServerPortNumbers
	Return
	ServerPort1:
	ServerPort2:
	ServerPort3:
	ServerPort4:
	ServerPort5:
	ServerPort6:
	ServerPort7:
	ServerPort8:
	ServerPort9:
	ServerPort0:
		StringRight, currentNumericKey, A_ThisLabel, 1
		ServerDigit[currentServerPortSlot]:=currentNumericKey
		Gosub, ServerPortMenuRight
		Gosub, UpdateServerPortNumbers
	Return
	ServerPortMenuLeft:
		currentServerPortSlot--
		If (currentServerPortSlot<1)
			currentServerPortSlot:=5
		Gosub, UpdateServerPortNumbers
	Return
	ServerPortMenuRight:
		currentServerPortSlot++
		If (currentServerPortSlot>5)
			currentServerPortSlot:=1
		Gosub, UpdateServerPortNumbers
	Return
	ServerPortMenuDown:
		ServerDigit[currentServerPortSlot]++
		If ((currentServerPortSlot=1) and (ServerDigit[currentServerPortSlot]>6))
			ServerDigit[currentServerPortSlot]:=-1
		Else If (ServerDigit[currentServerPortSlot]>9)
			ServerDigit[currentServerPortSlot]:=-1
		Gosub, UpdateServerPortNumbers
	Return
	ServerPortMenuUp:
		ServerDigit[currentServerPortSlot]--
		If ((currentServerPortSlot=1) and (ServerDigit[currentServerPortSlot]<-1))
			ServerDigit[currentServerPortSlot]:=6
		Else If (ServerDigit[currentServerPortSlot]<-1)
			ServerDigit[currentServerPortSlot]:=9
		Gosub, UpdateServerPortNumbers
	Return
	CloseServerPortMenu:
		Gdip_GraphicsClear(multiplayerMenu_G2)
		Gdip_GraphicsClear(multiplayerMenu_G3)
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd2, multiplayerMenu_hdc2, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd3, multiplayerMenu_hdc3, multiplayerMenuX+PortMargin, multiplayerMenuY+(multiplayerMenuH-Round(PortBackgroundBitmapH))//2, multiplayerMenuW-2*multiplayerMenuMargin, PortBackgroundBitmapH)
		Gosub, DisableServerPortMenuKeys
		If (previousMultiplayerMenu[multiplayerMenulevel]="MultiPlayerSelectionMenu"){
			RLLog.Info(A_ThisFunc . " - User pressed the exit key to cancel the Sever Port Menu. Back to the Multi Player Selection Menu.")
			multiplayerMenulevel--
			Gosub, DrawMultiPlayerSelectionMenu
		} Else If (previousMultiplayerMenu[multiplayerMenulevel]="PlayerSelectionMenu"){
			RLLog.Info(A_ThisFunc . " - User pressed the exit key to cancel the Sever Port Menu. Back to the Number of Players Selection Menu.")
			multiplayerMenulevel--
			Gosub, DrawPlayerSelectionMenu
		} Else {
			RLLog.Info(A_ThisFunc . " - User pressed exit key. Exiting RocketLauncher session.")
			Gosub, CleanMultiplayerMenuMemory
			ExitModule()
		}
	Return
	ServerPortMenuSelect:
		RLLog.Debug(A_ThisFunc . " - ServerPortMenuSelect")
		multiplayerMenulevel++
		previousMultiplayerMenu[multiplayerMenulevel] := "ServerPortMenu"
		ServerPortSelectedDigit := []
		Loop, 5
			ServerPortSelectedDigit[a_index] := If (ServerDigit[a_index]=-1) ? "" : ServerDigit[a_index]
		ServerPortSelected := % ServerPortSelectedDigit[1] . ServerPortSelectedDigit[2] . ServerPortSelectedDigit[3] . ServerPortSelectedDigit[4] . ServerPortSelectedDigit[5]
		If !(ValidPort(ServerPortSelected)){
			RLLog.Info(A_ThisFunc . " - Invalid Server Port Selected: " . ServerPortSelected . ". Please try again.")
			Gdip_GraphicsClear(multiplayerMenu_G4)
			Gdip_Alt_TextToGraphics(multiplayerMenu_G4, "Port number must be lower or equal to 65535. Please try again!", "x" . multiplayerMenuW-multiplayerMenuMargin . " y" . multiplayerMenuH-multiplayerMenuMargin . " Right c" . errorTextColor . " r4 s" . errorTextSize . " " . currentTextStyle, errorTextFont)	
			Alt_UpdateLayeredWindow(multiplayerMenu_hwnd4, multiplayerMenu_hdc4, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
			networkSession := false
			SetTimer, clearErrorMessage, %errorShowTime%
			Return
		} Else {
			RLLog.Info(A_ThisFunc . " - Server Port Selected: " . ServerPortSelected)
			networkPort := ServerPortSelected
			networkSession := true
		}
		Gosub, DisableServerPortMenuKeys
		Gdip_DisposeImage(PortBackgroundBitmap)
		Gdip_GraphicsClear(multiplayerMenu_G4)
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd4, multiplayerMenu_hdc4, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
		Gdip_GraphicsClear(multiplayerMenu_G3)
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd3, multiplayerMenu_hdc3, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
		Gdip_GraphicsClear(multiplayerMenu_G2)
		If (!(localIP) or !(publicIP)){
			Gdip_Alt_TextToGraphics(multiplayerMenu_G2, "Loading Server Info...", "x" . multiplayerMenuW//2 . " y" . (multiplayerMenuH-serverInfoMenuTextSize)//2 . " Center c" . serverInfoMenuTextColor . " r4 s" . serverInfoMenuTextSize . " Bold", serverInfoMenuTextFont)
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd2, multiplayerMenu_hdc2, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
			If !localIP
				localIP := GetLocalIP()
			If !publicIP
				publicIP := GetPublicIP()
		}
		If severUseNetworkIP
			networkIP := publicIP
		Else
			networkIP := localIP		
		If !(disableSeverInfoMenu)
			Gosub, DrawServerInfoMenu
		Else If (setupNetwork)
			Gosub, DrawSetupNetworkMenu
		else
			multiplayerMenuExit := true	
	Return
	DrawServerInfoMenu:
		RLLog.Debug(A_ThisFunc . " - Server Info Menu.")
		Gdip_GraphicsClear(multiplayerMenu_G2)
		InfoH := MeasureText("Tell your LAN clients to connect using the IP " . localIP[1,2] . "`r`nTell your WAN clients to connect using the IP " . publicIP . "`r`n`r`nBoth will use Port " . networkPort . "`r`n`r`nDo not forget to forward this port in your router to your LAN IP!!", "w" . multiplayerMenuW-2*multiplayerMenuMargin . " Center c" . serverInfoMenuTextColor . " r4 s" . serverInfoMenuTextSize . " Bold", serverInfoMenuTextFont,,,"H")
		Gdip_Alt_TextToGraphics(multiplayerMenu_G2, "Tell your LAN clients to connect using the IP " . localIP[1,2] . "`r`nTell your WAN clients to connect using the IP " . publicIP . "`r`n`r`nBoth will use Port " . networkPort . "`r`n`r`nDo not forget to forward this port in your router to your LAN IP!!", "x" . multiplayerMenuMargin . " y" . (multiplayerMenuH-InfoH)//2 . "w" . multiplayerMenuW-2*multiplayerMenuMargin . " Center c" . serverInfoMenuTextColor . " r4 s" . serverInfoMenuTextSize . " Bold", serverInfoMenuTextFont)	
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd2, multiplayerMenu_hdc2, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
		Gosub, EnableServerInfoMenuKeys
	Return
	EnableServerInfoMenuKeys:
		RLLog.Debug(A_ThisFunc . " - EnablePlayerSelectionMenuKeys")
		XHotKeywrapper(navSelectKey,"ServerInfoSelect","ON") 
		XHotKeywrapper(navP2SelectKey,"ServerInfoSelect","ON") 
		XHotKeywrapper(exitEmulatorKey,"CloseServerInfoMenu","ON")
	Return
	DisableServerInfoMenuKeys:
		RLLog.Debug(A_ThisFunc . " - DisablePlayerSelectionMenuKeys")
		XHotKeywrapper(navSelectKey,"ServerInfoSelect","OFF") 
		XHotKeywrapper(navP2SelectKey,"ServerInfoSelect","OFF") 
		XHotKeywrapper(exitEmulatorKey,"CloseServerInfoMenu","OFF")
	Return
	CloseServerInfoMenu:
		Gdip_GraphicsClear(multiplayerMenu_G2)
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd2, multiplayerMenu_hdc2, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
		Gosub, DisableServerInfoMenuKeys
		If (previousMultiplayerMenu[multiplayerMenulevel]="ServerPortMenu"){
			RLLog.Info(A_ThisFunc . " - User pressed the exit key to cancel the Sever Info Menu. Back to the Server Port Menu.")
			multiplayerMenulevel--
			Gosub, DrawServerPortMenu
		} Else {
			RLLog.Info(A_ThisFunc . " - User pressed exit key. Exiting RocketLauncher session.")
			Gosub, CleanMultiplayerMenuMemory
			ExitModule()
		}
	Return
	ServerInfoSelect:
		RLLog.Debug(A_ThisFunc . " - ServerInfoSelect")
		multiplayerMenulevel++
		previousMultiplayerMenu[multiplayerMenulevel] := "ServerInfoMenu"
		networkSession := true
		Gosub, DisableServerInfoMenuKeys
		if setupNetwork
			Gosub, DrawSetupNetworkMenu
		else
			multiplayerMenuExit := true	
	Return
	DrawSetupNetworkMenu:
		RLLog.Debug(A_ThisFunc . " - Starting Setup Network Menu.")
		Gdip_GraphicsClear(multiplayerMenu_G3)
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd3, multiplayerMenu_hdc3, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
		Gdip_GraphicsClear(multiplayerMenu_G2)
		; Initializing Variables
		currentSetupNetworkOption := 0
		; Loading Setup Network Background Image
		mpSetupNetworkBackgroundImage := CheckFile(RLMediaPath . "\Menu Images\RocketLauncher\Setup Network.png")
		SetupNetworkBackgroundBitmap := Gdip_CreateBitmapFromFile(mpSetupNetworkBackgroundImage)
		Gdip_GetDimensions(SetupNetworkBackgroundBitmap,SetupNetworkBackgroundBitmapW,SetupNetworkBackgroundBitmapH)
		;Drawing Image
		Gdip_DrawImage(multiplayerMenu_G2,SetupNetworkBackgroundBitmap, multiplayerMenuMargin,(multiplayerMenuH-SetupNetworkBackgroundBitmapH)//2,SetupNetworkBackgroundBitmapW,SetupNetworkBackgroundBitmapH)
		; Drawing question
		QuestionH := MeasureText("Do you need to setup the game's internal options to play Multi-Player first?", "w" . multiplayerMenuW-2*multiplayerMenuMargin-SetupNetworkBackgroundBitmapW-SetupNetworkMenuMarginBetweenOptionAndText . " Left c" . SetupNetworkMenuTextColor . " r4 s" . SetupNetworkMenuTextSize . " Bold", SetupNetworkMenuTextFont,,,"H")
		Gdip_Alt_TextToGraphics(multiplayerMenu_G2, "Do you need to setup the game's internal options to play Multi-Player first?", "x" . multiplayerMenuMargin+SetupNetworkBackgroundBitmapW+SetupNetworkMenuMarginBetweenOptionAndText . " y" . (multiplayerMenuH-QuestionH)//2 . " w" . multiplayerMenuW-2*multiplayerMenuMargin-SetupNetworkBackgroundBitmapW-SetupNetworkMenuMarginBetweenOptionAndText . " Left c" . SetupNetworkMenuTextColor . " r4 s" . SetupNetworkMenuTextSize . " Bold", SetupNetworkMenuTextFont)
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd2, multiplayerMenu_hdc2, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
		; Drawing current IP number
		pGraphUpd(multiplayerMenu_G3,SetupNetworkBackgroundBitmapW, SetupNetworkBackgroundBitmapH)		
		Gosub, UpdateSetupNetworkOption
		;Enabling Keys
		Gosub, EnableSetupNetworkMenuKeys
	Return
	UpdateSetupNetworkOption:
		Gdip_GraphicsClear(multiplayerMenu_G3)
		currentColor := (currentSetupNetworkOption=1) ? SetupNetworkMenuSlotYesTextColor : SetupNetworkMenuSlotNoTextColor
		Gdip_Alt_TextToGraphics(multiplayerMenu_G3, If (currentSetupNetworkOption=1) ? "YES" : "NO", "x" . SetupNetworkBackgroundBitmapW//2 . " y" . SetupNetworkBackgroundBitmapH//2-SetupNetworkMenuSlotTextSize//2 . " Center c" . currentColor . " r4 s" . SetupNetworkMenuSlotTextSize . " Bold", PlayerSelectionMenuSlotTextFont)	
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd3, multiplayerMenu_hdc3, multiplayerMenuX+multiplayerMenuMargin, multiplayerMenuY+(multiplayerMenuH-SetupNetworkBackgroundBitmapH)//2, SetupNetworkBackgroundBitmapW, SetupNetworkBackgroundBitmapH)
	Return
	EnableSetupNetworkMenuKeys:
		RLLog.Debug(A_ThisFunc . " - EnableSetupNetworkMenuKeys")
		XHotKeywrapper(navSelectKey,"SetupNetworkMenuSelect","ON") 
		XHotKeywrapper(navUpKey,"SetupNetworkMenuUp","ON")
		XHotKeywrapper(navDownKey,"SetupNetworkMenuDown","ON")
		XHotKeywrapper(navLeftKey,"SetupNetworkMenuLeft","ON")
		XHotKeywrapper(navRightKey,"SetupNetworkMenuRight","ON")
		XHotKeywrapper(navP2UpKey,"SetupNetworkMenuUp","ON")
		XHotKeywrapper(navP2DownKey,"SetupNetworkMenuDown","ON")
		XHotKeywrapper(navP2LeftKey,"SetupNetworkMenuLeft","ON")
		XHotKeywrapper(navP2RightKey,"SetupNetworkMenuRight","ON")
		XHotKeywrapper(navP2SelectKey,"SetupNetworkMenuSelect","ON") 
		XHotKeywrapper(exitEmulatorKey,"CloseSetupNetworkMenu","ON")
	Return
	DisableSetupNetworkMenuKeys:
		RLLog.Debug(A_ThisFunc . " - DisableSetupNetworkMenuKeys")
		XHotKeywrapper(navSelectKey,"SetupNetworkMenuSelect","OFF") 
		XHotKeywrapper(navUpKey,"SetupNetworkMenuUp","OFF")
		XHotKeywrapper(navDownKey,"SetupNetworkMenuDown","OFF")
		XHotKeywrapper(navLeftKey,"SetupNetworkMenuLeft","OFF")
		XHotKeywrapper(navRightKey,"SetupNetworkMenuRight","OFF")
		XHotKeywrapper(navP2UpKey,"SetupNetworkMenuUp","OFF")
		XHotKeywrapper(navP2DownKey,"SetupNetworkMenuDown","OFF")
		XHotKeywrapper(navP2LeftKey,"SetupNetworkMenuLeft","OFF")
		XHotKeywrapper(navP2RightKey,"SetupNetworkMenuRight","OFF")
		XHotKeywrapper(navP2SelectKey,"SetupNetworkMenuSelect","OFF") 
		XHotKeywrapper(exitEmulatorKey,"CloseSetupNetworkMenu","OFF")
	Return
	SetupNetworkMenuLeft:
	SetupNetworkMenuDown:
	SetupNetworkMenuRight:
	SetupNetworkMenuUp:
		If (currentSetupNetworkOption=1)
			currentSetupNetworkOption=0
		Else
			currentSetupNetworkOption=1
		Gosub, UpdateSetupNetworkOption
	Return
	CloseSetupNetworkMenu:
		Gdip_GraphicsClear(multiplayerMenu_G2)
		Gdip_GraphicsClear(multiplayerMenu_G3)
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd2, multiplayerMenu_hdc2, multiplayerMenuX, multiplayerMenuY, multiplayerMenuW, multiplayerMenuH)
		Alt_UpdateLayeredWindow(multiplayerMenu_hwnd3, multiplayerMenu_hdc3, multiplayerMenuX+multiplayerMenuMargin, multiplayerMenuY+(multiplayerMenuH-SetupNetworkBackgroundBitmapH)//2, SetupNetworkBackgroundBitmapW, SetupNetworkBackgroundBitmapH)
		Gosub, DisableSetupNetworkMenuKeys
		If (previousMultiplayerMenu[multiplayerMenulevel]="IPSelectionMenu"){
			RLLog.Info(A_ThisFunc . " - User pressed the exit key to cancel the Setup Network Menu. Back to the IP Selection Menu.")
			multiplayerMenulevel--
			Gosub, DrawIPSelectionMenu
		} Else If (previousMultiplayerMenu[multiplayerMenulevel]="ServerInfoMenu"){
			RLLog.Info(A_ThisFunc . " - User pressed the exit key to cancel the Setup Network Menu. Back to the Server Info Menu.")
			multiplayerMenulevel--
			Gosub, DrawServerInfoMenu
		} Else {
			RLLog.Info(A_ThisFunc . " - User pressed exit key. Exiting RocketLauncher session.")
			Gosub, CleanMultiplayerMenuMemory
			ExitModule()
		}
	Return
	SetupNetworkMenuSelect:
		RLLog.Debug(A_ThisFunc . " - SetupNetworkMenuSelect")
		multiplayerMenulevel++
		previousMultiplayerMenu[multiplayerMenulevel] := "SetupNetworkMenu"
		Gosub, DisableSetupNetworkMenuKeys
		Gdip_DisposeImage(SetupNetworkBackgroundBitmap)
		If (currentSetupNetworkOption=1){
			RLLog.Info(A_ThisFunc . " - User selected to run the multiplayer network setup.")
			networkRequiresSetup := true
		} Else {
			RLLog.Info(A_ThisFunc . " - User selected to not run the multiplayer network setup.")
			networkRequiresSetup := false
		}
		networkSession := true
		multiplayerMenuExit := true
	Return
}
