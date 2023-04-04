/// ABOUT
/// This instance handles all input signals. It will connect to the controller
/// and also connect to the keyboard and merge them into single generic 'action'
/// signals. So instead of having a controller signal of "face.left.up" the signal
/// thrown may be 'menu.up'

#region METHODS
function generate_cleared_input(){
    return {
        menu : {
            up : 0,
            down : 0,
            select : 0
        },
        game : {
            ship : {
                cw : 0, // When flat, this is 'left'
                ccw : 0
            }
        }
    };
}
#endregion

#region INIT
signaler = new Signaler();
input_struct = generate_cleared_input();

// Connect controller input to the generic input:
with (obj_controller){
    signaler.add_signal("face.left.north.pressed", method(other.id, function(){input_struct.menu.up |= 2}));
    signaler.add_signal("face.left.south.pressed", method(other.id, function(){input_struct.menu.down |= 2}));
    signaler.add_signal("face.right.south.pressed", method(other.id, function(){input_struct.menu.select |= 2}));
}

#endregion