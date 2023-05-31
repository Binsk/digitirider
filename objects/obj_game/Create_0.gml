/// ABOUT
/// Controls gameplay elements such as item spawning, death detection, 
/// and updating difficulty as the game progresses.

/// SIGNALS
/// tick (tick_count)     -   thrown every time the tick time is reset

#region PROPERTIES
tick_speed = 200;  // How long it takes for one pipe-shift
tick_count = 0;     // Number of ticks that have occurred
start_tick_time = current_time;
tick_speed_pipe = 5000;
start_tick_time_pipe = current_time;
signaler = new Signaler();
camera_rotation = 0; // Around the ring or across the plane; 0 = center
pipe_states = [ new PipeMorph(pi / 2, pi / 2),
                new PipeMorph(-pi / 2, pi / 2),
                new PipeMorph(-pi / 2, -pi / 2),
                new PipeMorph(pi / 2, -pi / 2, 0.0),
                new PipeMorph(0, 0, 0.0),
                new PipeMorph(0, pi * 0.1, 0.0),
                new PipeMorph(0, -pi * 0.1, 0.0),
                new PipeMorph(0, pi * 0.1, 0.0),
                new PipeMorph(-pi / 3, -pi / 3, 0.0)];
#endregion

pipe_states = [ new PipeMorph(+pi / 2, 0, 0),
                new PipeMorph(-pi / 2, 0, 0)];

#region INIT
if (instance_number(obj_game) > 1){
    throw "More than one instance of obj_game!";
    instance_destroy();
    return;
}
#endregion

#region METHODS
function update_camera(){
    static indx = 0;
    
    if (keyboard_check_pressed(vk_up))
        indx ++;
    else if (keyboard_check_pressed(vk_down))
        indx --;

    var pipe_lerp = (current_time - start_tick_time_pipe) / tick_speed_pipe;
    var theta = lerp(pipe_states[0].theta, pipe_states[1].theta, pipe_lerp);
    var phi = lerp(pipe_states[0].phi, pipe_states[1].phi, pipe_lerp);
    var unroll = lerp(pipe_states[0].unroll, pipe_states[1].unroll, pipe_lerp);
    var position_from_plane = pipe_states[0].calculate_position_on_plane(indx, camera_rotation, theta, phi, {y:24});
    var position_to_plane = pipe_states[0].calculate_position_on_plane(indx + 1, camera_rotation, theta, phi, {y:24});
    
    var position_from_ring = pipe_states[0].calculate_position_on_ring(indx, camera_rotation, theta, phi, PipeMorph.RADIUS, {y:24});
    var position_to_ring = pipe_states[0].calculate_position_on_ring(indx + 1, camera_rotation, theta, phi, PipeMorph.RADIUS, {y:24});

    var position_from = {
        x : lerp(position_from_plane.x, position_from_ring.x, unroll),
        y : lerp(position_from_plane.y, position_from_ring.y, unroll),
        z : lerp(position_from_plane.z, position_from_ring.z, unroll)
    };
    
    var position_to = {
        x : lerp(position_to_plane.x, position_to_ring.x, unroll),
        y : lerp(position_to_plane.y, position_to_ring.y, unroll),
        z : lerp(position_to_plane.z, position_to_ring.z, unroll)
    };

    obj_renderer.mat_view = matrix_build_lookat(position_from.x, position_from.y, position_from.z,
                                                position_to.x, position_to.y, position_to.z, 
                                                0, 1, 0);
}
#endregion

#region INIT
/// @stub test controls, replace with proper smooth accel
obj_input.signaler.add_signal("game.ship.cw", function(){
    var dt = delta_time / 1000000;
    camera_rotation = clamp(camera_rotation + pi / 2 * dt, -pi, pi);
});
obj_input.signaler.add_signal("game.ship.ccw", function(){
    var dt = delta_time / 1000000;
    camera_rotation = clamp(camera_rotation - pi / 2 * dt, -pi, pi);
});
#endregion