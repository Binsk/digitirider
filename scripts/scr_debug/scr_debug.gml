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


/// @desc   This is a simple structure solely existing to render debugging 3D
///         shapes.
function Debug3DShapes() constructor{
    static BLOCK = -1;
    static VFORMAT = -1;
    static draw_block = function(x, y, z, xscale=1, yscale=1, zscale=1){
        var matrix_old = matrix_get(matrix_world);
        matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, 0, xscale, yscale, zscale));
        vertex_submit(Debug3DShapes.BLOCK, pr_trianglelist, -1);
        matrix_set(matrix_world, matrix_old);
    }
    static init_format = function(){
        if (Debug3DShapes.VFORMAT != -1)
            return;
        
        vertex_format_begin();
        vertex_format_add_position_3d();
        vertex_format_add_color();
        Debug3DShapes.VFORMAT = vertex_format_end();
    }
    static init_block = function(){
        if (Debug3DShapes.BLOCK != -1)
            return;
        
        function vertex_add(x, y, z){
            vertex_position_3d(Debug3DShapes.BLOCK, x, y, z);
            vertex_color(Debug3DShapes.BLOCK, c_red, 1.0);
        }
        
        Debug3DShapes.BLOCK = vertex_create_buffer();
        vertex_begin(Debug3DShapes.BLOCK, Debug3DShapes.VFORMAT);
        
        var xscale = 0.5;
        var yscale = 0.5;
        var zscale = 0.5;
        
            // Top:
        vertex_add(-xscale, yscale, -zscale);
        vertex_add(xscale, yscale, -zscale);
        vertex_add(-xscale, yscale, zscale);
        
        vertex_add(xscale, yscale, -zscale);
        vertex_add(xscale, yscale, zscale);
        vertex_add(-xscale, yscale, zscale);
        
            // Bottom:
        vertex_add(-xscale, -yscale, zscale);
        vertex_add(xscale, -yscale, zscale);
        vertex_add(-xscale, -yscale, -zscale);
        
        vertex_add(xscale, -yscale, zscale);
        vertex_add(xscale, -yscale, -zscale);
        vertex_add(-xscale, -yscale, -zscale);
        
            // East:
        vertex_add(xscale, yscale, zscale);
        vertex_add(xscale, yscale, -zscale);
        vertex_add(xscale, -yscale, zscale);
        
        vertex_add(xscale, yscale, -zscale);
        vertex_add(xscale, -yscale, -zscale);
        vertex_add(xscale, -yscale, zscale);
        
            // South:
        vertex_add(-xscale, yscale, zscale);
        vertex_add(xscale, yscale, zscale);
        vertex_add(-xscale, -yscale, zscale);
        
        vertex_add(xscale, yscale, zscale);
        vertex_add(xscale, -yscale, zscale);
        vertex_add(-xscale, -yscale, zscale);
        
            // West:
        vertex_add(-xscale, yscale, -zscale);
        vertex_add(-xscale, yscale, zscale);
        vertex_add(-xscale, -yscale, -zscale);
        
        vertex_add(-xscale, yscale, zscale);
        vertex_add(-xscale, -yscale, zscale);
        vertex_add(-xscale, -yscale, -zscale);
        
            // North:
        vertex_add(xscale, yscale, -zscale);
        vertex_add(-xscale, yscale, -zscale);
        vertex_add(xscale, -yscale, -zscale);
        
        vertex_add(-xscale, yscale, -zscale);
        vertex_add(-xscale, -yscale, -zscale);
        vertex_add(xscale, -yscale, -zscale);
        
        vertex_end(Debug3DShapes.BLOCK);
    }
    
    init_format();
    init_block();
}

// Initialize static variables so we can call without a struct later on:
var debug = new Debug3DShapes();
delete debug;