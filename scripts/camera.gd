extends Camera2D


var ship: RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	ship = get_node("/root/root/Ship")
	position = ship.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = ship.position
