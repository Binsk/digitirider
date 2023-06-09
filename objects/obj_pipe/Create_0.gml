event_inherited();
/// ABOUT  
/// This renders the 'pipe' terrain in the runner. The pipe shape is fully handled
/// via the shader to allow easily bending and mutating its shape without actually
/// having to move anything in the game. The rendering performs as such:
///
///     -   The mesh is a bunch of vertices that only contain property and texture
///         values.
///     -   The vertices for each ring are assigned a ring ID
///     -   A stack of transformation arrays will be passed into the shader
///         to rotate / shift rings to make the map look like it is 'bending'
///     -   There will be a [0..1] lerp timer where each ring will lerp from one
///         array to the other
///     -   Once the timer crosses 1, it will reset to 0, the oldest matrix will
///         be popped off and the new one popped on.
///
///     This combined will give the illusion of movement and a constantly curving
///     tunnel that can go upside-down and turn in any direction while not actually
///     rotation or moving the player in space at all.

#region PROPERTIES
transform_array = array_create(PipeMorph.RING_COUNT * 3, 1.0); // Transformation data between two pipe morphs, formatted for the shader
#endregion

#region METHODS
/// @note   Coordinates are calculated on-the-fly by the shader based on wrap index etc.
function add_vertex(u, v, ring_index, wrap_angle, wrap_direction=1){
    vertex_normal(vbuffer, ring_index, wrap_angle, wrap_direction); // Custom attribute
    vertex_texcoord(vbuffer, u, v);
}

function draw(vrtype=pr_trianglelist, pipe_render_mode=1, depth_texture=undefined){
    if (vbuffer == -1)
        return;

    static u_vTransforms = shader_get_uniform(shd_pipe, "u_vTransforms");
    static u_fLerp = shader_get_uniform(shd_pipe, "u_fLerp");
    static u_fPipeRadius = shader_get_uniform(shd_pipe, "u_fPipeRadius");
    static u_fSegmentLength = shader_get_uniform(shd_pipe, "u_fSegmentLength");
    static u_fSliceCount = shader_get_uniform(shd_pipe, "u_fSliceCount");
    static u_iRenderMode = shader_get_uniform(shd_pipe, "u_iRenderMode");
    static u_sDepthBuffer = shader_get_sampler_index(shd_pipe, "u_sDepthBuffer");

    var mat_world_old = matrix_get(matrix_world);
    matrix_set(matrix_world, mat_world);
    shader_set(shd_pipe);
    shader_set_uniform_f_array(u_vTransforms, transform_array);
    shader_set_uniform_f(u_fLerp, (current_time - obj_game.start_tick_time) / obj_game.tick_speed);
    shader_set_uniform_f(u_fPipeRadius, pipe_render_mode <= 1 ? PipeMorph.RADIUS : PipeMorph.RADIUS + 2);
    shader_set_uniform_f(u_fSegmentLength, PipeMorph.SEGMENT_LENGTH);
    shader_set_uniform_f(u_fSliceCount, PipeMorph.RING_SLICES);
    shader_set_uniform_i(u_iRenderMode, pipe_render_mode);
    if (pipe_render_mode == 2 and not is_undefined(depth_texture))
        texture_set_stage(u_sDepthBuffer, depth_texture);
        
    vertex_submit(vbuffer, vrtype, texture);
    shader_reset();
    matrix_set(matrix_world, mat_world_old);
}
#endregion

#region INIT
vbuffer = vertex_create_buffer();
vertex_begin(vbuffer, obj_renderer.vformat_pipe);
for (var i = 0; i < PipeMorph.RING_COUNT; ++i){ // Ring count
    for (var j = 0; j < PipeMorph.RING_SLICES; ++j){ // Quad count for one half
        for (var k = 0; k <= 1; ++k){ // Quad for each side
            var wrap_direction = (k == 0 ? 1 : -1);
            var wrap_angle = pi / PipeMorph.RING_SLICES * j;
            /// Note: The vertex definition order is purely cosmetic in this case
            ///       to make all the tringle seams point in the same direction:
            if (wrap_direction > 0){
                add_vertex(0, 0, i, wrap_angle, wrap_direction);
                add_vertex(1, 0, i, wrap_angle, wrap_direction);
                add_vertex(0, 1, i, wrap_angle, wrap_direction); 
                
                add_vertex(1, 0, i, wrap_angle, wrap_direction);
                add_vertex(1, 1, i, wrap_angle, wrap_direction);
                add_vertex(0, 1, i, wrap_angle, wrap_direction);
            }
            else{
                add_vertex(0, 0, i, wrap_angle, wrap_direction);
                add_vertex(1, 0, i, wrap_angle, wrap_direction);
                add_vertex(1, 1, i, wrap_angle, wrap_direction); 
                
                add_vertex(0, 0, i, wrap_angle, wrap_direction);
                add_vertex(1, 1, i, wrap_angle, wrap_direction);
                add_vertex(0, 1, i, wrap_angle, wrap_direction);
            }
        }
    }
}
vertex_end(vbuffer);

type = RENDERABLE_TYPE.none;
#endregion
