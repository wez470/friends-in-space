extends RigidBody2D

const speed: int = 20

onready var tween = $Tween

var ship: RigidBody2D
var health: int = 2
var initialized: bool = false

puppet var puppet_pos: Vector2 setget puppet_pos_set

# Called when the node enters the scene tree for the first time.
func _ready():
	ship = get_node("/root/root/Ship")
	if is_network_master():
		get_node("NetworkTick").start()


func _integrate_forces(state):
	if is_network_master():
		var force_direction = global_position.direction_to(ship.global_position)
		rotation = force_direction.angle() + -PI/2
		applied_force = force_direction.normalized() * speed
		puppet_pos = position


func _process(_delta):
	if !is_network_master():
		var direction = global_position.direction_to(ship.global_position)
		rotation = direction.angle() + -PI/2
		if !tween.is_active() && initialized:
			position = puppet_pos


func puppet_pos_set(new_value) -> void:
	puppet_pos = new_value
	tween.interpolate_property(self, "position", position, puppet_pos, 0.1)
	tween.start()
	initialized = true


func _on_NetworkTick_timeout():
	if is_network_master():
		rset_unreliable("puppet_pos", puppet_pos)


func hit():
	rpc("remote_hit")


remotesync func remote_hit(): 
	health -= 1
	if health == 0:
		queue_free()
