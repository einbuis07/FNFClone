package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import sys.io.File;
import haxe.Json;
import Std;
import Reflect;

typedef NoteData = {
    var direction:Int;
    var time:Float; // seconds since song start
}

class PlayState extends FlxState
{
    var notes:FlxGroup;
    var noteRow:FlxGroup;
    var noteSpeed:Float = 200; // pixels/sec
    var hitZoneY:Float = 100; // near top (notes come from bottom)

    var chartNotes:Array<NoteData> = [];
    var elapsedTime:Float = 0;

    var songName:String = "tutorial"; // Change to your song

    override public function create():Void
    {
        super.create();

        notes = new FlxGroup();
        noteRow = new FlxGroup();

        // Draw hit zone row using Note sprites (arrow images)
        // Draw hit zone row using Note sprites (arrow images)
        for (i in 0...4)
        {
        var laneNote = new Note(i, 100 + i * 60, hitZoneY);
        laneNote.alpha = 1.0; // use property, not method
        noteRow.add(laneNote);
        }



        add(notes);
        add(noteRow);

        loadChartFromFile(songName);
    }

    // Add this function inside PlayState class
    public function restartChart():Void
    {
        elapsedTime = 0;
        loadChartFromFile(songName);
        trace("Chart restarted.");
    }


    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        elapsedTime += elapsed;

        // Remove missed notes (past the hit zone going upward)
        while(chartNotes.length > 0) {
            var firstNote = chartNotes[0];
            var noteY = getNoteY(firstNote.time);
            if(noteY < hitZoneY - 50) {
                chartNotes.shift();
                trace("Missed note direction: " + firstNote.direction);
            } else {
                break;
            }
        }

        // Clear all old note sprites
        notes.clear();

        // Spawn visible notes
        for(noteData in chartNotes)
        {
            var xPos = 100 + noteData.direction * 60;
            var yPos = getNoteY(noteData.time);

            if (yPos >= -50 && yPos <= 640 + 50) // inside game height
            {
                var n = new Note(noteData.direction, xPos, yPos);
                notes.add(n);
            }
        }

        // Key checks
        if(FlxG.keys.justPressed.A) tryHitNote(0);
        if(FlxG.keys.justPressed.S) tryHitNote(1);
        if(FlxG.keys.justPressed.W) tryHitNote(2);
        if(FlxG.keys.justPressed.D) tryHitNote(3);
        if(FlxG.keys.justPressed.R) restartChart();
    }

    function getNoteY(noteTime:Float):Float
    {
        // Notes start at bottom and move UP to the hit zone
        var startY = 640 + 50; // spawn just off bottom
        return startY - (elapsedTime - noteTime) * noteSpeed;
    }

    function tryHitNote(direction:Int):Void
    {
        var closestNoteIndex = -1;
        var closestDistance:Float = 9999;

        for(i in 0...chartNotes.length)
        {
            var noteData = chartNotes[i];
            if(noteData.direction == direction)
            {
                var yPos = getNoteY(noteData.time);
                var dist = Math.abs(yPos - hitZoneY);
                if(dist < 30 && dist < closestDistance)
                {
                    closestDistance = dist;
                    closestNoteIndex = i;
                }
            }
        }

        if(closestNoteIndex != -1)
        {
            chartNotes.splice(closestNoteIndex, 1);
            trace("Hit note direction: " + direction);
        }
    }

    function loadChartFromFile(song:String):Void
    {
        var path = "assets/data/" + song + "/chart.json";

        try
        {
            var raw = File.getContent(path);
            trace("Raw JSON content: " + raw);

            var parsed:Dynamic = Json.parse(raw);
            var dataArray:Array<Dynamic> = cast parsed;

            chartNotes = [];

            for (noteObj in dataArray)
            {
                if (Reflect.hasField(noteObj, 'direction') && Reflect.hasField(noteObj, 'time'))
                {
                    var dir:Int = Std.int(Reflect.field(noteObj, 'direction'));
                    var t:Float = Std.parseFloat(Std.string(Reflect.field(noteObj, 'time')));
                    chartNotes.push({ direction: dir, time: t });
                }
            }

            trace("Chart loaded: " + chartNotes.length + " notes.");
        }
        catch(e:Dynamic)
        {
            trace("Failed to load chart: " + e);
            chartNotes = [];
        }
    }
}
