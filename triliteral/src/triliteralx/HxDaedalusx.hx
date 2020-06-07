package trilateralx;
import hxDaedalus.factories.RectMesh;
import hxDaedalus.ai.PathFinder;
import hxDaedalus.ai.trajectory.LinearPathSampler;
import hxDaedalus.data.Object;
import hxDaedalus.ai.EntityAI;

@:structInit
class HxDaedalusStruct {
    public var mesh:            RectMesh;
    public var moveContainer:   Object;
    public var objects:         Array<Object>;
    public var path:            Array<Float>;
    public var entity:          EntityAI;
    public var pathSampler:     LinearPathSampler;
    public var pathfinder:      PathFinder;
    public var newPath:         Bool;
    public var x:               Float;
    public var y:               Float;
    function new( mesh:         RectMesh
                , moveContainer:MoveContainer
                , objects:      Objects
                , path:         Array<Float>
                , entity:       EntityAI
                , pathSampler:  PathSampler
                , pathFinder:   PathFinder
                , newPath:      Bool;
                , x:            Float
                , y:            Float ){
        this.mesh          = mesh; 
        this.moveContainer = moveContainer;
        this.objects       = objects;
        this.path          = path;
        this.entity        = entity;
        this.pathSampler   = pathSampler;
        this.pathFinder    = pathFinder;
        this.newPath       = newPath;
        this.x             = x;
        this.y             = y;
    }
}

abstract HxDaedalusx( HxDaedalusStruct ) from HxDaedalusStruct to HxDaedalusStruct {
    public inline function new ( ?hd: HxDaedalusStruct ){
        if( hd != null ) {
            this = hd;
        } else {
            this = generate();
        }
    } 
    public static inline 
    function generate(): HxDaedalusx {
        var mesh            = RectMesh.buildRectangle( min,  min );
        var moveContainer   = new Object();
        var objects         = new Array<Objects>();
        var path            = new Array<Float>();
        var entity          = new EntityAI();
        var pathSampler     = new PathSampler();
        var pathFinder      = new PathFinder();
        return {
              mesh:         mesh
            , moveContainer:moveContainer;
            , objects:      objects
            , path:         path
            , entity:       entity
            , pathSampler:  pathSampler
            , pathFinder:   pathFinder
            , newPath:      false
            , x:            0
            , y:            0
        };
    }
}