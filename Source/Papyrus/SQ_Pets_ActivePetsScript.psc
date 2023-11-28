ScriptName SQ_Pets_ActivePetsScript Extends RefCollectionAlias
{ Script attached to ActivePets refcollection alias.
Currently it is managing the COM_SandboxDistancePollSuccessful which is used to turn on/off the sandboxing while player is loitering }

;-- Variables ---------------------------------------
Int PollSuccessCount
Float PollSuccess_Distance = 5.0 Const
Int PollSuccessesNeeded = 3 Const
Float Timer_Dur_DistancePoll = 10.0 Const
Int Timer_ID_DistancePoll = 1 Const
Actor[] activePets
Bool activePetsArrayLock
Int iPollSuccess = 1 Const
Int iPollUnsetOrNotYetSuccess = 0 Const

;-- Properties --------------------------------------
GlobalVariable Property COM_SandboxDistancePollSuccessful Auto Const mandatory
{ Used to conditionalize sandbox package }

;-- Functions ---------------------------------------

Event OnPackageChange(ObjectReference akSenderRef, Package akOldPackage)
  ; Empty function
EndEvent

Event OnPackageEnd(ObjectReference akSenderRef, Package akOldPackage)
  ; Empty function
EndEvent

Event OnPackageStart(ObjectReference akSenderRef, Package akNewPackage)
  ; Empty function
EndEvent

Event OnAliasInit()
  Actor PlayerRef = Game.GetPlayer()
  Self.RegisterForRemoteEvent(PlayerRef as ScriptObject, "OnPlayerLoiteringBegin")
  Self.RegisterForRemoteEvent(PlayerRef as ScriptObject, "OnPlayerLoiteringEnd")
  activePets = Self.GetArray() as Actor[]
EndEvent

Event OnAliasChanged(ObjectReference akObject, Bool abRemove)
  While (activePetsArrayLock)
    Utility.Wait(0.100000001)
  EndWhile
  activePetsArrayLock = True
  activePets = Self.GetArray() as Actor[]
  activePetsArrayLock = False
EndEvent

Event OnTimer(Int aiTimerID)
  If (aiTimerID == Timer_ID_DistancePoll)
    Bool shouldKeepPolling = Self.KeepPolling()
    If (shouldKeepPolling)
      Self.StartTimer(Timer_Dur_DistancePoll, Timer_ID_DistancePoll)
    Else
      COM_SandboxDistancePollSuccessful.SetValue(iPollSuccess as Float)
      Self.EvaluatePackageForAll()
    EndIf
  EndIf
EndEvent

Event Actor.OnPlayerLoiteringBegin(Actor akSenderRef)
  Self.StartTimer(Timer_Dur_DistancePoll, Timer_ID_DistancePoll)
  Self.EvaluatePackageForAll()
EndEvent

Event Actor.OnPlayerLoiteringEnd(Actor akSenderRef)
  Self.CancelTimer(Timer_ID_DistancePoll)
  PollSuccessCount = 0
  COM_SandboxDistancePollSuccessful.SetValue(iPollUnsetOrNotYetSuccess as Float)
  Self.EvaluatePackageForAll()
EndEvent

Bool Function KeepPolling()
  While activePetsArrayLock
    Utility.Wait(0.100000001)
  EndWhile
  activePetsArrayLock = True
  Actor PlayerRef = Game.GetPlayer()
  Bool returnVal = True
  Int I = 0
  While (I < activePets.Length && returnVal == True)
    ObjectReference nearbyFollower = None
    If (activePets[I].GetDistance(PlayerRef as ObjectReference) <= PollSuccess_Distance)
      PollSuccessCount += 1
      If (PollSuccessCount >= PollSuccessesNeeded)
        PollSuccessCount = 0
        returnVal = False
      EndIf
    EndIf
    I += 1
  EndWhile
  activePetsArrayLock = False
  Return returnVal
EndFunction

Function EvaluatePackageForAll()
  While (activePetsArrayLock)
    Utility.Wait(0.100000001)
  EndWhile
  activePetsArrayLock = True
  Int I = 0
  While (I < activePets.Length)
    activePets[I].EvaluatePackage(False)
    I += 1
  EndWhile
  activePetsArrayLock = False
EndFunction

Bool Function Trace(ScriptObject CallingObject, String asTextToPrint, Int aiSeverity, String MainLogName, String SubLogName, Bool bShowNormalTrace, Bool bShowWarning, Bool bPrefixTraceWithLogNames)
  Return Debug.TraceLog(CallingObject, asTextToPrint, MainLogName, SubLogName, aiSeverity, bShowNormalTrace, bShowWarning, bPrefixTraceWithLogNames, True)
EndFunction

; Fixup hacks for debug-only function: warning
Bool Function Warning(ScriptObject CallingObject, String asTextToPrint, Int aiSeverity, String MainLogName, String SubLogName, Bool bShowNormalTrace, Bool bShowWarning, Bool bPrefixTraceWithLogNames)
  Return false
EndFunction
