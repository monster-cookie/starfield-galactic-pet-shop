# Venpi's Galactic Pet Store

## Version 1.0.9
* Removed the categories and overridden beacon/decorator. Now using the stuff from Outpost Builder Categories. This is now a hard requirement.

## Version 1.0.8
* Thank you Tritch for solving the category problems with the pets.
* This uses a custom version of xEdit to copy REFL records. I've tested it as best I could with new games, NG+ Universes, and multiple outposts/ships. 

## Version 1.0.7
* Now using user debug logs via Venpi Core v1.0.10

## Version 1.0.6
* Removing MAX_PETS lock it doesn't work well even if you use the decorator to remove the pet bed. I think there might be a engine bug in play too cause we are putting the decorator other places. 
* Due to AI performance I recommend no more them 2-3 pets in an house, outpost, or ship. 

## Version 1.0.5
* You can now have your pets follow you anywhere and have them stop following you if you desire. They are still immortal non-combat pets. THe CCT system used as the basis for this has odd weapon attachments driven through a funk omod template. I'm still trying to figure a way around it to give them fighting abilities. 
* New options on the owned pet management pet screen control the follower state. 
* I had to make a whole new pet follower system for this as the game one keys human stuff for a lot of things and having your pet start idle chattering is very lore breaking if funny lol. 

## Version 1.0.4
* Missed back to 100% on the scale menu

## Version 1.0.3
* Forgot to push up on the z axis. The flyer AI is stupid is just flies along the X/Y plane only so flyers need a special height on spawn. Adding a new keyword that pushes flyers up 1.5u on a ship and 5u elsewhere. 

## Version 1.0.2
* Added Aceles and Vampire as rare pets
* New AI package based on follower on ship but this means I need a AI package for an outpost and I actually need to make an outpost lol
* New AI package seems to make the glitching though the roof less likely. I think the cause is the collision layer is large then the the mesh cause of scaling so they punch thought the roof on any stumble to stepping up anywhere on the floor. Not sure how to fix the collision error. 

## Version 1.0.1
* Added foxbat as rare
* Attempting to work on spawning point so they are less likely to go through the roof but I think they are just using hatches
* Added scaling to the pet bed menu.
* Adding a return to pet bed function to pet bed menu for errant pets that go wondering around on the roof. 

## Version 1.0.0
* Initial Release
