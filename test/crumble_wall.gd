class_name CrumbleWall
extends StaticBody2D

@onready var sprite: Sprite2D = $sprite
@onready var mat: ShaderMaterial = sprite.material

const max_hp := 25.0
@export var hp: float = max_hp: set = set_hp

# NEW
var heat := 0.0
var heat_max := 50.0    # how much heat builds up total
var heat_accel := 20.0  # how fast light heats the wall
var heat_decay := 5.0   # how fast it cools when out of light
var melt_threshold := 0.5 # if wall HP < 20% → auto melt

func set_hp(value: float) -> void:
	hp = max(value, 0.0)
	update_decay(max(0.0, hp / max_hp))
	if hp <= 0.0:
		queue_free()

func _ready() -> void:
	if mat is ShaderMaterial:
		mat.set_shader_parameter("dissolve_value", 1.0)

func update_decay(decay_ratio:float) -> void:
	if mat is ShaderMaterial:
		mat.set_shader_parameter("dissolve_value", decay_ratio)

func _process(delta: float) -> void:
	apply_heat_behavior(delta)

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
