package overworld.worlds;

import overworld.World;

class World1 extends World
{
    public function new()
    {
        super();

        rooms.set("room_1", {
            id: "room_1",
            bgMusic: "overWorld/Naughty_Land",
            objects: [
                {id: "fog", type: "sprite", image: "overWorld/Worlds/world_1/room1_fog", x: -1000, y: -300, overPlayer: false},
                {id: "floor", type: "sprite", image: "overWorld/Worlds/world_1/room1_sprite", x: -350, y: 240, overPlayer: false},
                {id: "edgefog", type: "sprite", image: "overWorld/Worlds/world_1/room1_edgefog", x: -430, y: 100, overPlayer:false},
                {id: "trees", type: "sprite", image: "overWorld/Worlds/world_1/room1_trees", x: 20, y: -210, overPlayer: false},
                {id: "lights", type: "sprite", image: "overWorld/Worlds/world_1/room1_shadows", x: -465, y: -300, overPlayer: false},
                {id: "Tlights", type: "sprite", image: "overWorld/Worlds/world_1/room1_tlights", x: 135, y: -700, overPlayer: true},

                {id: "dedude", type: "level", level: "Blocked", difficulty:1, x: 2500, y: 300, width: 30, height: 10, overPlayer: false},
                
                {id: "toRoom2", type: "door", image: "", x: 1600, y: 320, width: 350, height: 50, overPlayer: false, targetRoom: "room_2", spawnX: -400, spawnY: 200},

                {id: "wall1", type: "hitbox", x: 350, y: 260, width: 750, height: 80}

                /*
                {tag='fog', file='room1_fog', type='sprite', x=-1000, y=-300, isAnimated=false, overPlr=false},
                {tag='floor', file='room1_sprite', type='sprite', x=-350, y=240, isAnimated=false, overPlr=false},
                {tag='edgefog', file='room1_edgefog', type='sprite', x=-430, y=100, isAnimated=false, overPlr=false},
                {tag='trees', file='room1_trees', type='sprite', x=20, y=-210, isAnimated=false, overPlr=false},
                {tag='lights', file='room1_shadows', type='sprite', x=-465, y=-300, isAnimated=false, overPlr=false},
                {tag='Tlights', file='room1_tlights', type='sprite', x=135, y=-700, isAnimated=false, overPlr=true},

                {tag='toRoom2', file='', type='door', x=1600, y=320, w=350, h=50, target='room_2', spawnX=-400, spawnY=200, color='00FF00'},

                {tag='jitbacs1', file='', type='hitbox', x=350, y=260, w=750, h=80, color='FFFFFF', isAnimated=false, overPlr=false},
                {tag='jitbacs2', file='', type='hitbox', x=1050, y=310, w=550, h=70, color='FFFFFF', isAnimated=false, overPlr=false},
                {tag='jitbacs3', file='', type='hitbox', x=-50, y=700, w=2200, h=50, color='FFFFFF', isAnimated=false, overPlr=false},
                {tag='jitbacs4', file='', type='hitbox', x=50, y=260, w=50, h=400, color='FFFFFF', isAnimated=false, overPlr=false},
                {tag='jitbacs5', file='', type='hitbox', x=1980, y=320, w=50, h=360, color='FFFFFF', isAnimated=false, overPlr=false},
                {tag='jitbacs6', file='', type='hitbox', x=140, y=260, w=130, h=150, color='FFFFFF', isAnimated=false, overPlr=false},*/
            ]
        });
    }
}