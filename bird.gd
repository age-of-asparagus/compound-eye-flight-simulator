extends Node3D

var test = preload("res://bird_flight_debugger.tscn")

@onready var bee_attacker = $bee_attacker
@onready var point_picker = $point_picker
@onready var bee_detector = $bee_detector
@onready var bird_model = $bird_model
@onready var animation_player = $bird_model/AnimationPlayer
@onready var audio_stream_player_3d = $AudioStreamPlayer3D

@export var attack_speed : float

var rng = RandomNumberGenerator.new()

@onready var starting_position = global_position

var previous_circling_point : Vector3
@onready var circling_point = global_position

@export var circling_radius : float
var circling_speed : float
@export var movement_speed = 10.0
var facing_angle
var angle : float = 0.0
var angle_direction = 1

var max_tilt = rad_to_deg(30)
var target_tilt = 0.0
var tilt_angle = 0.0
var tilt_speed = 5.0
var return_tilt_speed = 3.0

var audio_played = false

var direction : Vector3
var velocity : Vector3
var target_position : Vector3

var bee : Node3D

enum STATE {
	ENTERING_ORBIT,
	ORBITING,
	LEAVING_ORBIT,
	ATTACKING,
	FLYING_BACK
}

var current_state = STATE.LEAVING_ORBIT

func _ready():
	circling_speed = movement_speed/circling_radius
	pick_new_circling_point()
	rng.randomize()
	

func _physics_process(delta):

	#var TEST = test.instantiate()
	#get_parent().add_child(TEST)
	#TEST.global_position = global_position
	
	
	if (bee_detected() and current_state != STATE.FLYING_BACK) or current_state == STATE.ATTACKING:
		

		
		current_state = STATE.ATTACKING
		print(current_state)
		attack_bee(delta)
	else:
		print(current_state)
		move_naturally(delta)
	

func attack_bee(delta):
	
	var bee_direction = (Global.bee_position - global_position).normalized()
	var displacement_to_bee = (Global.bee_position - global_position).length()
	bee_attacker.target_position = bee_direction * (displacement_to_bee+15)
	
	print(bee_attacker.get_collider())
	if (bee_attacker.get_collider() == null or "boost_acceleration" in bee_attacker.get_collider().get_parent()) and Global.bee_position.y > 5:


		if not audio_played and not bee_attacker.get_collider() == null:
			audio_played = true
			audio_stream_player_3d.play()
		
		animation_player.play("flapping")
		var target_direction = bee_direction
		
		direction = lerp(direction, target_direction, 3 * delta)
		global_position += direction * attack_speed * delta
		
		
		bird_model.look_at(global_position-bee_direction)
		
		
		
	else:
		bee_attacker.target_position = Vector3.ZERO
		audio_played = false
		circling_point = starting_position
		current_state = STATE.FLYING_BACK

func move_naturally(delta):
	
	match current_state:
		
		STATE.FLYING_BACK:
			animation_player.play("flapping")
			var target_direction = (Vector3(circling_point.x, circling_point.y, circling_point.z+circling_radius) - global_position).normalized()
			direction = lerp(direction, target_direction, 3 * delta)
			global_position += direction * movement_speed * delta
			
			if (global_position - Vector3(circling_point.x, circling_point.y, circling_point.z+circling_radius)).length() < movement_speed * delta:
				global_position = circling_point
				pick_new_circling_point()
				angle = 0.0
				current_state = STATE.LEAVING_ORBIT
			
		
		STATE.ENTERING_ORBIT:
			animation_player.play("flapping")
			var direction_to_target = (target_position - global_position).normalized()
			velocity = direction_to_target * movement_speed * delta
			direction = direction_to_target
			global_position += velocity
			var scale = bird_model.transform.basis.get_scale()
			var new_basis = Basis(Vector3.UP, facing_angle).scaled(scale)
			
			bird_model.basis = new_basis
			
			max_tilt = 0
			
			if global_position.distance_to(target_position) < movement_speed * delta:
				global_position = target_position
				point_picker.start(rng.randf_range(5,15))
				current_state = STATE.ORBITING
		
		STATE.ORBITING:
			animation_player.play("gliding")
			angle += angle_direction * circling_speed * delta
			angle = fmod(angle, TAU)
			var next_xz_position = Vector2(circling_point.x +sin(angle) * circling_radius, circling_point.z +cos(angle) * circling_radius)
			direction = (Vector3(next_xz_position.x, starting_position.y, next_xz_position.y) - global_position).normalized()
			global_position = Vector3(next_xz_position.x, starting_position.y, next_xz_position.y)
			
			max_tilt = deg_to_rad(90/(circling_radius/5))
			
		STATE.LEAVING_ORBIT:
			
			animation_player.play("gliding")
			angle += angle_direction * circling_speed * delta
			angle = fmod(angle, TAU)
			
			var next_xz_position = Vector2(previous_circling_point.x +sin(angle) * circling_radius, previous_circling_point.z +cos(angle) * circling_radius)
			direction = (Vector3(next_xz_position.x, starting_position.y, next_xz_position.y) - global_position).normalized()
			global_position = Vector3(next_xz_position.x, starting_position.y, next_xz_position.y)
			
			max_tilt = deg_to_rad(90/(circling_radius/5))
			
			if get_tangent_line_target(delta) != target_position:
				current_state = STATE.ENTERING_ORBIT
				target_position = get_tangent_line_target(delta, true)
	
	
	facing_angle = atan2(direction.x, direction.z)
	var scale = bird_model.transform.basis.get_scale()
	var new_basis = Basis(Vector3.UP, facing_angle).scaled(scale)
	bird_model.basis = new_basis
	
	target_tilt = float(angle_direction * max_tilt * -1)
	tilt_angle = lerp(tilt_angle, target_tilt, tilt_speed * delta)
	bird_model.rotation.z = tilt_angle




func get_tangent_line_target(delta , check_angle = false):
	var tangent_direction_2D = Vector2(global_position.x - previous_circling_point.x, global_position.z- previous_circling_point.z).orthogonal().normalized()
	var tangent_direction = Vector3(tangent_direction_2D.x, 0, tangent_direction_2D.y)
	var rel = circling_point - global_position
	var proj = rel.dot(tangent_direction)
	var closest = global_position + tangent_direction * proj
	var dist = (circling_point - closest).length()
	if abs(dist - circling_radius) < movement_speed * delta and direction.dot((circling_point-global_position).normalized()) > 0.1:
		var dir = circling_point - previous_circling_point
		var dir_a = (global_position - previous_circling_point).normalized()
		var dir_b = (closest - circling_point).normalized()
		var cross = dir.cross(dir_a) * dir.cross(dir_b)
		if cross.y < 0: 
			if check_angle:
				angle += TAU/2
				angle_direction *= -1
		return closest
	else:
		return target_position


func bee_detected():
	var bee_detected = not bee_detector.get_overlapping_areas().is_empty()
	return bee_detected

func pick_new_circling_point():
	previous_circling_point = circling_point
	circling_point = Vector3(starting_position.x + rng.randf_range(-30,30), starting_position.y, starting_position.z + rng.randf_range(-30,30))
	current_state = STATE.LEAVING_ORBIT


func _on_point_picker_timeout():
	pick_new_circling_point()


func _on_bee_killer_area_entered(area):
	area.get_parent().die()
