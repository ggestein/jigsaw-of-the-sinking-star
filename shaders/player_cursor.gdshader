shader_type spatial;
render_mode blend_mix, cull_back;

uniform vec3 emission_color = vec3(-1.0, 2.0, -1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	EMISSION = emission_color;
	float dist = sqrt(pow(UV.x - 0.5, 2) + pow(UV.y - 0.5, 2));
	float angle = atan(UV.y - 0.5, UV.x - 0.5);
	ALPHA = step(0.0, sin((angle + TIME * 0.5) * 6.0)) * step(dist, 0.25) * (1.0 - step(dist, 0.23));
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
