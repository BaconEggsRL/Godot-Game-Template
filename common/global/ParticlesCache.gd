extends CanvasLayer


const WIND_PARTICLE = preload("uid://dvca1wuimr3ov")

# Particle materials to preload
var particle_materials := [
	WIND_PARTICLE,
]

# Dummy texture to use when preloading particles
const ICON = preload("uid://ctfl5lq83mmic")

var materials := [
]



var frames = 0
var loaded = false

var load_time:float = 2.0


func _ready() -> void:
	self.show()
	
	for mat in particle_materials:
		var instance = GPUParticles2D.new()
		instance.process_material = mat
		instance.one_shot = true
		instance.emitting = true
		self.add_child(instance)
		get_tree().create_timer(load_time).timeout.connect(func():
			instance.queue_free.call_deferred()
		)
		
	for mat in materials:
		var instance = Sprite2D.new()
		instance.texture = ICON
		instance.material = mat
		instance.modulate.a = 0.0
		self.add_child(instance)
		get_tree().create_timer(load_time).timeout.connect(func():
			instance.queue_free.call_deferred()
		)
		
	pass


func _physics_process(_delta:float) -> void:
	if frames >= 3:
		set_physics_process(false)
		loaded = true
		self.hide()
	frames += 1
