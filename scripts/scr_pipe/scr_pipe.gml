/// @desc   Defines a pipe morph state; angles are in radians.
function PipeMorph(theta=0, phi=0, unroll=0) constructor {
    self.theta = theta;
    self.phi = phi;
    self.unroll = unroll;
    
    /// @desc   Generate a shader-compatable array to morph the pipe with the
    ///         structures current angles.
    function construct_array(ring_count=32){
        var array = array_create(ring_count * 3);
        var theta_delta = self.theta / ring_count;
        var theta = 0;
        var phi_delta = self.phi / ring_count;
        var phi = 0;
/// @stub   Implement unroll 
        var al = ring_count * 3;
        for (var i = 0; i < al; i += 3){
            array[i] = theta;
            array[i + 1] = phi;
            array[i + 2] = 1.0; // Roll
            theta += theta_delta;
            phi += phi_delta;
        }
        
        return array;
    }
    
    /// @desc   Generates a shader-comatible array to merph teh pipe with a
    ///         lerped value between this structure's values and the specified
    ///         structures values.
    function construct_array_lerp(morph, mlerp=0.5, ring_count=32){
        var a1 = construct_array(ring_count);
        var a2 = morph.construct_array(ring_count);
        var array = array_create(ring_count * 3, 1.0);
        
/// @stub Implement unroll
        var al = ring_count * 3;
        for (var i = 0; i < al; i += 3){
            array[i] = lerp(a1[i], a2[i], mlerp);
            array[i + 1] = lerp(a1[i + 1], a2[i + 1], mlerp);
        }
        
        return array;
    }
}