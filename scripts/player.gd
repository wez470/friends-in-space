extends KinematicBody2D

const ship_wall_width: int = 20

export (int) var speed = 150

onready var tween = $Tween

var velocity: Vector2 = Vector2()
var num: int = 0
var ship: RigidBody2D
var game: Node2D
var initialized: bool = false

# module vars
var driving_module: KinematicBody2D
var driving_module_collision: bool = false
var driving: bool = false
var curr_firing_engine = false
var curr_steering_input = Global.Input.NONE
var rocket_rotation: float = PI
var curr_rotation_input = Global.Input.NONE
var firing: bool = false
# Top Gun
var gun_top: KinematicBody2D
var gun_top_collision: bool = false
var using_gun_top: bool = false
# Right Gun
var gun_right: KinematicBody2D
var gun_right_collision: bool = false
var using_gun_right: bool = false
# Bottom Gun
var gun_bottom: KinematicBody2D
var gun_bottom_collision: bool = false
var using_gun_bottom: bool = false
# Left Gun
var gun_left: KinematicBody2D
var gun_left_collision: bool = false
var using_gun_left: bool = false

puppet var puppet_pos: Vector2 setget puppet_pos_set

func _ready():
	ship = get_node("/root/root/Ship")
	driving_module = get_node("/root/root/Ship/Driving")
	gun_top = get_node("/root/root/Ship/GunTop")
	gun_right = get_node("/root/root/Ship/GunRight")
	gun_bottom = get_node("/root/root/Ship/GunBottom")
	gun_left = get_node("/root/root/Ship/GunLeft")
	game = get_node("/root/root/Game")
	if is_network_master():
		get_node("NetworkTick").start()


func _physics_process(_delta):
	if is_network_master():
		if driving:
			handle_driving()
		elif using_gun_top:
			handle_gun(gun_top)
		elif using_gun_right:
			handle_gun(gun_right)
		elif using_gun_bottom:
			handle_gun(gun_bottom)
		elif using_gun_left:
			handle_gun(gun_left)
		else:
			handle_movement()
	else:
		if not tween.is_active() && initialized:
			position = puppet_pos


func handle_driving():
	var new_input = Global.Input.NONE
	if Input.is_action_pressed("right") && Input.is_action_pressed("left"):
		new_input = Global.Input.NONE
	elif Input.is_action_pressed("right"):
		new_input = Global.Input.RIGHT
	if Input.is_action_pressed("left"):
		new_input = Global.Input.LEFT
	if curr_steering_input != new_input:
		ship.rpc_id(Global.SERVER_ID, "set_steering_input", new_input)
		curr_steering_input = new_input
	
	if Input.is_action_pressed("action") && !curr_firing_engine:
		curr_firing_engine = true
		ship.rpc_id(Global.SERVER_ID, "set_firing_engine", true)
	elif !Input.is_action_pressed("action") && curr_firing_engine:
		curr_firing_engine = false
		ship.rpc_id(Global.SERVER_ID, "set_firing_engine", false)


func handle_gun(gun: Node2D):
	var new_input = Global.Input.NONE
	if Input.is_action_pressed("right") && Input.is_action_pressed("left"):
		new_input = Global.Input.NONE
	elif Input.is_action_pressed("right"):
		new_input = Global.Input.RIGHT
	if Input.is_action_pressed("left"):
		new_input = Global.Input.LEFT
	if curr_rotation_input != new_input:
		gun.set_rotation_input(new_input)
		curr_rotation_input = new_input
	
	if Input.is_action_pressed("action") && !firing:
		firing = true
		gun.set_firing(true)
	elif !Input.is_action_pressed("action") && firing:
		firing = false
		gun.set_firing(false)


func set_movement_from_input():
	velocity = Vector2()
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	velocity = velocity.normalized() * speed
	
	
func handle_movement():
	set_movement_from_input()
	velocity = move_and_slide(velocity)

	# See if we're colliding with anything
	var slides  = get_slide_count()
	if slides > 0:
		var collision: KinematicCollision2D = get_slide_collision(slides - 1)
		var collision_obj = collision.get_collider()
		if collision_obj.get_instance_id() == driving_module.get_instance_id():
			driving_module_collision = true
		elif collision_obj.get_instance_id() == gun_top.get_instance_id():
			gun_top_collision = true
		elif collision_obj.get_instance_id() == gun_right.get_instance_id():
			gun_right_collision = true
		elif collision_obj.get_instance_id() == gun_bottom.get_instance_id():
			gun_bottom_collision = true
		elif collision_obj.get_instance_id() == gun_left.get_instance_id():
			gun_left_collision = true
	else:
		# Only reset module collisions if we're moving away from the module
		if velocity.x != 0 || velocity.y != 0:
			driving_module_collision = false
			gun_top_collision = false
			gun_right_collision = false
			gun_bottom_collision = false
			gun_left_collision = false

	# Lock player to ship radius. Do this manually to avoid Rigibody2D collision physics with the ship
	var ship_sprite: Sprite = ship.get_node("Sprite")
	var ship_radius = (ship_sprite.texture.get_width() / 2.0) * ship_sprite.transform.get_scale().x - ship_wall_width
	var ship_center_position = ship.global_position
	var distance_to_ship_center: float = global_position.distance_to(ship_center_position)

	if distance_to_ship_center > ship_radius:
		var ship_center_to_player = global_position - ship_center_position
		ship_center_to_player *= ship_radius / distance_to_ship_center
		global_position =  ship_center_position + ship_center_to_player


func _on_NetworkTick_timeout():
	if is_network_master():
		rset_unreliable("puppet_pos", position)


func puppet_pos_set(new_value) -> void:
	puppet_pos = new_value
	tween.interpolate_property(self, "position", position, puppet_pos, 0.1)
	tween.start()
	initialized = true


func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("toggle_control"):
			# handle all possible module toggles
			if driving_module_collision && !driving || driving:
				print("Toggled driving module")
				game.rpc_id(Global.SERVER_ID, "toggle_driving_module_use")
			elif gun_top_collision && !using_gun_top || using_gun_top:
				print("Toggled gun top module")
				game.rpc_id(Global.SERVER_ID, "toggle_gun_top_use")
			elif gun_right_collision && !using_gun_right || using_gun_right:
				print("Toggled gun right module")
				game.rpc_id(Global.SERVER_ID, "toggle_gun_right_use")
			elif gun_bottom_collision && !using_gun_bottom || using_gun_bottom:
				print("Toggled gun bottom module")
				game.rpc_id(Global.SERVER_ID, "toggle_gun_bottom_use")
			elif gun_left_collision && !using_gun_left || using_gun_left:
				print("Toggled gun left module")
				game.rpc_id(Global.SERVER_ID, "toggle_gun_left_use")	


remotesync func set_driving_module_use(drive: bool):
	print("Set driving module usage from server: ", drive)
	driving = drive
	if !driving:
		ship.rpc_id(Global.SERVER_ID, "set_steering_input", Global.Input.NONE)
		ship.rpc_id(Global.SERVER_ID, "set_firing_engine", false)


remotesync func set_gun_top_use(using: bool):
	print("Set gun top usage from server: ", using)
	using_gun_top = using
	set_gun_use(gun_top, using)
		
		
remotesync func set_gun_right_use(using: bool):
	print("Set gun right usage from server: ", using)
	using_gun_right = using
	set_gun_use(gun_right, using)
		
		
remotesync func set_gun_bottom_use(using: bool):
	print("Set gun bottom usage from server: ", using)
	using_gun_bottom = using
	set_gun_use(gun_bottom, using)
		
		
remotesync func set_gun_left_use(using: bool):
	print("Set gun left usage from server: ", using)
	using_gun_left = using
	set_gun_use(gun_left, using)


func set_gun_use(gun: Node2D, using: bool):
	if using:
		gun.controlling = true
	else:
		gun.controlling = false
		gun.set_rotation_input(Global.Input.NONE)
		gun.set_firing(false)
