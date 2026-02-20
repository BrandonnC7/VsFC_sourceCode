package overworld;

import flixel.group.FlxGroup.FlxTypedGroup;
import Discord.DiscordClient;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import MusicBeatState;
import PlayState;
import Song;
import Highscore;
import Paths;
import flixel.math.FlxMath;

import overworld.PlayerOW;
import overworld.World;
import overworld.World.RoomData;
import overworld.World.RoomObjectData;
import overworld.InventorySubState;

import overworld.worlds.World1;
import overworld.worlds.World2;
import overworld.worlds.World3;
import overworld.worlds.World4;
import overworld.worlds.World5;
import overworld.worlds.World6;
import overworld.worlds.World7;
import overworld.worlds.World8;


/* FAST EXPLANATION OF EVERY SCRIPT IN /OVERWORLD
-- OverWorldState.hx (this one):
Is the main state of the overworld, it manages almost all the loads around the overworld such as the player, the current room, the saves (in the future i hope so)
and obviously, the current world

-- InventorySubState.hx:
Is the inventory state, loaded by OverWorldState.hx, it manages the pause menu, also used as the inventory, where you can pause and exit the overworld to get some rest
or to manage your characters equipment (newBF & FOBF (sorry dont have og names for them))

-- LevelSelectedSubState.hx:
It is intended to show up when the player wants to enter to a level from the overworld, loaded by OverWorldState.hx, it manages basic things about the level the player wanna play
for example, it shows the level name, the difficulty of the level, and in the future i hope so to add the playable character icon.. (thinking rn for more info since this addition is recent lol)

-- NPC.hx
Has no code for the moment, but the idea is to manages the NPCs around the overworld, like their dialogues, or even if they got a challenge for ya

-- PlayerOW.hx
It manages the main characters theirselves (the player) on the overworld, loads your hitbox, and the player movement, sprites and animations, nothing more than that
(In the future planning for a character select in here, dont know for now)

-- World.hx
Very important, since this one manages from a list the current world, all the rooms of every world, and their music, it has a lot of variables for each addition of the overworld
for example:
- id: the tag of your sprite
- type: the type of the sprite (sprite, hitbox, level, door, etc)
- x , y: their position

It also contains optional variables, they're used depending of the type of the sprite
For example:
    For Sprites (just sprites):
- image: at least you want to make graphic with it, it loads the image used for your sprite (overworld/world1/lol)
- overPlayer: if the sprite is over the player or not, you can use for lightning or make perspective of things above the characters for example.

    For doors (leading you from a room to another)
- targetRoom: pretty self-explanarory, it indicates which room is the player going when touching the door
- spawnX, Y: the character position when it goes to the new room (normally put in front to another door leading to the previous room)

    For Levels (Loads the PlayState with the current song of the sprite)
- level: self-explanatory isnt it? type the level you want the sprite load
- difficulty: it is used for LevelSelectedSubState.hx, showing the player how hard the current level is
*/

class OverWorldState extends MusicBeatState
{
    public var player:PlayerOW;

    public var currentWorld:World;
    public var currentRoom:RoomData;

    public var roomObjects:Array<FlxSprite> = [];
    public var hitbox:Array<FlxSprite> = [];
    public var doors:Array<FlxSprite> = [];
    public var doorTargets:Map<FlxSprite, Dynamic> = new Map();

    public var bgLayer:FlxTypedGroup<FlxSprite>;
    public var fgLayer:FlxTypedGroup<FlxSprite>;

    private var curMusic:String = null;

    // Dev //
    public var showHitboxes:Bool = false;

    // IMPORTANT //
    var enteringLevel:Bool = false;

    override public function create()
    {
        super.create();

        persistentUpdate = true;
		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(false);

        if (FlxG.sound.music != null)
            FlxG.sound.music.stop();

        DiscordClient.changePresence("Fos Chronicles OverWorld", null);

        bgLayer = new FlxTypedGroup<FlxSprite>();
        fgLayer = new FlxTypedGroup<FlxSprite>();

        player = new PlayerOW(0, 0);

        add(bgLayer);
        add(player);
        add(player.plrHitbox);
        add(fgLayer);

        FlxG.camera.follow(player, LOCKON, 0.5);

        currentWorld = new World1();
        loadRoom(currentWorld.getRoom("room_1"));
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        // Dev //
        if (FlxG.keys.justPressed.H)
        {
            showHitboxes = !showHitboxes;
            toggleHitboxes(showHitboxes);
        }

        var mv = player.getMoveVector();

        if (mv.x != 0 || mv.y != 0)
        {
            moveOverWorld(mv.x, mv.y, elapsed);
        }


        // Inv //
        if (FlxG.keys.justPressed.TAB && PlayerOW.canMove && PlayerOW.canInv) {
            openInv();
        }

        // Colisiones
        for (hb in hitbox)
            FlxG.collide(hb, player.plrHitbox);

        // Puertas
        for (door in doors)
        {
            if (FlxG.overlap(player.plrHitbox, door))
            {
                var data = doorTargets.get(door);
                player.setPosition(data.spawnX, data.spawnY);
                loadRoom(currentWorld.getRoom(data.room));
                return;
            }
        }

        if (enteringLevel)
            return;

        for (obj in doorTargets.keys())
        {
            var data = doorTargets.get(obj);

            if (data.level == null)
                continue;

            if (FlxG.overlap(obj, player.plrHitbox) && controls.ACCEPT || FlxG.overlap(obj, player.plrHitbox) && FlxG.keys.justPressed.Z && PlayerOW.canInv) // como undertale xd
            {
                //loadPlaySong(data.level, 7);
                selectedLvl();
            }
        }
    }

    function loadRoom(room:RoomData)
    {
        removeRoom();
        currentRoom = room;
        enteringLevel = false;

        roomMusic(room);

        for (obj in room.objects)
        {
            switch (obj.type)
            {
                case "sprite":
                    var spr = new FlxSprite(obj.x, obj.y);
                    spr.loadGraphic(Paths.image(obj.image));
                    if (obj.overPlayer)
                        fgLayer.add(spr);
                    else
                        bgLayer.add(spr);
                    roomObjects.push(spr);

                case "hitbox":
                    var hb = new FlxSprite(obj.x, obj.y);
                    hb.makeGraphic(obj.width, obj.height, 0xFF8D8D8D);
                    hb.immovable = true;
                    hb.visible = showHitboxes;
                    hb.alpha = showHitboxes ? 0.5 : 0;
                    add(hb);
                    hitbox.push(hb);
                    roomObjects.push(hb);

                case "door":
                    var d = new FlxSprite(obj.x, obj.y);
                    d.makeGraphic(obj.width, obj.height, 0xFF1FAF73);
                    d.immovable = true;
                    add(d);
                    doors.push(d);
                    roomObjects.push(d);
                    doorTargets.set(d, {
                        room: obj.targetRoom,
                        spawnX: obj.spawnX,
                        spawnY: obj.spawnY
                    });

                case "level":
                    var lvl = new FlxSprite(obj.x, obj.y);
                    lvl.makeGraphic(obj.width, obj.height, 0xFF4BCBD4);
                    lvl.immovable = true;
                    add(lvl);
                    roomObjects.push(lvl);
                    doorTargets.set(lvl, {
                        level: obj.level
                        //week: obj.week
                    });
            }
        }
    }

    function removeRoom()
    {
        for (obj in roomObjects)
        {
            remove(obj);
            obj.destroy();
        }

        roomObjects = [];
        hitbox = [];
        doors = [];
        doorTargets.clear();
    }

    function roomMusic(room:RoomData)
    {
        if (room.bgMusic == null || curMusic == room.bgMusic)
            return;

        curMusic = room.bgMusic;

        FlxG.sound.playMusic(
            Paths.music(curMusic),
            0.8,
            true
        );
    }

    function toggleHitboxes(value:Bool)
    {
        player.plrHitbox.visible = value;

        for (hb in hitbox)
            if (hb != null)
                hb.visible = value;
    }

    
    
    
    function moveOverWorld(dx:Float, dy:Float, elapsed:Float)
    {
        // En realidad el overworld se mueve, no el jugador, asi tocó :c //
        var speed = player.walkSpeed * elapsed;

        var moveX = -dx * speed;
        var moveY = -dy * speed;

        for (obj in roomObjects)
            obj.x += moveX;

        var collidedX:Bool = false;

        for (hb in hitbox)
        {
            if (player.plrHitbox.overlaps(hb))
            {
                collidedX = true;
                break;
            }
        }

        if (collidedX)
        {
            for (obj in roomObjects)
                obj.x -= moveX;
        }

        for (obj in roomObjects)
            obj.y += moveY;

        var collidedY:Bool = false;

        for (hb in hitbox)
        {
            if (player.plrHitbox.overlaps(hb))
            {
                collidedY = true;
                break;
            }
        }

        if (collidedY)
        {
            for (obj in roomObjects)
                obj.y -= moveY;
        }
    }

    function openInv() // Opens Inv
    {
        if (subState != null) return;
        openSubState(new InventorySubState());
    }

    function selectedLvl() // Opens Level menú
    {
        if (subState != null) return;
        openSubState(new LevelSelectedSubState());
    }
}