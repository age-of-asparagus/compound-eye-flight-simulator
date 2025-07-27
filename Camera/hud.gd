extends CanvasLayer
@export var necter_progress_bar : TextureProgressBar
@export var hive_progress_bar : TextureProgressBar

func _ready() -> void:
	necter_progress_bar.max_value = Global.necter_max
	hive_progress_bar.max_value = Global.points_max

func _process(delta: float) -> void:
	necter_progress_bar.value = Global.necter
	hive_progress_bar.value = Global.points


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
