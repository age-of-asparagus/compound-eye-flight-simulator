extends Camera3D

@export var move_speed := 10.0
@export var mouse_sensitivity := 0.002

var rotation_x := 0.0  # Pitch (up/down)
var rotation_y := 0.0  # Yaw (left/right)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_y -= event.relative.x * mouse_sensitivity
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, deg_to_rad(-89), deg_to_rad(89))
		rotation = Vector3(rotation_x, rotation_y, 0)

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("Move_down"):
		direction -= transform.basis.z
	if Input.is_action_pressed("Move_up"):
		direction += transform.basis.z
	if Input.is_action_pressed("Move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("Move_right"):
		direction += transform.basis.x
	if Input.is_action_pressed("Move_forward"):
		direction += transform.basis.y
	if Input.is_action_pressed("Move_back"):
		direction -= transform.basis.y

	# Apply movement
	if direction != Vector3.ZERO:
		global_translate(direction.normalized() * move_speed * delta)
