package flixel.addons.plugin;

#if sys
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.tweens.FlxTween;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.system.FlxAssets.FlxSoundAsset;

import openfl.display.Sprite;
import openfl.utils.ByteArray;

import openfl.display.Bitmap;
import openfl.display.BitmapData;

using StringTools;

/**
 * This class allows the player to take in game screenshots via the `screenshotKeys`
 */
class ScreenShotPlugin extends flixel.FlxBasic {
    /**
     * Current `ScreenShotPlugin` instance
     */
    public static var current:ScreenShotPlugin = null;

    /**
     * Whether the plugin is currently enabled
     */
    public static var enabled:Bool = true;

    /**
     * Keys to press to screenshot
     */
    public static var screenshotKeys(default, set):Array<FlxKey> = [FlxKey.F2];

    /**
     * The save format used to save the screenshots, default to `PNG`.
     * The current available formats are `PNG` and `JPEG`
     */
    public static var saveFormat(default, set):FileFormatOption = PNG;

    /**
     * Screenshot path, where the screenshots are saved to
     */
    public static var screenshotPath(default, set):String = "screenshots";

    /**
     * The color used for the flash
     */
    public static var flashColor(default, set):Int = 0xFFFFFFFF;

    /**
     * The color used for the outline in the screenshot display
     */
    public static var outlineColor(default, set):Int = 0xFFFFFFFF;

    /**
     * The flash fade-in duration
     */
    public static var screenshotFadeTime:Float = 0.25;

    /**
     * The quality of screenshots saved as `JPEG`, default to 80
     */
    public static var jpegQuality(default, set):Int = 80;

    /**
     * Custom sound asset to play when the screenshot is taken.
     * If null, no sound is played
     */
    public static var sound:FlxSoundAsset = null;

    /**
     * A signal that gets dispatched when a screenshot is taken
     */
    public static var onScreenshotTaken(default, null):FlxTypedSignal<Bitmap->Void> = new FlxTypedSignal<Bitmap->Void>();

    /**
     * Post-signal that gets dispatched when a screenshot is taken
     */
    public static var onScreenshotTakenPost(default, null):FlxTypedSignal<Void->Void> = new FlxTypedSignal<Void->Void>();

    public static function set_screenshotKeys(v:Array<FlxKey>):Array<FlxKey> {
        if (v == null)
            v = [];

        var oldValue = v.copy();

        screenshotKeys = v;

        while (screenshotKeys.contains(-1))
            screenshotKeys.remove(-1);

        if (screenshotKeys.length <= 0) {
            FlxG.log.warn('ScreenShotPlugin: Invalid keybinds ${oldValue}, using [FlxKey.F2] instead');
            screenshotKeys = [FlxKey.F2];
        }

        return screenshotKeys;
    }

    public static function set_saveFormat(v:FileFormatOption) {
        if (v != JPEG && v != PNG) {
            FlxG.log.warn('ScreenShotPlugin: Unsupported format ${v}, using .png instead');
            v = PNG;
        }
        return saveFormat = v;
    }

    public static function set_screenshotPath(v:String):String {
        var oldValue = v;
        
        /*while (v.contains("/"))
            v = v.replace("/", "");*/

        #if windows
        if (v.startsWith(" "))
            v = v.substring(1);
        if (v.endsWith(" "))
            v = v.substring(0, v.lastIndexOf(" "));

        for (i in ["<", ">", ":", '"', '\\', "|", "?", "*"])
            if (v.contains(i))
                v = v.replace(i, "");

        for (word in ["CON", "PRN", "AUX", "NUL", "COM1", "COM2", "COM3",
            "COM4", "COM5", "COM6", "COM7", "COM8", "COM9", "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9"]) {
            if (v.toUpperCase() == word) {
                v = '_${v}';
                break;
            }
        }
        #elseif macos
        for (i in ["#", "%", "{", "}", "|", "`", ">", "<", "!", "?", "$", "^", '"', "'", ";", ":", "&", "+", "="])
            if (v.contains(i))
                v = v.replace(i, "");
        #end

        if (v.length <= 0) {
            FlxG.log.warn('ScreenShotPlugin: Invalid save folder name "${oldValue}", using "screenshots" instead');
            v = "screenshots";
        }

        return screenshotPath = v;
    }

    public static function set_flashColor(v:Int):Int {
        flashColor = v;
        if (current != null && current.flashBitmap != null)
            current.flashBitmap.bitmapData = new BitmapData(lastWidth, lastHeight, true, v);
        return flashColor;
    }

    public static function set_outlineColor(v:Int):Int {
        outlineColor = v;
        if (current != null && current.outlineBitmap != null)
            current.outlineBitmap.bitmapData = new BitmapData(Std.int(lastWidth / 5) + 10, Std.int(lastHeight / 5) + 10, true, outlineColor);
        return outlineColor;
    }

    public static function set_jpegQuality(v:Int):Int {
        if (v > 100 || v < 0) trace("Value out of range, clamped between 0 and 100");
        return jpegQuality = Std.int(Math.max(0, Math.min(100, v)));
    }
    
    private static var lastWidth:Int;
    private static var lastHeight:Int;

    private var container:Sprite;
    private var flashSprite:Sprite;
    private var flashBitmap:Bitmap;
    private var screenshotSprite:Sprite;
    private var shotDisplayBitmap:Bitmap;
    private var outlineBitmap:Bitmap;

    /**
     * Initialize a new `ScreenShotPlugin` instance
     */
    override public function new():Void {
        super();

        if (current != null) {
            destroy();
            return;
        }
        
        current = this;

        lastWidth = FlxG.width;
        lastHeight = FlxG.height;

        container = new Sprite();
        FlxG.stage.addChild(container);

        flashSprite = new Sprite();
        flashSprite.alpha = 0;
        flashBitmap = new Bitmap(new BitmapData(lastWidth, lastHeight, true, flashColor));
        flashSprite.addChild(flashBitmap);

        screenshotSprite = new Sprite();
        screenshotSprite.alpha = 0;
        container.addChild(screenshotSprite);

        outlineBitmap = new Bitmap(new BitmapData(Std.int(lastWidth / 5) + 10, Std.int(lastHeight / 5) + 10, true, outlineColor));
        outlineBitmap.x = 5;
        outlineBitmap.y = 5;
        screenshotSprite.addChild(outlineBitmap);

        shotDisplayBitmap = new Bitmap();
        shotDisplayBitmap.scaleX /= 5;
        shotDisplayBitmap.scaleY /= 5;
        screenshotSprite.addChild(shotDisplayBitmap);
        container.addChild(flashSprite);

        FlxG.signals.gameResized.add(this.resizeBitmap);
    }
    
    override public function update(elapsed:Float):Void {
        if (FlxG.keys.anyJustPressed(screenshotKeys) && enabled)
            screenshot();
    }

    private function screenshot():Void {
        for (sprite in [flashSprite, screenshotSprite]) {
            FlxTween.cancelTweensOf(sprite);
            sprite.alpha = 0;
        }

        var shot:Bitmap = new Bitmap(BitmapData.fromImage(FlxG.stage.window.readPixels()));
        onScreenshotTaken.dispatch(shot);

        var png:ByteArray = shot.bitmapData.encode(shot.bitmapData.rect, saveFormat.returnEncoder());
        png.position = 0;

        var path = '${screenshotPath}/Screenshot ' + Date.now().toString().split(":").join("-") + saveFormat;
        if (!sys.FileSystem.exists('./${screenshotPath}/'))
            sys.FileSystem.createDirectory('./${screenshotPath}/');
        sys.io.File.saveBytes(path, png);

        flashSprite.alpha = 1;
        FlxTween.tween(flashSprite, {alpha: 0}, screenshotFadeTime);

        shotDisplayBitmap.bitmapData = shot.bitmapData;
        shotDisplayBitmap.x = outlineBitmap.x + 5;
        shotDisplayBitmap.y = outlineBitmap.y + 5;

        screenshotSprite.alpha = 1;
        FlxTween.tween(screenshotSprite, {alpha: 0}, 0.5, {startDelay: .5});

        if (sound != null)
            FlxG.sound.play(sound);

        onScreenshotTakenPost.dispatch();
    }

    private function resizeBitmap(width:Int, height:Int) {
        lastWidth = width;
        lastHeight = height;
        flashBitmap.bitmapData = new BitmapData(lastWidth, lastHeight, true, flashColor);
        outlineBitmap.bitmapData = new BitmapData(Std.int(lastWidth / 5) + 10, Std.int(lastHeight / 5) + 10, true, outlineColor);
    }

    override public function destroy():Void {
        if (current == this)
            current = null;

        if (FlxG.plugins.list.contains(this))
            FlxG.plugins.remove(this);

        FlxG.signals.gameResized.remove(this.resizeBitmap);
        FlxG.stage.removeChild(container);

        super.destroy();

        if (container == null)
            return;

        @:privateAccess
        for (parent in [container, flashSprite, screenshotSprite])
            for (child in parent.__children)
                parent.removeChild(child);

        container = null;
        flashSprite = null;
        flashBitmap = null;
        screenshotSprite = null;
        shotDisplayBitmap = null;
        outlineBitmap = null;
    }

    override public function toString():String
        return "ScreenshotPlugin instance";

    // these variables below aren't necessary in this class

    @:deprecated('Do not reference `ScreenShotPlugin.visible`')
    override private function set_visible(Value:Bool):Bool return false;

    @:deprecated('Do not reference `ScreenShotPlugin.camera`')
    override private function set_camera(Value:FlxCamera):FlxCamera return null;

    @:deprecated('Do not reference `ScreenShotPlugin.camera`')
    override function get_camera():FlxCamera return null;

    @:deprecated('Do not reference `ScreenShotPlugin.cameras`')
    override private function set_cameras(Value:Array<FlxCamera>):Array<FlxCamera> return null;

    @:deprecated('Do not reference `ScreenShotPlugin.cameras`')
    override function get_cameras():Array<FlxCamera> return null;
}

enum abstract FileFormatOption(String) from String {
    var JPEG = ".jpg";
    var PNG = ".png";

    public function returnEncoder():Any {
        return switch (this:FileFormatOption) {
            case JPEG: new openfl.display.JPEGEncoderOptions(ScreenShotPlugin.jpegQuality);
            default: new openfl.display.PNGEncoderOptions();
        }
    }
}
#end
