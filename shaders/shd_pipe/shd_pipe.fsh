varying vec2 v_vTexcoord;
varying float v_fFogDensity;

void main() {
	gl_FragColor = vec4(1.0 * v_fFogDensity, 1.0 * v_fFogDensity, 1.0 * v_fFogDensity, 1.0);//texture2D(gm_BaseTexture, v_vTexcoord);
}