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