extends Node2D

var moving_platforms = []
var current_level = 1
var elapsed_time = 0.0
var timer_running = true
var lives = 3
var max_lives = 3


func _ready():
	RenderingServer.set_default_clear_color(Color(0.08, 0.08, 0.14))
	build_background()
	build_level()
	build_ui()

func _process(delta):
	if timer_running:
		elapsed_time += delta
	if has_node("UI/CoinLabel"):
		$UI/CoinLabel.text = "Coins: %d/%d   Time: %.1fs" % [Game.coins, Game.total_coins, elapsed_time]
	if Input.is_key_pressed(KEY_R) and Input.is_key_pressed(KEY_SHIFT):
		get_tree().reload_current_scene()
	if $Player.global_position.y > 1000 or $Player.global_position.y < -1000:
		lose_life()
		
func _physics_process(_delta):
	var t = Time.get_ticks_msec() / 1000.0
	for body in moving_platforms:
		var start = body.get_meta("start_pos")
		var dir = body.get_meta("move_dir")
		var dist = body.get_meta("move_dist")
		var speed = body.get_meta("move_speed")
		body.position = start + dir * sin(t * speed) * dist

func build_level():
	if current_level == 1:
		build_level_1()
	elif current_level == 2:
		build_level_2()
	else:
		build_level_3()

func build_level_1():
	var platforms = [
		[0, 400, 900, 40],
		[500, -100, 300, 40],
		[1300, -150, 300, 40],
	]
	for p in platforms:
		add_platform(p[0], p[1], p[2], p[3])
	add_platform(1000, 250, 300, 40, Vector2(1, 0), 150, 1.0)

	var coins = [
		Vector2(200, 360), Vector2(600, 360), Vector2(1100, 210),
		Vector2(600, -140), Vector2(1400, -190)
	]
	for c in coins:
		add_coin(c)

	var spikes = [Vector2(750, 370), Vector2(1150, 220)]
	for s in spikes:
		add_spike(s)

	add_goal(Vector2(1450, -250))
	$Player.position = Vector2(50, 350)

func build_level_2():
	var platforms = [
		[0, 400, 300, 40],
		[600, 350, 200, 40],
		[1100, -50, 200, 40],
		[1600, 300, 200, 40],
	]
	for p in platforms:
		add_platform(p[0], p[1], p[2], p[3])
	add_platform(400, 100, 150, 30, Vector2(0, 1), 120, 1.4)   # vertical mover
	add_platform(900, 200, 150, 30, Vector2(1, 0), 200, 0.8)   # horizontal mover
	add_platform(1400, -150, 200, 40, Vector2(0, 1), 100, 1.2)

	var coins = [
		Vector2(150, 360), Vector2(650, 310), Vector2(1150, -90),
		Vector2(1450, -190), Vector2(1650, 260)
	]
	for c in coins:
		add_coin(c)

	var spikes = [Vector2(500, 400), Vector2(1000, 400), Vector2(1350, 300)]
	for s in spikes:
		add_spike(s)

	add_goal(Vector2(1750, 220))
	$Player.position = Vector2(50, 350)

func build_level_3():
	add_platform(0, 400, 300, 40)
	add_platform(500, -300, 300, 40)   # ceiling only — must flip to reach
	add_platform(1000, 400, 300, 40)   # back to floor
	add_platform(1500, -300, 300, 40)  # ceiling again
	add_platform(2000, 400, 400, 40)   # final floor stretch
	add_platform(750, 50, 150, 30, Vector2(0, 1), 200, 1.0) # vertical mover in the void gap

	var coins = [Vector2(650, -340), Vector2(1150, 360), Vector2(1650, -340), Vector2(2100, 360)]
	for c in coins:
		add_coin(c)

	var spikes = [Vector2(300, 400), Vector2(1300, -300)]
	for s in spikes:
		add_spike(s)

	add_goal(Vector2(2300, 320))
	$Player.position = Vector2(50, 350)

func add_platform(x, y, w, h, move_dir = Vector2.ZERO, move_dist = 0, move_speed = 1.0):
	var body = StaticBody2D.new()
	body.position = Vector2(x, y)
	if move_dir != Vector2.ZERO:
		body.set_meta("start_pos", Vector2(x, y))
		body.set_meta("move_dir", move_dir)
		body.set_meta("move_dist", move_dist)
		body.set_meta("move_speed", move_speed)
	var rect = ColorRect.new()
	rect.size = Vector2(w, h)
	rect.color = Color(0.5, 0.5, 0.5)
	body.add_child(rect)
	var shape = CollisionShape2D.new()
	var rs = RectangleShape2D.new()
	rs.size = Vector2(w, h)
	shape.shape = rs
	shape.position = Vector2(w / 2, h / 2)
	body.add_child(shape)
	add_child(body)
	if move_dir != Vector2.ZERO:
		moving_platforms.append(body)

func add_coin(pos):
	var area = Area2D.new()
	area.position = pos
	var rect = ColorRect.new()
	rect.size = Vector2(20, 20)
	rect.color = Color(1, 0.9, 0.2)
	area.add_child(rect)
	var shape = CollisionShape2D.new()
	var cs = RectangleShape2D.new()
	cs.size = Vector2(20, 20)
	shape.shape = cs
	shape.position = Vector2(10, 10)
	area.add_child(shape)
	area.body_entered.connect(func(body):
		if body.name == "CharacterBody2D":
			Game.coins += 1
			spawn_burst(area.global_position, Color(1, 0.9, 0.2))
			area.queue_free()
	)
	add_child(area)

func add_spike(pos):
	var area = Area2D.new()
	area.position = pos
	var rect = ColorRect.new()
	rect.size = Vector2(30, 30)
	rect.color = Color(0.9, 0.1, 0.1)
	area.add_child(rect)
	var shape = CollisionShape2D.new()
	var cs = RectangleShape2D.new()
	cs.size = Vector2(30, 30)
	shape.shape = cs
	shape.position = Vector2(15, 15)
	area.add_child(shape)
	area.body_entered.connect(func(body):
		if body.name == "CharacterBody2D":
			spawn_burst(body.global_position, Color(0.9, 0.1, 0.1))
			Game.coins = 0
			get_tree().reload_current_scene()
	)
	add_child(area)

func add_goal(pos):
	var area = Area2D.new()
	area.position = pos
	var rect = ColorRect.new()
	rect.size = Vector2(40, 60)
	rect.color = Color(0.2, 0.9, 0.3)
	area.add_child(rect)
	var shape = CollisionShape2D.new()
	var cs = RectangleShape2D.new()
	cs.size = Vector2(40, 60)
	shape.shape = cs
	shape.position = Vector2(20, 30)
	area.add_child(shape)
	area.body_entered.connect(func(body):
		if body.name == "CharacterBody2D":
			if Game.coins < Game.total_coins:
				$UI/WinLabel.text = "Need all coins! (%d/%d)" % [Game.coins, Game.total_coins]
				get_tree().create_timer(1.2).timeout.connect(func():
					if is_instance_valid(self):
						$UI/WinLabel.text = ""
				)
			elif current_level < 3:
				current_level += 1
				reload_level()
			else:
				timer_running = false
				$UI/WinLabel.text = "You escaped! Time: %.1fs\nPress SHIFT+R to play again" % elapsed_time
	)
	add_child(area)

func reload_level():
	Game.coins = 0
	for child in get_children():
		if child.name != "Player" and child.name != "UI":
			child.queue_free()
	moving_platforms.clear()
	build_background()
	build_level()

func build_ui():
	var ui = CanvasLayer.new()
	ui.name = "UI"
	add_child(ui)

	var coin_label = Label.new()
	coin_label.name = "CoinLabel"
	coin_label.position = Vector2(20, 20)
	ui.add_child(coin_label)
	if has_node("UI/LifeLabel"):
		$UI/LifeLabel.text = "Lives: " + "❤️".repeat(Game.lives)
	
	var life_label = Label.new()
	life_label.name = "LifeLabel"
	life_label.position = Vector2(20, 50)
	ui.add_child(life_label)

	var win_label = Label.new()
	win_label.name = "WinLabel"
	win_label.position = Vector2(400, 300)
	win_label.add_theme_font_size_override("font_size", 32)
	ui.add_child(win_label)

func build_background():
	var parallax = ParallaxBackground.new()
	add_child(parallax)
	move_child(parallax, 0)

	var layer1 = ParallaxLayer.new()
	layer1.motion_scale = Vector2(0.3, 0.3)
	parallax.add_child(layer1)
	for i in range(6):
		var r = ColorRect.new()
		r.size = Vector2(120, 400)
		r.position = Vector2(i * 400, -200)
		r.color = Color(0.15, 0.12, 0.25)
		layer1.add_child(r)

	var layer2 = ParallaxLayer.new()
	layer2.motion_scale = Vector2(0.6, 0.6)
	parallax.add_child(layer2)
	for i in range(6):
		var r = ColorRect.new()
		r.size = Vector2(60, 250)
		r.position = Vector2(i * 350 + 150, -100)
		r.color = Color(0.22, 0.18, 0.35)
		layer2.add_child(r)

func spawn_burst(pos, color):
	var p = CPUParticles2D.new()
	p.position = pos
	p.emitting = true
	p.one_shot = true
	p.amount = 12
	p.lifetime = 0.5
	p.explosiveness = 1.0
	p.direction = Vector2.UP
	p.spread = 180
	p.initial_velocity_min = 80
	p.initial_velocity_max = 150
	p.gravity = Vector2(0, 300)
	p.scale_amount_min = 3
	p.scale_amount_max = 3
	p.color = color
	add_child(p)
	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(func():
		if is_instance_valid(p):
			p.queue_free()
	)
	
func lose_life():
	Game.lives -= 1
	if Game.lives <= 0:
		Game.lives = Game.max_lives
		Game.coins = 0
		current_level = 1
	get_tree().reload_current_scene()
