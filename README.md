# flixel-screenshot-plugin

## Flixel plugin for nice screenshot management.

## Press F2 to screenshot. All screenshots are saved to the `./screenshots/` folder.

### Some original code from [flixel-addons](http://lib.haxe.org/p/flixel-addons).

# Configuring
Make sure you have `flixel` and `openfl` installed.
Run the command:
```
haxelib install flixel-screenshot-plugin
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