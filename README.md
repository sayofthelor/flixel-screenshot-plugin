<div align="center">

# flixel-screenshot-plugin

## Flixel plugin for nice screenshot management.

## All screenshots are saved to the `./screenshots/` folder by default, but the path can be customized.

### Some original code from [flixel-addons](http://lib.haxe.org/p/flixel-addons).

# Configuring
Make sure you have `flixel` and `openfl` installed.
Run the command:
```
haxelib install flixel-screenshot-plugin
```
To install a more bleeding-edge version (may be unstable), run this:
```
haxelib git flixel-screenshot-plugin http://github.com/sayofthelor/flixel-screenshot-plugin
```
In your `Project.xml` make sure this is there:
```xml
<haxelib name="flixel-screenshot-plugin" />
```
In your project's `Main.hx` file, after the `FlxGame` is initialized, add this line:
```haxe
flixel.FlxG.plugins.add(new screenshotplugin.ScreenShotPlugin());
```
And you're done!

If you want to save as a JPEG file instead, run this after the last line.
```haxe
screenshotplugin.ScreenShotPlugin.saveFormat = JPEG;
```

The screenshot hotkey is an FlxKey, and is bound to F2 by default. You can change it like this:
```haxe
screenshotplugin.ScreenShotPlugin.screenshotKey = FlxKey.Q;
```
