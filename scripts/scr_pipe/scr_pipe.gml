/// @desc   Defines a pipe morph state; angles are in radians and coordinates are
///         spherical.
function PipeMorph(theta=0, phi=0, unroll=1.0) constructor {
    static RADIUS = 64;         // Radius of the pipe
    static SEGMENT_LENGTH = 64; // Length of each ring segment extrusion
    static RING_COUNT = 32;     // Number of rings to render (aka., how long the pipe is)
    static RING_SLICES = 12;    // Number of slices per ring (aka., precision of the ring circle)
    
    self.theta = theta;
    self.phi = phi;
    self.unroll = unroll;
    
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
    
    /// @desc Calculates the 3D cartesian position for a specified segment given the
    ///       angle around the ring, in radians. 0 radians is the bottom of the ring.
    function calculate_position_on_ring(index, angle, theta=self.theta, phi=self.phi, radius=PipeMorph.RADIUS, local_offsets={}){
        var position = {x : 0, y : 0, z : 0};
        
        if (is_undefined(local_offsets[$ "x"])) local_offsets.x = 0;
        if (is_undefined(local_offsets[$ "y"])) local_offsets.y = 0;
        if (is_undefined(local_offsets[$ "z"])) local_offsets.z = 0;
        
        if (index < 0 or index >= RING_COUNT) // Out-of-bounds
            return undefined;
            
        var vertex_index = RING_SLICES / pi * abs(angle * 0.5);
        
        // Calculate local coordinates:
        var theta_delta = theta / RING_COUNT;
        var phi_delta = phi / RING_COUNT;
        
        var gtheta = theta_delta * index;
        var gphi = phi_delta * index;
        theta = pi * 0.5 + gtheta;
        phi = angle;
        if (sign(angle) < 0){
            theta += gtheta;
            phi += gphi;
        }
        else
            phi -= gphi;
            
        position.x = radius * cos(theta) * -sin(phi);
        position.z = radius * -sin(theta) * -sin(phi);
        position.y = radius * -cos(phi);
        
        // Convert to world coordinates:
        var slength = (index + 1) * SEGMENT_LENGTH;
        var vforward = {
            x : cos(gtheta) * cos(gphi),
            y : sin(gphi),
            z : -sin(gtheta) * cos(gphi)
        };
        
        position.x += vforward.x * slength;
        position.z += vforward.z * slength;
        position.y += vforward.y * slength;
        
        return position;
    }
    
    /// @desc Calculates the 3D cartesian position for the specified segment given the
    ///       angle around the ring, in radians. 0 radians is the center of the plane.
    ///       Returns "undefined" if an error occurred.
    function calculate_position_on_plane(index, angle, theta=self.theta, phi=self.phi, local_offsets={}){
        var position = {x : 0, y : 0, z : 0};
        
        if (is_undefined(local_offsets[$ "x"])) local_offsets.x = 0;
        if (is_undefined(local_offsets[$ "y"])) local_offsets.y = 0;
        if (is_undefined(local_offsets[$ "z"])) local_offsets.z = 0;
        
        if (index < 0 or index >= RING_COUNT) // Out-of-bounds
            return undefined;
        
        var vertex_index = RING_SLICES / pi * abs(angle * 0.5);
        
        // Calculate local coordinates:
        var theta_delta = theta / RING_COUNT;
        var phi_delta = phi / RING_COUNT;
        
        var gtheta = theta_delta * index;
        var gphi = phi_delta * index;
        
        theta = pi * 0.5 + gtheta;
        var length = vertex_index * RADIUS * 0.25 * sign(angle); // From center
        position.x = length * cos(theta) + local_offsets.x;
        position.z = length * -sin(theta) + local_offsets.z;
        position.y = local_offsets.y;
    
        // Calculate world coordinates:
        // Note +1 because rendering actually bases coordinates off the NEXT index
        var slength = (index + 1) * SEGMENT_LENGTH; // From start of pipe
        var vforward = {
            x : cos(gtheta) * cos(gphi),
            y : sin(gphi),
            z : -sin(gtheta) * cos(gphi)
        };
        
        position.x += vforward.x * slength;
        position.z += vforward.z * slength;
        position.y += vforward.y * slength;
        
        return position;
    }
}

// We must create at least one PipeMorph so that the static variables are initialized.
// This allows direct access by other systems down the road, similar to a global variable.
var pm = new PipeMorph();
delete pm;