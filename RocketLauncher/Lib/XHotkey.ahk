MCRC := "B2090C73"
MVersion := "1.0.5"

; xHotkey Functions:
; xHotkey        - Extended Hotkey command allowing the use of multile keys pressed at the same time to execute specific labels for single click, hold Key, double click and more them two clicks modes.
;                  example of use: singleclick: XHotkey("~Esc","CloseProcess") 
;				                                hold 2 seconds: XHotkey("~Esc",,,"PauseLabel",2)
;				                                two simultaneous functions: XHotkey("~Esc","CloseProcess",,"PauseLabel",2)
; 				                                Single, Hold, Double or three or more clicks asigned to different gosub labels: XHotkey("~A|~S&~D|~q&~w&~e|~Joy1 & ~Joy2","SingleClick",,"ClickandHold",1,"DoubleClick","MoreThanTwoClicks",600)
;                                               disable xHotkey: XHotkey("~Esc",,"OFF")
;
; xHotKeywrapper - xHotkey command Wrapper for RocketLauncher use (allows sinlge line definition of XHotkey parameters)
;                  example of use: XHotKeywrapper("~Esc|H2000:~Z|~X|~A|~S&~D|~q & ~w & ~e|~Joy1 & ~Joy2|D:T:~F|D:T:~R&~T","CloseProcess")
;	
; xHotkeyVarEdit - function to remove or add key modifiers to previous defined XHotkeyWrapper key variables (these modifiers update should be called before calling the XHotkeyWrapper function)
;					example of use: exitEmulatorKey=Esc
;                                   xHotkeyVarEdit(exitEmulatorKey,"exitEmulatorKey","~","Add")
;  									xHotKeywrapper(exitEmulatorKey,"CloseProcess") 

; ---------------------------------------------
; XHOTKEY FUNCTION CODE WRAPPER
; ---------------------------------------------
; H1000 - means to enable hold for 1 second of the key group to go to label
; S or nothing - means to enable single click of the key group to go to label
; D - means to enable double click of the key group to go to label (If you use a number after the D, D600:, it means that xhotkey will wait 600 miliseconds for a second key press)
; T - means to enable more than two clicks of the key group to go to label

XHotKeywrapper(ExtendedKeyName,GeneralLabel,Options:="ON"){
	If !ExtendedKeyName
		Return
	Loop, parse, ExtendedKeyName, |, %A_Space% 
		{
		Nooption := true
		Keyoptions := DelimitedReversal(A_LoopField,"`:")
		Loop, parse, Keyoptions, `:, %A_Space%
		{
			wrapperLabelForSingleKey :=
			wrapperLabelForHoldKey :=
			wrapperLabelForDoubleClick :=
			wrapperLabelForMoreThanTwoClicks :=
			wrapperKeyHoldWait := 
			wrapperDoubleClickWait :=
			currentparseitem := A_index 
			If currentparseitem = 1
				Keys := A_loopfield	
			Else {
				If A_loopfield contains S,H,D,T
					Nooption := false
				If InStr(A_loopfield,"S")
					wrapperLabelForSingleKey := GeneralLabel
				If InStr(A_loopfield,"H"){
					wrapperLabelForHoldKey := GeneralLabel
					StringTrimLeft, wrapperKeyHoldWait, A_Loopfield, 1
					wrapperKeyHoldWait := wrapperKeyHoldWait/1000
					If not wrapperKeyHoldWait
						wrapperKeyHoldWait := 1 ;default value
				}
				If InStr(A_loopfield,"D"){
					wrapperLabelForDoubleClick := GeneralLabel
					StringTrimLeft, wrapperDoubleClickWait, A_Loopfield, 1
					If not wrapperDoubleClickWait
						wrapperDoubleClickWait := 600 ;default value
				}
				If InStr(A_loopfield,"T"){
					wrapperLabelForMoreThanTwoClicks := GeneralLabel
					StringTrimLeft, wrapperDoubleClickWait, A_Loopfield, 1
					If not wrapperDoubleClickWait
						wrapperDoubleClickWait := 600 ;default value
				}
			}
		}
		If Nooption 
			wrapperLabelForSingleKey := GeneralLabel
		If Keyoptions
			XHotkey(Keys,wrapperLabelForSingleKey,Options,wrapperLabelForHoldKey,wrapperKeyHoldWait,wrapperLabelForDoubleClick,wrapperLabelForMoreThanTwoClicks,wrapperDoubleClickWait)
	}
	Return
}

DelimitedReversal( str, delimiter:="`n" ) { ; By [VxE]. Reverses the order of substrings in 'string'.
	oel := ErrorLevel, ptr := A_PtrSize = "" ? "UInt" : "Ptr", len := StrLen( str ) << uni := A_IsUnicode = 1
	Loop, Parse, str, % delimiter := SubStr( delimiter "`n", 1, 1 )
		If ( siz := StrLen( sub := A_LoopField . ( A_Index = 1 ? "" : delimiter ) ) << uni )
			DllCall( "RtlMoveMemory", ptr, &str + len -= siz, ptr, &sub, "UInt", siz )
	Return str, ErrorLevel := oel
}

; ---------------------------------------------
; XHOTKEY FUNCTION CODE
; ---------------------------------------------
;Options:
;	ExtendedKeyName: ~A&~S|~q & ~w & ~e|~Joy1 & ~Joy2 
;	LabelForSingleKey: Same as original Hotkey command Label. 
;	Options: Original Hotkey command options (UseErrorLevel,On,Off,B or B0,Pn,Tn)
;	KeyWait: Optional, Time needed holding down the key combination for going to the label defined on LabelForSingleKey. If empty, the key combination redirects to the label instantaneously with a single key press.
;	LabelForDoubleClick: The label name whose contents will be executed when the double click is executed. 
;	LabelForMoreThanTwoClicks: The label name whose contents will be executed when more them two clicks are executed. 
;	DoubleClickKeyWait: Optional, Time between key press to register a double click (go to the label defined on LabelForDoubleKey). If empty there is no double click label redirection (acts always as a single key press).

;Preprocess multiple key assignments
XHotkey(ExtendedKeyName,LabelForSingleKey:="",Options:="ON",LabelForHoldKey:="",KeyHoldWait:="1",LabelForDoubleClick:="",LabelForMoreThanTwoClicks:="",DoubleClickKeyWait:="600"){
	Global
	IgnoreMultipleKeys := 0
	Loop, Parse, ExtendedKeyName, |, %A_Space% 
	{
		XHotkeyTableCreation(A_LoopField,LabelForSingleKey,Options,LabelForHoldKey,KeyHoldWait,LabelForDoubleClick,LabelForMoreThanTwoClicks,DoubleClickKeyWait)
	}
	Return
}

;xHotkey Table Creation
XHotkeyTableCreation(KeyGroup,LabelForSingleKey:="",Options:="",LabelForHoldKey:="",KeyHoldWait:="",LabelForDoubleClick:="",LabelForMoreThanTwoClicks:="",DoubleClickKeyWait:=""){
	Global
	RLLog.Debug(A_ThisFunc . " - Started")
	GoSubTimeDelay := 30 ; minimun time in miliseconds between key commands (necessary to avoid multiple gosub calls) 
	LabelHoldCallDelay := 3000 ; minimun time in miliseconds between labels call after a hold call (necessary to avoid ghost label calls after an hold key press)  
	KeyGroup := RegexReplace( KeyGroup, "^\s+|\s+$") ; KeyGroup without any spaces
	;Saving sorted Keys to avoid considering different ordered keys as different table items (ex. A&S and S&A should be the same table item)
	Keys := Array_Lib()
	Loop, Parse, KeyGroup, &,%a_space%
		{
		Keys.append(A_LoopField)
	}
	KeyGroup := Keys.sort().join("&")
	KeyGroupWithSpaces := KeyGroup
	If InStr(KeyGroup,"&")
		StringReplace, KeyGroupWithSpaces, KeyGroup, &, %a_space%&%a_space% ;  KeyGroup with spaces between multiple keys to avoid autohotkey error in normal hotkey call
	If !XHotKeyTable
        XHotKeyTable:=[] ; create key table XHotKeyTable[TableNumber,keynumber,column]
	If KeyGroup not in %TableKeyGroups% 
		{
		RLLog.Debug(A_ThisFunc . " - KeyGroup " . KeyGroup . " not in TableKeyGroups " . TableKeyGroups)
		KeyGroupNumber++
		currentGroup := KeyGroupNumber
		currentkeyNumber := 0
		XHotKeyTable[currentGroup,1,1] := KeyGroup
		Loop, Parse, KeyGroup, &,%a_space%
		{
			currentkeyNumber++
			currentkey := RegexReplace( A_LoopField, "^\s+|\s+$" )
			XHotKeyTable[currentGroup,currentkeyNumber,2] := currentkey	; Store each exit key in column 3 as they are defined in the var
			XHotKeyTable[currentGroup,1,3] := currentkeyNumber  ; number of keys in this group  
			replace := {"~":"","*":"","$":""} ; Saving Keys without modifiers
			currentKeyClean := currentkey
			For what, with in replace
				{
				If InStr(currentKeyClean,what)
					StringReplace, currentKeyClean, currentKeyClean, %what%, %with%, All
			}
			XHotKeyTable[currentGroup,currentkeyNumber,4] := currentKeyClean
		}
		RLLog.Debug(A_ThisFunc . " - Post loop 1 check")
		XHotKeyTable[currentGroup,1,5] := 0 ; initialize key press count for single, double and triple clicks
		XHotKeyTable[currentGroup,1,6] := LabelForSingleKey ; save label for single click
		XHotKeyTable[currentGroup,1,7] := LabelForHoldKey ; save label for press and hold
		XHotKeyTable[currentGroup,1,8] := KeyHoldWait ; save key hold wait time 
		XHotKeyTable[currentGroup,1,9] := LabelForDoubleClick ; save label for double click
		XHotKeyTable[currentGroup,1,10] := LabelForMoreThanTwoClicks ; save label for three or more clicks
		XHotKeyTable[currentGroup,1,11] := DoubleClickKeyWait ; save label for double click time between keys
		If not InStr(options, "OFF"){
			If	LabelForSingleKey
				XHotKeyTable[currentGroup,1,13] := true
			If	LabelForHoldKey
				XHotKeyTable[currentGroup,2,13] := true
			If	LabelForDoubleClick
				XHotKeyTable[currentGroup,3,13] := true
			If	LabelForMoreThanTwoClicks
				XHotKeyTable[currentGroup,4,13] := true
		} Else {
			If	LabelForSingleKey
				XHotKeyTable[currentGroup,1,13] := false
			If	LabelForHoldKey
				XHotKeyTable[currentGroup,2,13] := false
			If	LabelForDoubleClick
				XHotKeyTable[currentGroup,3,13] := false
			If	LabelForMoreThanTwoClicks
				XHotKeyTable[currentGroup,4,13] := false
		}
		RLLog.Debug(A_ThisFunc . " - Post loop 2 check")
		If (((Instr(KeyGroup,"joy")) and (XHotKeyTable[currentGroup,1,3]=1)) or ( not(Instr(KeyGroup,"joy")) and (XHotKeyTable[currentGroup,1,3]<=2))) and (((LabelForHoldKey="") and (LabelForDoubleClick="") and (LabelForMoreThanTwoClicks="") )){ ; defining normal hotkey command If the key group has: only one joy button or If it is a single key press with one or two simultaneous keys
			RLLog.Debug(A_ThisFunc . " - " . (If options = "OFF" ? "Disabling """ . LabelForSingleKey . """ standard Hotkey method for key(s): """ . KeyGroupWithSpaces . """" : "Using standard Hotkey method for key(s): """ . KeyGroupWithSpaces . """ to call label: """ . LabelForSingleKey . """"))
			Hotkey, % KeyGroupWithSpaces, %LabelForSingleKey%, %Options% ; normal hotkey command
		} Else { ; defining extended hotkey command If there are more them two simultaneous keys pressed (more them one for joy), or If it has hold, double or more click presses
			RLLog.Debug(A_ThisFunc . " - " . (If options = "OFF" ? "Disabling extended Hotkey method for key(s): """ . KeyGroup . """" : "Using extended Hotkey method for key(s): """ . KeyGroup . """ to call a group label"))
			Loop, Parse, KeyGroup, &,%a_space%
				{
				Hotkey, % XHotKeyTable[currentGroup,A_Index,2], HotKeyModeProcess, %Options% ; go to sub to test multiple key press If any exit emulator key is pressed
				XHotKeyTable[currentGroup,1,12] := true
			}
		}
		TableKeyGroups .= KeyGroup . ","
		RLLog.Debug(A_ThisFunc . " - Ended")
		Return XHotKeyTable
	} Else {
		RLLog.Debug(A_ThisFunc . " - KeyGroup " . KeyGroup . " is in TableKeyGroups " . TableKeyGroups)
		currentGroup:=0
		Loop, %KeyGroupNumber%
			{	
			currentGroup++
			currentKeysonKeyGroup := XHotKeyTable[currentGroup,1,1]
			If (currentKeysonKeyGroup = KeyGroup){
				Break
			}
		}
		RLLog.Debug(A_ThisFunc . " - Post loop 10 check")
			If not InStr(options, "OFF"){
				If	LabelForSingleKey
					XHotKeyTable[currentGroup,1,13] := true
				If	LabelForHoldKey
					XHotKeyTable[currentGroup,2,13] := true
				If	LabelForDoubleClick
					XHotKeyTable[currentGroup,3,13] := true
				If	LabelForMoreThanTwoClicks
					XHotKeyTable[currentGroup,4,13] := true
			} Else {
				If	LabelForSingleKey
					XHotKeyTable[currentGroup,1,13] := false
				If	LabelForHoldKey
					XHotKeyTable[currentGroup,2,13] := false
				If	LabelForDoubleClick
					XHotKeyTable[currentGroup,3,13] := false
				If	LabelForMoreThanTwoClicks
					XHotKeyTable[currentGroup,4,13] := false
			}
			If not InStr(options, "OFF"){
				If LabelForSingleKey
					If (XHotKeyTable[currentGroup,1,6] <> LabelForSingleKey)
						XHotKeyTable[currentGroup,1,6] := LabelForSingleKey ; update label for single click
				If LabelForHoldKey
					If XHotKeyTable[currentGroup,1,7] <> LabelForHoldKey
						XHotKeyTable[currentGroup,1,7] := LabelForHoldKey ; update label for press and hold
				If KeyHoldWait	
					If XHotKeyTable[currentGroup,1,8] <> KeyHoldWait
						XHotKeyTable[currentGroup,1,8] := KeyHoldWait ; update key hold wait time 
				If LabelForDoubleClick
					If XHotKeyTable[currentGroup,1,9] <> LabelForDoubleClick
						XHotKeyTable[currentGroup,1,9] := LabelForDoubleClick ; update label for double click
				If LabelForMoreThanTwoClicks
					If XHotKeyTable[currentGroup,1,10] <> LabelForMoreThanTwoClicks
						XHotKeyTable[currentGroup,1,10] := LabelForMoreThanTwoClicks ; update label for three or more clicks
				If DoubleClickKeyWait
					If XHotKeyTable[currentGroup,1,11] <> DoubleClickKeyWait
						XHotKeyTable[currentGroup,1,11] := DoubleClickKeyWait ; update label for double click time between keys
			}
			If not XHotKeyTable[currentGroup,1,12] ; disabling previous normal hotkey command If previously defined
			{	Hotkey, %KeyGroupWithSpaces%, Off
				RLLog.Debug(A_ThisFunc . " - Disabled Hotkey for: """ . KeyGroupWithSpaces . """")
			}
			RLLog.Debug(A_ThisFunc . " - Post loop 11 check")
			If (((Instr(KeyGroup,"joy")) and (XHotKeyTable[currentGroup,1,3]=1)) or ( not(Instr(KeyGroup,"joy")) and (XHotKeyTable[currentGroup,1,3]<=2))) and (((LabelForHoldKey="") and (LabelForDoubleClick="") and (LabelForMoreThanTwoClicks="") )){ ; defining normal hotkey command If the key group has: only one joy button or If it is a single key press with one or two simultaneous keys 
				RLLog.Debug(A_ThisFunc . " - " . (If options = "OFF" ? "Disabling """ . LabelForSingleKey . """ standard Hotkey method for key(s): """ . KeyGroupWithSpaces . """" : "Using standard Hotkey method for key(s): """ . KeyGroupWithSpaces . """ to call label: """ . LabelForSingleKey . """"))
				Hotkey, % KeyGroupWithSpaces, %LabelForSingleKey%, %Options% ; normal hotkey command
			} Else { ; defining extended hotkey command If there are more them two simultaneous keys pressed (more them one for joy), or If it has hold, double or more click presses
				RLLog.Debug(A_ThisFunc . " - " . (If options = "OFF" ? "Disabling extended Hotkey method for key(s): """ . KeyGroup . """" : "Using extended Hotkey method for key(s): """ . KeyGroup . """ to call a group label"))
				Loop, Parse, KeyGroup, &,%a_space%
					{
					Hotkey, % XHotKeyTable[currentGroup,A_Index,2], HotKeyModeProcess, %Options% ; go to sub to test multiple key press If any exit emulator key is pressed
					XHotKeyTable[currentGroup,1,12] := true
				}
			}
			RLLog.Debug(A_ThisFunc . " - Post loop 12 check")
		RLLog.Debug(A_ThisFunc . " - Ended")
		Return
	}
}

HotKeyModeProcess:
	If (A_TickCount < LastHotKeyModeProcessTime+GoSubTimeDelay) ; XHotkeyMinimunDelay  necessary to avoid multiple calls to subs in multiple Key groups
		Return
	LastHotKeyModeProcessTime := A_TickCount	
	currentkey := A_ThisHotkey ; current pressed keys
	replace := {"~":"","*":"","$":""} ; Saving current Key without modifiers to use on Keywait 
	For what, with in replace
		{
		If InStr(currentkey,what)
			StringReplace, currentkey, currentkey, %what%, %with%, All
	}
	currentGroup:=0
	Loop, %KeyGroupNumber%
		{	
		currentGroup++ 
		If XHotKeyTable[currentGroup,1,12] 
			{
			If AllKeysPressed(currentGroup) {
				CurrentPressandHoldLabel := % XHotKeyTable[currentGroup,1,7]	
				CurrentKeyHoldWait := % XHotKeyTable[currentGroup,1,8]
				If %CurrentPressandHoldLabel%
					KeyWait, %currentKey%, t%currentKeyHoldWait%
				Else
					KeyWait, %currentKey%
				If (GetKeyState(currentKey,"p")) ; could be a hold key press  
				{
					If IsLabel(CurrentPressandHoldLabel)
						If XHotKeyTable[currentGroup,2,13]
							If (A_TickCount > lastHoldLabelCall + LabelHoldCallDelay)
							{
								lastHoldLabelCall := A_TickCount
								Log("1",3)
								Gosub, %CurrentPressandHoldLabel%
							}
					LastGoSubTime := A_TickCount
					currentHoldKeyPressed := currentKey
					SetTimer, checkHoldKeyUp, 50
					XHotKeyTable[currentGroup,1,5] := 0 ; reset the count to prepare for the next series of presses
					Return
				} Else {
					If (XHotKeyTable[currentGroup,1,5]) > 0 { ; SetTimer already started, so we log the keypress instead
						If (IgnoreMultipleKeys>0) { ; necessary to avoid multiple key count in multiple Key groups
							IgnoreMultipleKeys--
						Return
						}
						IgnoreMultipleKeys := XHotKeyTable[currentGroup,1,3]-1
						XHotKeyTable[currentGroup,1,5]++
						Return
					}
					XHotKeyTable[currentGroup,1,5] := 1 ; Otherwise, this is the first press of a new series. Set count to 1 and start the timer:
					ActiveCurrentGroup := currentGroup
					CurrentDoubleClickKeyWait := % XHotKeyTable[ActiveCurrentGroup,1,11]
					If XHotKeyTable[ActiveCurrentGroup,1,9] or XHotKeyTable[ActiveCurrentGroup,1,10] {
						If XHotKeyTable[currentGroup,3,13] or XHotKeyTable[currentGroup,4,13]
							SetTimer, MultipleClickCheck, %CurrentDoubleClickKeyWait% ; Wait for more presses within a CurrentDoubleClickKeyWait millisecond time.
						Return
					} Else {
						CurrentSinglePressLabel := % XHotKeyTable[ActiveCurrentGroup,1,6]
						If IsLabel(CurrentSinglePressLabel)
							{
							If XHotKeyTable[currentGroup,1,13]
								If (A_TickCount > lastHoldLabelCall + LabelHoldCallDelay)
								{			Log("2",3)

									Gosub %CurrentSinglePressLabel%
								}
							LastGoSubTime := A_TickCount
						}
						XHotKeyTable[ActiveCurrentGroup,1,5] := 0 ; reset the count to prepare for the next series of presses
					}
					Return
				}
			}
		}
	}		
Return

checkHoldKeyUp:
	If !(GetKeyState(currentHoldKeyPressed,"p"))
		SetTimer, checkHoldKeyUp, off
Return

MultipleClickCheck: ;checking If the key group was pressed once, twice or more times.
	SetTimer, MultipleClickCheck, off
	CurrentSinglePressLabel := % XHotKeyTable[ActiveCurrentGroup,1,6]
	CurrentDoubleClickLabel := % XHotKeyTable[ActiveCurrentGroup,1,9]
	CurrentLabelForMoreThanTwoClicks := % XHotKeyTable[ActiveCurrentGroup,1,10]
	If (XHotKeyTable[ActiveCurrentGroup,1,5] > 2) and (IsLabel(CurrentLabelForMoreThanTwoClicks)) { ; The key was pressed three or more times.
		If XHotKeyTable[currentGroup,4,13]
			If (A_TickCount > lastHoldLabelCall + LabelHoldCallDelay) {
				Log("3",3)

				Gosub, %CurrentLabelForMoreThanTwoClicks%
			}
		LastGoSubTime := A_TickCount
	} Else If (XHotKeyTable[ActiveCurrentGroup,1,5] > 1) and (IsLabel(CurrentDoubleClickLabel)) { ; The key was pressed twice.
		If XHotKeyTable[currentGroup,3,13]
			If (A_TickCount > lastHoldLabelCall + LabelHoldCallDelay) {
			Log("4",3)
				Gosub, %CurrentDoubleClickLabel%
			}
		LastGoSubTime := A_TickCount
	} Else {
		If IsLabel(CurrentSinglePressLabel)
			If XHotKeyTable[currentGroup,1,13]
				If (A_TickCount > lastHoldLabelCall + LabelHoldCallDelay) {
					Log("5",3)
					Gosub %CurrentSinglePressLabel%
				}
		LastGoSubTime := A_TickCount
	}
	XHotKeyTable[ActiveCurrentGroup,1,5] := 0 ; reset the count to prepare for the next series of presses
Return


AllKeysPressed(currentKeygroup) { ; function to check If the keys are pressed simultneously
	Global
		ExitKeysPressed := true
		Loop, % XHotKeyTable[currentKeygroup,1,3]
		{
			If XHotKeyTable[currentKeygroup,A_index,4]
				If not (GetKeyState(XHotKeyTable[currentKeygroup,A_index,4],"p"))
					ExitKeysPressed := false
		}
		If ExitKeysPressed
			Return 1
	Return 0
}


; ---------------------------------------------
; XHOTKEYVAREDIT FUNCTION
; ---------------------------------------------
xHotKeyVarEdit(KeyEditList,KeyEditListVar,Keymodifier:="",action:="") {
	Loop, parse, %KeyEditListVar%, |, %A_Space% 
		{
		initialKeyEditListGroup := A_LoopField
		replace := {"~":"","*":"","$":""} ; removing modifiers before comparing keys
		currentVarKeyGroup := A_LoopField
		For what, with in replace
			{
			If InStr(currentVarKeyGroup,what)
				StringReplace, currentVarKeyGroup, currentVarKeyGroup, %what%, %with%, All
		}
		currentVarKeyGroup := RegexReplace( currentVarKeyGroup, "i)S:" ) ; removing options from keys
		currentVarKeyGroup := RegexReplace( currentVarKeyGroup, "i)H(.*):" ) ; removing options from keys
		currentVarKeyGroup := RegexReplace( currentVarKeyGroup, "i)D(.*):" ) ; removing options from keys
		currentVarKeyGroup := RegexReplace( currentVarKeyGroup, "i)T(.*):" ) ; removing options from keys
		currentVarKeyGroup := RegexReplace( currentVarKeyGroup, "^\s+|\s+$") ; KeyGroup without any spaces
		Keys := Array_Lib()
		Loop, Parse, currentVarKeyGroup, &,%a_space%
			{
			Keys.append(A_LoopField)
		}
		currentVarKeyGroup := Keys.sort().join("&")
		groupChecked := false
		Loop, parse, KeyEditList, |, %A_Space% 
			{
			currentKeyEditListGroup := A_LoopField
			replace := {"~":"","*":"","$":""} ; removing modifiers before comparing keys
			KeyEditListGroup := A_LoopField
			For what, with in replace
				{
				If InStr(KeyEditListGroup,what)
					StringReplace, KeyEditListGroup, KeyEditListGroup, %what%, %with%, All
			}
			KeyEditListGroup := RegexReplace( KeyEditListGroup, "i)S:" ) ; removing options from keys
			KeyEditListGroup := RegexReplace( KeyEditListGroup, "i)H(.*):" ) ; removing options from keys
			KeyEditListGroup := RegexReplace( KeyEditListGroup, "i)D(.*):" ) ; removing options from keys
			KeyEditListGroup := RegexReplace( KeyEditListGroup, "i)T(.*):" ) ; removing options from keys
			KeyEditListGroup := RegexReplace( KeyEditListGroup, "^\s+|\s+$") ; KeyGroup without any spaces
			Keys := Array_Lib()
			Loop, Parse, KeyEditListGroup, &,%a_space%
				{
				Keys.append(A_LoopField)
			}
			KeyEditListGroup := Keys.sort().join("&")
			If (KeyEditListGroup = currentVarKeyGroup){
				currentEditKey :=
				Loop, Parse, initialKeyEditListGroup, &,%a_space%
					{
					currentEditKey := A_LoopField
					If(action="Remove"){
						If InStr(currentEditKey,Keymodifier)
							StringReplace, currentEditKey, currentEditKey, %Keymodifier%, , all
					}
					If(action="Add"){
						ReverseKeyEdit := DelimitedReversal(currentEditKey,"`:")
						Loop, parse, ReverseKeyEdit, `:, %A_Space%
							{
							currentfield := A_LoopField
							If (a_index = 1) {
								If not InStr(currentfield,Keymodifier)
									currentEditKey := Keymodifier . currentfield
								Else
									currentEditKey := currentfield
							} Else {
								currentEditKey := currentfield . ":" . currentEditKey
							}
						}
					}
					currentKeyEditListVar := currentKeyEditListVar . "&" . currentEditKey
					groupChecked := true
				}
			}
		}
		If not groupChecked
			currentKeyEditListVar := "&" . initialKeyEditListGroup
		StringTrimLeft,currentKeyEditListVar,currentKeyEditListVar,1
		FinalKeyEditListVar := FinalKeyEditListVar . "|" . currentKeyEditListVar
		currentKeyEditListVar := ""
	}
	StringTrimLeft,FinalKeyEditListVar,FinalKeyEditListVar,1
	Return FinalKeyEditListVar
}



; ---------------------------------------------
; Check If all keys are pressed simultaneously (If all keys are pressed returns 1, Else, returns 0)
; ---------------------------------------------
XHotkeyAllKeysPressed(keysToBeChecked){
	RLLog.Debug(A_ThisFunc . " - Started, checking for these keys to be pressed: """ . keysToBeChecked . """")
	Loop, parse, keysToBeChecked, |, %A_Space%
		{
		ExitKeysPressed := true
		replace := {"~":"","*":"","$":""} ; removing modifiers before comparing keys
		keysToBeCheckedGroup := A_LoopField
		For what, with in replace
			{
			If InStr(keysToBeCheckedGroup,what)
				StringReplace, keysToBeCheckedGroup, keysToBeCheckedGroup, %what%, %with%, All
		}
		keysToBeCheckedGroup := RegexReplace( keysToBeCheckedGroup, "i)S:" ) ; removing options from keys
		keysToBeCheckedGroup := RegexReplace( keysToBeCheckedGroup, "i)H(.*):" ) ; removing options from keys
		keysToBeCheckedGroup := RegexReplace( keysToBeCheckedGroup, "i)D(.*):" ) ; removing options from keys
		keysToBeCheckedGroup := RegexReplace( keysToBeCheckedGroup, "i)T(.*):" ) ; removing options from keys
		keysToBeCheckedGroup := RegexReplace( keysToBeCheckedGroup, "^\s+|\s+$") ; keysToBeCheckedGroup without any spaces
		Loop, Parse, keysToBeCheckedGroup, &,%a_space%
			{
			If not (GetKeyState(A_LoopField,"p"))
				ExitKeysPressed := false
		}
		If ExitKeysPressed {
			RLLog.Debug(A_ThisFunc . " - Ended: Keys being checked were pressed")
			Return 1
		}
	}
	RLLog.Debug(A_ThisFunc . " - Ended: Keys being checked were not pressed")
	Return 0
}




; ---------------------------------------------
; AUXILIAR FUNCTIONS
; ---------------------------------------------
; Functions Needed for sorting (by some strange motive If i try to use the autohotkey sort, it not work for ~Z & ~X and ~X & ~Z keys. I was only able to do the sorte by using the array library at http://www.autohotkey.com/forum/viewtopic.php?t=49736
Array_Lib(p1:="��", p2:="��", p3:="��", p4:="��", p5:="��", p6:="��"){
	static ArrBase
	If !ArrBase
		ArrBase := Object("len", "Array_Length", "join", "Array_Join", "insert", "Array_Insert", "delete", "Array_Delete", "sort", "Array_sort", "append", "Array_Append")
	arr := Object("base", ArrBase)
	While (_:=p%A_Index%)!="��" && A_Index<=6
		arr[A_Index] := _
	Return arr
}
Array_Join(arr, sep:="`n"){
	Loop, % arr.len()
		str .= arr[A_Index] sep
	StringTrimRight, str, str, % StrLen(sep)
	Return str
}
Array_Append(arr, p1:="��", p2:="��", p3:="��", p4:="��", p5:="��", p6:="��"){
	Return arr.insert(arr.len()+1, p1, p2, p3, p4, p5, p6)
}
Array_Insert(arr, index, p1:="��", p2:="��", p3:="��", p4:="��", p5:="��", p6:="��"){
	While (_:=p%A_Index%)!="��" && A_Index<=6
		arr._Insert(index + (A_Index-1), _)
	Return arr
}
Array_Sort(arr, func:="Array_CompareFunc"){
	n := arr.len(), swapped := true
	while swapped {
		swapped := false
		Loop, % n-1 {
			i := A_Index
			If %func%(arr[i], arr[i+1], 1) > 0 ; standard ahk syntax for sort callout functions
				arr.insert(i, arr[i+1]).delete(i+2), swapped := true
		}
		n--
	}
	Return arr
}
Array_CompareFunc(a, b, c){
	Return a > b ? 1 : a = b ? 0 : -1
}
Array_Delete(arr, p1:="��", p2:="��", p3:="��", p4:="��", p5:="��", p6:="��"){
	While (_:=p%A_Index%)!="��" && A_Index<=6
		arr._Remove(_)
	Return arr
}
Array_Length(arr){
	len := arr._MaxIndex()
	Return len="" ? 0 : len
}