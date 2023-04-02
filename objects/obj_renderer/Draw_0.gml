if (not surface_exists(surface_depth))
    surface_depth = surface_create(room_width, room_height, surface_r32float);
if (not surface_exists(surface_opaque))
    surface_opaque = surface_create(room_width, room_height);
if (not surface_exists(surface_transluscent))
    surface_transluscent = surface_create(room_width, room_height);
if (not surface_exists(surface_merged))
    surface_merged = surface_create(room_width, room_height);

draw_set_color(c_white);
draw_set_alpha(1.0);

gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);
// gpu_set_cullmode(cull_counterclockwise);

#region DEPTH PASS
#endregion

#region OPAQUE PASS
surface_set_target(surface_opaque);
draw_clear_alpha(c_black, 0.0);

// mat_view = matrix_build_lookat(-128 * dcos(direction), 128, -128 * -dsin(direction), 0, 0, 0, 0, 1, 0);
// if (not keyboard_check(vk_space))
//     direction++;

apply_matrices();

/// Render pipe separately due to some custom shader handling:
with (obj_pipe)
    draw();

/// Render all color instances:
shader_set(shd_color);
with (par_renderable){
    if (not is_opaque)
        continue;
        
    draw();
}
shader_reset();
/// @STUB Render all textured instances

surface_reset_target();
#endregion

#region TRANSLUSCENT PASS
#endregion

gpu_set_zwriteenable(false);
gpu_set_ztestenable(false);
gpu_set_cullmode(cull_noculling);

#region MERGE PASSES
#endregion

#region RENDER
draw_surface_ext(surface_opaque, room_width, room_height, -1, -1, 0, c_white, 1.0);
#endregion
