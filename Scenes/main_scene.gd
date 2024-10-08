extends Node2D


var fullscreen := false:
	set(value):
		match value:
			true: get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
			_: get_window().mode = Window.MODE_WINDOWED
		fullscreen = value


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_F11 and event.is_pressed():
		fullscreen = not fullscreen
