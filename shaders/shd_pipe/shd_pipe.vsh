attribute vec2 in_TextureCoord;
attribute vec3 in_Normal; // Vertex group, wrap index, wrap dir

uniform vec3 u_vTransforms[64]; // One transform for each ring up to 64; [0] = az, [1] = po
uniform float u_fLerp;	// Lerp value where 0 = current position, 1 = next position
uniform float u_fPipeRadius;

varying float v_fDepth;

// const float PIPE_RADIUS = 64.0;
const float PIPE_SEGMENT_LENGTH = 64.0;	// Length following the pipe between segments
const float PIPE_SLICE_COUNT = 12.0;
const float PI = 3.14159;

int imax(int value1, int value2){
	if (value1 > value2)
		return value1;
	
	return value2;
}

/// Calculate the transform for our vertex, everything is done in spherical coordinates before
/// finally converting to cartesian.
vec3 calculate_transform(vec3 vTransform, int iRingIndex, float fWrapAngle, float fWrapDir, vec2 vTexcoord){
	vec3 vPosition = vec3(0, 0, 0);
	
	float fXLength = float(iRingIndex) * PIPE_SEGMENT_LENGTH + PIPE_SEGMENT_LENGTH * vTexcoord.x;
		// Calculate local 'ring' first:
	float fSliceDelta = PI / PIPE_SLICE_COUNT;
	float fUnwrapMultiplier = mix(0.5, 1.0, vTransform[2]);
	float fPo = (fUnwrapMultiplier * fWrapAngle + fSliceDelta * vTexcoord.y * fUnwrapMultiplier);
	float fAz = PI * 0.5;
	if (fWrapDir < 0.0){
		fAz += PI;
		fPo += vTransform[1]; // Add relative x/z-axis rotation
	}
	else
		fPo -= vTransform[1];	
	
		// Add y-axis rotation:
	fAz += vTransform[0];
	
	// Convert local coordinate system:
	float fPipeRadius = mix(PI, 1.0, vTransform[2]) * u_fPipeRadius;
	
	vPosition.x = fPipeRadius * cos(fAz) * -sin(fPo);
	vPosition.z = fPipeRadius * -sin(fAz) * -sin(fPo);
	vPosition.y = fPipeRadius * -cos(fPo);
	
	vec3 vRayForward = vec3(cos(vTransform[0]) * cos(vTransform[1]), sin(vTransform[1]), -sin(vTransform[0]) * cos(vTransform[1]));
	vec3 vRayLeft = normalize(vec3(cos(vTransform[0] + PI * 0.5) * cos(vTransform[1]), sin(vTransform[1]), -sin(vTransform[0] + PI * 0.5) * cos(vTransform[1])));
	vec3 vRayDown = normalize(vec3(cos(vTransform[0]) * cos(vTransform[1] - PI * 0.5), sin(vTransform[1] - PI * 0.5), -sin(vTransform[0]) * cos(vTransform[1] - PI * 0.5))) * mix(u_fPipeRadius, 0.0, vTransform[2]);
	
	vPosition = mix(dot(vRayLeft, vPosition) * vRayLeft, vPosition, vTransform[2]);

	// Convert local to 'world' (which is just a translation)
	vPosition.x += fXLength * vRayForward.x; // Forward
	vPosition.z += fXLength * vRayForward.z;	// Left
	vPosition.y += fXLength * vRayForward.y;	// Up
	
	return vPosition + vRayDown;
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
	
	// vec4 vCoordLocal = vec4(vCoordFrom.x, vCoordFrom.y, vCoordFrom.z, 1.0);
	vec4 vCoordLocal = vec4(mix(vCoordFrom.x, vCoordTo.x, u_fLerp), mix(vCoordFrom.y, vCoordTo.y, u_fLerp), mix(vCoordFrom.z, vCoordTo.z, u_fLerp), 1.0);
	vec4 vCoordProj = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vCoordLocal;
	gl_Position = vCoordProj;
	v_fDepth = clamp(vCoordProj.z / 1536.0, 0.0, 1.0);
}