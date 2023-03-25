/// ABOUT
/// Some simple debug printing scripts to help display important info while not
/// throwing an actual error. Messages will display the calling instance, event,
/// and latest script it was called from to provide context to the message.

function print_info_message(prefix, message, callstack_offset=2){
    static evtype = [   "ev_create", "ev_destroy", "ev_alarm",
                        "ev_step", "ev_collision", "ev_keyboard",
                        "ev_mouse", "ev_other", "ev_draw", 
                        "ev_keypress", "ev_keyrelease", "unknown",
                        "unkown", "ev_gesture"
        ];
    
    var callstack = debug_get_callstack(callstack_offset);
    if (array_length(callstack) < callstack_offset)
        callstack = ["",""];
    
    var obj_idx = "[unknown object name]";
    try{
        obj_idx = object_get_name(object_index);
    }
    catch(e){}
    
    show_debug_message(string_substitute("{5} :: {0} [{1} : {2}, {3}]: {4}", [message, obj_idx, evtype[event_type], event_number, callstack[callstack_offset - 1], prefix]));
}

function print_stub(message){
    print_info_message("STUB", message, 3);
}

function print_fixme(message){
    print_info_message("FIXME", message, 3);
}