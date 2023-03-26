for (var i = 0; i < array_length(element_array); ++i){
    element_array[i].color = (i == element_current ? c_yellow : c_white);
    element_array[i].draw();
}
    