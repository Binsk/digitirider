/// ABOUT
/// Handles joystick-based controls in a smooth manner. The controller both
/// records button states for direct monitoring and manages a signaler for
/// passive controls.
///
/// This system is going to replace the joystick_controls system for two main
/// reasons:
///     1.  That system is heavy in that it processes EVERYTHING every time even
///         a single instance needs to chehck controls
///     2.  The system doesn't have a solid structure so adding / removing support
///         for various elements is difficult.

/// SIGNALS
/// [control_state_id] (value)              -   dot-connected state of the current control
///                                             e.g., "shoulder.left.trigger"
///                                             For 'pressed' and 'released' events just add
///                                             the relevant portion to the signal name.
///                                             e.g., "shoulder.left.trigger.pressed"
/// joystick.left.axis (x-value, y-value)   -   x and y values of the left axis
/// joystick.right.axis (x-value, y-value)   -   x and y values of the right axis

/// BUTTON STATES
/// You can directly check any button state by calling CONTROLLER.[button_state_name].
/// Each value, with the exception of axes, is a bitwised integer of values that can
/// be used with the BUTTON_STATE. For example
///
///     Check down:     if (CONTROLLER.face.left.north & BUTTON_STATE.down)
///     Check pressed:  if (CONTROLLER.face.left.north & BUTTON_STATE.pressed)
///     Check released: if (CONTROLLER.face.left.north & BUTTON_STATE.released)

#macro CONTROLLER obj_controller.control_state

#region PROPERTIES
controller_id = -1; // Slot id of our active controller
signaler = new Signaler();
control_state = {}; // Mostly used internally; see `function input_clear()` for layout
deadzone = 0.5;

repeat_label = "";  // For 'held' events, holds the label of the last one (only applies to face.left)
repeat_time = current_time; // Time the button was held
repeat_length = 0.15;    // Time (in seconds) for a repeat to trigger
repeat_flip = 0;    // Used to switch between "release" and "press"
repeat_multiplier = 2;  // Used for first 'repeat' time multiplier (like the delay w/ holding keyboard key)
#endregion

#region METHODS
/// @desc   Scans currently connected controllers and picks the first one as the
///         'active' controller.
/// NOTE:   It is possible to make this significantly more intelligent but I do not
///         think it is necessary in this case.
function scan_controllers(){
    controller_id = -1;
    var slot_count = gamepad_get_device_count();
    for (var i = 0; i < slot_count; ++i){
        if (gamepad_is_connected(i)){
            controller_id = i;
            
            gamepad_set_axis_deadzone(controller_id, deadzone);
            
            break;
        }
    }
}

function update_deadzone(_deadzone){
    if (controller_id >= 0)
        gamepad_set_axis_deadzone(controller_id, _deadzone);
    
    deadzone = _deadzone;
}

function generate_cleared_input(){
    return { // NOTE: While some buttons have pressure sensitivity, we don't need it and don't use it
        face : {
            left : { // D-pad
                north : 0,
                south : 0,
                east : 0,
                west : 0
            },
            right : { // Symbols
                north : 0,
                south : 0,
                east : 0,
                west : 0
            }
        },
        menu : {    // Labels might not be exact, but they should be functionally equivalent
            start : 0,
            select : 0
        },
        shoulder : {
            left : {
                bumper : 0,
                trigger : 0,
            },
            right : {
                bumper : 0,
                trigger : 0,
            }
        },
        joystick : {
            left : {
                axis_x : 0,
                axis_y : 0,
                button : 0,
                simulated : { // Simulated 'button press' based on joystick movement
                	east : 0,
                	south : 0,
                	west : 0,
                	north : 0
                }
            },
            right : {
                axis_x : 0,
                axis_y : 0,
                button : 0,
                simulated : { // Simulated 'button press' based on joystick movement
                	east : 0,
                	south : 0,
                	west : 0,
                	north : 0
                }
            }
        }
    };
}

function input_clear(){
    control_state = generate_cleared_input();
}

/// @desc   Processes the new state and compares it to the old state.
///         The 'key array' is the array of keys to get to the current state
function process_state(new_state, key_array=[]){
    var old_state = control_state;
    for (var i = 0; i < array_length(key_array); ++i)
        old_state = variable_struct_get(old_state, key_array[i]);

    var keys = variable_struct_get_names(old_state);
    for (var i = 0; i < array_length(keys); ++i){
        var old_value = old_state[$ keys[i]];
        var new_value = new_state[$ keys[i]];
        
        // If there is a sub-state, process that itself
        if (is_struct(old_value)){
            var array = array_duplicate_shallow(key_array);
            array_push(array, keys[i]);
            process_state(new_value, array);
            continue;
        }
        
        // Calculate the base signal label. E.g.: "face.left.east"
        var label = glue(".", key_array) + sprintf(".%1", keys[i]);
        // If not a sub-state, compare values and signal as needed
        if (is_int64(old_value)){
                // State change, signal.
                // E.g., "face.left.east.pressed"
            if (old_value != new_value and (old_value & 1 == 0 or new_value & 1 == 0))
                signaler.signal(sprintf("%1.%2", label, new_value & 2 ? "pressed" : "released"));
            
                // If down, signal:
                // E.g., "face.left.east"
            if (new_value)
                signaler.signal(label, true);
        }
        // If not int, it is an axis and we constantly signal
        else
            signaler.signal(label, new_value);
    }
}
#endregion

#region INIT
if (instance_number(obj_controller) > 1){
    instance_destroy();
    return;
}
    
input_clear();  // Done merely to define our initial struct
    
// Add a 'controller update' ticker
with (obj_system)
    signaler.add_signal("tick-second", method(other.id, other.scan_controllers));
#endregion
