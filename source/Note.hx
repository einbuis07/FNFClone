package;

import flixel.FlxSprite;

class Note extends FlxSprite
{
    public var direction:Int;

    public function new(direction:Int, x:Float, y:Float)
    {
        super(x, y);
        this.direction = direction;
        loadGraphic("assets/images/note.png");

        // Rotate note sprite based on direction
        switch(direction)
        {
            case 0: angle = -90; // left
            case 1: angle = 180; // down
            case 2: angle = 0;   // up
            case 3: angle = 90;  // right
        }
    }
}
