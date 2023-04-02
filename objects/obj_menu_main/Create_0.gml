event_inherited();

start_idx = add_button("Start");
options_idx = add_button("Options");

signaler.add_signal("element.pressed", function(element_id){
    switch (element_id){
        case start_idx:
            instance_create_depth(0, 0, 0, obj_game);
            instance_create_depth(0, 0, 0, obj_pipe);
            instance_destroy();
        break;
    }
});