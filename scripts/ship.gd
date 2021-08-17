extends RigidBody2D


onready var tween = $Tween

puppet var engine_firing: bool = false
puppet var puppet_pos: Vector2 setget puppet_pos_set

var initialized: bool = false
var rocket_pos: float = PI

func _process(delta):
	if !is_network_master():
		if not tween.is_active() && initialized:
			print(puppet_pos)
			set_global_position(puppet_pos)


func _physics_process(delta):
	if is_network_master() && engine_firing:
		var rocket = get_node("Rocket")
		var force_direction = rocket.global_position.direction_to(global_position)
		linear_velocity += force_direction * 0.5
		var ship_speed = linear_velocity.length()
		ship_speed = clamp(ship_speed, 0, 200)
		linear_velocity = linear_velocity.normalized() * ship_speed	


func puppet_pos_set(new_value) -> void:
	puppet_pos = new_value
	tween.interpolate_property(self, "global_position", global_position, puppet_pos, 0.1)
	tween.start()
	initialized = true
	

func _on_NetworkTick_timeout():
	if is_network_master():
		rset("engine_firing", engine_firing)
		rset("puppet_pos", global_position)


mastersync func set_steering_input(input):
	get_node("Rocket").set_steering_input(input)


mastersync func set_firing_engine(firing: bool):
	get_node("Rocket").set_firing_engine(firing)
	engine_firing = firing
