/// ABOUT
/// This object represents a basic renderable 3D object.

#region PROPERTIES
mat_world = matrix_build_identity();
texture = -1;
vbuffer = -1;
is_opaque = true;   // If false, renders in opaque pass else transluscent pass
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
    if (alpha < 1.0)
        is_opaque = false;
    
    vertex_position_3d(vbuffer, x, y, z);
    vertex_color(vbuffer, color, alpha)
}

#endregion