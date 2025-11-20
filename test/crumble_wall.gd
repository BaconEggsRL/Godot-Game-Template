@tool
class_name CrumbleWall
extends StaticBody2D

enum WallType { DARK, LIGHT }

@export var wall_type: WallType = WallType.DARK:
	set(value):
		wall_type = value
		if sprite:
			_apply_wall_visuals()


const CRUMBLE_WALL_MAT = preload("uid://d08bybqiu7vrn")

@onready var sprite: Sprite2D = $sprite
var mat: ShaderMaterial


# --------------------------
# SHARED WALL VISUAL LOGIC
# --------------------------

func _apply_wall_visuals() -> void:
	var color: Color = Color.BLACK if wall_type == WallType.DARK else Color.WHITE

	mat = CRUMBLE_WALL_MAT.duplicate(true)
	sprite.material = mat

	if mat is ShaderMaterial:
		mat.set_shader_parameter("dissolve_value", 1.0)
		mat.set_shader_parameter("sprite_modulate", color)



# --------------------------
# HEALTH + HEAT SYSTEM
# --------------------------

const max_hp := 25.0
@export var hp: float = max_hp: set = set_hp

var heat := 0.0
var heat_max := 50.0
var heat_accel := 20.0
var heat_decay := 5.0
var melt_threshold := 0.5

var time_since_damage := 0.0
@onready var damage_audio: AudioStreamPlayer2D = $damage_audio
var max_vol := 18.0
var min_vol := 0.0
var target_volume_db := min_vol
var volume_smooth_speed := 10.0


func set_hp(value: float) -> void:
	var last_hp = hp
	hp = max(value, 0.0)

	if hp < last_hp:  # took damage
		if not damage_audio.playing:
			damage_audio.playing = true
		time_since_damage = 0.0

	update_decay(hp / max_hp)

	if hp <= 0.0:
		AudioManager.play_sound("light_crack", 0.0, 1.0, true)
		queue_free()


func _ready() -> void:
	if damage_audio:
		damage_audio.volume_db = max_vol

	if sprite:
		_apply_wall_visuals()


func update_decay(decay_ratio: float) -> void:
	if mat is ShaderMaterial:
		mat.set_shader_parameter("dissolve_value", decay_ratio)


func _process(delta: float) -> void:
	time_since_damage += delta
	apply_heat_behavior(delta)

	# volume smoothing
	damage_audio.volume_db = lerp(damage_audio.volume_db, target_volume_db, volume_smooth_speed * delta)

	if time_since_damage > 0.1:
		target_volume_db = lerp(target_volume_db, min_vol, heat_decay * delta)
		if target_volume_db < min_vol + 0.1:
			damage_audio.stop()


func apply_heat_behavior(delta: float) -> void:
	if hp <= 0.0:
		return

	heat = max(0.0, heat - heat_decay * delta)

	if hp / max_hp < melt_threshold:
		heat = min(heat_max, heat + heat_accel * 2.0 * delta)

	var heat_damage_rate = pow(heat / heat_max, 2.0) * 12.0

	if heat_damage_rate > 0.01:
		set_hp(hp - heat_damage_rate * delta)


func take_light_damage(beam_dps: float, delta: float) -> void:
	if wall_type == WallType.DARK:
		# Normal (light hurts)
		heat = min(heat_max, heat + heat_accel * delta)
		set_hp(hp - beam_dps * delta)

	else:
		# LIGHT WALL: Light heals instead of hurts
		heat = max(0.0, heat - heat_decay * delta)  # cool down
		set_hp(hp + beam_dps * 0.6 * delta)  # heal (slightly slower than damage)

	# Update audio intensity
	target_volume_db = lerp(min_vol, max_vol, clamp(beam_dps / 20.0, 0.0, 1.0))
