package overworld;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxCamera;

import Paths;

class PlayerOW extends FlxSprite
{
    public static var canMove:Bool = true;
    public static var isMoving:Bool = false;
    public static var canInv:Bool = true;

    public var walkSpeed:Float = 360; // pps
    public var plrDirection:String = "down";

    public var animOffsets:Map<String, Array<Float>>;

    var moveX:Float = 0;
    var moveY:Float = 0;

    public var plrHitbox:FlxSprite;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        plrHitbox = new FlxSprite(x, y);

        animOffsets = new Map<String, Array<Float>>();

        var atlas:FlxAtlasFrames = Paths.getSparrowAtlas("overWorld/FOS-overworld");

        if (atlas != null)
            frames = atlas;
        else
            loadGraphic(Paths.image("overWorld/FOS-overworld"), true, 32, 32);


        // Animaciones

        animation.addByPrefix("leftIdle",  "FOS Left Idle",  24, true);
        animation.addByPrefix("leftWalk",  "FOS Left Walk",  24, true);

        animation.addByPrefix("downIdle",  "FOS Down Idle",  24, true);
        animation.addByPrefix("downWalk",  "FOS Down Walk",  24, true);

        animation.addByPrefix("upIdle",    "FOS Up Idle",    24, true);
        animation.addByPrefix("upWalk",    "FOS Up Walk",    24, true);

        animation.addByPrefix("rightIdle", "FOS Right Idle", 24, true);
        animation.addByPrefix("rightWalk", "FOS Right Walk", 24, true);


        // Offsets

        addOffset("leftIdle", 33,0);
        addOffset("leftWalk", 31,0);
        
        addOffset("downIdle", 0,0);
        addOffset("downWalk", -1,0);

        addOffset("upIdle", -11,0);
        addOffset("upWalk", -11,0);

        addOffset("rightIdle", -26,0);
        addOffset("rightWalk", -16,0);

        playAnim("downIdle");


        // Player Hitbox

        
        plrHitbox = new FlxSprite(x, y);

        plrHitbox.makeGraphic(305, 55, 0x41FF8800);
        plrHitbox.offset.set(-9, 0);

        plrHitbox.visible = false;

        plrHitbox.immovable = true;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        move(elapsed);
    }

    public function move(elapsed:Float)
    {
        if (!canMove)
        {
            playAnim(plrDirection + "Idle");
            return;
        }

        moveX = 0;
        moveY = 0;

        if (canMove)
            if (FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT)
            {
                moveX = -1;
                plrDirection = "left";
            }
            else if (FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT)
            {
                moveX = 1;
                plrDirection = "right";
            }

            if (FlxG.keys.pressed.W || FlxG.keys.pressed.UP)
            {
                moveY = -1;
                plrDirection = "up";
            }
            else if (FlxG.keys.pressed.S || FlxG.keys.pressed.DOWN)
            {
                moveY = 1;
                plrDirection = "down";
            }

            isMoving = (moveX != 0 || moveY != 0);

        if (moveX != 0 && moveY != 0)
        {
            var d = Math.sqrt(2);
            moveX /= d;
            moveY /= d;
        }
        
        // El plr se mueve.. o deberia ( no me sirve asi :c)
        //velocity.x = moveX * walkSpeed;
        //velocity.y = moveY * walkSpeed;

        if (isMoving)
            playAnim(plrDirection + "Walk");
        else
            playAnim(plrDirection + "Idle");


        // Player Hitbox //

        plrHitbox.x = x + width / 2 - plrHitbox.width / 2;
        plrHitbox.y = y + height - plrHitbox.height - 2;
    }

    
    // Función Offset

    public function addOffset(name:String, x:Float = 0, y:Float = 0)
    {
        animOffsets.set(name, [x, y]);
    }


    // Función Anims

    public function playAnim(name:String, force:Bool = false)
    {
        animation.play(name, force);

        if (animOffsets.exists(name))
        {
            var off = animOffsets.get(name);
            offset.set(off[0], off[1]);
        }
        else
        {
            offset.set(0, 0);
        }
    }

    public function getMoveVector():{x:Float, y:Float}
    {
        return { x: moveX, y: moveY };
    }

}
