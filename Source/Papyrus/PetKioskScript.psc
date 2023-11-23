ScriptName PetKioskScript Extends ObjectReference

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
Message Property PET_MAIN_MENU Auto Const mandatory
Message Property PET_MENU_QUADPET Auto Const mandatory
Message Property FAILED_MAX_PETS Auto Const mandatory
Message Property FAILED_MAX_PET_BEDS Auto Const mandatory

ActorBase Property QuadrupedPet Auto Const mandatory
Furniture Property PetBed Auto Const mandatory

FormList Property ActivePetsList Auto Const mandatory
FormList Property ActivePetBedList Auto Const mandatory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Variables
;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Events
;;;
Event OnInit()
  VPI_Debug.DebugMessage("PetKioskScript", "OnInit", "OnInit Triggered.", 0, Venpi_DebugEnabled.GetValueInt())
EndEvent

Event OnLoad()
  VPI_Debug.DebugMessage("PetKioskScript", "OnLoad", "OnLoad Triggered.", 0, Venpi_DebugEnabled.GetValueInt())
EndEvent

Event OnActivate(ObjectReference akActionRef)
  If (akActionRef == Game.GetPlayer() as ObjectReference)
    self.ProcessMenu(PET_MAIN_MENU, -1, True)
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
    If (message == PET_MAIN_MENU)
      menuButtonClicked = PET_MAIN_MENU.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
      If (menuButtonClicked == 0)
        ;; CLICKED 0: Close Menu Clicked
        menuActive = False
      ElseIf (menuButtonClicked == 1)
        ;; CLICKED 1: Show Enabled FEautre Menu
        VPI_Debug.DebugMessage("PetKioskScript", "ProcessMenu", "Main Menu Button 1 clicked launching PET_MENU_QUADPET.", 0, Venpi_DebugEnabled.GetValueInt())
        message = PET_MENU_QUADPET
      ElseIF (menuButtonClicked == 1) 
        ;; CLICKED 1: Release From Cage
        VPI_Debug.DebugMessage("PetKioskScript", "ProcessMenu", "Main Menu Button 1 clicked deploying pet bed.", 0, Venpi_DebugEnabled.GetValueInt())
        self.DeployPetBed()
        menuActive = False
      EndIf
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Show Quadruped Pet Menu
    ElseIf(message == PET_MENU_QUADPET)
      menuButtonClicked = PET_MENU_QUADPET.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
      message = PET_MAIN_MENU ;; Return to root menu
      If (menuButtonClicked == 0)
        ;; CLICKED 0: Return to main menu
      ElseIF (menuButtonClicked == 1) 
        ;; CLICKED 1: Release From Cage
        VPI_Debug.DebugMessage("PetKioskScript", "ProcessMenu", "Quadruped Mgmt Menu Button 1 clicked releasing the pet.", 0, Venpi_DebugEnabled.GetValueInt())
        self.ReleasePet(QuadrupedPet)
        menuActive = False
      EndIf

    EndIf ;; End Main Menu
  EndWhile
EndFunction

Function ReleasePet(ActorBase pet)
  If (ActivePetsList.GetSize() + 1 >= MAX_PETS.GetValueInt())
    VPI_Debug.DebugMessage("PetKioskScript", "ReleasePet", "Failed to deploy pet, the max number of pets limit has been reached.", 0, Venpi_DebugEnabled.GetValueInt())
    FAILED_MAX_PETS.show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    Return
  Else
    VPI_Debug.DebugMessage("PetKioskScript", "ReleasePet", "Releasing a PET " + pet + ".", 0, Venpi_DebugEnabled.GetValueInt())
    Float[] offset = new Float[3]
    offset[CONST_OFFSET_X] = -1
    offset[CONST_OFFSET_Y] = -1
    ObjectReference ref = self.PlaceAtMe(pet as Form, 1, False, False, True, None, None, True)
    ActivePetsList.AddForm(ref.GetBaseObject() as Form)
  EndIf
EndFunction

Function DeployPetBed()
  If (ActivePetBedList.GetSize() + 1 >= MAX_PETS.GetValueInt())
    VPI_Debug.DebugMessage("PetKioskScript", "DeployPetBed", "Failed to deploy pet bed, the max number of pets limit has been reached.", 0, Venpi_DebugEnabled.GetValueInt())
    FAILED_MAX_PET_BEDS.show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    Return
  Else
    VPI_Debug.DebugMessage("PetKioskScript", "DeployPetBed", "Deploying pet bed " + PetBed + ".", 0, Venpi_DebugEnabled.GetValueInt())
    Float[] offset = new Float[3]
    offset[CONST_OFFSET_X] = -1
    offset[CONST_OFFSET_Y] = -1
    ObjectReference ref = self.PlaceAtMe(PetBed as Form, 1, False, False, True, None, None, True)
    ActivePetBedList.AddForm(ref.GetBaseObject() as Form)
  EndIf
EndFunction
