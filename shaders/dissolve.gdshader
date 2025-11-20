shader_type canvas_item;

uniform sampler2D dissolve_texture;
uniform float dissolve_value : hint_range(0.0, 1.0);
uniform vec2 dissolve_tiling = vec2(1.0, 1.0);

uniform vec4 sprite_modulate : source_color; // shows a color picker

void fragment() {
    vec2 tiled_uv = fract(UV * dissolve_tiling);

    vec4 main_texture = texture(TEXTURE, UV);
    vec4 noise_texture = texture(dissolve_texture, tiled_uv);

    // dissolve logic
    main_texture.a *= floor(dissolve_value + min(1.0, noise_texture.r));

    // multiply by modulate color from inspector
    COLOR = main_texture * sprite_modulate;
}
