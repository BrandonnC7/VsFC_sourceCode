package overworld;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import MusicBeatState;
import Paths;

import overworld.PlayerOW;
import overworld.World;

class LevelSelectedSubState extends MusicBeatSubstate
{
    var animOffsets:Map<FlxSprite, Map<String, Array<Float>>>;
    
    var bgLevel:FlxSprite;
    var okButton:FlxSprite;
    var lvlDifficulty:FlxSprite; // Faces like GD :D (thats the idea lol)

    var curLvl:RoomData;


    public function new() // UPDATE: NEED TO ADD THE SRITES TO MAKE IT WORK
    {
        super();
        animOffsets = new Map<FlxSprite, Map<String, Array<Float>>>();

        PlayerOW.canInv = false; // for obvious reasons
        PlayerOW.canMove = false;

        bgLevel = new FlxSprite(0,0);
        bgLevel.makeGraphic(100, 50, 0xFFFFAF47);

        okButton = new FlxSprite(0,0);
        okButton.makeGraphic(50,30, 0xFF8D8D8D);

    }

    public static function loadPlaySong(songName:String, week:Int)
    {
        PlayState.isStoryMode = true;
        PlayState.storyWeek = week;
        PlayState.storyDifficulty = 0;

        WeekData.reloadWeekFiles(false);
        WeekData.loadTheFirstEnabledMod();

        var songLowercase:String = Paths.formatToSongPath(songName);

        PlayState.SONG = Song.loadFromJson(songLowercase, songLowercase);

        if (PlayState.SONG == null)
        {
            trace('LOADING SONG ERROR: ' + songLowercase);
            return;
        }

        LoadingState.loadAndSwitchState(new PlayState());
    }

    public function addOffset(sprite:FlxSprite, name:String, x:Float = 0, y:Float = 0)
    {
        if (!animOffsets.exists(sprite))
            animOffsets.set(sprite, new Map<String, Array<Float>>());

        animOffsets.get(sprite).set(name, [x, y]);
    }


    public function playAnim(sprite:FlxSprite, name:String, force:Bool = false)
    {
        sprite.animation.play(name, force);

        if (animOffsets.exists(sprite) && animOffsets.get(sprite).exists(name))
        {
            var off = animOffsets.get(sprite).get(name);
            sprite.offset.set(off[0], off[1]);
        }
        else
        {
            sprite.offset.set(0, 0);
        }
    }
}