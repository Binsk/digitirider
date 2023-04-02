/// ABOUT   A very simple menu system that allow a single-column row of items
///         that will center both vertically and horizontally in the menu.
///         Menus by default take up the entire screen, but this can be adjusted
///         through anchors / margins.

/// SIGNALS
/// element.pressed (index)     -   thrown when an element is activated

#region PROPERTIES
element_array = [];
element_padding = 72;   // Space between elements, not accounting for size
element_current = 0;    // Index of currently active element
menu_anchor = new AnchorElement(); // Used to anchor all elements within a screen region
signaler = new Signaler();
#endregion

#region METHODS
function AnchorElement(anchor=undefined, margin=undefined) constructor{
    #region PROPERTIES
    self.anchor = {
        x1 : 0,
        y1 : 0,
        x2 : 1,
        y2 : 1
    }
    
    self.margin = {
        x1 : 0,
        y1 : 0,
        x2 : 0,
        y2 : 0
    }
    
    draw_stack = [];
    
    #endregion
    
    #region METHODS

    function set_anchor(anchor){
        if (not is_struct(anchor))
            return false;
        
        if (not variable_struct_exists(anchor, "x1"))
            return false;
        
        if (not variable_struct_exists(anchor, "y1"))
            return false;
        
        if (not variable_struct_exists(anchor, "x2"))
            return false;
        
        if (not variable_struct_exists(anchor, "y2"))
            return false;
        
        self.anchor = anchor;
        
        return true;
    }

    function set_margin(margin){
        if (not is_struct(margin))
            return false;
        
        if (not variable_struct_exists(margin, "x1"))
            return false;
        
        if (not variable_struct_exists(margin, "y1"))
            return false;
        
        if (not variable_struct_exists(margin, "x2"))
            return false;
        
        if (not variable_struct_exists(margin, "y2"))
            return false;
        
        self.margin = margin;
        
        return true;
    }
    
    function get_position(x_perc=0.5, y_perc=0.5){
        return {
            x : lerp(room_width * anchor.x1 + margin.x1, room_width * anchor.x2 + margin.x2, x_perc),
            y : lerp(room_height * anchor.y1 + margin.y1, room_height * anchor.y2 + margin.y2, y_perc)
        }
    }
    
    function draw(){
        var corner1_pos = get_position(0, 0);
        var corner2_pos = get_position(1, 1);
        
        draw_set_color(color);
        draw_set_alpha(alpha);
        
        draw_rectangle(corner1_pos.x, corner1_pos.y, corner2_pos.x, corner2_pos.y, true);
    }; // ~virtual
    #endregion
    
    #region INIT
    if (not is_undefined(_anchor))
        set_anchor(_anchor);
    
    if (not is_undefined(_margin))
        set_margin(_margin);
    
    array_push(draw_stack, draw);
    #endregion
}

function MenuButton(label="", anchor=undefined, margin=undefined) : AnchorElement(anchor, margin) constructor{
    self.label = string(label);
    color = c_white;
    alpha = 1.0;
    
    function draw(){
        draw_stack[0]();
        var center_pos = get_position();
        draw_set_valign(fa_middle);
        draw_set_halign(fa_center);
        
        draw_text(center_pos.x, center_pos.y, label);
    }
    
    array_push(draw_stack, draw);
}

function MenuCheckbox(label="", is_checked=false, anchor=undefined, margin=undefined) : MenuButton(label, anchor, margin) constructor{
    self.is_checked = is_checked;
    
    function draw(){
        draw_stack[0]();
        draw_set_valign(fa_middle);
        draw_set_halign(fa_left);
        
        var corner1_pos = get_position(0, 0);
        var corner2_pos = get_position(1, 1);
        var center_pos = get_position();
        
        draw_text(corner1_pos.x + 8, center_pos.y, label);
        draw_rectangle(corner2_pos.x - 8, center_pos.y - 12, corner2_pos.x - 31, center_pos.y + 12, true);
        if (is_checked)
            draw_rectangle(corner2_pos.x - 12, center_pos.y - 7, corner2_pos.x - 26, center_pos.y + 8, false);
    }
    
    array_push(draw_stack, draw);
}

/// @desc   Adds a generic element structure (inherited from AnchorElement) to
///         the menu and returns the index.
function add_element(element){
    var center_pos = menu_anchor.get_position();
        // Currently hard-coded size via margins.
        // If we want reactive display then it would be better to utilize anchors
    element.margin.x1 = -128;
    element.margin.x2 = +128;
    element.margin.y1 = -20;
    element.margin.y2 = +20;
    element.anchor.x1 = center_pos.x / room_width;
    element.anchor.x2 = element.anchor.x1;
    array_push(element_array, element);
    
    var element_count = array_length(element_array);
    var y_pos = center_pos.y - floor(element_count * 0.5 * element_padding);
    if (element_count % 2 == 1)
        y_pos += element_padding * 0.5;
    
    for (var i = 0; i < element_count; ++i){
        element = element_array[i]; // Repurpose variable 
        element.anchor.y1 = y_pos / room_height;
        element.anchor.y2 = element.anchor.y1;
        y_pos += element_padding;
    }
    
    return element_count - 1;
}

/// @desc   Adds a button to the menu and returns the index of the menu element.
function add_button(label){
    var element = new MenuButton(label);
    return add_element(element);
}

function add_checkbox(label, is_checked=false){
    var element = new MenuCheckbox(label, is_checked);
    var element_index = add_element(element);
    signaler.add_signal("element.pressed", method(id, function(pressed_index, element_index){
        if (pressed_index != element_index)// Ignore presses for other elements
            return;

        element_array[pressed_index].is_checked = not element_array[pressed_index].is_checked;
    }), element_index);
    return element_index;
}
#endregion

#region INIT
// Add controls for navigating the menu
with (obj_input){
    signaler.add_signal("menu.up", method(other.id, function(value){
        if (value & BUTTON_STATE.pressed <= 0) // If not a 'button press' action, ignore
            return;
        
        element_current = mod2(element_current - 1, array_length(element_array));
    }));
    
    signaler.add_signal("menu.down", method(other.id, function(value){
        if (value & BUTTON_STATE.pressed <= 0) // If not a 'button press' action, ignore
            return;
        
        element_current = mod2(element_current + 1, array_length(element_array));
    }));
    
    signaler.add_signal("menu.select", method(other.id, function(value){
        if (value & BUTTON_STATE.pressed <= 0) // If not a 'button press' action, ignore
            return;

        signaler.signal("element.pressed", element_current);
    }));
}
#endregion