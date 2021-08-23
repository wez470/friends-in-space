extends Node2D

const rocket_to_center_distance: int = 230
const rotation_speed: float = PI/200

onready var tween = $Tween

var curr_input = Global.Input.NONE
var curr_rotation = PI
puppet var puppet_pos: Vector2 setget puppet_pos_set
puppet var puppet_engine_firing: bool = false
var ship: RigidBody2D
var initialized: bool = false


func _ready():
	ship = get_parent()


func _process(_delta):
	rotation = global_position.direction_to(ship.global_position).angle()
	
	var rocket_flame = get_node("Flame")
	if !rocket_flame.is_visible() && puppet_engine_firing:
		rocket_flame.set_visible(true)
	elif rocket_flame.is_visible() && !puppet_engine_firing:
		rocket_flame.set_visible(false)


func _physics_process(_delta):
	if is_network_master():
		if curr_input == Global.Input.LEFT:
			curr_rotation -= rotation_speed
		elif curr_input == Global.Input.RIGHT:
			curr_rotation += rotation_speed
		
		puppet_pos = Vector2(cos(curr_rotation), sin(curr_rotation)) * rocket_to_center_distance
		position = puppet_pos
	else:
		if not tween.is_active() && initialized:
			position = puppet_pos


func set_steering_input(input):
	curr_input = input


func set_firing_engine(firing: bool):
	puppet_engine_firing = firing


func puppet_pos_set(new_value) -> void:
	puppet_pos = new_value
	tween.interpolate_property(self, "position", position, puppet_pos, 0.1)
	tween.start()
	initialized = true


func _on_NetworkTick_timeout():
	if is_network_master():
		rset_unreliable("puppet_pos", puppet_pos)
		rset("puppet_engine_firing", puppet_engine_firing)
