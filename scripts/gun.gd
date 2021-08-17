extends KinematicBody2D

const rotation_speed: float = PI/150
const fire_rate: int = 250000 # microseconds

onready var tween = $Tween

var initialized: bool = false
var max_rotation: float = PI/2
var min_rotation: float = -PI/2
var firing: bool = false
var last_fire_ticks: int = 0
var curr_input = Global.Input.NONE

puppet var puppet_rotation: float setget puppet_rot_set


func _ready():
	puppet_rotation = rotation


func _physics_process(_delta):
	if is_network_master():
		handle_rotation()
		handle_firing()
	else:
		if !tween.is_active() && initialized:
			rotation = puppet_rotation


func handle_rotation():
	if curr_input == Global.Input.LEFT:
		puppet_rotation -= rotation_speed
	elif curr_input == Global.Input.RIGHT:
		puppet_rotation += rotation_speed
		
	puppet_rotation = clamp(puppet_rotation, min_rotation, max_rotation)
	rotation = puppet_rotation


func handle_firing():
	var curr_ticks = OS.get_ticks_usec()
	if firing && (curr_ticks - last_fire_ticks) > fire_rate:
		last_fire_ticks = curr_ticks
		rpc("create_bullet", get_node("BulletSpawn").global_position, rotation)


func puppet_rot_set(new_val):
	puppet_rotation = new_val
	tween.interpolate_property(self, "rotation", rotation, puppet_rotation, 0.1)
	tween.start()
	initialized = true


func _on_NetworkTick_timeout():
	if is_network_master():
		rset("puppet_rotation", puppet_rotation)


mastersync func set_rotation_input(input):
	curr_input = input
	
	
mastersync func set_firing(fire: bool):
	firing = fire


remotesync func create_bullet(pos: Vector2, rotation: float):
	var bullet: KinematicBody2D = preload("res://scenes/bullet.tscn").instance()
	bullet.position = pos
	bullet.rotation = rotation
	get_node("/root/root/Bullets").add_child(bullet)
