shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    vec4 light_color = texture(TEXTURE, UV);

    // Limit the brightness of the light (or apply a custom blending rule)
    light_color.rgb = min(light_color.rgb, vec3(0.2));  // Clamp the brightness

    COLOR = light_color;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
