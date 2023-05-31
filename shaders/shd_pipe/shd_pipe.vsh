attribute vec2 in_TextureCoord;
attribute vec3 in_Normal; // Vertex group, wrap index, wrap dir

uniform vec3 u_vTransforms[64]; // One transform for each ring up to 64; [0] = az, [1] = po
uniform float u_fLerp;	// Lerp value where 0 = current position, 1 = next position
uniform float u_fPipeRadius;
uniform float u_fSegmentLength;
uniform float u_fSliceCount;

varying float v_fDepth;

const float PI = 3.14159;

int imax(int value1, int value2){
	if (value1 > value2)
		return value1;
	
	return value2;
}

// Calculate the vertex position of the pipe:
vec3 calculate_ring_transform(vec3 vTransform, int iRingIndex, float fWrapAngle, float fWrapDir, vec2 vTexcoord){
	vec3 vPosition = vec3(0, 0, 0);
	float fSliceDelta = PI / u_fSliceCount;
	
	// Calculate local vertex position:
	float fPo = (fWrapAngle + fSliceDelta * vTexcoord.y); // Phi
	float fAz = PI * 0.5; // Theta
	if (fWrapDir < 0.0){
		fAz += PI;
		fPo += vTransform[1]; // Relative x/z-axis rotation
	}
	else
		fPo -= vTransform[1];
	
	// Add y-axis rotation:
	fAz += vTransform[0];
	
	// Convert to ring coordinates:
	vPosition.x = u_fPipeRadius * cos(fAz) * -sin(fPo);
	vPosition.z = u_fPipeRadius * -sin(fAz) * -sin(fPo);
	vPosition.y = u_fPipeRadius * -cos(fPo);
	
	// Convert to world coordinates
	float fXLength = float(iRingIndex) * u_fSegmentLength + u_fSegmentLength * vTexcoord.x;
	vec3 vRayForward = vec3(cos(vTransform[0]) * cos(vTransform[1]), sin(vTransform[1]), -sin(vTransform[0]) * cos(vTransform[1]));
	vPosition.x += fXLength * vRayForward.x;
	vPosition.z += fXLength * vRayForward.z;
	vPosition.y += fXLength * vRayForward.y;
	
	return vPosition;
}

// Calculate the vertex position of the plane:
vec3 calculate_plane_transform(vec3 vTransform, int iRingIndex, float fWrapAngle, float fWrapDir, vec2 vTexcoord){
	vec3 vPosition = vec3(0, 0, 0);
	float fIndex = floor(u_fSliceCount / PI * fWrapAngle); // Vertex index (used for measuring)
	float fAz = PI * 0.5;
	
	fAz += vTransform[0];
	float fLength = (fIndex + vTexcoord.y) * (u_fPipeRadius * 0.25) * -fWrapDir;
	
	vPosition.x = fLength * cos(fAz);
	vPosition.z = fLength * -sin(fAz);
	vPosition.y = 0.0;
	
	// Convert to world coordinates:
	float fXLength = float(iRingIndex) * u_fSegmentLength + u_fSegmentLength * vTexcoord.x;
	vec3 vRayForward = vec3(cos(vTransform[0]) * cos(vTransform[1]), sin(vTransform[1]), -sin(vTransform[0]) * cos(vTransform[1]));
	vPosition.x += fXLength * vRayForward.x;
	vPosition.z += fXLength * vRayForward.z;
	vPosition.y += fXLength * vRayForward.y;
	
	return vPosition;
}

/// Calculate the transform for our vertex, everything is done in spherical coordinates before
/// finally converting to cartesian.
vec3 calculate_transform(vec3 vTransform, int iRingIndex, float fWrapAngle, float fWrapDir, vec2 vTexcoord){
	vec3 fCoordA = calculate_ring_transform(vTransform, iRingIndex, fWrapAngle, fWrapDir, vTexcoord);
	vec3 fCoordB = calculate_plane_transform(vTransform, iRingIndex, fWrapAngle, fWrapDir, vTexcoord);
	return mix(fCoordB, fCoordA, vTransform[2]);
}


void main() {
	int iRingIndex = int(in_Normal[0]);
	float fWrapAngle = in_Normal[1];
	float fWrapDir = in_Normal[2];
	vec2 vTextureCoordTo = vec2(1.0 - in_TextureCoord.x, in_TextureCoord.y);
	vec3 vCoordFrom;
	vec3 vCoordTo;
	
	if (in_TextureCoord.x > 0.5){
		vec3 vTransformFrom = u_vTransforms[iRingIndex];
		vec3 vTransformTo = u_vTransforms[imax(0, iRingIndex - 1)];
		vCoordFrom = calculate_transform(vTransformFrom, iRingIndex, fWrapAngle, fWrapDir, in_TextureCoord);
		vCoordTo = calculate_transform(vTransformTo, imax(iRingIndex - 1, 0), fWrapAngle, fWrapDir, in_TextureCoord);
	}
	else{
		vec3 vTransformFrom = u_vTransforms[imax(0, iRingIndex - 1)];
		vec3 vTransformTo = u_vTransforms[imax(0, iRingIndex - 2)];
		vCoordFrom = calculate_transform(vTransformFrom, imax(iRingIndex - 1, 0), fWrapAngle, fWrapDir, vTextureCoordTo);
		vCoordTo = calculate_transform(vTransformTo, imax(iRingIndex - 2, 0), fWrapAngle, fWrapDir, vTextureCoordTo);
	}
	
	vec4 vCoordLocal = vec4(mix(vCoordFrom.x, vCoordTo.x, u_fLerp), mix(vCoordFrom.y, vCoordTo.y, u_fLerp), mix(vCoordFrom.z, vCoordTo.z, u_fLerp), 1.0);
	vec4 vCoordProj = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vCoordLocal;

	gl_Position = vCoordProj;
	v_fDepth = clamp(vCoordProj.z / 1536.0, 0.0, 1.0);
}