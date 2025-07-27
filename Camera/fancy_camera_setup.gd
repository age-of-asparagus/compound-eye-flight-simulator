extends Node

@export var attach_camera_to : Node3D
@export var Minimap : Node3D
@export_range(20,150) var field_of_view = 150
@onready var camera: Camera3D = $SubViewport/Camera3D
@onready var sub_viewport: SubViewport = $SubViewport
@onready var texture_rect: TextureRect = $TextureRect

func _ready() -> void:
	#var viewport_texture := ViewportTexture.new()
	#viewport_texture.viewport_path = sub_viewport.get_path()
	#texture_rect.texture = viewport_texture
	texture_rect.texture = sub_viewport.get_texture()
	camera.fov = field_of_view
	
	#print("Acute", Global.settings_hex_acute, "Hex", Global.settings_hex_mosaic)
	
	texture_rect.material.set_shader_parameter("hex_view", Global.settings_hex_mosaic)
	if Global.settings_hex_acute:
		texture_rect.material.set_shader_parameter("hex_inner_radius", 0.2)
		
	texture_rect.material.set_shader_parameter("spectrum_bee", Global.settings_bee_spectrum )
	
func _process(delta: float) -> void:
	if attach_camera_to:
		camera.global_position = attach_camera_to.global_position
		camera.global_basis = attach_camera_to.global_basis
	
