attribute vec2 in_TextureCoord;
attribute vec3 in_Normal; // Vertex group, wrap index, wrap dir

uniform vec3 u_vTransforms[64]; // One transform for each ring up to 64; [0] = az, [1] = po
uniform float u_fLerp;	// Lerp value where 0 = current position, 1 = next position

varying vec2 v_vTexcoord;
varying float v_fFogDensity; // stub, temporary; was for simple depth checking

const float PIPE_RADIUS = 64.0;
const float PIPE_SEGMENT_LENGTH = 64.0;
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
	float fPo = fWrapAngle + fSliceDelta * vTexcoord.y;
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
	vPosition.x = PIPE_RADIUS * cos(fAz) * sin(fPo);
	vPosition.z = PIPE_RADIUS * -sin(fAz) * sin(fPo);
	vPosition.y = PIPE_RADIUS * cos(fPo);

	// Convert local to 'world' (which is just a translation)
	vPosition.x += fXLength * cos(vTransform[0]) * cos(vTransform[1]); // Forward
	vPosition.z += fXLength * -sin(vTransform[0]) * cos(vTransform[1]);	// Right
	vPosition.y += fXLength * sin(vTransform[1]);			// Up
	return vPosition;
}

void main() {
	v_vTexcoord = in_TextureCoord;
	
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
		// vCoordTo = calculate_transform(vTransformTo, imax(iRingIndex - 1, 0), fWrapAngle, fWrapDir, vTextureCoordTo);
		vCoordTo = calculate_transform(vTransformTo, imax(iRingIndex - 1, 0), fWrapAngle, fWrapDir, in_TextureCoord);
		v_fFogDensity = 1.0 - pow(in_Normal[0] / 24.0, 2.0); // stub, for distinguishing depth
	}
	else{
		vec3 vTransformFrom = u_vTransforms[imax(0, iRingIndex - 1)];
		vec3 vTransformTo = u_vTransforms[imax(0, iRingIndex - 2)];
		// vCoordFrom = calculate_transform(vTransformFrom, imax(iRingIndex - 1, 0), fWrapAngle, fWrapDir, vTextureCoordTo);
		vCoordFrom = calculate_transform(vTransformFrom, imax(iRingIndex - 1, 0), fWrapAngle, fWrapDir, vTextureCoordTo);
		vCoordTo = calculate_transform(vTransformTo, imax(iRingIndex - 2, 0), fWrapAngle, fWrapDir, vTextureCoordTo);
		v_fFogDensity = 1.0 - pow(max(in_Normal[0] - 1.0, 0.0) / 24.0, 2.0); // stub, for distinguishing depth
	}
	
	// vec4 vCoordLocal = vec4(vCoordFrom.x, vCoordFrom.y, vCoordFrom.z, 1.0);
	vec4 vCoordLocal = vec4(mix(vCoordFrom.x, vCoordTo.x, u_fLerp), mix(vCoordFrom.y, vCoordTo.y, u_fLerp), mix(vCoordFrom.z, vCoordTo.z, u_fLerp), 1.0);
	vec4 vCoordProj = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vCoordLocal;
	gl_Position = vCoordProj;
}