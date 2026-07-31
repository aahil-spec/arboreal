shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_disabled, diffuse_burley, specular_schlick_ggx;

// --- RIVER COLORS ---
uniform vec3 shallow_color : source_color = vec3(0.1, 0.6, 0.5);
uniform vec3 deep_color : source_color = vec3(0.0, 0.2, 0.3);
uniform vec3 foam_color : source_color = vec3(1.0, 1.0, 1.0);

// --- DEPTH & FOAM ---
uniform float depth_distance : hint_range(0.0, 20.0, 0.1) = 4.0;
uniform float foam_distance : hint_range(0.0, 2.0, 0.1) = 0.4;

// --- STREAMS & FLOW ---
uniform vec2 flow_direction = vec2(0.0, 1.0); // Direction of the river
uniform float flow_speed = 3.0;               // How fast the water rushes
uniform vec2 stream_stretch = vec2(1.0, 6.0); // STRETCHES the water to look like currents!
uniform float wave_scale = 3.0;               // Size of the streams
uniform float wave_height = 0.15;             // Height of the physical ripples

// --- TEXTURES ---
uniform sampler2D river_texture_1; 
uniform sampler2D river_texture_2; 

// --- REFRACTION ---
uniform float refraction_strength : hint_range(0.0, 0.1, 0.001) = 0.015;

// Godot 4 Screen & Depth reading
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void vertex() {
	// 1. Stretch the UVs to create long, rushing streams
	vec2 stretched_uv = UV * wave_scale * stream_stretch;
	vec2 flow_time = flow_direction * TIME * flow_speed;
	
	// 2. Add organic weaving (makes the currents warp side-to-side)
	float distortion = texture(river_texture_1, UV * 2.0 + flow_time * 0.1).r * 0.5;

	// 3. Calculate two layers of streams crashing at different speeds
	float h1 = texture(river_texture_1, stretched_uv + flow_time + distortion).r;
	float h2 = texture(river_texture_2, stretched_uv + flow_time * 1.3 - distortion).r; 
	
	VERTEX.y += (h1 + h2) * wave_height;
}

void fragment() {
	// Repeat the stretch and distortion for the visual pixels
	vec2 stretched_uv = UV * wave_scale * stream_stretch;
	vec2 flow_time = flow_direction * TIME * flow_speed;
	float distortion = texture(river_texture_1, UV * 2.0 + flow_time * 0.1).r * 0.5;
	
	// Two layers of normal maps weaving into each other
	vec3 normal1 = texture(river_texture_1, stretched_uv + flow_time + distortion).rgb;
	vec3 normal2 = texture(river_texture_2, stretched_uv + flow_time * 1.3 - distortion).rgb;
	vec3 blended_normal = mix(normal1, normal2, 0.5);

	// Depth Calculation
	float depth_raw = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV, depth_raw) * 2.0 - 1.0;
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	float surface_depth = -VERTEX.z;
	float depth_diff = max(0.0, linear_depth - surface_depth);

	// Color Blending
	float depth_blend = clamp(depth_diff / depth_distance, 0.0, 1.0);
	vec3 base_color = mix(shallow_color, deep_color, depth_blend);

	// Stream Foam (Stretches the foam into long, rushing streaks!)
	float foam_blend = clamp(depth_diff / foam_distance, 0.0, 1.0);
	float foam_noise = texture(river_texture_1, stretched_uv * 1.5 + flow_time).r;
	float foam_threshold = step(foam_blend, 0.1 + foam_noise * 0.4);

	// Refraction
	vec2 ref_ofs = blended_normal.xy * refraction_strength * depth_blend;
	vec3 ref_color = texture(SCREEN_TEXTURE, SCREEN_UV + ref_ofs).rgb;

	// Final Mix
	vec3 final_color = mix(ref_color * base_color, base_color, 0.7); 
	final_color = mix(final_color, foam_color, foam_threshold);

	ALBEDO = final_color;
	NORMAL_MAP = blended_normal;
	ROUGHNESS = 0.15; // Slightly rougher so the streams catch the sunlight better
	METALLIC = 0.8;
}