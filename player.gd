extends CharacterBody3D

@export var speed := 4.5
@export var acceleration := 10.0
@export var friction := 8.0
@export var gravity := 20.0
@export var jump_velocity := 5.0
@export var mouse_sensitivity := 0.0015
@export var bob_speed := 7.0
@export var bob_amount := 0.05

var y_velocity := 0.0
var current_velocity := Vector3.ZERO
var camera: Camera3D
var bob_timer := 0.0
var original_cam_position := Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera = $Camera3D
	original_cam_position = camera.transform.origin

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)

func _physics_process(delta):
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("ui_up"):
		input_dir.z -= 1
	if Input.is_action_pressed("ui_down"):
		input_dir.z += 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1

	input_dir = input_dir.normalized()

	# الجاذبية
	if not is_on_floor():
		y_velocity -= gravity * delta
	else:
		if Input.is_action_just_pressed("ui_accept"):
			y_velocity = jump_velocity

	# حساب الاتجاه
	var target_velocity = (transform.basis * input_dir).normalized() * speed

	# تسارع وتباطؤ
	current_velocity.x = move_toward(current_velocity.x, target_velocity.x, acceleration * delta)
	current_velocity.z = move_toward(current_velocity.z, target_velocity.z, acceleration * delta)

	if input_dir == Vector3.ZERO:
		current_velocity.x = move_toward(current_velocity.x, 0, friction * delta)
		current_velocity.z = move_toward(current_velocity.z, 0, friction * delta)

	current_velocity.y = y_velocity
	velocity = current_velocity
	move_and_slide()

	# اهتزاز الرأس
	if input_dir.length() > 0.1 and is_on_floor():
		bob_timer += delta * bob_speed
		camera.transform.origin.y = original_cam_position.y + sin(bob_timer) * bob_amount
	else:
		bob_timer = 0.0
		camera.transform.origin.y = original_cam_position.y
