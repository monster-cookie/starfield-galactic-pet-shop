ScriptName SQ_PetsScript Extends SQ_ActorRolesScript conditional
{ Quest script attached to SQ_Pets. Handles various pet functionality }

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Properties
;;;
Group Autofill
  ActorValue Property IdleChatterTimeMax Auto Const mandatory
  ActorValue Property IdleChatterTimeMin Auto Const mandatory
  GlobalVariable Property FOL_IdleChatterTimeMax Auto Const mandatory
  GlobalVariable Property FOL_IdleChatterTimeMin Auto Const mandatory
  ActorValue Property FOL_PreviousIdleChatterTimeMax Auto Const mandatory
  ActorValue Property FOL_PreviousIdleChatterTimeMin Auto Const mandatory
  ActorValue Property PetState Auto Const mandatory
  GlobalVariable Property iFollower_Com_Follow Auto Const mandatory
  GlobalVariable Property iFollower_Com_Wait Auto Const mandatory
  GlobalVariable Property iFollower_Com_GoHome Auto Const mandatory
  Keyword Property SQ_Followers_Link_WaitAtRef Auto Const mandatory
  Keyword Property SQ_Followers_IdleChatterAllowed Auto Const mandatory
  Faction Property SQ_Followers_GroupFormation_Faction Auto Const mandatory
  GlobalVariable Property PlayerFollowers_HasFollower Auto Const mandatory
  GlobalVariable Property PlayerFollowers_HasFollowerFollowing Auto Const mandatory
  GlobalVariable Property PlayerFollowers_HasFollowerWaiting Auto Const mandatory
  GlobalVariable Property PlayerFollowers_HasCompanion Auto Const mandatory
  GlobalVariable Property PlayerFollowers_HasCompanionFollowing Auto Const mandatory
  GlobalVariable Property PlayerFollowers_HasCompanionWaiting Auto Const mandatory
  GlobalVariable Property PlayerFollowers_Count Auto Const mandatory
  GlobalVariable Property PlayerFollowers_CountFollowing Auto Const mandatory
  GlobalVariable Property PlayerFollowers_CountWaiting Auto Const mandatory
  Keyword Property SQ_Followers_TeleportToShipWithPlayerWhenWaiting Auto Const mandatory
  Keyword Property SQ_Followers_DisallowTeleportWaitingFollowersToShip Auto Const mandatory
  Package Property SQ_Followers_Wait Auto Const mandatory
  ActorValue Property Cached_PreFollowerAggression Auto Const mandatory
EndGroup

Group Properties
  ReferenceAlias Property PlayerShipCrewMarker Auto Const mandatory
  { PlayerShipCrewMarker alias in SQ_PlayerShip }
  Int Property ObjectiveRetrieveWaitingFollowers = 100 Auto Const
  { Objective to turn on if you have any followers waiting for you to return }
EndGroup

Float Property AllPetState = 1.0 Auto conditional hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Variables
;;;
Int CountUpdateTrackingRequests
Actor PlayerRef
Int SkipNextWaitingFollowersObjective
Float TimerDur_UpdateTrackingData = 1.0 Const
Int TimerID_UpdateTrackingGlobalsAndObjectives = 1 Const

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Events
;;;
Event OnInit()
  PlayerRef = Game.GetPlayer() ; #DEBUG_LINE_NO:67
  Self.RegisterForRemoteEvent((Alias_Active as RefCollectionAlias) as ScriptObject, "OnAliasChanged") ; #DEBUG_LINE_NO:68
  Self.RegisterForRemoteEvent(PlayerRef as ScriptObject, "OnLocationChange") ; #DEBUG_LINE_NO:69
EndEvent

Event OnTimer(Int aiTimerID)
  If aiTimerID == TimerID_UpdateTrackingGlobalsAndObjectives ; #DEBUG_LINE_NO:73
    CountUpdateTrackingRequests -= 1 ; #DEBUG_LINE_NO:74
    Self.UpdateTrackingGlobalsAndObjectives() ; #DEBUG_LINE_NO:75
    If CountUpdateTrackingRequests > 0 ; #DEBUG_LINE_NO:77
      CountUpdateTrackingRequests = 1 ; #DEBUG_LINE_NO:78
      Self.StartTimer(TimerDur_UpdateTrackingData, TimerID_UpdateTrackingGlobalsAndObjectives) ; #DEBUG_LINE_NO:79
    EndIf
  EndIf
EndEvent

Event RefCollectionAlias.OnAliasChanged(RefCollectionAlias akSender, ObjectReference akObject, Bool abRemove)
  If akSender == Alias_Active as RefCollectionAlias ; #DEBUG_LINE_NO:92
    Self.TriggerTrackingGlobalsAndObjectivesUpdate() ; #DEBUG_LINE_NO:93
  EndIf
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
  If akSender == PlayerRef ; #DEBUG_LINE_NO:99
    Self.TeleportWaitingFollowersToShip(akNewLoc) ; #DEBUG_LINE_NO:100
  EndIf
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Functions
;;;
Function _CustomSetRoleAvaliable(Actor ActorToUpdate)
  ; Empty function
EndFunction

Function _CustomSetRoleUnavailable(Actor ActorToUpdate)
  ; Empty function
EndFunction

Function TriggerTrackingGlobalsAndObjectivesUpdate()
  CountUpdateTrackingRequests += 1 ; #DEBUG_LINE_NO:85
  Self.StartTimer(TimerDur_UpdateTrackingData, TimerID_UpdateTrackingGlobalsAndObjectives) ; #DEBUG_LINE_NO:86
EndFunction

Function TeleportWaitingFollowersToShip(Location akNewLoc)
  If PlayerRef.GetCurrentShipRef() != None ; #DEBUG_LINE_NO:106
    If akNewLoc as Bool && akNewLoc.HasKeyword(SQ_Followers_DisallowTeleportWaitingFollowersToShip) ; #DEBUG_LINE_NO:107
      
    Else
      Self.TeleportFollowers(PlayerRef as ObjectReference, None, False, True, True, False, False) ; #DEBUG_LINE_NO:112
    EndIf
  EndIf
EndFunction

Function _CustomSetRoleActive(Actor ActorToUpdate, Actor PriorActiveActor)
  Self.SetGroupFormationFactionData(ActorToUpdate) ; #DEBUG_LINE_NO:137
  ActorToUpdate.SetPlayerTeammate(True, False, False) ; #DEBUG_LINE_NO:140
  Self.SetIdleChatterTimes(ActorToUpdate, True) ; #DEBUG_LINE_NO:141
  ActorToUpdate.SetNotShowOnStealthMeter(True) ; #DEBUG_LINE_NO:142
  ActorValue aggressionAV = Game.GetAggressionAV() ; #DEBUG_LINE_NO:145
  Float aggression = ActorToUpdate.GetValue(aggressionAV) ; #DEBUG_LINE_NO:146
  ActorToUpdate.SetValue(Cached_PreFollowerAggression, aggression) ; #DEBUG_LINE_NO:147
  ActorToUpdate.SetValue(aggressionAV, 0.0) ; #DEBUG_LINE_NO:150
  Self.CommandFollow(ActorToUpdate) ; #DEBUG_LINE_NO:153
EndFunction

Function _CustomSetRoleInactive(Actor ActorToUpdate)
  Self.UnsetGroupFormationFactionData(ActorToUpdate) ; #DEBUG_LINE_NO:160
  ActorToUpdate.SetPlayerTeammate(False, False, False) ; #DEBUG_LINE_NO:161
  Self.SetIdleChatterTimes(ActorToUpdate, False) ; #DEBUG_LINE_NO:162
  ActorToUpdate.SetNotShowOnStealthMeter(False) ; #DEBUG_LINE_NO:163
  ActorValue aggressionAV = Game.GetAggressionAV() ; #DEBUG_LINE_NO:166
  Float aggression = ActorToUpdate.GetValue(Cached_PreFollowerAggression) ; #DEBUG_LINE_NO:167
  ActorToUpdate.SetValue(aggressionAV, aggression) ; #DEBUG_LINE_NO:171
EndFunction

Function SetGroupFormationFactionData(Actor ActorToSet)
  Int rank = 0 ; #DEBUG_LINE_NO:175
  If SQ_Companions.IsCompanion(ActorToSet, True) || SQ_Crew.IsEliteCrew(ActorToSet) ; #DEBUG_LINE_NO:176
    rank = 2 ; #DEBUG_LINE_NO:177
  EndIf
  ActorToSet.SetFactionRank(SQ_Followers_GroupFormation_Faction, rank) ; #DEBUG_LINE_NO:181
  ActorToSet.SetGroupFaction(SQ_Followers_GroupFormation_Faction) ; #DEBUG_LINE_NO:182
EndFunction

Function UnsetGroupFormationFactionData(Actor ActorToSet)
  ActorToSet.RemoveFromFaction(SQ_Followers_GroupFormation_Faction) ; #DEBUG_LINE_NO:189
  ActorToSet.SetGroupFaction(None) ; #DEBUG_LINE_NO:190
EndFunction

Function SetIdleChatterTimes(Actor ActorToSet, Bool IsFollower)
  If ActorToSet.HasKeyword(SQ_Followers_IdleChatterAllowed) ; #DEBUG_LINE_NO:200
    
  ElseIf IsFollower
    Self._SetIdleChatterTimeAV(ActorToSet, IdleChatterTimeMax, FOL_PreviousIdleChatterTimeMax, FOL_IdleChatterTimeMax) ; #DEBUG_LINE_NO:203
    Self._SetIdleChatterTimeAV(ActorToSet, IdleChatterTimeMin, FOL_PreviousIdleChatterTimeMin, FOL_IdleChatterTimeMin) ; #DEBUG_LINE_NO:204
  Else
    Self._RestoreIdleChatterTimeAV(ActorToSet, IdleChatterTimeMax, FOL_PreviousIdleChatterTimeMax) ; #DEBUG_LINE_NO:206
    Self._RestoreIdleChatterTimeAV(ActorToSet, IdleChatterTimeMin, FOL_PreviousIdleChatterTimeMin) ; #DEBUG_LINE_NO:207
  EndIf
EndFunction

Function _SetIdleChatterTimeAV(Actor ActorToSet, ActorValue IdleChatterTimeAV, ActorValue PreviousIdleChatterTimeAV, GlobalVariable TargetIdleChatterTime)
  Float currentVal = ActorToSet.GetValue(IdleChatterTimeAV) ; #DEBUG_LINE_NO:213
  Float targetVal = TargetIdleChatterTime.GetValue() ; #DEBUG_LINE_NO:214
  If currentVal != targetVal ; #DEBUG_LINE_NO:217
    ActorToSet.SetValue(PreviousIdleChatterTimeAV, currentVal) ; #DEBUG_LINE_NO:219
    ActorToSet.SetValue(IdleChatterTimeAV, targetVal) ; #DEBUG_LINE_NO:221
  EndIf
EndFunction

Function _RestoreIdleChatterTimeAV(Actor ActorToSet, ActorValue IdleChatterTimeAV, ActorValue PreviousIdleChatterTimeAV)
  Float targetVal = ActorToSet.GetValue(PreviousIdleChatterTimeAV) ; #DEBUG_LINE_NO:227
  ActorToSet.SetValue(IdleChatterTimeAV, targetVal) ; #DEBUG_LINE_NO:230
EndFunction

Function CommandFollow(Actor Follower)
  Follower.SetLinkedRef(None, SQ_Followers_Link_WaitAtRef, True) ; #DEBUG_LINE_NO:244
  Follower.SetValue(PetState, iFollower_Com_Follow.GetValue()) ; #DEBUG_LINE_NO:246
  Follower.EvaluatePackage(False) ; #DEBUG_LINE_NO:247
  Self.TriggerTrackingGlobalsAndObjectivesUpdate() ; #DEBUG_LINE_NO:248
EndFunction

Function CommandWait(Actor Follower, ObjectReference WaitAtRef)
  If WaitAtRef ; #DEBUG_LINE_NO:255
    Follower.SetLinkedRef(WaitAtRef, SQ_Followers_Link_WaitAtRef, True) ; #DEBUG_LINE_NO:256
  EndIf
  Follower.SetValue(PetState, iFollower_Com_Wait.GetValue()) ; #DEBUG_LINE_NO:259
  Follower.EvaluatePackage(False) ; #DEBUG_LINE_NO:260
  If Follower.IsInScene() == False && Follower.IsInCombat() == False ; #DEBUG_LINE_NO:262
    Float waitTime = 0.5 ; #DEBUG_LINE_NO:264
    Float timeWaiting = 0.0 ; #DEBUG_LINE_NO:265
    Float maxWaitTimeBeforeBailout = 10.0 ; #DEBUG_LINE_NO:266
    While Follower.GetCurrentPackage() != SQ_Followers_Wait && timeWaiting <= maxWaitTimeBeforeBailout ; #DEBUG_LINE_NO:267
      Utility.Wait(waitTime) ; #DEBUG_LINE_NO:268
      timeWaiting += waitTime ; #DEBUG_LINE_NO:269
    EndWhile
  EndIf
  Self.TriggerTrackingGlobalsAndObjectivesUpdate() ; #DEBUG_LINE_NO:273
EndFunction

Bool Function IsFollowing(Actor FollowerToTest)
  Return FollowerToTest.GetValue(PetState) == iFollower_Com_Follow.GetValue() ; #DEBUG_LINE_NO:277
EndFunction

Bool Function IsWaiting(Actor FollowerToTest)
  Return FollowerToTest.GetValue(PetState) == iFollower_Com_Wait.GetValue() ; #DEBUG_LINE_NO:281
EndFunction

Function UpdateRetrieveWaitingFollowersObjective(Actor[] ActiveFollowersArray)
  If ActiveFollowersArray == None ; #DEBUG_LINE_NO:288
    ActiveFollowersArray = Self.GetFollowers(True, True) ; #DEBUG_LINE_NO:289
  EndIf
  Bool turnOnObjective = False ; #DEBUG_LINE_NO:293
  Int I = 0 ; #DEBUG_LINE_NO:295
  While turnOnObjective == False && I < ActiveFollowersArray.Length ; #DEBUG_LINE_NO:296
    turnOnObjective = ActiveFollowersArray[I].GetValue(PetState) == iFollower_Com_Wait.GetValue() ; #DEBUG_LINE_NO:297
    I += 1 ; #DEBUG_LINE_NO:298
  EndWhile
  If turnOnObjective ; #DEBUG_LINE_NO:303
    If SkipNextWaitingFollowersObjective > 0 ; #DEBUG_LINE_NO:305
      SkipNextWaitingFollowersObjective -= 1 ; #DEBUG_LINE_NO:306
    Else
      Self.SetObjectiveActive(ObjectiveRetrieveWaitingFollowers, True) ; #DEBUG_LINE_NO:308
    EndIf
  Else
    Self.SetObjectiveDisplayed(ObjectiveRetrieveWaitingFollowers, False, False) ; #DEBUG_LINE_NO:311
  EndIf
EndFunction

Actor[] Function GetFollowers(Bool IncludeFollowingFollowers, Bool IncludeWaitingFollowers)
  Actor[] ActiveFollowersArray = (Alias_Active as RefCollectionAlias).GetArray() as Actor[] ; #DEBUG_LINE_NO:323
  Actor[] followersToReturn = new Actor[0] ; #DEBUG_LINE_NO:326
  Int I = 0 ; #DEBUG_LINE_NO:328
  While I < ActiveFollowersArray.Length ; #DEBUG_LINE_NO:329
    Actor currentFollower = ActiveFollowersArray[I] ; #DEBUG_LINE_NO:330
    If IncludeFollowingFollowers && Self.IsFollowing(currentFollower) || IncludeWaitingFollowers && Self.IsWaiting(currentFollower) ; #DEBUG_LINE_NO:332
      followersToReturn.add(currentFollower, 1) ; #DEBUG_LINE_NO:333
    EndIf
    I += 1 ; #DEBUG_LINE_NO:336
  EndWhile
  Return followersToReturn ; #DEBUG_LINE_NO:340
EndFunction

Actor[] Function AllFollowersWait(ObjectReference WaitAtRef, Bool IgnoreCurrentlyWaitingFollowers, Bool SkipWaitingFollowersObjective)
  If SkipWaitingFollowersObjective ; #DEBUG_LINE_NO:348
    SkipNextWaitingFollowersObjective += 1 ; #DEBUG_LINE_NO:349
  EndIf
  Actor[] ActiveFollowersArray = (Alias_Active as RefCollectionAlias).GetArray() as Actor[] ; #DEBUG_LINE_NO:352
  Actor[] commandedFollowers = new Actor[0] ; #DEBUG_LINE_NO:355
  Int I = 0 ; #DEBUG_LINE_NO:357
  While I < ActiveFollowersArray.Length ; #DEBUG_LINE_NO:358
    Actor currentActor = ActiveFollowersArray[I] ; #DEBUG_LINE_NO:360
    If IgnoreCurrentlyWaitingFollowers == False || Self.IsWaiting(currentActor) == False ; #DEBUG_LINE_NO:362
      Self.CommandWait(currentActor, WaitAtRef) ; #DEBUG_LINE_NO:363
      commandedFollowers.add(currentActor, 1) ; #DEBUG_LINE_NO:364
    EndIf
    I += 1 ; #DEBUG_LINE_NO:366
  EndWhile
  Return commandedFollowers ; #DEBUG_LINE_NO:370
EndFunction

Function AllFollowersFollow(Actor[] SpecificFollowersToCommand)
  Actor[] ActiveFollowersArray = (Alias_Active as RefCollectionAlias).GetArray() as Actor[] ; #DEBUG_LINE_NO:379
  If SpecificFollowersToCommand == None ; #DEBUG_LINE_NO:382
    SpecificFollowersToCommand = ActiveFollowersArray ; #DEBUG_LINE_NO:383
  EndIf
  Int I = 0 ; #DEBUG_LINE_NO:386
  While I < SpecificFollowersToCommand.Length ; #DEBUG_LINE_NO:387
    Self.CommandFollow(SpecificFollowersToCommand[I]) ; #DEBUG_LINE_NO:388
    I += 1 ; #DEBUG_LINE_NO:389
  EndWhile
  Self.TriggerTrackingGlobalsAndObjectivesUpdate() ; #DEBUG_LINE_NO:392
EndFunction

Function UpdateTrackingGlobalsAndObjectives()
  Actor[] ActiveFollowersArray = Self.GetFollowers(True, True) ; #DEBUG_LINE_NO:403
  Self.UpdateRetrieveWaitingFollowersObjective(ActiveFollowersArray) ; #DEBUG_LINE_NO:407
  Int followerCount = ActiveFollowersArray.Length ; #DEBUG_LINE_NO:410
  PlayerFollowers_Count.SetValueInt(followerCount) ; #DEBUG_LINE_NO:411
  If followerCount > 0 ; #DEBUG_LINE_NO:413
    PlayerFollowers_HasFollower.SetValueInt(1) ; #DEBUG_LINE_NO:414
  Else
    PlayerFollowers_HasFollower.SetValueInt(0) ; #DEBUG_LINE_NO:416
  EndIf
  Int followerCountFollowing = 0 ; #DEBUG_LINE_NO:419
  Int followerCountWaiting = 0 ; #DEBUG_LINE_NO:420
  Bool hasCompanion = False ; #DEBUG_LINE_NO:422
  Int companionCountFollowing = 0 ; #DEBUG_LINE_NO:423
  Int companionCountWaiting = 0 ; #DEBUG_LINE_NO:424
  Int iWait = iFollower_Com_Wait.GetValue() as Int ; #DEBUG_LINE_NO:426
  Int I = 0 ; #DEBUG_LINE_NO:428
  While I < ActiveFollowersArray.Length ; #DEBUG_LINE_NO:429
    Actor currentFollower = ActiveFollowersArray[I] ; #DEBUG_LINE_NO:430
    If currentFollower.GetValue(PetState) == iWait as Float ; #DEBUG_LINE_NO:432
      followerCountWaiting += 1 ; #DEBUG_LINE_NO:433
      If currentFollower is companionactorscript ; #DEBUG_LINE_NO:435
        companionCountWaiting += 1 ; #DEBUG_LINE_NO:436
        hasCompanion = True ; #DEBUG_LINE_NO:437
      EndIf
    Else
      followerCountFollowing += 1 ; #DEBUG_LINE_NO:441
      If currentFollower is companionactorscript ; #DEBUG_LINE_NO:443
        companionCountFollowing += 1 ; #DEBUG_LINE_NO:444
        hasCompanion = True ; #DEBUG_LINE_NO:445
      EndIf
    EndIf
    I += 1 ; #DEBUG_LINE_NO:450
  EndWhile
  If followerCountFollowing > 0 ; #DEBUG_LINE_NO:455
    PlayerFollowers_HasFollowerFollowing.SetValueInt(1) ; #DEBUG_LINE_NO:456
  Else
    PlayerFollowers_HasFollowerFollowing.SetValueInt(0) ; #DEBUG_LINE_NO:458
  EndIf
  If followerCountWaiting > 0 ; #DEBUG_LINE_NO:461
    PlayerFollowers_HasFollowerWaiting.SetValueInt(1) ; #DEBUG_LINE_NO:462
  Else
    PlayerFollowers_HasFollowerWaiting.SetValueInt(0) ; #DEBUG_LINE_NO:464
  EndIf
  PlayerFollowers_CountFollowing.SetValueInt(followerCountFollowing) ; #DEBUG_LINE_NO:467
  PlayerFollowers_CountWaiting.SetValueInt(followerCountWaiting) ; #DEBUG_LINE_NO:468
  If hasCompanion ; #DEBUG_LINE_NO:472
    PlayerFollowers_HasCompanion.SetValue(1.0) ; #DEBUG_LINE_NO:473
  Else
    PlayerFollowers_HasCompanion.SetValue(0.0) ; #DEBUG_LINE_NO:475
  EndIf
  If companionCountFollowing > 0 ; #DEBUG_LINE_NO:478
    PlayerFollowers_HasCompanionFollowing.SetValueInt(1) ; #DEBUG_LINE_NO:479
  Else
    PlayerFollowers_HasCompanionFollowing.SetValueInt(0) ; #DEBUG_LINE_NO:481
  EndIf
  If companionCountWaiting > 0 ; #DEBUG_LINE_NO:484
    PlayerFollowers_HasCompanionWaiting.SetValueInt(1) ; #DEBUG_LINE_NO:485
  Else
    PlayerFollowers_HasCompanionWaiting.SetValueInt(0) ; #DEBUG_LINE_NO:487
  EndIf
EndFunction

Actor[] Function TeleportFollowers(ObjectReference DestinationRef, Actor[] SpecificFollowersToTeleport, Bool IncludeFollowingFollowers, Bool IncludeWaitingFollowers, Bool StartFollowingAfterTeleport, Bool StartWaitingAfterTeleport, Bool SkipWaitingFollowersObjective)
  If SpecificFollowersToTeleport == None ; #DEBUG_LINE_NO:497
    SpecificFollowersToTeleport = (Alias_Active as RefCollectionAlias).GetActorArray() ; #DEBUG_LINE_NO:498
  EndIf
  If DestinationRef == None ; #DEBUG_LINE_NO:501
    DestinationRef = PlayerRef as ObjectReference ; #DEBUG_LINE_NO:502
  EndIf
  Actor[] teleportedActors = new Actor[0] ; #DEBUG_LINE_NO:505
  Int I = 0 ; #DEBUG_LINE_NO:507
  While I < SpecificFollowersToTeleport.Length ; #DEBUG_LINE_NO:508
    Actor currentActor = SpecificFollowersToTeleport[I] ; #DEBUG_LINE_NO:509
    Bool shouldTeleport = IncludeFollowingFollowers && Self.IsFollowing(currentActor) || IncludeWaitingFollowers && Self.IsWaiting(currentActor) ; #DEBUG_LINE_NO:513
    If shouldTeleport ; #DEBUG_LINE_NO:515
      If StartFollowingAfterTeleport ; #DEBUG_LINE_NO:516
        Self.CommandFollow(currentActor) ; #DEBUG_LINE_NO:518
      ElseIf StartWaitingAfterTeleport
        If SkipWaitingFollowersObjective ; #DEBUG_LINE_NO:521
          SkipNextWaitingFollowersObjective += 1 ; #DEBUG_LINE_NO:522
        EndIf
        If DestinationRef != PlayerRef as ObjectReference ; #DEBUG_LINE_NO:525
          Self.CommandWait(currentActor, DestinationRef) ; #DEBUG_LINE_NO:526
        Else
          Self.CommandWait(currentActor, None) ; #DEBUG_LINE_NO:528
        EndIf
      EndIf
      currentActor.MoveTo(DestinationRef, 0.0, 0.0, 0.0, True, False) ; #DEBUG_LINE_NO:533
      teleportedActors.add(currentActor, 1) ; #DEBUG_LINE_NO:534
    EndIf
    I += 1 ; #DEBUG_LINE_NO:537
  EndWhile
  Return teleportedActors ; #DEBUG_LINE_NO:541
EndFunction

Function DebugFollower(Actor Follower)
  Self.SetRoleActive(Follower, True, True, 0.0, 0.0) ; #DEBUG_LINE_NO:550
  Follower.MoveTo(PlayerRef as ObjectReference, 0.0, 0.0, 0.0, True, False) ; #DEBUG_LINE_NO:551
EndFunction

SQ_FollowersScript Function GetScript() Global
  Return (Game.GetFormFromFile(55155, "Starfield.esm") as Quest) as SQ_FollowersScript ; #DEBUG_LINE_NO:558
EndFunction
