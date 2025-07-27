extends Control
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

@onready var hexellate_vision_check_buttons: CheckButton = $MarginContainer/HBoxContainer/VBoxContainer2/PanelContainer/VBoxContainer/HexellateVisionCheckButtons
@onready var acute_vision_check_button: CheckButton = $MarginContainer/HBoxContainer/VBoxContainer2/PanelContainer/VBoxContainer/AcuteVisionCheckButton
@onready var bee_spectrums_vision_check_button: CheckButton = $MarginContainer/HBoxContainer/VBoxContainer2/PanelContainer/VBoxContainer/BeeSpectrumsVisionCheckButton


func _ready() -> void:
	hexellate_vision_check_buttons.button_pressed = Global.settings_hex_mosaic
	acute_vision_check_button.button_pressed = Global.settings_hex_acute
	bee_spectrums_vision_check_button.button_pressed = Global.settings_bee_spectrum

func _on_hexellate_vision_check_buttons_toggled(toggled_on: bool) -> void:
	Global.settings_hex_mosaic = toggled_on
	audio.play()

func _on_acute_vision_check_button_toggled(toggled_on: bool) -> void:
	Global.settings_hex_acute = toggled_on
	audio.play()

func _on_bee_spectrums_vision_check_button_toggled(toggled_on: bool) -> void:
	Global.settings_bee_spectrum = toggled_on
	audio.play()
