varying float v_fFogDensity;

void main() {
	gl_FragColor = vec4(1.0 * v_fFogDensity, 1.0 * v_fFogDensity, 1.0 * v_fFogDensity, 1.0);
}