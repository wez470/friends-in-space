extends Node2D


var player_pos = [Vector2(810, 440), Vector2(1110, 440), Vector2(810, 640), Vector2(1110, 640)]
var p2 = preload("res://sprites/p2-placeholder.png")
var p3 = preload("res://sprites/p3-placeholder.png")
var p1 = preload("res://sprites/p1-placeholder.png")
var p4 = preload("res://sprites/p4-placeholder.png")


# Called when the node enters the scene tree for the first time.
func _ready():
	var player_textures = [p1, p2, p3, p4]

	for id in Global.players_by_id:
		var player = preload("res://scenes/player.tscn").instance()
		player.set_network_master(id)
		player.set_name(str(id))
		var player_num: int = Global.player_ids_to_num[id]
		player.set_global_position(player_pos[player_num - 1])
		player.get_node("Sprite").set_texture(player_textures[player_num - 1])
		player.num = player_num
		player.get_node("Username/Username").text = Global.players_by_id[id].name
		Global.player_nodes_by_id[id] = player
		get_node("Ship/Players").add_child(player)
