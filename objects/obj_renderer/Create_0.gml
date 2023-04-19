/// ABOUT
/// This object is responsible for rendering gameplay elements in 3D space.
/// The renderer will be extremely simple and generally follow these guidelines:
///
///     -   Render simple depth pass for opaque/transparent elements
///     -   Render opaque/transparent elements, forward, to a surface
///     -   Render transluscent elements to their own surface using depth buffer
///         from the previous pass.
///     -   Merge transluscent surface to opaque and push to screen

#region PROPERTIES
surface_depth = -1;     // Contains our depth-buffer; used when blending glow & transluscent items
surface_glow = -1;      // Contains the render for 'glowy' bits; everything will be blurred
surface_opaque = -1;    // Fully opaque or fully transparent items draw to this layer; this is the layer most used
surface_transluscent = -1;  // Transluscent items will be blended in a special way on this layer
surface_merged = -1;        // The final merging of layers ends up here, "full screen effects" can be applied
surface_depth_transition = -1;    // Used to transition surfaces to work around a WebGL false positive error
mat_view = matrix_build_lookat(PipeMorph.SEGMENT_LENGTH, -PipeMorph.RADIUS * 0.75, 0, PipeMorph.SEGMENT_LENGTH * 2.0, -PipeMorph.RADIUS * 0.75, 0, 0, 1, 0);
mat_projection = matrix_build_projection_perspective_fov(70, 1.0, 0.01, 1536);

// Vertex format color
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_color();
vformat_color = vertex_format_end();

// Vertex format pipe
vertex_format_begin(); // Coords are calculate in the shader
vertex_format_add_normal();
vertex_format_add_texcoord();
vformat_pipe = vertex_format_end();
#endregion

#region METHODS
function apply_matrices(){
    matrix_set(matrix_world, matrix_build_identity());
    matrix_set(matrix_view, mat_view);
    matrix_set(matrix_projection, mat_projection);
}
#endregion

#region INIT
gpu_set_cullmode(cull_noculling);
#endregion