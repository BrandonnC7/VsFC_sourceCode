package overworld;

typedef RoomObjectData =
{
    var id:String;
    var type:String;
    var x:Float;
    var y:Float;

    @:optional var image:String;
    @:optional var overPlayer:Bool;

    @:optional var width:Int;
    @:optional var height:Int;

    @:optional var targetRoom:String;
    @:optional var spawnX:Float;
    @:optional var spawnY:Float;

    @:optional var level:String;
    @:optional var difficulty:Int; // Difficulty goes from 1 to 10 (like GD faces thats the idea)

    @:optional var event:String;
}

typedef RoomData =
{
    var id:String;
    var objects:Array<RoomObjectData>;

    @:optional var curWorld:String;
    @:optional var bgMusic:String;
}

class World
{
    public var rooms:Map<String, RoomData>;

    public function new()
    {
        rooms = new Map();
    }

    public function getRoom(id:String):RoomData
    {
        if (rooms.exists(id))
            return rooms.get(id);

        return rooms.iterator().next();
    }
}
