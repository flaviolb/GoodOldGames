; Transition Animation functions:
; User Transition Animation used for FadeIn and/or FadeOut. Select this as your Transition Animation in RLUI.
; FadeIn animations should contain the text FadeIn on their name and FadeOut animations should contain the text FadeOut on their name.
; Function arguments should be exactly "direction,time".
MyCustomAnimateFadeIn(direction,time){
	RLLog.Info("MyCustomAnimateFadeIn - Started")
	IniRead, myVar, %userFadeAnimIniFile%, ExampleSection, ExampleSetting	; userFadeAnimIniFile is the variable pointing to the User Fade Animations.ini file
	RLLog.Info("MyCustomAnimateFadeIn - Ended")
}

; Progress Animation labels:
; User Progress Animation used for FadeIn when 7z is enabled and used. Select this as your Progress Animation in RLUI.
; They can have any name, but cannot start with the underscore (_) character.
; Functions or Label names starting by an underscore (_) will be ignored by RLUI since they are reserved for any extra labels/functions the user might need to create. Example _MyLabel:
MyCustomAnimation:
	RLLog.Info("MyCustomAnimation - Started")
	RLLog.Info("MyCustomAnimation - Ended")
Return
