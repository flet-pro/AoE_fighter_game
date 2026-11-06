extends SceneTree

# Dependency-free Godot 3.6 integration checks for the animation-only preview.
const ANIMATIONS = ["idle", "step_walk", "straight_punch", "dodge", "knockdown"]
const COUNTS = [8, 8, 8, 5, 5]
const SPEEDS = [8.0, 12.0, 16.0, 18.0, 10.0]

var failures: Array = []
var checks: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var version: Dictionary = Engine.get_version_info()
	_expect(version.major == 3 and version.minor == 6 and version.patch == 3,
		"The project is tested with Godot 3.6.3")
	var file := File.new()
	if not file.file_exists("res://scenes/AnimationPreview.tscn"):
		_expect(false, "AnimationPreview.tscn exists")
		_finish()
		return
	var packed_scene = load("res://scenes/AnimationPreview.tscn")
	if not packed_scene is PackedScene:
		_expect(false, "Animation preview loads as a PackedScene")
		_finish()
		return
	var preview = packed_scene.instance()
	get_root().add_child(preview)
	yield(self, "idle_frame")
	if not preview.has_method("select_animation"):
		_expect(false, "Preview exposes animation selection")
		preview.queue_free()
		_finish()
		return

	var black = preview.get_node("Stage/BlackFighter/AnimatedSprite")
	var red = preview.get_node("Stage/RedFighter/AnimatedSprite")
	_check_resources(black.frames, "black")
	_check_resources(red.frames, "red")
	_expect(black.frames != red.frames, "Each color uses a separate frame resource")
	_expect(preview.selected_animation == "idle", "The preview starts on idle")
	_expect(red.flip_h and not black.flip_h, "Fighters initially face each other")
	_expect(int(ProjectSettings.get_setting("display/window/size/width")) == 1024,
		"Base window width is 1024")
	_expect(int(ProjectSettings.get_setting("display/window/size/height")) == 600,
		"Base window height is 600")
	_expect(ProjectSettings.get_setting("rendering/quality/driver/driver_name") == "GLES2",
		"The project uses GLES2")

	for animation in ANIMATIONS:
		_expect(preview.select_animation(animation), "Can select " + animation)
		_expect(black.animation == animation and red.animation == animation,
			"Selection reaches both fighters: " + animation)
		_expect(black.frame == 0 and red.frame == 0,
			"Selection restarts both fighters: " + animation)
	_expect(not preview.select_animation("not_an_animation"),
		"Unknown animations are rejected")
	_expect(preview.selected_animation == "knockdown",
		"An invalid selection preserves the previous animation")

	preview.select_animation("step_walk")
	yield(create_timer(0.22), "timeout")
	_expect(black.frame > 0 and red.frame > 0, "Looping animation advances")
	var pause_button = preview.get_node("Controls/PauseButton")
	pause_button.emit_signal("pressed")
	var paused_frame: int = black.frame
	yield(create_timer(0.18), "timeout")
	_expect(preview.is_paused and not black.playing and not red.playing,
		"Pause stops both players")
	_expect(black.frame == paused_frame, "A paused animation holds its frame")
	preview.get_node("Controls/ReplayButton").emit_signal("pressed")
	_expect(black.frame == 0 and red.frame == 0, "Replay resets both frames")
	_expect(preview.is_paused and not black.playing,
		"Replay preserves the paused state")
	pause_button.emit_signal("pressed")
	yield(create_timer(0.18), "timeout")
	_expect(not preview.is_paused and black.frame > 0, "Resume advances again")

	var selector = preview.get_node("Controls/AnimationSelector")
	selector.emit_signal("item_selected", 3)
	_expect(black.animation == "dodge" and red.animation == "dodge",
		"The dropdown selects both animations")
	yield(create_timer(0.45), "timeout")
	_expect(black.frame == 4 and red.frame == 4,
		"A one-shot animation holds its final pose")
	preview.get_node("Controls/FaceEachOther").pressed = false
	_expect(not red.flip_h, "The facing checkbox can disable red mirroring")
	preview.get_node("Controls/FaceEachOther").pressed = true
	_expect(red.flip_h, "The facing checkbox can restore red mirroring")
	_expect("5 frames" in preview.get_node("Details").text,
		"The details label describes the selected animation")

	preview.queue_free()
	yield(self, "idle_frame")
	_finish()


func _check_resources(frames: SpriteFrames, color: String) -> void:
	_expect(frames.get_animation_names().size() == ANIMATIONS.size(),
		color + " has exactly the five starter animations")
	for index in range(ANIMATIONS.size()):
		var animation: String = ANIMATIONS[index]
		_expect(frames.has_animation(animation), color + " contains " + animation)
		if not frames.has_animation(animation):
			continue
		_expect(frames.get_frame_count(animation) == COUNTS[index],
			color + " frame count: " + animation)
		_expect(is_equal_approx(frames.get_animation_speed(animation), SPEEDS[index]),
			color + " speed: " + animation)
		_expect(frames.get_animation_loop(animation) == (index < 2),
			color + " loop setting: " + animation)
		for frame_index in range(frames.get_frame_count(animation)):
			var texture: Texture = frames.get_frame(animation, frame_index)
			_expect(texture != null, color + " frame exists: " + animation)
			if texture == null:
				continue
			_expect(texture.get_width() == 256 and texture.get_height() == 208,
				color + " frame keeps the source canvas")
			var expected_path := "res://assets/characters/%s/%s/%02d.png" % [
				color, animation, frame_index]
			_expect(texture.resource_path == expected_path,
				color + " frames remain in numeric order: " + animation)


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		printerr("FAIL: " + message)


func _finish() -> void:
	if failures.empty():
		print("PASS: %d animation preview checks." % checks)
		quit(0)
	else:
		printerr("FAILED: %d of %d checks." % [failures.size(), checks])
		quit(1)
