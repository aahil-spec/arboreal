shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, unshaded;

uniform vec4 color_inner: source_color=vec4(0.8,0.2,1.0,1.0);
uniform vec4 color_outer: source_color=vec4(0.1,0.0,0.4,1.0);
uniform float spin_speed:hint_range(0.5,10.0)=3.0;
uniform float ring_count: hint_range(1.0,8.0)=4.0;

void fragment(){
	vec2 uv =UV*2.0-1.0;
	float dist=length(uv);
	float angle=atan(uv.y,uv.x);
	float spin=angle+TIME*spin_speed;
	float rings=abs(sin(dist*ring_count*3.141159-TIME*spin_speed));
	float swirl=abs(sin(spin*3.0+dist*5.0));
	float mask=1.0-smoothstep(0.85,1.0,dist);
	vec3 color=mix(color_inner.rgb,color_outer.rgb,dist);
	color=mix(color,vec3(1.0),swirl*3.0*mask);
	color+=rings*0.2*mask;
	ALBEDO=color*mask;
	ALPHA=mask*0.92;
	
}