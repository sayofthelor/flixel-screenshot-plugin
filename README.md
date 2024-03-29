<div align="center">

# flixel-screenshot-plugin

## `haxelib install flixel-screenshot-plugin`

## or

## `haxelib git flixel-screenshot-plugin http://github.com/sayofthelor/flixel-screenshot-plugin` (currently recommended)

</div>

## Flixel plugin for nice screenshot management, with many customizations
```haxe
ScreenShotPlugin.enabled; // Enable/disable the plugin at any time
ScreenShotPlugin.screenshtotKeys; // Keys to press to do a screenshot
ScreenShotPlugin.saveFormat; // The save file type (PNG/ JPEG)
ScreenShotPlugin.screenshotPath; // The path where to save the screenshots
ScreenShotPlugin.flashColor; // The color of the flash that appears when taking a screenshot
ScreenShotPlugin.outlineColor; // The shot display outline's color that appears when taking a screenshot
ScreenShotPlugin.screenshotFadeTime; // The flash fade-in duration
ScreenShotPlugin.jpegQuality; // If `saveFormat` is set to JPEG, this defines the quality of the JPEG files
ScreenShotPlugin.sound; // Custom sound asset to play when the screenshot is taken (if null, no sound is played)
```

### Some original code from [flixel-addons](http://lib.haxe.org/p/flixel-addons).

# Configuring
Make sure you have `flixel` and `openfl` installed.
In your `Project.xml` make sure this is there:
```xml
<haxelib name="flixel-screenshot-plugin" />
```
In your project's `Main.hx` file, after the `FlxGame` is initialized, add this line:
```haxe
flixel.FlxG.plugins.add(new flixel.addons.plugin.ScreenShotPlugin());
```
And you're done!
