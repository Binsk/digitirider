while (current_time - tick_speed >= start_tick_time){
    start_tick_time += tick_speed;
    signaler.signal("tick", tick_count);
}

while (current_time - tick_speed_pipe >= start_tick_time_pipe){
    start_tick_time_pipe += tick_speed_pipe;
/// @stub For testing pipe morph
    array_cycle(pipe_states, -1);
}

var pipe_lerp = (current_time - start_tick_time_pipe) / tick_speed_pipe;

obj_pipe.transform_array = pipe_states[0].construct_array_lerp(pipe_states[1], pipe_lerp);