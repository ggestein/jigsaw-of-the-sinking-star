shader_type spatial;
render_mode blend_mix, cull_back;

uniform vec3 line_color = vec3(0.0, 0.0, 0.0);
uniform float line_width = 0.02;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float half_line_width = line_width * 0.5;
	float x = world_pos.x;
	float z = world_pos.z;
	float fx = x - floor(x);
	float fz = z - floor(z);
	float rx0 = step(1.0 - half_line_width, fx);
	float rx1 = 1.0 - step(half_line_width, fx);
	float rz0 = step(1.0 - half_line_width, fz);
	float rz1 = 1.0 - step(half_line_width, fz);
	float rx = 1.0 - (1.0 - rx0) * (1.0 - rx1);
	float rz = 1.0 - (1.0 - rz0) * (1.0 - rz1);
	ALPHA = 1.0 - (1.0 - rx) * (1.0 - rz);
	ALBEDO = line_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
