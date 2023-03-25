/// @desc   A simple function that takes an array of arguments and passes them
///         into a function regularly. Supports up to 12 arguments.
/// @param  {script}    function    function to execute
/// @param  {array}     params=[]   array of arguments to pass
/// @returns    {any}   returns whatever the script returns
function callv(_method, _params=[]) {
    if (not is_array(_params))
        throw "Invalid parameter type [1]!";
    
    var _param_count = array_length(_params);
    if (_param_count == 0)
        return _method();
    else if (_param_count == 1)
        return _method(_params[0]);
    else if (_param_count == 2)
        return _method(_params[0], _params[1]);
    else if (_param_count == 3)
        return _method(_params[0], _params[1], _params[2]);
    else if (_param_count == 4)
        return _method(_params[0], _params[1], _params[2], _params[3]);
    else if (_param_count == 5)
        return _method(_params[0], _params[1], _params[2], _params[3],
                       _params[4]);
    else if (_param_count == 6)
        return _method(_params[0], _params[1], _params[2], _params[3],
                       _params[4], _params[5]);
    else if (_param_count == 7)
        return _method(_params[0], _params[1], _params[2], _params[3],
                       _params[4], _params[5], _params[6]);
    else if (_param_count == 8)
        return _method(_params[0], _params[1], _params[2], _params[3],
                       _params[4], _params[5], _params[6], _params[7]);
    else if (_param_count == 9)
        return _method(_params[0], _params[1], _params[2], _params[3],
                       _params[4], _params[5], _params[6], _params[7],
                       _params[8]);
    else if (_param_count == 10)
        return _method(_params[0], _params[1], _params[2], _params[3],
                       _params[4], _params[5], _params[6], _params[7],
                       _params[8], _params[9]);
    else if (_param_count == 11)
        return _method(_params[0], _params[1], _params[2], _params[3],
                       _params[4], _params[5], _params[6], _params[7],
                       _params[8], _params[9], _params[10]);
    else if (_param_count == 12)
        return _method(_params[0], _params[1], _params[2], _params[3],
                       _params[4], _params[5], _params[6], _params[7],
                       _params[8], _params[9], _params[10], _params[11]);
        
    throw "Too many arguments for callv [" + string(_param_count - 1) + "]!";
}


/// @desc   Creates a new signaler system that can execute multiple methods
///         at a time while passing optional static and dynamic arguments.
///
///         Signalers can be slow to create / destroy but they are fast to 
///         execute. Excessive addition / removal of signals can cause slow-down
///         and should be minimized as much as possible.
///
///         Signals can accept optional arguments in two cases:
///             1. When creating the signal
///             2. When calling the signal
///
///         The arguments in case 1 will ALWAYS be provided AFTER the arguments
///         in case 2 when the method is executed. This allows you to specify
///         defaults or custom data that can be overridden at actual signal
///         execution.
///
///         Lastly, it is possible to disable 'safe execution'. When each signal
///         is triggered the system makes sure the attached structs/instances to
///         the signal exist before executing. If you have a lot of instances then
///         this can be slow. By disabling 'safe execution' this check is skipped
///         which requires that you always remove signals for instances that get
///         destroyed.
function Signaler() constructor{
    
    #region SUBCLASSES
    
    enum FUNCREF_TYPE {
    	method_instance,	// Method attached to an instance
    	method_struct,		// Method attached to structure
    	unbound				// Unbound function / unknown value
    }
    
    /// @desc   A 'method' with attached arguments and signaling name
    function FuncRef(_name, _method, _args=[]) constructor{
        /// Member variables:
        fr_name = _name;
        fr_method = _method;
        fr_args = _args;
        
        /// Member methods:
        /// @desc   Returns if the two FuncRef structs are equal
        function get_is_equal(funcref){
            // Check names:
            if (fr_name != funcref.fr_name) return false;
            // Check methods:
            var meth1 = fr_method;
            var meth2 = funcref.fr_method;
                // Both are just functions:
            if (not is_method(meth1) and not is_method(meth2))
                return meth1 == meth2;
                // One is a method, one is a function:
            if (not is_method(meth1) and is_method(meth2))
                return false;
            if (is_method(meth1) and not is_method(meth2))
                return false;
                // Both are methods:
            if (method_get_self(meth1) != method_get_self(meth2))
                return false;
            if (method_get_index(meth1) != method_get_index(meth2))
                return false;
                
            // Check arguments:
            return (array_equals(fr_args, funcref.fr_args));
        }
        
        function get_type(){
        	var inst = method_get_self(fr_method);
        	if (is_undefined(inst))
        		return FUNCREF_TYPE.unbound;
        		
        	if (is_struct(inst))
        		return FUNCREF_TYPE.method_struct;
        	
        		// Explicitly checking last case for readability reasons:
        	if (is_numeric(inst) or is_ptr(inst))
        		return FUNCREF_TYPE.method_instance;
        	
        	return undefined; // Should never occur
        }
        
        /// @desc   Returns if the struct / instance of the method still exists
        function get_is_valid(){
            if (not is_method(fr_method)) return true;
            var instance = method_get_self(fr_method);
            if (not is_struct(instance) and not instance_exists(instance)) return false;
            return true;
        }
        /// @desc   Execute the funcref w/ the attached args:
        function execute(args=[]){
            var alen = array_length(args);
            var fralen = array_length(fr_args);
            var array = array_create(fralen + alen);
            
            for (var i = 0; i < alen; ++i)
                array[i] = args[i];
            for (var i = alen; i < alen + fralen; ++i)
                array[i] = fr_args[i - alen];
                
            callv(fr_method, array);
        }
    }
    #endregion
    
    #region MEMBERS
    signal_map = {}; // signal -> ref pairs
    is_safe_execution = true;
    #endregion
    
    #region METHODS
    /// @desc   Cleans the signaler, removing all attached signals.
    function clear(){
        signal_map = {};
    }
    
    /// @desc   Cleans the signaler, removing all attached signals for a given title.
    function clear_title(title=""){
        if (variable_struct_exists(signal_map, title))
            variable_struct_remove(signal_map, title);
    }
    
    /// @desc   Enables/disables safe execution. Unsafe execution is quicker to
    ///         execute but can crash if a signal is thrown for a deleted instance
    ///         or struct. Only disable if you can guarantee signals will be
    ///         properly removed.
    /// @param  {bool}  safe=true   if true, safe execution is used
    function set_safe_execution(safe=true){
        is_safe_execution = bool(safe);
    }
    /// @desc   Adds a new signal to the system.
    /// @param  {string}    name        name to give the signal
    /// @param  {method}    method      method to execute upon call
    /// @param              ...         arguments to attach, if any
    /// @return {bool}      true if success
    function add_signal(_name, _method){
        // Grab any optional arguments:
        var args = [];
        if (argument_count > 2){
            args = array_create(argument_count - 2);
            for (var i = 2; i < argument_count; ++i)
                args[i - 2] = argument[i];
        }
        
        return add_signalv(_name, _method, args);
    }
    /// @desc   The same as add_signal but takes an array of 
    ///         arguments.
    /// @param  {string}    name        name to give the signal
    /// @param  {method}    method      method to execute upon call
    /// @param  {array}     args=[]     arguments to attach
    /// @return {bool}      true if success
    function add_signalv(_name, _method, _args=[]){
        // Create our funcref:
        var funcref = new FuncRef(_name, _method, _args);
        
        // Grab our signal array if it exists:
        var array = signal_map[$ _name];
        if (is_undefined(array)) array = [];
        
        // Look for duplicate funcrefs:
        for (var i = 0; i < array_length(array); ++i){
            if (funcref.get_is_equal(array[i])){
                delete funcref;
                return false;
            }
        }
        
        // Add our funcref to the signaler:
        array[array_length(array)] = funcref;
        signal_map[$ _name] = array;
        return true;
    }
    
    /// @desc   Performs the same as add_signal but sets it as a 'prioritized'
    ///         signal that will execute before the others.
    /// @param  {string}    name        name to give the signal
    /// @param  {method}    method      method to execute upon call
    /// @param              ...         arguments to attach, if any
    /// @return {bool}      true if success
    function add_psignal(_name, _method){
        // Grab any optional arguments:
        var args = [];
        if (argument_count > 2){
            args = array_create(argument_count - 2);
            for (var i = 2; i < argument_count; ++i)
                args[i - 2] = argument[i];
        }
        
        return add_psignalv(_name, _method, args);
    }
    
    /// @desc   Performs the same as add_signalv but sets it as a 'prioritized'
    ///         signal that will execute before the others.
    /// @param  {string}    name        name to give the signal
    /// @param  {method}    method      method to execute upon call
    /// @param  {array}     args=[]     arguments to attach
    /// @return {bool}      true if success
    function add_psignalv(_name, _method, _args=[]){
        // Create our funcref:
        var funcref = new FuncRef(_name, _method, _args);
        
        // Grab our signal array if it exists:
        var array = signal_map[$ _name];
        if (is_undefined(array)) array = [];
        
        // Look for duplicate funcrefs:
        for (var i = 0; i < array_length(array); ++i){
            if (funcref.get_is_equal(array[i])){
                delete funcref;
                return false;
            }
        }
        
        // Add our funcref to the signaler:
        array_insert(array, 0, funcref);
        signal_map[$ _name] = array;
        return true;
    }
    
    /// @desc   Removes a signal from the signaler. This should ALWAYS be called
    ///         for every signal created once the signal is no longer needed.
    ///         The only exception is if you clean the system w/ clear().
    /// @param  {string}    name        name of the signal that was added
    /// @param  {method}    method      method of the signal that was added
    /// @param              ...         any arguments that were added to the signal
    /// @return {bool}      true if success
    function remove_signal(_name, _method){
        // Grab any optional arguments:
        var args = [];
        if (argument_count > 2){
            args = array_create(argument_count - 2);
            for (var i = 2; i < argument_count; ++i)
                args[i - 2] = argument[i];
        }
        
        return remove_signalv(_name, _method, args);
    }
    /// @desc   Performs the same as remove_signal() except that the function
    ///         takes arguments as an array.
    /// @param  {string}    name        name of the signal that was added
    /// @param  {method}    method      method of the signal that was added
    /// @param  {array}     args=[]     argument array to pass
    /// @return {bool}      true if success
    function remove_signalv(_name, _method, _args=[]){
        var array = signal_map[$ _name];
        if (is_undefined(array)) return false;
    
            // Create a funcref for easy comparing:
        var funcref = new FuncRef(_name, _method, _args);
        var queue = ds_queue_create(); // Valid ref queue
        for (var i = 0; i < array_length(array); ++i){
            if (funcref.get_is_equal(array[i])){
                delete array[i];
                continue;
            }
            ds_queue_enqueue(queue, array[i]);
        }
        
        // Add the modified list back into the array:
        var qlen = ds_queue_size(queue);
        array = array_create(qlen);
        for (var i = 0; i < qlen; ++i)
            array[i] = ds_queue_dequeue(queue);
            
        ds_queue_destroy(queue);
        signal_map[$ _name] = array;
        delete funcref; // Cleanup temp funcref
        return true;
    }
    
    /// @desc	Similar to remove_signal() only it will remove ALL signals attached
    ///			to a certain label, regardless of instance or arguments
    /// @param	{string}	name		name of the signal to remove
    function remove_signal_label(_name){
    	var array = signal_map[$ _name];
    	for (var i = 0; i < array_length(array); ++i)
			delete array[i];
    
    	variable_struct_remove(signal_map, _name);
    	return true;
    }
    
    /// @desc	Clears ALL signals that would be thrown for the specified instance
    ///			ID. Does NOT account for non-method attachemnts nor struct-based
    ///			attachments.
    ///			Returns the number signals cleared.
    /// @return {real}
    function clear_instance_signals(instance){
    	var keys = variable_struct_get_names(signal_map);
    	var clear_array = [];
    	
    	// Add all valid signals to the clear array:
    	for (var i = 0; i < array_length(keys); ++i){
    		var array = signal_map[$ keys[i]];
    		for (var j = 0; j < array_length(array); ++j){
    			var funcref = array[j];
    			if (funcref.get_type() != FUNCREF_TYPE.method_instance)
    				continue;
    			
    			if (method_get_self(funcref.fr_method) == instance)
    				array_push(clear_array, funcref);
    		}
    	}
    	
    	// Loop the clear array and destroy the signals:
    	for (var i = 0; i < array_length(clear_array); ++i){
    		var funcref = clear_array[i];
    		remove_signalv(funcref.fr_name, funcref.fr_method, funcref.fr_args);
    	}
    	
    	return array_length(clear_array);
    }
    
    /// @desc   Trigger a signal if it exists.
    /// @param  {string}    name        name of the signal to trigger
    /// @param              ...         arguments, if any
    function signal(_name){
        // Grab any optional arguments:
        var args = [];
        if (argument_count > 1){
            args = array_create(argument_count - 1);
            for (var i = 1; i < argument_count; ++i)
                args[i - 1] = argument[i];
        }
        
        return signalv(_name, args);
    }
    /// @desc   Performs the same as signal() except that the function takes
    ///         arguments as an array.
    /// @param  {string}    name        name of the signal to trigger
    /// @param  {array}     args=[]     argument array to pass
    function signalv(_name, _args=[]){
        // Look up our signal:
        var array = signal_map[$ _name];
        if (is_undefined(array)) return; // No signal w/ this name

        // Loop through each attached signal:
        for (var i = 0; i < array_length(array); ++i){
            var funcref = array[i];
                // If instance / struct isn't valid we cancel:
            if (is_safe_execution and not funcref.get_is_valid()) continue;
            funcref.execute(_args);
        }
    }
    
    /// @desc   Convert-to-string override to print out some useful signal data
    ///         if required.
    function toString(){
        var str = "";
        
        var keys = variable_struct_get_names(signal_map);
        var list = ds_list_create();
        for (var i = 0; i < array_length(keys); ++i)
            ds_list_add(list, keys[i]);
            
        ds_list_sort(list, true);
        for (var i = 0; i < ds_list_size(list); ++i)
            keys[i] = list[| i];

        for (var i = 0; i < ds_list_size(list); ++i){
            var array = signal_map[$ list[| i]];
            str += list[| i] + ": [" + string(array_length(array)) + " signals]\n\t[";
            for (var j = 0; j < array_length(array); ++j){
                if (j > 0)
                    str += ", ";
                var funcref = array[j];
                var meth = funcref.fr_method;
                if (not is_method(meth)){
                    str += "[function]";
                    continue;
                }
                
                meth = method_get_self(meth);
                if (is_struct(meth)){
                    str += "[method, struct]";
                    continue;
                }
                
                if (instance_exists(meth)){
                    str += "[method, " + string(object_get_name(meth.object_index)) + ", " + string(meth) + "]";
                    continue;
                }
                else
                    str += "[method, " + string(meth) + "]";
            }
            str += "]\n";
        }
        
        ds_list_destroy(list);
        return str;
    }
    #endregion
}