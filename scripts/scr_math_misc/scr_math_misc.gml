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