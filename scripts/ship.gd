extends KinematicBody2D


onready var tween = $Tween

puppet var engine_firing: bool = false
puppet var puppet_pos: Vector2 setget puppet_pos_set

var initialized: bool = false
var rocket_pos: float = PI
var velocity = Vector2(0, 0)
var speed: float = 10
var dspeed: float = 0.00
var force_direction = Vector2(0, 0)
var x: float = self.position.x
var y: float = self.position.y
var dx: float = 0
var dy: float = 0
var angle: float = PI / 2

func _ready():
	var gun_top = get_node("GunTop")
	gun_top.max_rotation = PI/2
	gun_top.min_rotation = -PI/2
	var gun_right = get_node("GunRight")
	gun_right.max_rotation = PI
	gun_right.min_rotation = 0
	var gun_bottom = get_node("GunBottom")
	gun_bottom.max_rotation = 3*PI/2
	gun_bottom.min_rotation = PI/2
	var gun_left = get_node("GunLeft")
	gun_left.max_rotation = 2*PI
	gun_left.min_rotation = PI


func _process(_delta):
	if !is_network_master():
		if not tween.is_active() && initialized:
			set_global_position(puppet_pos)


#func _physics_process(_delta): # TODO: Should this be physics process or integrate forces?
func _physics_process(_delta):
	if is_network_master():
#		if engine_firing:
#			var rocket = get_node("Rocket")
#			var force_direction = rocket.global_position.direction_to(global_position)
#			force_direction = force_direction.normalized()
#			var drag_coefficient = 0.0001
#			var drag_accel = speed * speed * drag_coefficient
#			var speeddd = speed - drag_accel * _delta
#			velocity += force_direction * speeddd
#			move_and_slide(velocity)
#		else:
#			var new_speed = speed - (2 * _delta)
#			speed = clamp(new_speed, 0, 1.5)
#			velocity *= 0.995
#			move_and_slide(velocity)
		if engine_firing:
			var rocket = get_node("Rocket")
			var asdf = rocket.global_position.direction_to(global_position)
			dx += cos(asdf.angle()) * 0.02
			dy += sin(asdf.angle()) * 0.02
		
			# Don't let forces build up past a certain point (can happen during collisions)
			if abs(position.x - x) < 150:
				x += dx
			if abs(position.y - y) < 150:
				y += dy
			dx *= 0.995
			dy *= 0.995
		else:
			if abs(position.x - x) < 150:
				x += dx
			if abs(position.y - y) < 150:
				y += dy
			dx *= 0.996
			dy *= 0.996
			
		move_and_slide(Vector2(x, y) - self.position)
		
#		    if(this.hasControl){
#                if(keys.ArrowUp){
#                    this.delta.x += Math.cos(this.angle) * 0.1;
#                    this.delta.y += Math.sin(this.angle) * 0.1;
#                }
#                if(keys.ArrowLeft){
#                    this.deltaAngle -= 0.001;
#                }
#                if(keys.ArrowRight){
#                    this.deltaAngle += 0.001;
#                }
#            }
#            this.pos.x += this.delta.x;
#            this.pos.y += this.delta.y;
#            this.angle += this.deltaAngle;
#            this.displayAngle = this.angle;
#            this.delta.x *= 0.995;
#            this.delta.y *= 0.995;
#            this.deltaAngle *= 0.995;  

#	         m[3] = m[0] = Math.cos(this.displayAngle);
#	         m[2] = -(m[1] = Math.sin(this.displayAngle));
#	         m[4] = this.pos.x;
#	         m[5] = this.pos.y;
#	         this.element.style.transform = `matrix(${m.join(",")})`;	

func puppet_pos_set(new_value) -> void:
	puppet_pos = new_value
	tween.interpolate_property(self, "global_position", global_position, puppet_pos, 0.1)
	tween.start()
	initialized = true
	

func _on_NetworkTick_timeout():
	if is_network_master():
		rset_unreliable("puppet_pos", global_position)


mastersync func set_steering_input(input):
	get_node("Rocket").set_steering_input(input)


mastersync func set_firing_engine(firing: bool):
	get_node("Rocket").set_firing_engine(firing)
	engine_firing = firing
