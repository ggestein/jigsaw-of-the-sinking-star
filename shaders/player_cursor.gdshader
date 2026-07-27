shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back;

uniform vec3 emission_color = vec3(-1.0, 2.0, -1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	EMISSION = emission_color;
	float dist = sqrt(pow(UV.x - 0.5, 2) + pow(UV.y - 0.5, 2));
	ALPHA = step(dist, 0.15) * (1.0 - step(dist, 0.13));
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
