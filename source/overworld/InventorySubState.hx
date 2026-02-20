package overworld;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import MusicBeatSubstate;
import Paths;

import overworld.PlayerOW;

class InventorySubState extends MusicBeatSubstate
{   
    var bgInv:FlxSprite;
    var resumeButton:FlxSprite;
    var exitButton:FlxSprite;

    var curSelected:Int = 0;
    var buttons:Array<FlxSprite>;

    var selectionLocked:Bool = false;

    var animOffsets:Map<FlxSprite, Map<String, Array<Float>>>;

    public function new()
    {
        super();
        PlayerOW.canMove = false;
        PlayerOW.canInv = false;

        animOffsets = new Map<FlxSprite, Map<String, Array<Float>>>();

        // Fondo oscuro
        bgInv = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x88000000);

        // === RESUME BUTTON ===
        resumeButton = new FlxSprite(FlxG.width / 2 - 100, 250);
        resumeButton.frames = Paths.getSparrowAtlas("overWorld/InventoryHUD/resumeButton");
        resumeButton.animation.addByPrefix("idle", "Resume Idle", 24, true);
        resumeButton.animation.addByPrefix("on", "Resume on", 24, true);
        resumeButton.animation.addByPrefix("selected", "Pressed Resume", 24, true);

        // === EXIT BUTTON ===
        exitButton = new FlxSprite(FlxG.width / 2 - 100, 330);
        exitButton.frames = Paths.getSparrowAtlas("overWorld/InventoryHUD/exitButton");
        exitButton.animation.addByPrefix("idle", "Menu Idle", 24, true);
        exitButton.animation.addByPrefix("on", "Menu on", 24, true);
        exitButton.animation.addByPrefix("selected", "Pressed Menu", 24, true);

        playAnim(resumeButton, "idle");
        playAnim(exitButton, "idle");

        addOffset(resumeButton, "idle", 0,0);
        addOffset(resumeButton, "on", 27,27);
        addOffset(resumeButton, "selected", 27,27);

        addOffset(exitButton, "idle", 0,0);
        addOffset(exitButton, "on", 27,27);
        addOffset(exitButton, "selected", 27,27);
        

        bgInv.x = -475;
        bgInv.y = -180;

        resumeButton.x = -400;
        resumeButton.y = -50;

        exitButton.x = 200;
        exitButton.y = -50;

        bgInv.alpha = 0;
        resumeButton.alpha = 0;
        exitButton.alpha = 0;

        add(bgInv);
        add(resumeButton);
        add(exitButton);

        FlxTween.tween(bgInv, {alpha: 1}, 0.1);
        FlxTween.tween(resumeButton, {alpha: 1}, 0.3);
        FlxTween.tween(exitButton, {alpha: 1}, 0.3);

        buttons = [resumeButton, exitButton];
        updateSelection();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (selectionLocked)
            return;

        if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
            changeSelection(-1);

        if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
            changeSelection(1);

        if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.Z)
            selectOption();
    }

    function changeSelection(change:Int)
    {
        curSelected += change;

        if (curSelected < 0)
            curSelected = buttons.length - 1;
        if (curSelected >= buttons.length)
            curSelected = 0;

        updateSelection();
        FlxG.sound.play(Paths.sound("scrollMenu"));
    }

    function updateSelection()
    {
        for (i in 0...buttons.length)
        {
            playAnim(buttons[i], i == curSelected ? "on" : "idle");
        }
    }

    function selectOption() // When player selects option
    {
        selectionLocked = true;
        FlxG.sound.play(Paths.sound("confirmMenu"));

        for (i in 0...buttons.length) 
        {
            playAnim(buttons[i], i == curSelected ? "selected" : "idle");
        }

        new FlxTimer().start(0.4, function(tmr:FlxTimer)
        {
            switch (curSelected)
            {
                case 0: // Resume (CERRAR INV)
                    fadeOutMenu(function()
                    {
                        PlayerOW.canMove = true;
                        PlayerOW.canInv = true;
                        close();
                    });
                case 1: // Exit
                    MusicBeatState.switchState(new MainMenuState());
                    FlxG.sound.playMusic(Paths.music('freakyMenu'));
                    PlayerOW.canMove = true;
                    PlayerOW.canInv = true;
            }
        });
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



    /*
    public function playAnim(tag:String, name:String, force:Bool = false)
    {
        tag.animation.play(name, force);

        if (animOffsets.exists(name))
        {
            var off = animOffsets.get(name);
            offset.set(off[0], off[1]);
        }
        else
        {
            offset.set(0, 0);
        }
    }*/

    function fadeOutMenu(onComplete:Void->Void)
    {
        var objects = [resumeButton, exitButton, bgInv];
        var finishedTweens:Int = 0;
        var totalTweens:Int = objects.length;

        for (obj in objects)
        {
            FlxTween.tween(obj, {alpha: 0}, 0.4, {
                onComplete: function(twn)
                {
                    finishedTweens++;
                    if (finishedTweens >= totalTweens)
                    {
                        if (onComplete != null)
                            onComplete();
                    }
                }
            });
        }
    }
}