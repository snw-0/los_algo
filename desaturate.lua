vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec4 pixel = Texel(texture, texture_coords) * color;//This is the current pixel color
  	number luma = dot(vec3(0.299f, 0.587f, 0.114f), pixel.rgb);
  	pixel.r = luma;
  	pixel.g = luma;
  	pixel.b = luma;
  	return pixel;
}
