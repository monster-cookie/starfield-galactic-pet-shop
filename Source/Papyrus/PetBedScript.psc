ScriptName PetBedScript Extends ObjectReference

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Constants
;;;
; Int CONST_AILEVELMOD_EASY = 0 Const
; Int CONST_AILEVELMOD_MEDIUM = 1 Const
; Int CONST_AILEVELMOD_HARD = 2 Const
; Int CONST_AILEVELMOD_VERYHARD = 4 Const

; Int CONST_OFFSET_X=0 Const
; Int CONST_OFFSET_Y=1 Const
; Int CONST_OFFSET_Z=2 Const

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
Message Property PET_MENU_NOTOWNED Auto Const mandatory
Message Property PET_MENU_OWNED Auto Const mandatory
Message Property PET_MENU_OWNED_SCALING Auto Const mandatory
Message Property FAILED_MAX_PETS Auto Const mandatory
Message Property FAILED_PETBED_OWNED Auto Const mandatory
Message Property FAILED_PETBED_NOT_OWNED Auto Const mandatory
Message Property FAILED_NOT_IMPLEMENTED Auto Const mandatory
Message Property PETBED_OWNED_MESG Auto Const Mandatory
Keyword Property PETBED_HAS_OWNER Auto Const Mandatory
ActorBase Property PET_TYPE Auto Const mandatory
FormList Property ActivePetsList Auto Const mandatory
Keyword Property CCT_Instance_Name_Flyer Auto Const Mandatory


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
    If (self.HasKeyword(PETBED_HAS_OWNER) == False)
      self.ProcessMenu(PET_MENU_NOTOWNED, -1, True)
    Else
      self.ProcessMenu(PET_MENU_OWNED, -1, True)
    EndIf
  EndIf
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Functions
;;;
Function ProcessMenu(Message message, Int menuButtonClicked, Bool menuActive)
  While (menuActive)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Show No Pet Owned Menu
    If (message == PET_MENU_NOTOWNED)
      menuButtonClicked = PET_MENU_NOTOWNED.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
      If (menuButtonClicked == 0)
        ;; CLICKED 0: Close Menu Clicked
        menuActive = False
      ElseIf (menuButtonClicked == 1)
        ;; CLICKED 1: Call Pet
        VPI_Debug.DebugMessage("PetKioskScript", "ProcessMenu", "PET_MENU_NOTOWNED Button 1 clicked - call pet.", 0, Venpi_DebugEnabled.GetValueInt())
        self.SummonPet()
        menuActive = False
      EndIf

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Show Pet Owned Menu
    ElseIf (message == PET_MENU_OWNED)
      menuButtonClicked = PET_MENU_OWNED.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
      If (menuButtonClicked == 0)
        ;; CLICKED 0: Close Menu Clicked
        menuActive = False
      ElseIf (menuButtonClicked == 1)
        ;; CLICKED 1: Release Pet
        VPI_Debug.DebugMessage("PetKioskScript", "ProcessMenu", "PET_MENU_OWNED Button 1 clicked - release pet.", 0, Venpi_DebugEnabled.GetValueInt())
        self.ReleasePet()
        menuActive = False
      ElseIF (menuButtonClicked == 2) 
        ;; CLICKED 2: Scale Pet
        VPI_Debug.DebugMessage("PetKioskScript", "ProcessMenu", "PET_MENU_OWNED Button 2 clicked - scale pet.", 0, Venpi_DebugEnabled.GetValueInt())
        message = PET_MENU_OWNED_SCALING
      ElseIF (menuButtonClicked == 3) 
        ;; CLICKED 3: Scale Pet
        VPI_Debug.DebugMessage("PetKioskScript", "ProcessMenu", "PET_MENU_OWNED Button 3 clicked - recall pet to bed.", 0, Venpi_DebugEnabled.GetValueInt())
        self.RecallPet()
        menuActive = False
      EndIf

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Show Pet Own Scaling Menu
    ElseIf (message == PET_MENU_OWNED_SCALING)
      menuButtonClicked = PET_MENU_OWNED_SCALING.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
      message = PET_MENU_OWNED ;; Return to root menu
      If (menuButtonClicked == 0)
        ;; CLICKED 0: Return to main menu
      ElseIF (menuButtonClicked == 1) 
        ;; CLICKED 1: Scale to 150%
        self.ScalePet(1.50)
        menuActive = False
      ElseIF (menuButtonClicked == 2) 
        ;; CLICKED 2: Scale to 140%
        self.ScalePet(1.40)
        menuActive = False
      ElseIF (menuButtonClicked == 3) 
        ;; CLICKED 3: Scale to 130%
        self.ScalePet(1.30)
        menuActive = False
      ElseIF (menuButtonClicked == 4) 
        ;; CLICKED 4: Scale to 120%
        self.ScalePet(1.30)
        menuActive = False
      ElseIF (menuButtonClicked == 5) 
        ;; CLICKED 5: Scale to 110%
        self.ScalePet(1.10)
        menuActive = False
      ElseIF (menuButtonClicked == 6) 
        ;; CLICKED 6: Scale to 100%
        self.ScalePet(1.00)
        menuActive = False
      ElseIF (menuButtonClicked == 7) 
        ;; CLICKED 7: Scale to 90%
        self.ScalePet(0.90)
        menuActive = False
      ElseIF (menuButtonClicked == 8) 
        ;; CLICKED 8: Scale to 80%
        self.ScalePet(0.80)
        menuActive = False
      ElseIF (menuButtonClicked == 9) 
        ;; CLICKED 9: Scale to 70%
        self.ScalePet(0.70)
        menuActive = False
      ElseIF (menuButtonClicked == 10) 
        ;; CLICKED 10: Scale to 60%
        self.ScalePet(0.60)
        menuActive = False
      ElseIF (menuButtonClicked == 11) 
        ;; CLICKED 11: Scale to 50%
        self.ScalePet(0.50)
        menuActive = False
      ElseIF (menuButtonClicked == 12) 
        ;; CLICKED 12: Scale to 40%
        self.ScalePet(0.40)
        menuActive = False
      ElseIF (menuButtonClicked == 13) 
        ;; CLICKED 13: Scale to 30%
        self.ScalePet(0.30)
        menuActive = False
      ElseIF (menuButtonClicked == 14) 
        ;; CLICKED 14: Scale to 15%
        self.ScalePet(0.15)
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

    if (PET_TYPE.HasKeyword(CCT_Instance_Name_Flyer))
      ;; PET is a flyer and needs z axis increased by 1.5
      VPI_Debug.DebugMessage("PetKioskScript", "SummonPet", "Pet is a flyer adjusting coords(x, y, z) to 0, -1.5, 1.5.", 0, Venpi_DebugEnabled.GetValueInt())
      offset[0] = 1.5
      offset[1] = -1.5
      offset[2] = 0
    Else
      offset[0] = 0
      offset[1] = -1.5
      offset[2] = 0
    EndIf

    myPet = self.PlaceAtMe(PET_TYPE as Form, 1, False, False, True, offset, None, True)
    self.AddKeyword(PETBED_HAS_OWNER)
    self.SetActivateTextOverride(PETBED_OWNED_MESG)
    ActivePetsList.AddForm(myPet.GetBaseObject() as Form)
  EndIf
EndFunction

Function ScalePet(Float scale)
  If (myPet == None || self.HasKeyword(PETBED_HAS_OWNER) == False)
    VPI_Debug.DebugMessage("PetKioskScript", "ScalePet", "Scale pet failed pet is null or pet bed is not owned", 0, Venpi_DebugEnabled.GetValueInt())
    FAILED_PETBED_NOT_OWNED.show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    Return
  EndIf
  myPet.SetScale(scale)
EndFunction

Function ReleasePet()
  VPI_Debug.DebugMessage("PetKioskScript", "ReleasePet", "NOT IMPLEMENTED", 0, Venpi_DebugEnabled.GetValueInt())
  FAILED_NOT_IMPLEMENTED.show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction

Function RecallPet()
  VPI_Debug.DebugMessage("PetKioskScript", "RecallPet", "Moving pet back to the pet bed.", 0, Venpi_DebugEnabled.GetValueInt())

  if (PET_TYPE.HasKeyword(CCT_Instance_Name_Flyer))
    ;; PET is a flyer and needs z axis increased by 1.5
    VPI_Debug.DebugMessage("PetKioskScript", "SummonPet", "Pet is a flyer adjusting recall coords(x, y, z) to 0, -1.5, 1.5.", 0, Venpi_DebugEnabled.GetValueInt())
    myPet.MoveTo(self, 0, -1.5, 1.5, True, True)
  Else
    myPet.MoveTo(self, 0, -1.5, 0, True, True)
  EndIf
EndFunction
