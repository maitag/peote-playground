import bpy
from string import Template

# helper to trace output into python-console window
def trace(data):
    for window in bpy.context.window_manager.windows:
        screen = window.screen
        for area in screen.areas:
            if area.type == 'CONSOLE':
                override = {'window': window, 'screen': screen, 'area': area}
                bpy.ops.console.scrollback_append(override, text=str(data), type="OUTPUT")


# precision of floats output
def mid(num): return round(num, 5)

# msdf format for bezier points and control-points per segment
point_tmpl = Template('$aX,$aY; ($bX,$bY; $cX,$cY); ')
def makePoint(points, i):
    co = points[i].co
    left = points[i].handle_left
    right = points[(i+1) % len(points)].handle_right
    return point_tmpl.substitute (
        aX=mid(co.x),
        aY=mid(co.y),
        bX=mid(left.x),
        bY=mid(left.y),
        cX=mid(right.x),
        cY=mid(right.y)
    )

# msdf format for one fully curve
curve_tmpl = Template('{ $points # }')
def makeCurve(points):
    return curve_tmpl.substitute( 
        points = ''.join([
            makePoint(spline.bezier_points, i)
                for i in range(len(points))
        ])
    )
    
##################################################


myCurve = bpy.data.curves[0] # first curve
spline= myCurve.splines[0] # first spline into

trace( makeCurve(spline.bezier_points) )