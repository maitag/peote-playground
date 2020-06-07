package trilateralx;

import trilateralx.TrilateralBase;

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
import trilateral3.shape.Shaper;
import trilateral3.shape.IndexRange;
import trilateral3.shape.Regular;
import trilateral3.shape.StyleRegular;

@:forward
abstract TrilateralSample( TrilateralBase ) from TrilateralBase to TrilateralBase {
    
    inline public
    function new( trilateralBase: TrilateralBase ){
        this = trilateralBase;
        this.drawRender = drawRender_;
        this.setup( drawFirst );
    }
    
    public function update( deltaTime: Int ):Void{
        
    }
    
    public function drawFirst(){
        trace( 'Peote and Trilateral3 Mashup' );
        
        var arr = [];
        var min = this.min;
        for( i in 0...50 ){
            arr.push( Math.random()*min );
        }
        drawPath(arr);
        var arr2 = [];
        for( i in 0...50 ){
            arr2.push( { x: Math.random()*min, y: Math.random()*min } );
        }
        drawMesh( arr2 );
    }
    
    public function drawRender_(){
        //trace( 'drawRender' );
        /*
        var min = this.min;
        var totRange: IndexRange = { start: 0, end: 0 };
        for( i in 0...10 ){
            var entity = drawEntity( Math.random()*min, Math.random()*min );
            totRange = totRange + entity;
        }
        var color = Std.int( 4294967295 * Math.random() );
        for( i in totRange.start...totRange.end ){
            this.pen.pos = i;
            this.argb = color;
        }*/
        trace( this.penNodule.size );
    }
    
    inline
    function drawEntity( x: Float, y: Float ): IndexRange {
        return this.regular.addRegular({ x: x, y: y, radius: 5, color: 0xFF00FF00 }, CIRCLE );
    }
    
    inline
    function drawPath( path: Array<Float> ){
        trace( 'drawPath' );
        var sketch = new Sketch( this.pen, StyleSketch.Fine, StyleEndLine.both );
        sketch.width = 2;
        this.pen.currentColor = Red;
        sketch.plotCoord( path );
    }
    
    inline
    function drawMesh( points: Array<{x:Float,y:Float}>){
        var edges = new Sketch( this.pen, StyleSketch.Fine, StyleEndLine.both );
        edges.width = 0.5;
        this.pen.currentColor = LightGrey;
        for( i in 0...(points.length-1) ){
            var p0 = points[i];
            var p1 = points[i+1];
            edges.moveTo( p0.x, p0.y );
            edges.lineTo( p1.x, p1.y );
        }
    }
    
}