shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform vec4 water_color:source_color=vec4(0.05,0.3,0.5,0.85);
uniform vec4 deep_color:source_color=vec4(0.02,0.1,0.25,1.0);
uniform float wave_height:hint_range(0.0,2.0)=0.3;
uniform float wave_speed:hint_range(0.0,5.0)=1.2;
uniform float wave_scale:hint_range(0.1,10.0)=2.0;
uniform float transparency:hint_range(0.0, 1.0)=0.85;

void vertex(){
	float time =TIME*wave_speed;
	float wave=sin(VERTEX.x*wave_scale+time)*cos(VERTEX.z*wave_scale*0.7+time*0.8);
	VERTEX.y+=wave*wave_height;
	NORMAL=normalize(vec3(
		-cos(VERTEX.x*wave_scale+time)*wave_height*wave_scale,
		1.0,
		sin(VERTEX.z*wave_scale*0.7+time*0.8)*wave_height*wave_scale*0.7
	));
}

void fragment(){
	float depth_factor=clamp(VERTEX.y*0.5+0.5,0.0,1.0);
	ALBEDO=mix(deep_color.rgb,water_color.rgb,depth_factor);
	ALPHA=transparency;
	ROUGHNESS=0.05;
	METALLIC=0.1;
	SPECULAR=0.9;
}