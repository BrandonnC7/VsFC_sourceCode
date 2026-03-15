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
import overworld.LevelSelectedSubState;

import overworld.worlds.World1;
import overworld.worlds.World2;
import overworld.worlds.World3;
import overworld.worlds.World4;
import overworld.worlds.World5;
import overworld.worlds.World6;
import overworld.worlds.World7;
import overworld.worlds.World8;


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
    public var OWDebugMode:Bool = true;

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


        // Dev // (just for checking)

        if (OWDebugMode) {
            player.plrHitbox.visible = true;

            for (hb in hitbox)
            {
                hb.visible = true;
                hb.alpha = 0.4;
            }
            for (d in doors)
            {
                d.visible = true;
                d.alpha = 0.4;
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
                    if (OWDebugMode) {
                        hb.visible = true;
                        hb.alpha = 1;
                    } else {
                        hb.visible = false;
                        hb.alpha = 0;
                    }
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
                    if (!OWDebugMode) {
                        d.visible = false; 
                    }
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