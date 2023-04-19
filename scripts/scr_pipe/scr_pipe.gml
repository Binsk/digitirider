/// @desc   Defines a pipe morph state; angles are in radians.
function PipeMorph(theta=0, phi=0, unroll=1.0) constructor {
    self.theta = theta;
    self.phi = phi;
    self.unroll = unroll;
    static RADIUS = 64;         // Radius of the pipe
    static SEGMENT_LENGTH = 64; // Length of each ring segment extrusion
    static RING_COUNT = 32;     // Number of rings to render (aka., how long the pipe is)
    static RING_SLICES = 12;    // Number of slices per ring (aka., precision of the ring circle)
    
    /// @desc   Generate a shader-compatable array to morph the pipe with the
    ///         structures current angles.
    function construct_array(){
        var array = array_create(RING_COUNT * 3);
        var theta_delta = self.theta / RING_COUNT;
        var theta = 0;
        var phi_delta = self.phi / RING_COUNT;
        var phi = 0;
        var al = RING_COUNT * 3;
        for (var i = 0; i < al; i += 3){
            array[i] = theta;
            array[i + 1] = phi;
            array[i + 2] = unroll; // Roll
            theta += theta_delta;
            phi += phi_delta;
        }
        
        return array;
    }
    
    /// @desc   Generates a shader-comatible array to merph teh pipe with a
    ///         lerped value between this structure's values and the specified
    ///         structures values.
    function construct_array_lerp(morph, mlerp=0.5){
        var a1 = construct_array(RING_COUNT);
        var a2 = morph.construct_array(RING_COUNT);
        var array = array_create(RING_COUNT * 3, 1.0);
        
        var al = RING_COUNT * 3;
        for (var i = 0; i < al; i += 3){
            array[i] = lerp(a1[i], a2[i], mlerp);
            array[i + 1] = lerp(a1[i + 1], a2[i + 1], mlerp);
            array[i + 2] = lerp(a1[i + 2], a2[i + 2], mlerp);
        }
        
        return array;
    }
}

// We must create at least one PipeMorph so that the static variables are initialized.
// This allows direct access by other systems down the road, similar to a global variable.
var pm = new PipeMorph();
delete pm;