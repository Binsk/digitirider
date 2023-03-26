/// Monitor controls:
if (controller_id < 0) // No controller connected
    return;

#region FETCH CONTROLER STATE
var new_control_state = generate_cleared_input();
    // D-Pad
new_control_state.face.left.north = int64(gamepad_button_check(controller_id, gp_padu) | (gamepad_button_check_pressed(controller_id, gp_padu) * 2) | (gamepad_button_check_released(controller_id, gp_padu) * 4));
new_control_state.face.left.south = int64(gamepad_button_check(controller_id, gp_padd) | (gamepad_button_check_pressed(controller_id, gp_padd) * 2) | (gamepad_button_check_released(controller_id, gp_padd) * 4));
new_control_state.face.left.east = int64(gamepad_button_check(controller_id, gp_padr) | (gamepad_button_check_pressed(controller_id, gp_padr) * 2) | (gamepad_button_check_released(controller_id, gp_padr) * 4));
new_control_state.face.left.west = int64(gamepad_button_check(controller_id, gp_padl) | (gamepad_button_check_pressed(controller_id, gp_padl) * 2) | (gamepad_button_check_released(controller_id, gp_padl) * 4));

    // Symbols
new_control_state.face.right.north = int64(gamepad_button_check(controller_id, gp_face4) | (gamepad_button_check_pressed(controller_id, gp_face4) * 2) | (gamepad_button_check_released(controller_id, gp_face4) * 4));
new_control_state.face.right.south = int64(gamepad_button_check(controller_id, gp_face1) | (gamepad_button_check_pressed(controller_id, gp_face1) * 2) | (gamepad_button_check_released(controller_id, gp_face1) * 4));
new_control_state.face.right.east = int64(gamepad_button_check(controller_id, gp_face2) | (gamepad_button_check_pressed(controller_id, gp_face2) * 2) | (gamepad_button_check_released(controller_id, gp_face2) * 4));
new_control_state.face.right.west = int64(gamepad_button_check(controller_id, gp_face3) | (gamepad_button_check_pressed(controller_id, gp_face3) * 2) | (gamepad_button_check_released(controller_id, gp_face3) * 4));

    // Start / Select
new_control_state.menu.start = int64(gamepad_button_check(controller_id, gp_start) | (gamepad_button_check_pressed(controller_id, gp_start) * 2) | (gamepad_button_check_released(controller_id, gp_start) * 4));
new_control_state.menu.select = int64(gamepad_button_check(controller_id, gp_select) | (gamepad_button_check_pressed(controller_id, gp_select) * 2) | (gamepad_button_check_released(controller_id, gp_select) * 4));

    // Shoulder
new_control_state.shoulder.left.bumper = int64(gamepad_button_check(controller_id, gp_shoulderl) | (gamepad_button_check_pressed(controller_id, gp_shoulderl) * 2) | (gamepad_button_check_released(controller_id, gp_shoulderl) * 4));
new_control_state.shoulder.left.trigger = int64(gamepad_button_check(controller_id, gp_shoulderlb) | (gamepad_button_check_pressed(controller_id, gp_shoulderlb) * 2) | (gamepad_button_check_released(controller_id, gp_shoulderlb) * 4));
new_control_state.shoulder.right.bumper = int64(gamepad_button_check(controller_id, gp_shoulderr) | (gamepad_button_check_pressed(controller_id, gp_shoulderr) * 2) | (gamepad_button_check_released(controller_id, gp_shoulderr) * 4));
new_control_state.shoulder.right.trigger = int64(gamepad_button_check(controller_id, gp_shoulderrb) | (gamepad_button_check_pressed(controller_id, gp_shoulderrb) * 2) | (gamepad_button_check_released(controller_id, gp_shoulderrb) * 4));

    // Joysticks
new_control_state.joystick.left.axis_x = real(gamepad_axis_value(controller_id, gp_axislh));
new_control_state.joystick.left.axis_y = real(gamepad_axis_value(controller_id, gp_axislv));
new_control_state.joystick.left.button = int64(gamepad_button_check(controller_id, gp_stickl) | (gamepad_button_check_pressed(controller_id, gp_stickl) * 2) | (gamepad_button_check_released(controller_id, gp_stickl) * 4));

new_control_state.joystick.right.axis_x = real(gamepad_axis_value(controller_id, gp_axisrh));
new_control_state.joystick.right.axis_y = real(gamepad_axis_value(controller_id, gp_axisrv));
new_control_state.joystick.right.button = int64(gamepad_button_check(controller_id, gp_stickr) | (gamepad_button_check_pressed(controller_id, gp_stickr) * 2) | (gamepad_button_check_released(controller_id, gp_stickr) * 4));

		// Simulated joystick button:
var side = ["left", "right"];
var axis = ["axis_x", "axis_y"];
var dir = ["west", "east", "north", "south"];
var thresh = [-0.25, 0.25, -0.25, 0.25];
for (var i = 0; i < array_length(side); ++i){
	var _side = side[i];
	for (var j = 0; j < array_length(axis); ++j){
		var _axis = axis[j];
		for (var k = 0; k < 2; ++k){
			var _dir = dir[k + 2 * j];
			var _thresh = thresh[k + 2 * j];
			var in_threshold = false;
			if (_thresh < 0)
				in_threshold = (new_control_state.joystick[$ _side][$ _axis] < _thresh);
			else
				in_threshold = (new_control_state.joystick[$ _side][$ _axis] > _thresh);
				
			if (in_threshold)
				new_control_state.joystick[$ _side].simulated[$ _dir] = int64(control_state.joystick[$ _side].simulated[$ _dir] & 3 ? 1 : 2);
			else
				new_control_state.joystick[$ _side].simulated[$ _dir] = int64(control_state.joystick[$ _side].simulated[$ _dir] & 3 ? 4 : 0);
		}
	}
}

#endregion

#region PROCESS face.left REPEAT
if (repeat_label == "" or not in_range(new_control_state.face.left[$ repeat_label], [1, 3])){
    repeat_label = "";
    
    if (in_range(new_control_state.face.left.north, [1, 3]))
        repeat_label = "north";
    else if (in_range(new_control_state.face.left.south, [1, 3]))
        repeat_label = "south";
    else if (in_range(new_control_state.face.left.east, [1, 3]))
        repeat_label = "east";
    else if (in_range(new_control_state.face.left.west, [1, 3]))
        repeat_label = "west";
    
    repeat_flip = 0;
    
    if (repeat_label != "")
        repeat_time = current_time;
    else
        repeat_multiplier = 2.0
}

/// If held long enough, simulate another press:
if (repeat_label != "" and current_time - repeat_time >= repeat_length * 1000 * repeat_multiplier){
    repeat_multiplier = 1.0;
    if (repeat_flip == 0){
        new_control_state.face.left[$ repeat_label] = int64(BUTTON_STATE.released);
        ++repeat_flip;
    }
    else {
        repeat_time = current_time;
        new_control_state.face.left[$ repeat_label] |= BUTTON_STATE.pressed;
        repeat_flip = 0;
    }
}
#endregion

#region PROCESS CONTROLLER STATE CHANGES
process_state(new_control_state);
control_state = new_control_state;

// Special-case for joystick axes in case we need both values at once:
signaler.signal("joystick.left.axis", control_state.joystick.left.axis_x, control_state.joystick.left.axis_y);
signaler.signal("joystick.right.axis", control_state.joystick.right.axis_x, control_state.joystick.right.axis_y);
#endregion