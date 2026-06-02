shader_type canvas_item;
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float max_val = max(max(c.r, c.g), c.b);
	float min_val = min(min(c.r, c.g), c.b);
	float saturation = max_val - min_val;
	
	float alpha = 1.0;
	if (max_val < 0.22 && saturation < 0.12) {
		alpha = 0.0;
	} else if (max_val < 0.35 && saturation < 0.2) {
		alpha = smoothstep(0.18, 0.35, max_val);
	}
	
	// Circular mask to cut hard rectangular borders entirely
	float dist = distance(UV, vec2(0.5, 0.5));
	alpha *= smoothstep(0.65, 0.50, dist); 
	
	COLOR = vec4(c.rgb, c.a * alpha);
}
