ScriptName SQ_PetsScript Extends SQ_ActorRolesScript conditional

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Global Variables
;;;
GlobalVariable Property Venpi_DebugEnabled Auto Const Mandatory
String Property Venpi_ModName Auto Const Mandatory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Properties
;;;
Group Autofill
  GlobalVariable Property PET_IdleChatterTimeMax Auto Const mandatory
  GlobalVariable Property PET_IdleChatterTimeMin Auto Const mandatory
  GlobalVariable Property iFollower_Com_Follow Auto Const mandatory
  GlobalVariable Property iFollower_Com_Wait Auto Const mandatory
  GlobalVariable Property iFollower_Com_GoHome Auto Const mandatory
  GlobalVariable Property PlayerPets_HasPet Auto Const mandatory
  GlobalVariable Property PlayerPets_HasPetFollowing Auto Const mandatory
  GlobalVariable Property PlayerPets_HasPetWaiting Auto Const mandatory
  GlobalVariable Property PlayerPets_Count Auto Const mandatory
  GlobalVariable Property PlayerPets_CountFollowing Auto Const mandatory
  GlobalVariable Property PlayerPets_CountWaiting Auto Const mandatory

  ActorValue Property PetState Auto Const mandatory
  ActorValue Property IdleChatterTimeMax Auto Const mandatory
  ActorValue Property IdleChatterTimeMin Auto Const mandatory
  ActorValue Property PET_PreviousIdleChatterTimeMax Auto Const mandatory
  ActorValue Property PET_PreviousIdleChatterTimeMin Auto Const mandatory
  ActorValue Property Cached_PrePetAggression Auto Const mandatory

  Faction Property SQ_Followers_GroupFormation_Faction Auto Const mandatory

  Keyword Property SQ_Followers_Link_WaitAtRef Auto Const mandatory
  Keyword Property SQ_Followers_IdleChatterAllowed Auto Const mandatory
  Keyword Property SQ_Followers_TeleportToShipWithPlayerWhenWaiting Auto Const mandatory
  Keyword Property SQ_Followers_DisallowTeleportWaitingFollowersToShip Auto Const mandatory

  Package Property SQ_Pets_Wait Auto Const mandatory
EndGroup

Group Related_Quests_Autofill
  SQ_PetsScript Property SQ_Pets Auto Const mandatory
EndGroup

Group Properties
  ReferenceAlias Property PlayerShipCrewMarker Auto Const mandatory
  { PlayerShipCrewMarker alias in SQ_PlayerShip }
  Int Property ObjectiveRetrieveWaitingPets = 100 Auto Const
  { Objective to turn on if you have any pets waiting for you to return }
EndGroup

Float Property AllPetState = 1.0 Auto conditional hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Variables
;;;
Int CountUpdateTrackingRequests
Actor PlayerRef
Int SkipNextWaitingPetObjective
Float TimerDur_UpdateTrackingData = 1.0 Const
Int TimerID_UpdateTrackingGlobalsAndObjectives = 1 Const

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Events
;;;
Event OnInit()
  PlayerRef = Game.GetPlayer()
  Self.RegisterForRemoteEvent((Alias_Active as RefCollectionAlias) as ScriptObject, "OnAliasChanged")
  Self.RegisterForRemoteEvent(PlayerRef as ScriptObject, "OnLocationChange")
EndEvent

Event OnTimer(Int aiTimerID)
  If (aiTimerID == TimerID_UpdateTrackingGlobalsAndObjectives)
    CountUpdateTrackingRequests -= 1
    Self.UpdateTrackingGlobalsAndObjectives()
    If (CountUpdateTrackingRequests > 0)
      CountUpdateTrackingRequests = 1
      Self.StartTimer(TimerDur_UpdateTrackingData, TimerID_UpdateTrackingGlobalsAndObjectives)
    EndIf
  EndIf
EndEvent

Event RefCollectionAlias.OnAliasChanged(RefCollectionAlias akSender, ObjectReference akObject, Bool abRemove)
  If (akSender == Alias_Active as RefCollectionAlias)
    Self.TriggerTrackingGlobalsAndObjectivesUpdate()
  EndIf
EndEvent

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
  If (akSender == PlayerRef)
    Self.TeleportWaitingFollowersToShip(akNewLoc)
  EndIf
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Functions
;;;
Function TriggerTrackingGlobalsAndObjectivesUpdate()
  CountUpdateTrackingRequests += 1
  Self.StartTimer(TimerDur_UpdateTrackingData, TimerID_UpdateTrackingGlobalsAndObjectives)
EndFunction

Function TeleportWaitingFollowersToShip(Location akNewLoc)
  If (PlayerRef.GetCurrentShipRef() != None)
    If (akNewLoc as Bool && (akNewLoc.HasKeyword(SQ_Followers_DisallowTeleportWaitingFollowersToShip) == False))
      Self.TeleportPets(PlayerRef as ObjectReference, None, False, True, True, False, False)
    EndIf
  EndIf
EndFunction

Function _CustomSetRoleAvaliable(Actor ActorToUpdate)
  ; Empty function
EndFunction

Function _CustomSetRoleUnavailable(Actor ActorToUpdate)
  ; Empty function
EndFunction

Function _CustomSetRoleActive(Actor ActorToUpdate, Actor PriorActiveActor)
  Self.SetGroupFormationFactionData(ActorToUpdate)
  ActorToUpdate.SetPlayerTeammate(True, False, False)
  Self.SetIdleChatterTimes(ActorToUpdate, True)
  ActorToUpdate.SetNotShowOnStealthMeter(True)
  ActorValue aggressionAV = Game.GetAggressionAV()
  Float aggression = ActorToUpdate.GetValue(aggressionAV)
  ActorToUpdate.SetValue(Cached_PrePetAggression, aggression)
  ActorToUpdate.SetValue(aggressionAV, 0.0)
  Self.CommandFollow(ActorToUpdate)
EndFunction

Function _CustomSetRoleInactive(Actor ActorToUpdate)
  Self.UnsetGroupFormationFactionData(ActorToUpdate)
  ActorToUpdate.SetPlayerTeammate(False, False, False)
  Self.SetIdleChatterTimes(ActorToUpdate, False)
  ActorToUpdate.SetNotShowOnStealthMeter(False)
  ActorValue aggressionAV = Game.GetAggressionAV()
  Float aggression = ActorToUpdate.GetValue(Cached_PrePetAggression)
  ActorToUpdate.SetValue(aggressionAV, aggression)
EndFunction

Function SetGroupFormationFactionData(Actor ActorToUpdate)
  ActorToUpdate.SetFactionRank(SQ_Followers_GroupFormation_Faction, 0)
  ActorToUpdate.SetGroupFaction(SQ_Followers_GroupFormation_Faction)
EndFunction

Function UnsetGroupFormationFactionData(Actor ActorToUpdate)
  ActorToUpdate.RemoveFromFaction(SQ_Followers_GroupFormation_Faction)
  ActorToUpdate.SetGroupFaction(None)
EndFunction

Function SetIdleChatterTimes(Actor ActorToUpdate, Bool IsPet)
  If (ActorToUpdate.HasKeyword(SQ_Followers_IdleChatterAllowed))
    ;; This seems like a but I think there is a logic error here 
  ElseIf (IsPet)
    Self._SetIdleChatterTimeAV(ActorToUpdate, IdleChatterTimeMax, PET_PreviousIdleChatterTimeMax, PET_IdleChatterTimeMax)
    Self._SetIdleChatterTimeAV(ActorToUpdate, IdleChatterTimeMin, PET_PreviousIdleChatterTimeMin, PET_IdleChatterTimeMin)
  Else
    Self._RestoreIdleChatterTimeAV(ActorToUpdate, IdleChatterTimeMax, PET_PreviousIdleChatterTimeMax)
    Self._RestoreIdleChatterTimeAV(ActorToUpdate, IdleChatterTimeMin, PET_PreviousIdleChatterTimeMin)
  EndIf
EndFunction

Function _SetIdleChatterTimeAV(Actor ActorToUpdate, ActorValue IdleChatterTimeAV, ActorValue PreviousIdleChatterTimeAV, GlobalVariable TargetIdleChatterTime)
  Float currentVal = ActorToUpdate.GetValue(IdleChatterTimeAV)
  Float targetVal = TargetIdleChatterTime.GetValue()
  If (currentVal != targetVal)
    ActorToUpdate.SetValue(PreviousIdleChatterTimeAV, currentVal)
    ActorToUpdate.SetValue(IdleChatterTimeAV, targetVal)
  EndIf
EndFunction

Function _RestoreIdleChatterTimeAV(Actor ActorToUpdate, ActorValue IdleChatterTimeAV, ActorValue PreviousIdleChatterTimeAV)
  Float targetVal = ActorToUpdate.GetValue(PreviousIdleChatterTimeAV)
  ActorToUpdate.SetValue(IdleChatterTimeAV, targetVal)
EndFunction

Function CommandFollow(Actor Pet)
  Pet.SetLinkedRef(None, SQ_Followers_Link_WaitAtRef, True)
  Pet.SetValue(PetState, iFollower_Com_Follow.GetValue())
  Pet.EvaluatePackage(False)
  Self.TriggerTrackingGlobalsAndObjectivesUpdate()
EndFunction

Function CommandWait(Actor Pet, ObjectReference WaitAtRef)
  If (WaitAtRef)
    Pet.SetLinkedRef(WaitAtRef, SQ_Followers_Link_WaitAtRef, True)
  EndIf
  Pet.SetValue(PetState, iFollower_Com_Wait.GetValue())
  Pet.EvaluatePackage(False)
  If (Pet.IsInScene() == False && Pet.IsInCombat() == False)
    Float waitTime = 0.5
    Float timeWaiting = 0.0
    Float maxWaitTimeBeforeBailout = 10.0
    While (Pet.GetCurrentPackage() != SQ_Pets_Wait && timeWaiting <= maxWaitTimeBeforeBailout)
      Utility.Wait(waitTime)
      timeWaiting += waitTime
    EndWhile
  EndIf
  Self.TriggerTrackingGlobalsAndObjectivesUpdate()
EndFunction

Bool Function IsFollowing(Actor PetToTest)
  Return (PetToTest.GetValue(PetState) == iFollower_Com_Follow.GetValue())
EndFunction

Bool Function IsWaiting(Actor PetToTest)
  Return (PetToTest.GetValue(PetState) == iFollower_Com_Wait.GetValue())
EndFunction

Function UpdateRetrieveWaitingPetsObjective(Actor[] ActivePetsArray)
  If (ActivePetsArray == None)
    ActivePetsArray = Self.GetPets(True, True)
  EndIf
  Bool turnOnObjective = False
  Int I = 0
  While (turnOnObjective == False && I < ActivePetsArray.Length)
    turnOnObjective = ActivePetsArray[I].GetValue(PetState) == iFollower_Com_Wait.GetValue()
    I += 1
  EndWhile
  If (turnOnObjective)
    If (SkipNextWaitingPetObjective > 0)
      SkipNextWaitingPetObjective -= 1
    Else
      Self.SetObjectiveActive(ObjectiveRetrieveWaitingPets, True)
    EndIf
  Else
    Self.SetObjectiveDisplayed(ObjectiveRetrieveWaitingPets, False, False)
  EndIf
EndFunction

Actor[] Function GetPets(Bool IncludeFollowingPets, Bool IncludeWaitingPets)
  Actor[] ActivePetsArray = (Alias_Active as RefCollectionAlias).GetArray() as Actor[]
  Actor[] followersToReturn = new Actor[0]
  Int I = 0
  While (I < ActivePetsArray.Length)
    Actor currentPet = ActivePetsArray[I]
    If (IncludeFollowingPets && Self.IsFollowing(currentPet) || IncludeWaitingPets && Self.IsWaiting(currentPet))
      followersToReturn.add(currentPet, 1)
    EndIf
    I += 1
  EndWhile
  Return followersToReturn
EndFunction

Actor[] Function AllPetsWait(ObjectReference WaitAtRef, Bool IgnoreCurrentlyWaitingPets, Bool SkipWaitingPetsObjective)
  If (SkipWaitingPetsObjective)
    SkipNextWaitingPetObjective += 1
  EndIf
  Actor[] ActivePetsArray = (Alias_Active as RefCollectionAlias).GetArray() as Actor[]
  Actor[] commandedPets = new Actor[0]
  Int I = 0
  While (I < ActivePetsArray.Length)
    Actor currentActor = ActivePetsArray[I]
    If (IgnoreCurrentlyWaitingPets == False || Self.IsWaiting(currentActor) == False)
      Self.CommandWait(currentActor, WaitAtRef)
      commandedPets.add(currentActor, 1)
    EndIf
    I += 1
  EndWhile
  Return commandedPets
EndFunction

Function AllPetsFollow(Actor[] SpecificPetsToCommand)
  Actor[] ActivePetsArray = (Alias_Active as RefCollectionAlias).GetArray() as Actor[]
  If (SpecificPetsToCommand == None)
    SpecificPetsToCommand = ActivePetsArray
  EndIf
  Int I = 0
  While I < SpecificPetsToCommand.Length
    Self.CommandFollow(SpecificPetsToCommand[I])
    I += 1
  EndWhile
  Self.TriggerTrackingGlobalsAndObjectivesUpdate()
EndFunction

Function UpdateTrackingGlobalsAndObjectives()
  Actor[] ActivePetsArray = Self.GetPets(True, True)
  Self.UpdateRetrieveWaitingPetsObjective(ActivePetsArray)

  Int followerCount = ActivePetsArray.Length
  PlayerPets_Count.SetValueInt(followerCount)
  If (followerCount > 0)
    PlayerPets_HasPet.SetValueInt(1)
  Else
    PlayerPets_HasPet.SetValueInt(0)
  EndIf

  Int petCountFollowing = 0
  Int petCountWaiting = 0
  Int iWait = iFollower_Com_Wait.GetValue() as Int
  Int I = 0
  While I < ActivePetsArray.Length
    Actor currentPet = ActivePetsArray[I]
    If (currentPet.GetValue(PetState) == iWait as Float)
      petCountWaiting += 1
    Else
      petCountFollowing += 1
    EndIf
    I += 1
  EndWhile

  If (petCountFollowing > 0)
    PlayerPets_HasPetFollowing.SetValueInt(1)
  Else
    PlayerPets_HasPetFollowing.SetValueInt(0)
  EndIf
  PlayerPets_CountFollowing.SetValueInt(petCountFollowing)

  If petCountWaiting > 0
    PlayerPets_HasPetWaiting.SetValueInt(1)
  Else
    PlayerPets_HasPetWaiting.SetValueInt(0)
  EndIf
  PlayerPets_CountWaiting.SetValueInt(petCountWaiting)
EndFunction

Actor[] Function TeleportPets(ObjectReference DestinationRef, Actor[] SpecificPetsToTeleport, Bool IncludeFollowingPets, Bool IncludeWaitingPets, Bool StartFollowingAfterTeleport, Bool StartWaitingAfterTeleport, Bool SkipWaitingPetsObjective)
  If (SpecificPetsToTeleport == None)
    SpecificPetsToTeleport = (Alias_Active as RefCollectionAlias).GetActorArray()
  EndIf

  If (DestinationRef == None)
    DestinationRef = PlayerRef as ObjectReference
  EndIf

  Actor[] teleportedActors = new Actor[0]
  Int I = 0
  While (I < SpecificPetsToTeleport.Length)
    Actor currentActor = SpecificPetsToTeleport[I]
    Bool shouldTeleport = IncludeFollowingPets && Self.IsFollowing(currentActor) || IncludeWaitingPets && Self.IsWaiting(currentActor)
    If (shouldTeleport)
      If (StartFollowingAfterTeleport)
        Self.CommandFollow(currentActor)
      ElseIf (StartWaitingAfterTeleport)
        If (SkipWaitingPetsObjective)
          SkipNextWaitingPetObjective += 1
        EndIf
        If (DestinationRef != PlayerRef as ObjectReference)
          Self.CommandWait(currentActor, DestinationRef)
        Else
          Self.CommandWait(currentActor, None)
        EndIf
      EndIf
      currentActor.MoveTo(DestinationRef, 0.0, 0.0, 0.0, True, False)
      teleportedActors.add(currentActor, 1)
    EndIf
    I += 1
  EndWhile
  Return teleportedActors
EndFunction
