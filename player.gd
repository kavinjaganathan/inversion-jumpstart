extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -420.0
const GRAVITY = 1200.0

var gravity_dir = 1
var was_on_floor = true

func _physics_process(delta):
	velocity.y += gravity_dir * GRAVITY * delta

	if Input.is_action_just_pressed("flip_gravity"):
		gravity_dir *= -1
		up_direction = Vector2(0, -gravity_dir)
		$Sprite.scale.y = -$Sprite.scale.y
		velocity.y = 0

	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY * gravity_dir

	move_and_slide()
	
	if not was_on_floor and is_on_floor():
		$Sprite.scale = Vector2(1.3, 0.7) # land squash
	elif was_on_floor and not is_on_floor() and velocity.y * gravity_dir < 0:
		$Sprite.scale = Vector2(0.7, 1.3) # jump stretch
	else:
		$Sprite.scale = $Sprite.scale.lerp(Vector2(1, 1) * sign($Sprite.scale.y), 10 * delta)
	was_on_floor = is_on_floor()
