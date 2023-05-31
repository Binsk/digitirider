/// @desc   Flattens an n-dimensional array in a naive way. Thes function is slow
///         and was whipped up quickly for the purpose of shader uniform passing.
/// @param  {array}     array       array to flatten
/// @return {array}
function array_flatten(array){
    if (not is_array(array))
        return [array];

    var newarray = [];
    var al = array_length(array);
    for (var i = 0; i < al; ++i){
        if (not is_array(array[i])){
            array_push(newarray, array[i]);
            continue;
        }
        
        var subarray = array_flatten(array[i]);
        var sal = array_length(subarray);
        for (var j = 0; j < sal; ++j)
            array_push(newarray, subarray[j]);
    }
    
    return newarray;
}

/// @desc   Cycles all the values in the array by one in the specified direction
/// @param  {array}     array       array to modify in-place
/// @param  {real}      direction   direction to shift the values
/// @return {array}
function array_cycle(array, direction){
    if (not is_array(array))
        return array;
    
    if (not is_real(direction))
        return array;
    
    if (direction < 0){
        var al = array_length(array);
        var value = array[0];
        for (var i = 0; i < al - 1; ++i)
            array[@ i] = array[i + 1];
        
        array[@ al - 1] = value;
    }
    else if (direction > 0){
        var al = array_length(array);
        var value = array[al - 1];
        for (var i = al - 1; i > 0; --i)
            array[@ i] = array[i - 1];
        
        array[@ 0] = value;
    }
    
    return array;
}

/// @desc   Given two arrays, generates a new array where 
///         size=min(len(array_1), len(array_2)) and each element is determined
///         by some function that takes a value from array_1 as argument0 and
///         a value from array_2 as argument1.
/// @param  {array} array_1     first array to pass to the function
/// @param  {array} array_2     second array to pass to the function
/// @param  {function} func     function to determine what value is in each slot
/// @param  {array} argv=[]     optional arguments to pass along-side the arrays
function array_process_array(array_1, array_2, func, args=[]){
    var min_length = min(array_length(array_1), array_length(array_2));
    var array = array_create(min_length);
    var argv = array_create(array_length(args) + 2);
    for (var i = 0; i < array_length(args); ++i)
        argv[2 + i] = args[i];
    
    for (var i = 0; i < min_length; ++i){
        argv[0] = array_1[i];
        argv[1] = array_2[i];
        array[i] = callv(func, argv);
    }
    
    return array;
}