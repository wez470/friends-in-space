extends KinematicBody2D

const rotation_speed: float = PI/100
const fire_rate: int = 250000 # microseconds

onready var tween = $Tween

var initialized: bool = false
var max_rotation: float = PI/2
var min_rotation: float = -PI/2
var firing: bool = false
var last_fire_ticks: int = 0
var curr_input = Global.Input.NONE
var controlling: bool = false

remote var remote_rotation: float setget puppet_rot_set


func _ready():
	remote_rotation = rotation


func _physics_process(_delta):
	if controlling:
		handle_rotation()
		handle_firing()
	else:
		if !tween.is_active() && initialized:
			rotation = remote_rotation


func handle_rotation():
	if curr_input == Global.Input.LEFT:
		remote_rotation -= rotation_speed
	elif curr_input == Global.Input.RIGHT:
		remote_rotation += rotation_speed
		
	remote_rotation = clamp(remote_rotation, min_rotation, max_rotation)
	rotation = remote_rotation


func handle_firing():
	var curr_ticks = OS.get_ticks_usec()
	if firing && (curr_ticks - last_fire_ticks) > fire_rate:
		last_fire_ticks = curr_ticks
		rpc("create_bullet", get_node("BulletSpawn").global_position, rotation, get_tree().get_network_unique_id())


func puppet_rot_set(new_val):
	remote_rotation = new_val
	tween.interpolate_property(self, "rotation", rotation, remote_rotation, 0.1)
	tween.start()
	initialized = true


func _on_NetworkTick_timeout():
	if controlling:
		rset("remote_rotation", remote_rotation)


func set_rotation_input(input):
	curr_input = input
	
	
func set_firing(fire: bool):
	firing = fire


remotesync func create_bullet(pos: Vector2, rotation: float, player_id: int):
	var bullet: KinematicBody2D = preload("res://scenes/bullet.tscn").instance()
	bullet.position = pos
	bullet.rotation = rotation
	bullet.set_network_master(player_id)
	get_node("/root/root/Bullets").add_child(bullet)
