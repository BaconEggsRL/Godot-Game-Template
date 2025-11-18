shader_type canvas_item;

uniform sampler2D dissolve_texture;
uniform float dissolve_value : hint_range(0.0, 1.0);

// how many times the dissolve texture repeats across the sprite
uniform vec2 dissolve_tiling = vec2(1.0, 1.0);

void fragment() {
    vec2 tiled_uv = fract(UV * dissolve_tiling);

    vec4 main_texture = texture(TEXTURE, UV);
    vec4 noise_texture = texture(dissolve_texture, tiled_uv);

    main_texture.a *= floor(dissolve_value + min(1.0, noise_texture.r));
    COLOR = main_texture;
}


//shader_type canvas_item;
//
//uniform sampler2D dissolve_texture;
//uniform float dissolve_value : hint_range(0,1);
//
//void fragment(){
    //vec4 main_texture = texture(TEXTURE, UV);
    //vec4 noise_texture = texture(dissolve_texture, UV);
    //main_texture.a *= floor(dissolve_value + min(1, noise_texture.x));
    //COLOR = main_texture;
//}