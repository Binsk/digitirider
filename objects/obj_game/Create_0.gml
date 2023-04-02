/// ABOUT
/// Controls gameplay elements such as item spawning, death detection, 
/// and updating difficulty as the game progresses.

/// SIGNALS
/// tick (tick_count)     -   thrown every time the tick time is reset

#region PROPERTIES
tick_speed = 250;  // How long it takes for one pipe-shift
tick_count = 0;     // Number of ticks that have occurred
start_tick_time = current_time;
signaler = new Signaler();
#endregion

#region INIT
if (instance_number(obj_game) > 1){
    throw "More than one instance of obj_game!";
    instance_destroy();
    return;
}
#endregion