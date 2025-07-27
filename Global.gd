extends Node

var level = 0
var necter = 0
var necter_max = 100
var points = 0
var points_max = 300

var settings_hex_mosaic = true
var settings_hex_acute = false
var settings_bee_spectrum = false

var bee_position : Vector3

var levels : Array = [
	preload("res://world.tscn")
	]
