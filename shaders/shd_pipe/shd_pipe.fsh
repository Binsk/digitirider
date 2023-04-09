varying float v_fDepth;

uniform sampler2D u_sDepthBuffer;	// Only used w/ transluscent render
uniform int u_iRenderMode;	// 0 = depth, 1 = opaque, 2 = transluscent

void main() {
	
	float fFog = 1.0 - v_fDepth;
	if (u_iRenderMode == 0) // Depth
		gl_FragColor = vec4(v_fDepth, 0, 0, 1);
	else if (u_iRenderMode == 1) // Opaque
		gl_FragColor = vec4(1.0 * fFog, 1.0 * fFog, 1.0 * fFog, 1.0);
	else{ // Transluscent
		// Note: 512 is the size of our 'window'
		float fDepth = texture2D(u_sDepthBuffer, gl_FragCoord.xy / 512.0).r;
		if (fDepth <= v_fDepth)
			discard;
		
		gl_FragColor = vec4(0.25 * fFog, 0.25 * fFog, 1.0 * fFog, 0.5);
	}
}