extends CharacterBody3D
@onready var audio_buzz: AudioStreamPlayer = $AudioStreamPlayer

@export var boost_acceleration : float
@export var forward_acceleration : float
@export var drag_coefficient : float
@export var turn_speed : float
@export var smooth_time : float
@export var roll_smooth_time : float
@export var max_roll : float


@onready var vertical_rotation = rotation.x
@onready var horizontal_rotation = rotation.y
@onready var roll_rotation = rotation.z

@onready var target_vertical_rotation = rotation.x
@onready var target_horizontal_rotation = rotation.y
@onready var target_roll_rotation = rotation.z

func _physics_process(delta):
	
	Global.bee_position = global_position
	
	apply_rotation(delta)
	
	apply_boost(delta)
	
	apply_air_resistance(delta)
	
	move_and_slide()
	
	audio_buzz.pitch_scale = 0.9 + velocity.length()/5


func apply_rotation(delta : float):
	target_vertical_rotation += get_input_vertical_rotation() * turn_speed * delta
	target_horizontal_rotation += get_input_horizontal_rotation() * turn_speed * delta
	target_roll_rotation = get_input_horizontal_rotation() * max_roll * delta
	
	vertical_rotation = lerp_angle(vertical_rotation, target_vertical_rotation, smooth_time * delta)
	horizontal_rotation = lerp_angle(horizontal_rotation, target_horizontal_rotation, smooth_time * delta)
	roll_rotation = lerp_angle(roll_rotation, target_roll_rotation, roll_smooth_time * delta)
	
	
	rotation = Vector3(vertical_rotation, horizontal_rotation, roll_rotation)

func apply_boost(delta : float):
	if Input.is_action_pressed("Boost"):
		velocity += -basis.z * boost_acceleration * delta
	else:
		velocity += -basis.z * forward_acceleration * delta

func apply_air_resistance(delta : float):
	velocity -= velocity.normalized() * velocity.length_squared() * drag_coefficient * delta

func get_input_vertical_rotation():
	var input_vertical_rotation = Input.get_axis("Move_down", "Move_up")
	return input_vertical_rotation

func get_input_horizontal_rotation():
	var input_horizontal_rotation = Input.get_axis("Move_right", "Move_left")
	return input_horizontal_rotation

func die():
	Global.necter = 0
	Global.points = 0
	
	get_tree().change_scene_to_file("res://Menus/game_over_menu.tscn")
	#var level = Global.levels[Global.level]
	#get_tree().change_scene_to_packed(level)

func _on_crash_detector_body_entered(body):
	die()


func _on_flower_detector_area_entered(area):
	if Global.necter < Global.necter_max:
		var flower : Flower = area.get_parent()
		flower.used_up()
		Global.necter += 25


func _on_hive_detector_area_entered(area: Area3D) -> void:
	Global.points += Global.necter
	Global.necter = 0
	
	if Global.points >= Global.points_max:
		get_tree().change_scene_to_file("res://Menus/win_menu.tscn")
