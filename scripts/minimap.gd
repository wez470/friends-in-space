extends MarginContainer


onready var map_container = $Border/Map
var background: TextureRect = null
var map_ship: Node2D = null
var ship: Node2D = null
var map_scale: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	background = get_node("/root/root/Background/Image")
	# Background is square, so we only need one of width or height
	var w = background.get_rect().size.x
	var h = background.get_rect().size.y
	map_scale = Vector2(map_container.get_rect().size.x / w, map_container.get_rect().size.y / h)
	
	var level_objects = get_node("/root/root/Level")
	for obj in level_objects.get_children():
		var dup = obj.duplicate()
		dup.global_position = (map_scale * obj.global_position) + (map_container.get_rect().size / 2)
		dup.set_z_index(20)
		# Find colliders and disable them
		for child in dup.get_children():
			if "disabled" in child:
				child.set_disabled(true)
		dup.scale = obj.scale * map_scale
		map_container.add_child(dup)
	
	ship = get_node("/root/root/Ship")
	map_ship = preload("res://scenes/map_ship.tscn").instance()
	map_ship.set_z_index(20)
	map_ship.scale = ship.get_node("Sprite").scale * map_scale
	map_container.add_child(map_ship)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	map_ship.position = (map_scale * ship.global_position) + (map_container.get_rect().size / 2)
	
	visible = Input.is_action_pressed("map")
