if (not surface_exists(surface_glow))
    surface_glow = surface_create(room_width, room_height);
if (not surface_exists(surface_depth))
    surface_depth = surface_create(room_width, room_height, surface_r32float);
if (not surface_exists(surface_depth_transition)){
    surface_depth_disable(true);
    surface_depth_transition = surface_create(room_width, room_height, surface_r32float);
    surface_depth_disable(false);
}
if (not surface_exists(surface_opaque))
    surface_opaque = surface_create(room_width, room_height);
if (not surface_exists(surface_transluscent))
    surface_transluscent = surface_create(room_width, room_height);
if (not surface_exists(surface_merged)){
    surface_depth_disable(true);
    surface_merged = surface_create(room_width, room_height);
    surface_depth_disable(false);
}

draw_set_color(c_white);
draw_set_alpha(1.0);

gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);

#region GLOW PASS
#endregion

#region DEPTH PASS
/// @note   We do a separate depth-pass because of the shader version GameMaker
///         uses for web; we can't use MRTs. Not a huge issue since our scene is
///         extremely simple.
surface_set_target(surface_depth);
draw_clear(c_white);
apply_matrices();
shader_set(shd_depth);
with (par_renderable){
    if (type != RENDERABLE_TYPE.opaque)
        continue;
    
    draw();
}
shader_reset();

with (obj_pipe) // Uses a custom shader; it can handle depth writing automatically
    draw(pr_linelist, 0);

surface_reset_target();
#endregion

#region OPAQUE PASS
surface_set_target(surface_opaque);
draw_clear_alpha(c_black, 0.0);
apply_matrices();

/// Render all color instances:
shader_set(shd_color);
with (par_renderable){
    if (type != RENDERABLE_TYPE.opaque)
        continue;
        
    draw();
}
shader_reset();

/// @note Again, handles its own rendering shader due to the vertex morphing
with (obj_pipe)
    draw(pr_linelist, 1);

surface_reset_target();
#endregion

/// @note   Due to us rendering to surface_depth, webgl will throw an error
///         if we try attaching it as an extra sampler. To get around this we
///         copy it to a separate surface and use that instead.
surface_copy(surface_depth_transition, 0, 0, surface_depth);

#region TRANSLUSCENT PASS
surface_set_target(surface_transluscent);
draw_clear_alpha(c_black, 0);
apply_matrices();
// Blend as such to so any overlapping pieces completely replace what is behind them.
// This removes the depth-sorting issue with transluscent-to-transluscent instances while
// merging w/ the depth buffer allows blending with opaque instances correctly regardless
// if depth.
gpu_set_blendmode_ext(bm_one, bm_zero);

/// @stub Add generic transluscent rendering

with (obj_pipe)
    draw(pr_trianglelist, 2, surface_get_texture(other.surface_depth_transition));
    
gpu_set_blendmode(bm_normal);
surface_reset_target();
#endregion

gpu_set_zwriteenable(false);
gpu_set_ztestenable(false);

#region MERGE PASSES
surface_set_target(surface_merged);
draw_clear_alpha(c_black, 0);
draw_surface(surface_opaque, 0, 0);
draw_surface(surface_transluscent, 0, 0);
surface_reset_target();
#endregion

#region RENDER
gpu_set_blendmode_ext(bm_one, bm_zero); // Prevents double-blending alpha
draw_surface_ext(surface_merged, room_width, room_height, -1, -1, 0, c_white, 1.0);
gpu_set_blendmode(bm_normal);
#endregion
