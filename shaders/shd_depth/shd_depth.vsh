attribute vec3 in_Position;

varying v_fDepth;

void main() {
	vec4 object_space_pos = vec4(in_Position.x, in_Position.y, in_Position.z, 1.0);
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
	v_fDepth = clamp(gl_Position.z / 1536.0, 0.0, 1.0); // 1536 comes from our view distance
}