while (current_time - tick_speed >= start_tick_time){
    start_tick_time += tick_speed;
    signaler.signal("tick", tick_count);
}