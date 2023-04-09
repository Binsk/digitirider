/// ABOUT
/// This object represents a basic renderable 3D object.

enum RENDERABLE_TYPE{
    none,           // Don't render (done for special handling of some renderables)
    opaque,         // Fully opaque or fully transparent elements only; renders to depth buffer
    transluscent,   // Transluscent elements of any kind, does NOT render to the depth buffer
    glow            // Will render (similar to transluscent) but then be blurred and clipped w/ the depth buffer; rendered behind transluscent
}

#region PROPERTIES
mat_world = matrix_build_identity();
texture = -1;
vbuffer = -1;
type = RENDERABLE_TYPE.opaque;
#endregion

#region METHODS
function draw(){
    if (vbuffer == -1)
        return;
        
    var mat_world_old = matrix_get(matrix_world);
    matrix_set(matrix_world, mat_world);
    vertex_submit(vbuffer, pr_trianglelist, texture);
    matrix_set(matrix_world, mat_world_old);
}

function add_vertex(x, y, z, color=c_white, alpha=1.0){
    if (alpha < 1.0 and type != RENDERABLE_TYPE.glow)
        type = RENDERABLE_TYPE.opaque;
    
    vertex_position_3d(vbuffer, x, y, z);
    vertex_color(vbuffer, color, alpha)
}

#endregion