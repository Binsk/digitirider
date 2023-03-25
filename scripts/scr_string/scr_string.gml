/// @desc   Returns a string with values substituted inside. Possible substitutions
///         are:
///         -   {}  will substitute value into this location
///         -   {#} will substitute assuming value is an array with the specified
///                 number indicating the array index.
/// @param  {string}    string      string to parse
/// @param  {any}       value       can be a value or an array of values
/// @return {string}
function string_substitute(str, value=""){
    var saw_open = false;   // Whether or not we saw '{'
    var saw_escape = false; // Whether or not we saw a backslash
    var digits = "1234567890";  // Valid digits that can occur between {}
    var newstr = "";            // The final processed string
    var strlen = string_length(str);
    var indexstr = "";  // A string of the current array index to read
    
    /// NOTE: This is a bit naive in approach and is thus relatively slow.
    ///       This should be improved if this function ends up being used a lot
    ///       or with long strings.
    for (var i = 1; i <= strlen; ++i){
        var char = string_copy(str, i, 1);
        if (saw_open){
                // Generic 'insert in place'
            if (char == "}"){
                if (string_length(indexstr) > 0){
                    var indexint = int64(indexstr);
                    if (not is_array(value) or array_length(value) <= indexint)
                        print_fixme(string_substitute("index {0} out of bounds [0..{1}]", [indexint, array_length(value)]));
                    else
                        newstr += string(value[indexint]);
                }
                else
                    newstr += string(value);
                
                indexstr = "";
                saw_open = false;
                continue;
            }
                // We are looking at an array index specification:
            else if (string_pos(char, digits) > 0){
                indexstr += char;
                continue;
            }
            
            saw_open = false;
            newstr += "{" + indexstr;
            indexstr = "";
            continue;
        }
        
        if (char == "{" and not saw_escape){
            saw_open = true;
            continue;
        }
        
        if (char == "\\" and not saw_escape){
            saw_escape = true;
            continue;
        }
        
        saw_escape = false;
        newstr += char;
    }
    
    return newstr;
}

/// @desc   Given a delimiter and a string, the string will be sliced into
///         sections at every occurrence of the delimiter.
/// @param  {string}    delimiter   string to cut by
/// @param  {string}    string      string to cut
function string_explode(delim, str, keepempty=true){
    var slices = [];
    var cutstr = str;
    var pos = string_pos(delim, cutstr);
    while (pos > 0){
        var substr = string_copy(cutstr, 1, pos - 1);
        if (substr != "" or keepempty)
            array_push(slices, substr);
        
        cutstr = string_delete(cutstr, 1, pos - 1 + string_length(delim));
        pos = string_pos(delim, cutstr);
    }
    
    if (string_length(cutstr) > 0)
        array_push(slices, cutstr);
        
    return slices;
}