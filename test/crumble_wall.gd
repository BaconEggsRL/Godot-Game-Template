class_name CrumbleWall
extends StaticBody2D


const CRUMBLE_WALL_MAT = preload("uid://d08bybqiu7vrn")

@onready var sprite: Sprite2D = $sprite
var mat: ShaderMaterial


const max_hp := 25.0
@export var hp: float = max_hp: set = set_hp

# NEW
var heat := 0.0
var heat_max := 50.0    # how much heat builds up total
var heat_accel := 20.0  # how fast light heats the wall
var heat_decay := 5.0   # how fast it cools when out of light
var melt_threshold := 0.5 # if wall HP < 20% → auto melt

var time_since_damage := 0.0
@onready var damage_audio: AudioStreamPlayer2D = $damage_audio
var max_vol := 18.0
var min_vol := 0.0
var target_volume_db := min_vol  # the desired volume each frame
var volume_smooth_speed := 10.0  # how fast volume interpolates (dB per second)


func set_hp(value: float) -> void:
	var last_hp = hp
	hp = max(value, 0.0)
	
	if hp < last_hp:  # took damage
		if damage_audio.playing == false:
			damage_audio.playing = true
		time_since_damage = 0.0   # reset timer when damaged
		
	update_decay(hp/max_hp)
	
	# Destroy wall
	if hp <= 0.0:
		AudioManager.play_sound("light_crack", 0.0, 1.0, true)
		queue_free()
		
		
		
func _ready() -> void:
	damage_audio.volume_db = max_vol
	mat = CRUMBLE_WALL_MAT.duplicate(true)
	sprite.material = mat
	if mat is ShaderMaterial:
		mat.set_shader_parameter("dissolve_value", 1.0)

func update_decay(decay_ratio:float) -> void:
	if mat is ShaderMaterial:
		mat.set_shader_parameter("dissolve_value", decay_ratio)

func _process(delta: float) -> void:
	time_since_damage += delta
	apply_heat_behavior(delta)
	
	# Smoothly interpolate volume toward target_volume_db
	damage_audio.volume_db = lerp(damage_audio.volume_db, target_volume_db, volume_smooth_speed * delta)
	
	# Gradually decay target volume when no new damage
	if time_since_damage > 0.1:  # small buffer to avoid instant decay
		target_volume_db = lerp(target_volume_db, min_vol, heat_decay * delta)
		if target_volume_db < min_vol + 0.1:
			damage_audio.stop()
		
		

func apply_heat_behavior(delta: float) -> void:
	if hp <= 0.0:
		return
		
	# normal cooling
	heat = max(0.0, heat - heat_decay * delta)

	# runaway melt when weak
	if hp / max_hp < melt_threshold:
		# accelerate heat buildup (no direct hp manipulation)
		heat = min(heat_max, heat + heat_accel * 2.0 * delta)

	# heat causes nonlinear melting
	var heat_damage_rate = pow(heat / heat_max, 2.0) * 12.0

	if heat_damage_rate > 0.01:
		set_hp(hp - heat_damage_rate * delta)


func take_light_damage(beam_dps:float, delta:float) -> void:
	# heat buildup
	heat = min(heat_max, heat + heat_accel * delta)

	# direct immediate damage
	set_hp(hp - beam_dps * delta)
	
	# set target volume based on damage intensity
	target_volume_db = lerp(min_vol, max_vol, clamp(beam_dps / 20.0, 0.0, 1.0))  # normalize damage intensity
