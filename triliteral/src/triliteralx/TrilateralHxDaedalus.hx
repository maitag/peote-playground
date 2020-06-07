package trilateralx;
// Lets have some fun... oops I might just try some hxDaedalus..
import hxDaedalus.ai.EntityAI;
import hxDaedalus.ai.PathFinder;
import hxDaedalus.ai.trajectory.LinearPathSampler;
import hxDaedalus.data.math.RandGenerator;
import hxDaedalus.data.Mesh;
import hxDaedalus.data.Object;
import hxDaedalus.ai.EntityAI;
import hxDaedalus.ai.PathFinder;
import hxDaedalus.factories.RectMesh;
import hxDaedalus.data.math.Point2D;
import hxDaedalus.data.Edge;
import hxDaedalus.data.Face;

import trilateralx.HxDaedalus;

// Color pallettes
import pallette.QuickARGB;

// SVG path parser
import justPath.*;
import justPath.transform.ScaleContext;
import justPath.transform.ScaleTranslateContext;
import justPath.transform.TranslationContext;
// Sketching
import trilateral3.drawing.StyleEndLine;
import trilateral3.drawing.Sketch;
import trilateral3.drawing.StyleSketch;
import trilateral3.drawing.Fill;
import trilateral3.drawing.Pen;

abstract TrilateralHxDaedalus( TrilateralBase ){
    public static var hxDaedalusx: HxDaedadalusx;
    public static var alpha = 0.;
    inline public
    function new( trilateralBase: TrilateralBase ){
        this = trilateralBase;
        setup(); // CORE Required
        buildDaedalus();
    }
    
    function buildDaedalus(){
        hxDaedalusx = new HxDaedalusx();
        var mesh         = hxDaedalusx.mesh;
        var moveContainer= hxDaedalusx.moveContainer;
        var path         = hxDaedalusx.path;
        var objects      = hxDaedalusx.objects;
        var entity       = hxDaedalusx.entity;
        var pathSampler  = hxDaedalusx.pathSampler;
        var pathFinder   = hxDaedalusx.pathFinder;
        /*
        var randGen : RandGenerator;
        randGen = new RandGenerator();
        randGen.seed = 7259;  // put a 4 digits number here
        // populate mesh with many square objects
        
        var object: Object;
        var shapeCoords : Array<Float>;
        for (i in 0...50){
            object = new Object();
            shapeCoords = new Array<Float>();
            shapeCoords = [ -1, -1, 1, -1,
                             1, -1, 1, 1,
                            1, 1, -1, 1,
                            -1, 1, -1, -1];
            object.coordinates = shapeCoords;
            randGen.rangeMin = 10;
            randGen.rangeMax = 40;
            object.scaleX = randGen.next();
            object.scaleY = randGen.next();
            randGen.rangeMin = 0;
            randGen.rangeMax = 1000;
            object.rotation = (randGen.next() / 1000) * Math.PI / 2;
            randGen.rangeMin = 50;
            randGen.rangeMax = 550;
            object.x = randGen.next();
            object.y = randGen.next();
            objects.push( object );
            mesh.insertObject(object);
        }
        */
        moveContainer.multiPoints = [shape,shape2];
        moveContainer.scaleX = .5;
        moveContainer.scaleY = .5;
        objects.push( moveContainer );
        var object2 = new Object();
        object2.multiPoints = [shape1,shape2];
        object2.scaleX = .5;
        object2.scaleY = .5;
        objects.push( object2 );
        mesh.insertObject(object2);
        var object3 = new Object();
        object3.multiPoints = [shape1,shape2];
        object3.scaleX = .5;
        object3.scaleY = .5;
        object3.x = 300;
        object3.y = 300;
        objects.push( object3 );
        mesh.insertObject(object3);
        mesh.insertObject(moveContainer);
        entity.radius = 4;
        entity.x = 20;
        entity.y = 20;
        pathfinder.entity            = _entity;  // set the entity
        pathfinder.mesh              = mesh;
        pathSampler.entity           = entity;
        pathSampler.samplingDistance = 10;
        pathSampler.path             = path;
    }
    
    inline
    function clear(){
        clearPen();
    }
    
    inline
    function drawEntity(){
        regular.addRegular({ x: entity.x, y: entity.y, radius: 5, color: 0xFF00FF00 }, CIRCLE );
    }
    
    inline
    function drawPath(){
        var sketch = new Sketch( pen, StyleSketch.Fine, StyleEndLine.both );
        sketch.width = 2;
        pen.currentColor = Red;
        sketch.plotCoord( hxDaedalusx.path );
    }
    
    // CORE FUNCTION
    override
    public function update( deltaTime: Int ):Void{
        
    }
    
    // CORE FUNCTION
    override
    public function drawFirst(){
        trace( 'Peote and Trilateral3 Mashup' );
    }
    
    // CORE FUNCTION
    override
    public function drawRender(){
        var mesh         = hxDaedalusx.mesh;
        var moveContainer= hxDaedalusx.moveContainer;
        var path         = hxDaedalusx.path;
        var objects      = hxDaedalusx.objects;
        var entity       = hxDaedalusx.entity;
        var pathSampler  = hxDaedalusx.pathSampler;
        var pathFinder   = hxDaedalusx.pathFinder;
        
        clear();
        object.x = 200 + 100 * Math.sin( alpha );
        alpha += 0.08;
        object.y = 200 + 100 * Math.cos( alpha );
        mesh.updateObjects();  // don't forget to update
        pathfinder.mesh = mesh;  // set the mesh
        
        // show result mesh on screen
        drawMesh();
        if( hxDaedalusx.newPath ){
            // find path !
            pathfinder.findPath( hxDaedalusx.x, hxDaedalusx.y, path );
            
            // show path on screen
            drawPath();
             // show entity position on screen
            drawEntity(); 
            // reset the path sampler to manage new generated path
            pathSampler.reset();
        }
        // animate !
        if ( pathSampler.hasNext ) {
            // move entity
            pathSampler.next();
        }
        // show entity position on screen
        drawEntity();
    }
    
    inline
    function drawMesh(){
        var mesh         = hxDaedalusx.mesh;
        var all = mesh.getVerticesAndEdges();
        var p0: Point2D;
        var p1: Point2D;
        var constrainPath = = new Sketch( pen, StyleSketch.Fine, StyleEndLine.both );
        constrainPath.width = 0.5;
        var edgePath = = new Sketch( pen, StyleSketch.Fine, StyleEndLine.both );
        edgePath.width = 0.5;
        for (e in all.edges) {   
            p0 = e.originVertex.pos;
            p1 = e.destinationVertex.pos;
            if( e.isConstrained ){
                pen.currentColor = LightGrey;
                constrainPath.moveTo( p0.x, p0.y );
                constrainPath.lineTo( p1.x, p1.y );
            } else {
                pen.currentColor = MidGrey;
                edgePath.moveTo( p0.x, p0.y );
                edgePath.lineTo( p1.x, p1.y );
            }
        }
        for( o in _objects ) extractObjectTrilateralArray( o, pen );
        for (v in all.vertices) {
            // Add pallette
            regular.addRegular({ x: v.pos.x, y: v.pos.y, radius: 2, color: Orange }, CIRCLE );
        }
    }
    
    public inline
    function mouseDown( x_: Float, y_: Float ){
        hxDaedalus.x = x_;
        hxDaedalus.y = y_;
        hxDaedalus.newPath = true;
    }
    public inline
    function mouseUp( x_: Float, y_: Float ){
        hxDaedalus.x = x_;
        hxDaedalus.y = y_;
        hxDaedalus.newPath = false;
    }
    public inline
    function mouseMove( x_: Float, y_: Float ){
        if( hxDaedalus.newPath ){
            hxDaedalus.x = x_;
            hxDaedalus.y = y_;
        }
    }
    
    public static var shape0 = [ 93., 195., 129., 92., 280., 81., 402., 134., 477., 70., 619., 61.,759., 97., 758., 247., 662., 347., 665., 230., 721., 140., 607., 117., 472., 171., 580., 178., 603., 257., 605., 377., 690., 404., 787., 328., 786., 480., 617., 510., 611., 439., 544., 400., 529., 291., 509., 218., 400., 358., 489., 402., 425., 479., 268., 464., 341., 338., 393., 427., 373., 284., 429., 197., 301., 150., 296., 245., 252., 384., 118., 360., 190., 272., 244., 165., 81., 259., 40., 216.];
    public static var shape1: Array<Float> = [55,55,145,55,235,100,325,55,415,55,415,145,370,235,415,320,415,410,325,410,235,365,145,410,55,410,55,320,105,235,55,145];
    public static var shape2: Array<Float> = [115,235,235,355,360,235,235,110];
    
    
    static public function extractObjectTrilateralArray( object: Object, pen: Pen ){
        var facesDone = new Map<Face,Bool>();
        var openFacesList = new Array<Face>();
        for( i in 0...object.edges.length ) openFacesList.push( object.edges[ i ].rightFace );
        var currFace:Face;
        while( openFacesList.length > 0 ){
            currFace = openFacesList.pop();
            if( facesDone[ currFace ] ) continue;
            if( currFace.isReal ) {
                var currEdge = currFace.edge;
                var a = currEdge.originVertex.pos;
                var b = currEdge.nextLeftEdge.originVertex.pos;
                var c = currEdge.nextLeftEdge.destinationVertex.pos;
                //var isSolid = ( (a.x * b.y - b.x * a.y) + (b.x * c.y - c.x * b.y) + (c.x * a.y - a.x * c.y) )<0;
                //if( isSolid ) 
                add2DTriangle( pen.drawType, a.x, a.y, 0, b.x, b.y, 0, c.x, c.y, 0 );
                pen.pos--;
                pen.colorTriangles( 0xFFFF0000,3 );
                pen.pos++;
            }
            if( !currFace.edge.isConstrained) openFacesList.push(currFace.edge.rightFace);
            if( !currFace.edge.nextLeftEdge.isConstrained ) openFacesList.push(currFace.edge.nextLeftEdge.rightFace);
            if( !currFace.edge.prevLeftEdge.isConstrained ) openFacesList.push(currFace.edge.prevLeftEdge.rightFace);
            facesDone[ currFace ] = true;
        }
    }
    
}