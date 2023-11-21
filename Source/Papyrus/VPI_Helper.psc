ScriptName VPI_Helper 

;;
;; MAJOR NOTE: ALL HELPER FUNCTIONS MUST BE GLOBAL WITHOUT CREATION KIT
;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Public Member Functions
;;;

;;
;; Helper functions for setting game settings
;;

;; ****************************************************************************
;; Set a float based game setting 
;;
Function SetGameSettingFloat(String gameSetting, Float value) Global
  Debug.ExecuteConsole("setgs " + gameSetting + " " + value)
EndFunction

;; ****************************************************************************
;; Set a integer based game setting 
;;
Function SetGameSettingInt(String gameSetting, Int value) Global
  Debug.ExecuteConsole("setgs " + gameSetting + " " + value)
EndFunction

;; ****************************************************************************
;; Get, scale, and update a float based game setting 
;;
Function ScaleGameSettingFloat(String gameSetting, Float defaultValue, Float scaleFactor) Global
  Float scaledValue = defaultValue * scaleFactor
  SetGameSettingFloat(gameSetting, scaledValue)
EndFunction

;; ****************************************************************************
;; Get, scale, and update a float based game setting 
;;
Function ScaleGameSettingInt(String gameSetting, Int defaultValue, Float scaleFactor) Global
  Int scaledValue = (defaultValue * scaleFactor) as Int
  SetGameSettingInt(gameSetting, scaledValue)
EndFunction

;;
;; Helper functions for setting form settings
;;

;; ****************************************************************************
;; Set a float based form setting 
;;
Function SetFormSettingFloat(String formID, Float value) Global
  Debug.ExecuteConsole("set " + formID + " to " + value)
EndFunction

;; ****************************************************************************
;; Set a integer based form setting 
;;
Function SetFormSettingInt(String formID, Int value) Global
  Debug.ExecuteConsole("set " + formID + " to " + value)
EndFunction

;; ****************************************************************************
;; Get, scale, and update a float based game setting 
;;
Function ScaleFormSettingFloat(String formID, Float defaultValue, Float scaleFactor) Global
  Float scaledValue = defaultValue * scaleFactor
  SetFormSettingFloat(formID, scaledValue)
EndFunction

;; ****************************************************************************
;; Get, scale, and update a float based game setting 
;;
Function ScaleFormSettingInt(String formID, Int defaultValue, Int scaleFactor) Global
  Int scaledValue = defaultValue * scaleFactor
  SetFormSettingInt(formID, scaledValue)
EndFunction

;;
;; Helper functions for Difficulty mode stuff
;;

;; ****************************************************************************
;; Convert the difficulty int value to the string value
;;
String Function GetDifficulty(int iDifficulty) Global
  if (iDifficulty == 0)
    return "Very Easy"
  ElseIf (iDifficulty == 1)
    return "Easy"
  ElseIf (iDifficulty == 2)
    return "Normal"
  ElseIf (iDifficulty == 3)
    return "Hard"
  ElseIf (iDifficulty == 4)
    return "Very Hard"
  Else
    return "Unknown(" + iDifficulty +")"
  EndIf
EndFunction

;;
;; Helper functions for Level Scaling Brackets
;;

;; ****************************************************************************
;; Get the bracket that applies to the player's current level
;;
Int Function GetBracketForPlayerLevel(int playerLevel) Global
  If (1 <= playerLevel && playerLevel <= 25)
    return 1
  ElseIf (26 <= playerLevel && playerLevel <= 50)
    return 2
  ElseIf (51 <= playerLevel && playerLevel <= 75)
    return 3
  ElseIf (76 <= playerLevel && playerLevel <= 100)
    return 4
  ElseIf (101 <= playerLevel && playerLevel <= 125)
    return 5
  ElseIf (126 <= playerLevel && playerLevel <= 150)
    return 6
  ElseIf (151 <= playerLevel && playerLevel <= 200)
    return 7
  ElseIf (201 <= playerLevel && playerLevel <= 250)
    return 8
  ElseIf (251 <= playerLevel && playerLevel <= 300)
    return 9
  Else
    return 10
  EndIf
EndFunction

;;
;; Helper functions for Debugging
;;

;; ****************************************************************************
;; Debug Message Handler
;;
Function DebugMessage(string moduleName, string functionName, string message, int level, int debugModeEnabled) Global
  If (debugModeEnabled == 0)
    return
  EndIf

  If (level == 1)
    Debug.Trace("VPI_WARN " + moduleName + "(" + functionName + "): " + message, level)
  ElseIf (level == 2)
    Debug.Trace("VPI_ERROR " + moduleName + "(" + functionName + "): " + message, level)
  Else
    Debug.Trace("VPI_DEBUG " + moduleName + "(" + functionName + "): " + message, level)
  EndIf
EndFunction

Int Function GetNPCType(ObjectReference npc, Keyword NPC_Type_MK5, Keyword NPC_Type_MK4, Keyword NPC_Type_MK3, Keyword NPC_Type_MK2, Keyword NPC_Type_MK1) Global
  If (npc.HasKeyword(NPC_Type_MK5))
    return 5
  ElseIf (npc.HasKeyword(NPC_Type_MK4))
    return 4
  ElseIf (npc.HasKeyword(NPC_Type_MK3))
    return 3
  ElseIf (npc.HasKeyword(NPC_Type_MK2))
    return 2
  ElseIf (npc.HasKeyword(NPC_Type_MK1))
    return 1
  Else
    return 0
  EndIf
EndFunction

String Function GetNPCRace(ObjectReference npc, Keyword NPC_Varuun, Keyword NPC_CrimsonFleet, Keyword NPC_Ecliptic, Keyword NPC_Spacer) Global
  If (npc.HasKeyword(NPC_Varuun))
    return "Va'ruun"
  ElseIf (npc.HasKeyword(NPC_CrimsonFleet))
    return "Crimson Fleet or Pirate"
  ElseIf (npc.HasKeyword(NPC_Ecliptic))
    return "Ecliptix PMC"
  ElseIf (npc.HasKeyword(NPC_Spacer))
    return "Spacer"
  Else
    return "Unkown - " + npc
  EndIf
EndFunction
