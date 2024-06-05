shader_type canvas_item;
uniform float amt:hint_range(0.0, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (distance(UV, vec2(0.5,0.5)) > amt/2.0) 
	{
		COLOR = vec4(0.0);
	}
	else 
	{
		COLOR = texture(TEXTURE,UV);
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
