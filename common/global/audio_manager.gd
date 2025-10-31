extends Node

@export var MUSIC_PLAYER:AudioStreamPlayer
var ambient_players := {}
var active_fx_players: Dictionary = {}  # Store FX players with names

# set up audio bus names as follows:
# Master, music, ambient, sfx


# music
# list of all music
const MUSIC_1 = preload("uid://b2j225xmqrrkd")

# ambient
# list of all ambient sounds

# fx
# list of all sound effects



# sound load test
var fx_path = "res://assets/sounds/fx/"
var sounds: Dictionary[String, AudioStream] = {}  # key: name of sound, value: AudioStream
var active_sounds: Dictionary[String, Array] = {}  # key: name of sound, value: array of stream ids
var polyphonic_player: AudioStreamPlayer




func _ready() -> void:
	# sound test
	AudioManager.play_music("music_1", 0.0, 0.5)
	
	# polyphonic player
	polyphonic_player = AudioStreamPlayer.new()
	polyphonic_player.bus = "SFX"  # Ensure this matches an existing audio bus
	polyphonic_player.max_polyphony = 128  # arbitrary, default is 1--max number of fx that can play at the same time
	add_child(polyphonic_player)
	
	# Load sounds
	load_sounds()
	# print(sounds)
	
	
	#############################################
	# Test sounds
	#play_sound("yeow-103553.mp3", 0.0, 0.8)  # Lower volume, higher pitch
	#play_sound("yay-6326.mp3", -5.0, 0.8)  # Normal volume, lower pitch
	#play_sound("yeow-103553.mp3", 0.0, 0.8)  # Lower volume, higher pitch
	#play_sound("yay-6326.mp3", -5.0, 0.8)  # Normal volume, lower pitch
	
	# stop_sound("yay-6326.mp3")
	
	# How to play a random sound
	#var fx = ["yeow-103553.mp3", "yay-6326.mp3"].pick_random()
	#print(fx)
	#play_sound(fx)
	
	# How to play a sound with random pitch variation
	#var diff = 0.2
	#var pitch = randf_range(1.0 - diff, 1.0 + diff)
	#play_sound("yeow-103553.mp3", 0.0, pitch)
	
	pass


#func load_sounds() -> void:
	#var dir: DirAccess = DirAccess.open(fx_path)
	#if dir:
		#dir.list_dir_begin()
		#var file_name: String = dir.get_next()
		## var extensions: Array = [".ogg", ".wav", ".mp3", ".import"]  # Only load sound files
		#
		#while file_name != "":
			#if !dir.current_is_dir(): # and extensions.any(func(ending): return file_name.ends_with(ending)):
				#if (file_name.get_extension() == "import"):
					#file_name = file_name.replace('.import', '')
				#var file_path: String = fx_path + file_name
				#var sound: Resource = ResourceLoader.load(file_path)  # Use ResourceLoader for safety
				#if sound:
					#sounds[file_name] = sound
				#else:
					#print("Warning: Failed to load sound file - " + file_path)
			#file_name = dir.get_next()
		#
		#dir.list_dir_end()  # Properly close the directory access
	#else:
		#print("Failed to open directory: " + fx_path)



func get_features_list() -> Array[Dictionary]:
	var FEATURE_TAGS:Array[Dictionary] = [
		{"name": "android", "desc": "Running on Android (but not within a Web browser)"},
		{"name": "bsd", "desc": "Running on *BSD (but not within a Web browser)"},
		{"name": "linux", "desc": "Running on Linux (but not within a Web browser)"},
		{"name": "macos", "desc": "Running on macOS (but not within a Web browser)"},
		{"name": "ios", "desc": "Running on iOS (but not within a Web browser)"},
		{"name": "visionos", "desc": "Running on visionOS (but not within a Web browser)"},
		{"name": "windows", "desc": "Running on Windows"},
		{"name": "linuxbsd", "desc": "Running on Linux or *BSD"},
		{"name": "debug", "desc": "Running on a debug build (including the editor)"},
		{"name": "release", "desc": "Running on a release build"},
		{"name": "editor", "desc": "Running on an editor build"},
		{"name": "editor_hint", "desc": "Running on an editor build, and inside the editor"},
		{"name": "editor_runtime", "desc": "Running on an editor build, and running the project"},
		{"name": "template", "desc": "Running on a non-editor (export template) build"},
		{"name": "double", "desc": "Running on a double-precision build"},
		{"name": "single", "desc": "Running on a single-precision build"},
		{"name": "64", "desc": "Running on a 64-bit build (any architecture)"},
		{"name": "32", "desc": "Running on a 32-bit build (any architecture)"},
		{"name": "x86_64", "desc": "Running on a 64-bit x86 build"},
		{"name": "x86_32", "desc": "Running on a 32-bit x86 build"},
		{"name": "x86", "desc": "Running on an x86 build (any bitness)"},
		{"name": "arm64", "desc": "Running on a 64-bit ARM build"},
		{"name": "arm32", "desc": "Running on a 32-bit ARM build"},
		{"name": "arm", "desc": "Running on an ARM build (any bitness)"},
		{"name": "rv64", "desc": "Running on a 64-bit RISC-V build"},
		{"name": "riscv", "desc": "Running on a RISC-V build (any bitness)"},
		{"name": "ppc64", "desc": "Running on a 64-bit PowerPC build"},
		{"name": "ppc32", "desc": "Running on a 32-bit PowerPC build"},
		{"name": "ppc", "desc": "Running on a PowerPC build (any bitness)"},
		{"name": "wasm64", "desc": "Running on a 64-bit WebAssembly build (not yet possible)"},
		{"name": "wasm32", "desc": "Running on a 32-bit WebAssembly build"},
		{"name": "wasm", "desc": "Running on a WebAssembly build (any bitness)"},
		{"name": "mobile", "desc": "Host OS is a mobile platform"},
		{"name": "pc", "desc": "Host OS is a PC platform (desktop/laptop)"},
		{"name": "web", "desc": "Host OS is a Web browser"},
		{"name": "nothreads", "desc": "Running without threading support"},
		{"name": "threads", "desc": "Running with threading support"},
		{"name": "web_android", "desc": "Host OS is a Web browser running on Android"},
		{"name": "web_ios", "desc": "Host OS is a Web browser running on iOS"},
		{"name": "web_linuxbsd", "desc": "Host OS is a Web browser running on Linux or *BSD"},
		{"name": "web_macos", "desc": "Host OS is a Web browser running on macOS"},
		{"name": "web_windows", "desc": "Host OS is a Web browser running on Windows"},
		{"name": "etc", "desc": "Textures using ETC1 compression are supported"},
		{"name": "etc2", "desc": "Textures using ETC2 compression are supported"},
		{"name": "s3tc", "desc": "Textures using S3TC (DXT/BC) compression are supported"},
		{"name": "movie", "desc": "Movie Maker mode is active"},
		{"name": "shader_baker", "desc": "Project was exported with shader baking enabled (only applies to the exported project, not when running in the editor)"},
		{"name": "dedicated_server", "desc": "Project was exported as a dedicated server (only applies to the exported project, not when running in the editor)"}
	]
	
	# Add has_feature to each entry
	for f in FEATURE_TAGS:
		f["has_feature"] = OS.has_feature(f["name"])

	return FEATURE_TAGS


func print_features(only_true := true, include_desc := true) -> void:
	print("====================================================")
	print("OS.has_feature():")
	print("====================================================")
	var features = get_features_list()
	for f in features:
		if only_true and not f["has_feature"]:
			continue
		if include_desc:
			print("[%s] %s: %s" % [f["has_feature"], f["name"], f["desc"]])
		else:
			print(f["name"])
	print("====================================================")
	print()


func load_sounds() -> void:
	# print_features()
	
	# Accept common audio formats (ignore .import in editor)
	var extensions:Array[String]
	if OS.has_feature("editor"):
		extensions = ["ogg", "wav", "mp3"]
	else:
		extensions = ["import"]

	sounds.clear()
	_load_sounds_recursive("res://", extensions)
	print("Loaded %d sounds from project" % sounds.size())
	print(sounds)


func _load_sounds_recursive(path:String, extensions:Array[String]) -> void:
	print("Scanning:", path)
	var dir := DirAccess.open(path)
	if dir == null:
		push_warning("Failed to open directory: " + path)
		return

	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name == "":
			break
		if file_name.begins_with("."):
			continue

		var full_path := path + file_name
		

		if dir.current_is_dir():
			# Recurse into subfolders
			_load_sounds_recursive(full_path + "/", extensions)
		else:
			var ext := file_name.get_extension().to_lower()
			if ext in extensions:
				var stream := ResourceLoader.load(full_path)
				if stream:
					# sounds[file_name] = stream
					var base_name := file_name.get_basename().get_file()  # removes extension
					sounds[base_name] = stream
				else:
					push_warning("Could not load sound: " + full_path)
	dir.list_dir_end()






func play_sound(sound_name:String, volume:float=0.0, pitch:float=1.0, layer:bool=true, bus="SFX") -> void:
	var offset = 0.0  # starting time/point of sound
	# var bus = "SFX"  # sound bus
	var playback_type:AudioServer.PlaybackType
	
	if OS.has_feature("web"):
		# print("running in web, use stream")
		playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	else:
		playback_type = AudioServer.PLAYBACK_TYPE_DEFAULT
			
	if sound_name in sounds:
		# Ensure the player has an active (default) stream
		if polyphonic_player.stream == null:
			polyphonic_player.stream = AudioStreamPolyphonic.new()
			polyphonic_player.play()
		
		var playback = polyphonic_player.get_stream_playback() as AudioStreamPlaybackPolyphonic
		if playback:
			
			var stream_ids:Array = []
			
			if active_sounds.has(sound_name):
				stream_ids = active_sounds[sound_name]
				# print("Stream IDs = ", stream_ids)
				for id in stream_ids:
					if not playback.is_stream_playing(id):
						stream_ids.erase(id)
					else:
						if layer==false:
							# stop_sound(sound_name)
							playback.stop_stream(id)
							stream_ids.erase(sound_name)
				
			var stream_id = playback.play_stream(sounds[sound_name], offset, volume, pitch, playback_type, bus)
			stream_ids.append(stream_id)
			
			active_sounds[sound_name] = stream_ids
			# print("playing '%s', id = %s" % [sound_name, stream_id])

		else:
			print("Error: Failed to retrieve AudioStreamPlaybackPolyphonic")
	else:
		print("Sound not found:", sound_name)


# stop sound fx
func stop_sound(sound_name:String, fade_time:float=0.5) -> void:

	if sound_name in sounds:
		# Ensure the player has an active (default) stream
		if polyphonic_player.stream == null:
			polyphonic_player.stream = AudioStreamPolyphonic.new()
			polyphonic_player.play()
		
		var playback = polyphonic_player.get_stream_playback() as AudioStreamPlaybackPolyphonic
		if playback:
			if active_sounds.has(sound_name):
				var stream_ids:Array = active_sounds[sound_name]
				# print("Stream IDs = ", stream_ids)
				for id in stream_ids:
					if playback.is_stream_playing(id):
						_tween_sound_volume(playback, id, -12.0, -80.0, fade_time)
						# playback.stop_stream(id)
				active_sounds.erase(sound_name)
		else:
			print("Error: Failed to retrieve AudioStreamPlaybackPolyphonic")
	else:
		print("Sound not found:", sound_name)



func stop_all_sounds(fade_time: float = 0.5) -> void:
	if polyphonic_player.stream == null:
		return
	
	var playback = polyphonic_player.get_stream_playback() as AudioStreamPlaybackPolyphonic
	if playback == null:
		print("Error: Failed to retrieve AudioStreamPlaybackPolyphonic")
		return

	for sound_name in active_sounds.keys():
		var stream_ids: Array = active_sounds[sound_name]
		for id in stream_ids:
			if playback.is_stream_playing(id):
				_tween_sound_volume(playback, id, -12.0, -80.0, fade_time)

	active_sounds.clear()





# stop sound fx
func tween_sound(sound_name:String, target:float = -80.0, fade_time:float=0.5) -> void:

	if sound_name in sounds:
		# Ensure the player has an active (default) stream
		if polyphonic_player.stream == null:
			polyphonic_player.stream = AudioStreamPolyphonic.new()
			polyphonic_player.play()
		
		var playback = polyphonic_player.get_stream_playback() as AudioStreamPlaybackPolyphonic
		if playback:
			if active_sounds.has(sound_name):
				var stream_ids:Array = active_sounds[sound_name]
				# print("Stream IDs = ", stream_ids)
				for id in stream_ids:
					if playback.is_stream_playing(id):
						_tween_sound_volume(playback, id, -12.0, target, fade_time)
						# playback.stop_stream(id)
				active_sounds.erase(sound_name)
		else:
			print("Error: Failed to retrieve AudioStreamPlaybackPolyphonic")
	else:
		print("Sound not found:", sound_name)
		
		
		

func _tween_sound_volume(_playback:AudioStreamPlaybackPolyphonic, _id:int, start_volume:float, end_volume:float, duration:float) -> void:
	var tween = create_tween()
	var callable := func(volume):
		_update_sound_volume(volume, _playback, _id)

	tween.tween_method(callable, start_volume, end_volume, duration)
	tween.finished.connect(func():
		_playback.stop_stream(_id)
	)

func _update_sound_volume(_volume:float, _playback:AudioStreamPlaybackPolyphonic, _id:int) -> void:
	_playback.set_stream_volume(_id, _volume)
	


#func tween_font_size(start_size: int, end_size: int, duration: float):
	#var tween = get_tree().create_tween()
	#tween.tween_method(update_font_size, start_size, end_size, duration)
	#tween.finished.connect(func():
		#tween_font_size(end_size, start_size, grow_duration)
	#)
#
#func update_font_size(size: int):
	#growing.add_theme_font_size_override("normal_font_size", size)
	
#######################################################################################







func play_ambient(ambient_name: String, fade_in_time: float = 2.0, final_db: float = -6.0) -> void:
	if ambient_name in ambient_players:
		# push_warning("Ambient sound '%s' is already playing" % ambient_name)
		return

	var ambient_stream: AudioStream
	match ambient_name:
		"ambient_1":
			ambient_stream = null  # insert ambient const here
		_:
			push_warning("'%s' has no resource listed in AudioManager" % ambient_name)
			return

	if ambient_stream:
		
		var ambient_player := AudioStreamPlayer.new()
		ambient_player.stream = ambient_stream
		ambient_player.bus = "Ambient"  # Make sure you have an "Ambient" bus in the audio settings
		ambient_player.volume_db = -80.0  # Start silent
		# ambient_player.loop = true  # Ensure looping
		add_child(ambient_player)
		ambient_player.play()

		# Store the player reference
		ambient_players[ambient_name] = ambient_player

		# Fade-in effect
		var tween = get_tree().create_tween()
		tween.tween_property(ambient_player, "volume_db", final_db, fade_in_time)


func stop_ambient(ambient_name: String, fade_out_time: float = 2.0) -> void:
	if ambient_name not in ambient_players:
		push_warning("Ambient sound '%s' is not currently playing" % ambient_name)
		return

	var ambient_player = ambient_players[ambient_name]
	var tween = get_tree().create_tween()
	tween.tween_property(ambient_player, "volume_db", -80.0, fade_out_time)
	await tween.finished

	# Remove player from dictionary and free it
	ambient_players.erase(ambient_name)
	ambient_player.queue_free()
	
	
func stop_music(fade_out_time=0.5, music_player:=MUSIC_PLAYER) -> void:
	var tween_out = get_tree().create_tween()
	tween_out.tween_property(music_player, "volume_db", -80.0, fade_out_time)
	await tween_out.finished
	# Ensure music stops and resets
	music_player.stop()
	music_player.stream = null  # Reset to ensure _play_music() reloads it
		
		
func _play_music(
	music:AudioStream, 
	final_db:=0.0, 
	fade_out:bool=true, 
	fade_out_time:float=0.5,
	fade_in:bool=true,
	fade_in_time:float=0.5,
	init:bool=false,
	init_db:float = -80.0,
	music_player:=MUSIC_PLAYER) -> void:

	# If the music is currently being played already, do nothing
	if music_player.stream == music:
		return
	
	
	# don't fade out prev track if there's no stream
	if !music_player.stream:
		fade_out = false

	
	# check if should fade audio in/out
	if fade_out:
		var tween_out = get_tree().create_tween()
		tween_out.tween_property(music_player, "volume_db", -80.0, fade_out_time)
		await tween_out.finished
	
	else:
		
		# check if we need to initialize the volume
		if init:
			music_player.volume_db = init_db
		
		if fade_in:
			# audio_player.stop()
			music_player.stream = music
			music_player.play()
			
			var tween_in = get_tree().create_tween()
			tween_in.set_ease(Tween.EASE_OUT)
			tween_in.set_trans(Tween.TRANS_CUBIC)
			tween_in.tween_property(music_player, "volume_db", final_db, fade_in_time)
			await tween_in.finished
		
		else:
			
			# audio_player.stop()
			music_player.stream = music
			music_player.volume_db = final_db
			music_player.bus = "Music"
			music_player.play()


# Play music for scene
func play_music(scene_name:String, final_db:float=0.0, fade_in_time=0.5) -> void:
	var music:Resource
	var fade_out:bool = true
	var fade_out_time = 0.5
	var fade_in:bool = true
	var init:bool = false
	var init_db:float = -80.0
	match scene_name:
		"music_1":
			music = MUSIC_1  # insert music const here
		_:
			push_warning("'%s' has no resource listed in AudioManager" % scene_name)
	
	if music:
		_play_music(music, final_db, fade_out, fade_out_time, fade_in, fade_in_time, init, init_db)


func play_fx(fx_name:String, volume:float=0.0, _index:int=-1) -> void:
	var fx:Resource
	var pitch:float = 1.0
	match fx_name:
		"scene_transition":
			fx = null  # for any time scene changes
		"pitch_var_1":
			fx = null  # insert fx const here
			var diff = 0.2
			pitch = randf_range(1.0 - diff, 1.0 + diff)
		"random_1":
			fx = [].pick_random()  # can pick random from array of sounds
		_:
			push_warning("'%s' has no resource listed in AudioManager" % fx_name)
	
	if fx:
		_play_fx(fx_name, fx, volume, pitch)
	
	
	
	
func _play_fx(fx_name: String, stream: AudioStream, volume: float = 0.0, pitch: float = 1.0) -> void:
	var fx_player = AudioStreamPlayer.new()
	fx_player.stream = stream
	fx_player.name = "FX_PLAYER_" + fx_name  # Name it uniquely
	fx_player.volume_db = volume
	fx_player.pitch_scale = pitch
	fx_player.bus = "SFX"
	
	add_child(fx_player)
	
	if not active_fx_players.has(fx_name):
		active_fx_players[fx_name] = []
	
	active_fx_players[fx_name].append(fx_player)  # Track this FX under its name
	
	if fx_player != null:
		fx_player.play()
		await fx_player.finished
		
		if active_fx_players.has(fx_name):
			active_fx_players[fx_name].erase(fx_player)  # Remove from tracking
			fx_player.queue_free()


func stop_fx(fx_name: String, fade_time: float = 0.5) -> void:
	if active_fx_players.has(fx_name):
		for fx_player in active_fx_players[fx_name]:
			if is_instance_valid(fx_player):  # Ensure it's still valid
				var tween = get_tree().create_tween()
				tween.tween_property(fx_player, "volume_db", -80.0, fade_time)  # Fade out
				await tween.finished
				if fx_player != null:
					fx_player.stop()
					fx_player.queue_free()
		
		active_fx_players.erase(fx_name)  # Remove all instances of that FX


func clear(fade_time:float = 2.0) -> void:
	# stop music
	stop_music(fade_time)
	# clear fx
	if active_fx_players:
		var fx_players = active_fx_players.keys()
		for fx_player in fx_players:
			if active_fx_players.has(fx_player):  # Ensure key still exists
				stop_fx(fx_player, fade_time)
		
		
