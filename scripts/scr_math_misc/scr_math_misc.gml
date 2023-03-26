/// ABOUT
/// This script contains the odd-ball math function that I ended up needing.

/// @desc   The same as mod (or %) except it wraps in reverse, disallowing 
///         negative numbers.
function mod2(value, wrap){
    value %= wrap; // Normal wrap
    
        // Reverse wrap:
    if (value < 0){
        var nvalue = abs(value) % wrap;
        value = wrap - nvalue;
    }
    
    return value;
}

/// @desc   Returns if the specified number is within the specified range. If multiple
///         ranges are provided a match of ANY range will return true
/// @param  {real}  number              number to check
/// @param  {array} range               ranges of numbers in the form of an array (must be sets of 2)
/// @param  {bool}  min_inclusive=true whether or not the minimum value is inclusive
/// @param  {bool}  max_inclusive=true whether or not the maximum value is inclusive
function in_range(value, range=[-infinity, infinity], min_inclusive=true, max_inclusive=true){
    if (not is_numeric(value)) return false;
    if (not is_array(range)) return false;
    if (array_length(range) < 2 or array_length(range) % 2 == 1) return false;
    
    var _min;
    var _max;
    for (var i = 0; i < array_length(range) - 1; i += 2){
        _min = range[i];
        _max = range[i + 1];
        var clamped = clamp(value, _min, _max);
        if (clamped == value){
            if (not min_inclusive and value == _min)
                continue;
            
            if (not max_inclusive and value == _max)
                continue;
                
           return true;
        }
    }
    
    return false;
}