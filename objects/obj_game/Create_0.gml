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
// pipe_states = [ new PipeMorph(pi / 2, pi / 2),
//                 new PipeMorph(-pi / 2, pi / 2),
//                 new PipeMorph(-pi / 2, -pi / 2),
//                 new PipeMorph(pi / 2, -pi / 2)];

pipe_states = [ new PipeMorph(0.0, +pi / 2),
                new PipeMorph(0.0, -pi / 2)];
#endregion

#region INIT
if (instance_number(obj_game) > 1){
    throw "More than one instance of obj_game!";
    instance_destroy();
    return;
}
#endregion

#region METHODS
function update_camera(){
    var ysin = -dcos(camera_rotation) * 48;
    var zsin = -dsin(camera_rotation) * 48;
    obj_renderer.mat_view = matrix_build_lookat(64, ysin, zsin, 96, ysin, zsin, 0, dcos(camera_rotation), dsin(camera_rotation));
}
#endregion

#region INIT
/// @stub test controls, replace with proper smooth accel
obj_input.signaler.add_signal("game.ship.cw", function(){
    var dt = delta_time / 1000000;
   camera_rotation = mod2(camera_rotation + 90 * dt, 360); 
   update_camera();
});
obj_input.signaler.add_signal("game.ship.ccw", function(){
    var dt = delta_time / 1000000;
   camera_rotation = mod2(camera_rotation - 90 * dt, 360); 
   update_camera();
});
#endregion