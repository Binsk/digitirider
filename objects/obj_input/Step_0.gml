
input_struct.menu.up |= (keyboard_check(vk_up) + keyboard_check_pressed(vk_up) * 2 + keyboard_check_released(vk_up) * 4);
input_struct.menu.down |= (keyboard_check(vk_down) + keyboard_check_pressed(vk_down) * 2 + keyboard_check_released(vk_down) * 4);
input_struct.menu.select |= (keyboard_check(vk_enter) + keyboard_check_pressed(vk_enter) * 2 + keyboard_check_released(vk_enter) * 4);
input_struct.game.ship.cw |= (keyboard_check(vk_left) + keyboard_check_pressed(vk_left) * 2 + keyboard_check_released(vk_left) * 4) 
input_struct.game.ship.ccw |= (keyboard_check(vk_right) + keyboard_check_pressed(vk_right) * 2 + keyboard_check_released(vk_right) * 4) 

/// NOTE: Would be best to loop through the structs similar to how the controller
///       does it. At this moment in time, I am lazy and just want something basic
///       up and going.
if (input_struct.menu.up > 0) signaler.signal("menu.up", input_struct.menu.up);
if (input_struct.menu.down > 0) signaler.signal("menu.down", input_struct.menu.down);
if (input_struct.menu.select > 0) signaler.signal("menu.select", input_struct.menu.select);
if (input_struct.game.ship.cw > 0) signaler.signal("game.ship.cw", input_struct.game.ship.cw);
if (input_struct.game.ship.ccw > 0) signaler.signal("game.ship.ccw", input_struct.game.ship.ccw);

input_struct  = generate_cleared_input();