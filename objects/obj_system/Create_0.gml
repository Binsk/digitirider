/// ABOUT
/// Controls the overall game system and makes sure things sync together and
/// run smoothly. If the game needs to pause, end, or a anything that would 
/// significantly change the state of the system then it should go through this
/// instance.

signaler = new Signaler();

    // Generic ticker that triggers every second; useful for controller detection
    // and similar non-immediate checks
last_tick_second = current_time;
signaler.signal("tick-second");