if (current_time - last_tick_second >= 1000){
    signaler.signal("tick-second");
    last_tick_second += 1000;
}