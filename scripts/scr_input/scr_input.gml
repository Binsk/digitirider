enum BUTTON_STATE {
    down = 1,
    pressed = 2,
    released = 4
}


/// @desc   Checks the gamepad controller info diectly for an input value (or 0
///         if not initialized). This is the SLOWEST method of doing so and you
///         should use signals or the other wrappers below when possible.
/// @param  {string}    label       label of the input to check
/// @param  {int}       state=7     if an int64 value, bit wise OP will be performed and
///                                 a bool will be returned, true if OP > 0
/// @example if (input_check_gamepad("shoulder.left.bumper", BUTTON_STATE.pressed)){...}
function input_check_gamepad(label="", state=7){
    var segments = string_explode(".", label);
    var struct = CONTROLLER;
    for (var i = 0; i < array_length(segments); ++i){
        if (not variable_struct_exists(struct, segments[i]))
            return 0;
        
        struct = struct[$ segments[i]];
    }
    
    if (is_int64(struct))
        return (struct & state) > 0;
        
    return struct;
}