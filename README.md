The mod uses FNF' Psych Engine 0.6.3

-- WHATS NEW?:

The source folder contains a different hud exclusive for the mod
New Overworld folder (it contains a lot of .hx files, creating a functional overworld)
Little additions to the gameplay (like animations based on combo and winning icons)

New main menu & freeplay is planned for later..

-- HOW DOES THE OVERWORLD WORK? (remember, all the overworld stuff is placed inside de overworld folder)

-- OverWorldState.hx: Is the main state of the overworld, it manages almost all the loads around the overworld such as the player, the current room, the saves (in the future i hope so) and obviously, the current world

-- InventorySubState.hx: Is the inventory state, loaded by OverWorldState.hx, it manages the pause menu, also used as the inventory, where you can pause and exit the overworld to get some rest or to manage your characters equipment (newBF & FOBF (sorry dont have og names for them))

-- LevelSelectedSubState.hx: It is intended to show up when the player wants to enter to a level from the overworld, loaded by OverWorldState.hx, it manages basic things about the level the player wanna play for example, it shows the level name, the difficulty of the level, and in the future i hope so to add the playable character icon.. (thinking rn for more info since this addition is recent lol)

-- NPC.hx Has no code for the moment, but the idea is to manages the NPCs around the overworld, like their dialogues, or even if they got a challenge for ya

-- PlayerOW.hx It manages the main characters theirselves (the player) on the overworld, loads your hitbox, and the player movement, sprites and animations, nothing more than that (In the future planning for a character select in here, dont know for now)

-- World.hx Very important, since this one manages from a list the current world, all the rooms of every world, and their music, it has a lot of variables for each addition of the overworld for example:

id: the tag of your sprite
type: the type of the sprite (sprite, hitbox, level, door, etc)
x , y: their position
It also contains optional variables, they're used depending of the type of the sprite For example: For Sprites (just sprites):

image: at least you want to make graphic with it, it loads the image used for your sprite (overworld/world1/lol)

overPlayer: if the sprite is over the player or not, you can use for lightning or make perspective of things above the characters for example.

For doors (leading you from a room to another)

targetRoom: pretty self-explanarory, it indicates which room is the player going when touching the door

spawnX, Y: the character position when it goes to the new room (normally put in front to another door leading to the previous room)

For Levels (Loads the PlayState with the current song of the sprite)

level: self-explanatory isnt it? type the level you want the sprite load

difficulty: it is used for LevelSelectedSubState.hx, showing the player how hard the current level is

The main idea is based on UNDERTALE, creating rooms, NPCs with dialogues, but with the addition of creating worlds

