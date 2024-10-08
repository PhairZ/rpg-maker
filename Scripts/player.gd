@tool
class_name RPGController
extends Node2D

@export_range(0.1, 10, 0.1, "or_greater") var base_speed := 1.0:
	set(value):
		if value > sprint_speed:
			sprint_speed = value
		base_speed = value
@export_range(0.1, 10, 0.1, "or_greater") var sprint_speed := 2.0:
	set(value):
		if base_speed > value:
			base_speed = value
		sprint_speed = value

@export_group("Animation", "animation")
@export var animation_based_on_velocity: = true
@export var animation_sprite_frames: SpriteFrames:
	set(value):
		animation_sprite_frames = value
		if not is_node_ready():
			await ready
		sprite.sprite_frames = animation_sprite_frames

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast: RayCast2D = $RayCast2D

const GRID  := 16
const BUFFER_TIME := 8

var curr_anim := 0
var target_pos: Vector2
var move_buffer_x := 0
var move_buffer_y := 0
var move_buffer_x_time := 0
var move_buffer_y_time := 0


func _ready() -> void:
	global_position = round(global_position/16)*16
	target_pos = global_position


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_R:
		get_tree().reload_current_scene()


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	var move_x := sign(Input.get_axis("Left", "Right"))
	var move_y := sign(Input.get_axis("Up", "Down"))
	
	if move_buffer_y:
		if move_buffer_y_time == 0:
			move_buffer_y = 0
		else :
			move_buffer_y_time -= 1
	
	if move_y and not is_curr_pos_valid(true, false) and not move_x:
		move_buffer_y = move_y
		move_buffer_y_time = BUFFER_TIME
	
	if is_curr_pos_valid():
		if move_buffer_y:
			target_pos = (global_position/GRID + Vector2(0, move_buffer_y)) * GRID
			move_buffer_y = 0
			move_buffer_y_time = 0
		elif move_x:
			target_pos = (global_position/GRID + Vector2(move_x, 0)) * GRID
		elif move_y:
			target_pos = (global_position/GRID + Vector2(0, move_y)) * GRID
	
	var dir = target_pos - global_position
	validate_move()
	
	var prev_pos = global_position
	var speed = base_speed
	if Input.is_action_pressed("Sprint"):
		speed = sprint_speed
	global_position = round(position.move_toward(target_pos, speed))
	var vel = global_position - prev_pos
	
	update_anim(dir, vel)


func is_curr_pos_valid(x:= true, y:= true) -> bool:
	var ret = true
	if x:
		ret =  roundi(global_position.x) % GRID == 0
	if y:
		ret = ret and roundi(global_position.y) % GRID == 0
	return ret


func validate_move() -> void:
	ray_cast.target_position = target_pos - global_position
	if is_curr_pos_valid():
		ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		target_pos = position


func update_anim(dir: Vector2, velocity: Vector2) -> void:
	if dir.x:
		sprite.flip_h = dir.x < 0
		curr_anim = 4
	elif dir.y:
		sprite.flip_h = false
		curr_anim = 5 if dir.y < 0 else 3
	if not velocity and curr_anim > 2: curr_anim -= 3 
	sprite.play(
		sprite.sprite_frames.get_animation_names()[curr_anim],
		velocity.length() if velocity and animation_based_on_velocity else 1.0
	)
