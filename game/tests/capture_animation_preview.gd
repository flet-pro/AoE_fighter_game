extends SceneTree

# Render the real preview into a workspace-local image for visual inspection.
func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var packed_scene: PackedScene = load("res://scenes/AnimationPreview.tscn")
	var preview = packed_scene.instance()
	get_root().add_child(preview)
	yield(create_timer(0.15), "timeout")
	yield(VisualServer, "frame_post_draw")
	var image: Image = get_root().get_texture().get_data()
	if image.empty():
		printerr("FAIL: the preview did not produce a rendered image")
		quit(1)
		return
	image.flip_y()
	var directory := Directory.new()
	var output_directory := ProjectSettings.globalize_path("res://../.tools")
	var error: int = directory.make_dir_recursive(output_directory)
	if error != OK:
		printerr("FAIL: cannot create the local screenshot directory")
		quit(1)
		return
	var output := output_directory.plus_file("animation-preview.png")
	error = image.save_png(output)
	if error != OK:
		printerr("FAIL: cannot save the preview screenshot")
		quit(1)
		return
	print("PASS: rendered %dx%d preview to %s" % [
		image.get_width(), image.get_height(), output])
	preview.queue_free()
	yield(self, "idle_frame")
	quit(0)
