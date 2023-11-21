@echo off

@REM Notepad++/VSCODE needs current working directory to be where Caprica.exe is 
cd "C:\Repositories\Public\Starfield Mods\starfield-galactic-pet-shop\Tools"

@echo "Deploying Main Archive to MO2 Mod DIR"
copy /y "C:\Repositories\Public\Starfield Mods\starfield-galactic-pet-shop\Dist\GalacticPetShop - Main.ba2" "D:\MO2Staging\Starfield\mods\GalacticPetShop-Experimental"

@REM @echo "Deploying Texture Archive to MO2 Mod DIR"
@REM copy /y "C:\Repositories\Public\Starfield Mods\starfield-galactic-pet-shop\Dist\GalacticPetShop - Textures.ba2" "D:\MO2Staging\Starfield\mods\GalacticPetShop-Experimental"
