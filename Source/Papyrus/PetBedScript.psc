ScriptName PetBedScript Extends ObjectReference

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Constants
;;;
Int CONST_AILEVELMOD_EASY = 0 Const
Int CONST_AILEVELMOD_MEDIUM = 1 Const
Int CONST_AILEVELMOD_HARD = 2 Const
Int CONST_AILEVELMOD_VERYHARD = 4 Const

Int CONST_OFFSET_X=0 Const
Int CONST_OFFSET_Y=1 Const
Int CONST_OFFSET_Z=2 Const

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Global Variables
;;;
GlobalVariable Property Venpi_DebugEnabled Auto Const Mandatory
GlobalVariable Property MAX_PETS Auto Const Mandatory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Properties
;;;
Message Property PET_MENU Auto Const mandatory
Message Property FAILED_MAX_PETS Auto Const mandatory
Message Property FAILED_PETBED_OWNED Auto Const mandatory
Message Property FAILED_NOT_IMPLEMENTED Auto Const mandatory
Message Property PETBED_OWNED_MESG Auto Const Mandatory
Keyword Property PETBED_HAS_OWNER Auto Const Mandatory
ActorBase Property PET_TYPE Auto Const mandatory
FormList Property ActivePetsList Auto Const mandatory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Variables
;;;
ObjectReference Property myPet Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Events
;;;
Event OnActivate(ObjectReference akActionRef)
  If (akActionRef == Game.GetPlayer() as ObjectReference)
    self.ProcessMenu(PET_MENU, -1, True)
  EndIf
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Functions
;;;
Function ProcessMenu(Message message, Int menuButtonClicked, Bool menuActive)
  While (menuActive)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Show Pet Main Menu
    If (message == PET_MENU)
      menuButtonClicked = PET_MENU.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
      If (menuButtonClicked == 0)
        ;; CLICKED 0: Close Menu Clicked
        menuActive = False
      ElseIf (menuButtonClicked == 1)
        ;; CLICKED 1: Call Pet
        VPI_Debug.DebugMessage("PetKioskScript", "ProcessMenu", "Main Menu Button 1 clicked call pet.", 0, Venpi_DebugEnabled.GetValueInt())
        self.SummonPet()
        menuActive = False
      ElseIF (menuButtonClicked == 2) 
        ;; CLICKED 2: Release Pet
        VPI_Debug.DebugMessage("PetKioskScript", "ProcessMenu", "Main Menu Button 1 clicked deploying pet bed.", 0, Venpi_DebugEnabled.GetValueInt())
        self.ReleasePet()
        menuActive = False
      EndIf
    EndIf ;; End Main Menu
  EndWhile
EndFunction

Function SummonPet()
  If (ActivePetsList.GetSize() + 1 > MAX_PETS.GetValueInt())
    VPI_Debug.DebugMessage("PetKioskScript", "SummonPet", "Failed to deploy pet, the max number of pets limit has been reached.", 0, Venpi_DebugEnabled.GetValueInt())
    FAILED_MAX_PETS.show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    Return
  ElseIF (self.HasKeyword(PETBED_HAS_OWNER))
    VPI_Debug.DebugMessage("PetKioskScript", "SummonPet", "Failed to deploy pet, I already have a pet allocated.", 0, Venpi_DebugEnabled.GetValueInt())
    FAILED_PETBED_OWNED.show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    Return
  Else
    VPI_Debug.DebugMessage("PetKioskScript", "SummonPet", "Releasing a new pet of type " + PET_TYPE + ".", 0, Venpi_DebugEnabled.GetValueInt())
    Float[] offset = new Float[3]
    offset[CONST_OFFSET_X] = 0.5
    offset[CONST_OFFSET_Y] = 0.5
    myPet = self.PlaceAtMe(PET_TYPE as Form, 1, False, False, True, offset, None, True)
    self.AddKeyword(PETBED_HAS_OWNER)
    self.SetActivateTextOverride(PETBED_OWNED_MESG)
    ActivePetsList.AddForm(myPet.GetBaseObject() as Form)
  EndIf
EndFunction

Function ReleasePet()
  VPI_Debug.DebugMessage("PetKioskScript", "ReleasePet", "NOT IMPLEMENTED", 0, Venpi_DebugEnabled.GetValueInt())
  FAILED_NOT_IMPLEMENTED.show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction
