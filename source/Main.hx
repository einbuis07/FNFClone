package;

import flixel.FlxGame;
import openfl.display.Sprite;
import PlayState;

class Main extends Sprite
{
    public static final game = {
        width: 840,
        height: 640,
        initialState: PlayState,
        framerate: 60,
        skipSplash: true,
        startFullscreen: false
    };

    public function new()
    {
        super();

        // Pass width, height, and initialState from the game config
        var gameInstance = new FlxGame(game.width, game.height, game.initialState);

        // Now add the FlxGame to the display list
        addChild(gameInstance);
    }
}
