extends Node2D

func _ready():
	RenderingServer.set_default_clear_color(Color(0.08, 0.08, 0.14))

	var ui = CanvasLayer.new()
	add_child(ui)

	var title = Label.new()
	title.text = "INVERSION"
	title.position = Vector2(500, 250)
	title.add_theme_font_size_override("font_size", 48)
	ui.add_child(title)

	var subtitle = Label.new()
	subtitle.text = "A gravity-flip platformer"
	subtitle.position = Vector2(500, 320)
	ui.add_child(subtitle)

	var start = Label.new()
	start.text = "Press SPACE to start"
	start.position = Vector2(500, 400)
	ui.add_child(start)

	var controls = Label.new()
	controls.text = "A/D move   SPACE jump   SHIFT flip gravity"
	controls.position = Vector2(500, 450)
	ui.add_child(controls)

func _process(_delta):
	if Input.is_action_just_pressed("jump"):
		get_tree().change_scene_to_file("res://Main.tscn")
