/// ABOUT
/// This object is responsible for loading any external resources and seting up
/// backend networking system. It is also responsible for displaying the company
/// and game logo before shunting the system into the primary 'game' room where
/// everything else takes place.
print_stub("add logo fetch and highscore init system");
instance_create_depth(0, 0, 0, obj_system);
instance_create_depth(0, 0, 0, obj_controller);
instance_create_depth(0, 0, 0, obj_input);
room_goto(room_game);