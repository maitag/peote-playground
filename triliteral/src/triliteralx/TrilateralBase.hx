package trilateralx;
import lime.ui.Window;
import lime.graphics.RenderContext;
import lime.graphics.WebGLRenderContext;
//import lime.Assets;
//import lime.utils.AssetType;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;
import lime.math.Matrix4;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLBuffer;

import kitGL.glLime.Shaders;
import kitGL.glLime.HelpGL;
import kitGL.glLime.BufferGL;

import trilateral3.Trilateral;
import trilateral3.drawing.Pen;
import trilateral3.geom.FlatColorTriangles;
import trilateral3.nodule.PenNodule;
import trilateral3.matrix.MatrixDozen;

// Sketching
import trilateral3.drawing.Pen;
import trilateral3.shape.Shaper;
import trilateral3.drawing.TriangleAbstract;
import trilateral3.drawing.Color3Abstract;
import trilateral3.shape.IndexRange;
import trilateral3.shape.Regular;
import trilateral3.Trilateral;
import trilateral3.color.ColorInt;
import trilateral3.structure.ARGB;
// To trace on screen
#if js
import kitGL.glWeb.DivertTrace;
import js.Browser;
#end

import trilateralx.TrilateralSample;

// format style adopted in Nanjizal code feel free to adjust
// This is just 2D example not 2.5D will have to look at that extension another time.
class TrilateralBase {
    var program: GLProgram;
    public var pen: Pen;
    public var divertTrace: DivertTrace;
    public var penNodule = new PenNodule();
    public var buf: GLBuffer;
    public var scale: Float;
    public var min: Float;
    public var currentTriangle: TriangleAbstract;
    public var currentColor:    Color3Abstract; // can only use with interleave.
    public var window: Window;
    public var regular: Regular;
    public var first = true;
    //public var drawFirst:Void -> Void;
    //public var drawRender: Void -> Void;
    // public var isDynamic: Bool = true;
    public function new( window_: Window ){
        #if js
        divertTrace = new DivertTrace();
        #end
        window = window_;
        // for clarity going to build sample here to keep setup code seperate from use code.
        var sample = new TrilateralSample( this );
        // call setup in sample.
    }
    
    public function setup( drawFirst: Void->Void ){
         // PenNodule hard coded at 1000x1000 for convience so adjust
        //adjustTransform( 500, 500 );//window.width, window.height );  <- BROKEN?
        var gl = window.context.webgl;
        // this uses kitGL to setup some interleave shaders you can used different ones
        // but PenNodule is setup as a helper to just use these as quick start.
        program = programSetup( gl, vertexString0, fragmentString0 );
        // this is called by our example program, you might setup the basic scene 
        pen             = penNodule.pen;
        currentTriangle = pen.triangleCurrent;
        currentColor    = pen.color3Current;
        regular         = new Regular( pen );
        
        drawFirst();
        // creates the buffer stuff
        buf   = interleaveXYZ_RGBA( gl
                                   , program
                                   , cast penNodule.data
                                   , 'vertexPosition', 'vertexColor' );
        // These are like pointers to the current selected triangles

        first           = false; // allow render now
    }
    // ------------------------------------------------------------
    // ---------------------  EVENTS ------------------------------
    // ------------------------------------------------------------	
    
    public function update( deltaTime: Int ):Void{
        //if( count++ % 100 == 0 ) trace( 'size' + penNodule.size );
    }
    var count = 0;
    @:access( kitGL.glWeb.DivertTrace )
    public function render( context: RenderContext ): Void {

        if( first ) return;
        var gl = context.webgl;
        drawRender();
        
        // this assumes dynamic... for non change data you could handle windows resize
        // with a uniform projection but for now this is heavier but more flexible
        // if( isDynamic ){
        gl.bindBuffer( gl.ARRAY_BUFFER, buf );
        gl.bufferSubData( gl.ARRAY_BUFFER, 0, cast penNodule.data );
        // }
        gl.useProgram( program );
        gl.drawArrays( gl.TRIANGLES, 0, penNodule.size );
    }
    public var drawRender: Void -> Void;

    public function onWindowResize ( width: Int, height: Int ): Void {
        adjustTransform( width, height );
    }
    public inline
    function adjustTransform( width: Int, height: Int ){
    // for the moment I will be lazy..
        // for more complex probably use geom library
        // this is just rough quick
        min = Math.min( width, height );
        scale = 1/min;
        var transformMin: MatrixDozen = { a : scale, b : 0, c : 0, d : -1
                                         , e : 0,  f : -scale, g : 0, h : 1
                                         , i : 0, j : 0,k : scale, l : 0 };
        Trilateral.transformMatrix = transformMin;
    }
    // may need optimizing
    public function clearPen(){
        penNodule = new PenNodule();
        pen = penNodule.pen;
        adjustTransform( window.width, window.height );
        currentTriangle = pen.triangleCurrent;
        currentColor    = pen.color3Current;
        regular = new Regular( pen );
    }
    
    // some convinent helpers kind of hard coded, they are used with the current triangle
    // set the pen.pos first to access the triangle/s you require
    // if this was improved ( generalized ) might add to trilateral3 directly
    public function rotateCentre( vx: Float, vy: Float, v: Float ){
        currentTriangle.rotate( (vx-min)/min, -(vy-min)/min, v );
    }
    public var triX( get, set ): Float;
    function get_triX(): Float {
        return currentTriangle.x*min+min;
    }
    function set_triX( v: Float ): Float {
        v = (v-min)/min;
        currentTriangle.x = v;
        return v;
    }
    public var triY( get, set ): Float;
    inline
    function get_triY(): Float {
        return -(currentTriangle.y*min-min);
    }
    inline
    function set_triY( v: Float ): Float {
        v = -(v-min)/min;
        currentTriangle.y = v;
        return v;
    }
    public var argb( never, set ): Int;
    inline
    function set_argb( v: Int ): Int {
        currentColor.argb = v;
        return v;
    }
    public inline
    function blendRGB( c0: Int, c1: Int, t: Float ): Int {
        // seperate colors
        var colA: ColorInt = c0;
        var r0 = colA.red;
        var g0 = colA.green;
        var b0 = colA.blue;
        var colB: ColorInt = c1;
        var r1 = colB.red;
        var g1 = colB.green;
        var b1 = colB.blue;
        // blend each channel colors
        var v = smootherStep( t );
        var r2 = blend( r0, r1, v );
        var g2 = blend( g0, g1, v );
        var b2 = blend( b0, b1, v );
        // put together
        var argb: ARGB = { a: 1., r: r2, g: g2, b: b2 };
        var colInt: ColorInt = argb;
        var c: Int = colInt;
        return c;
    }
    inline
    function blend( a: Float, b: Float, t: Float ): Float {
        return a + t * ( b - a );
    }
    // Ken Perlin smoothStep 
    inline 
    function smootherStep( t: Float ): Float {
      return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
    }
}
