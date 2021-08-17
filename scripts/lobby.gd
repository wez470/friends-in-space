extends Node


onready var lobby_ui = $UI
onready var lobby_players = $UI/Players
onready var server_lobby_ui = $ServerUI

func _ready():
	server_lobby_ui.hide()
	if get_tree().is_network_server():
		server_lobby_ui.show()
	reset_lobby_ui()
	var err = get_tree().connect("network_peer_connected", self, "_player_connected")
	if err != OK:
		print(err)
	err = get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	if err != OK:
		print(err)
	err = get_tree().connect("connected_to_server", self, "_connected_to_server")
	if err != OK:
		print(err)


func _player_connected(id):
	print("Player connected: " + str(id))
	# Only send if we're initialized
	if Global.player_num > 0:
		rpc_id(id, "register_player", {name=Global.player_name, id=get_tree().get_network_unique_id(), num=Global.player_num})
	# only send player info if we are initialized (assigned a num by the server)
	if get_tree().is_network_server():
		var num = Global.player_nums.pop_front()
		Global.player_ids_to_num[id] = num
		rpc_id(id, "assign_player_num", num)


func _player_disconnected(id):
	print("Player disconnected: " + str(id))
	# TODO, deregister


func _connected_to_server() -> void:
	print("connected to server")


remote func assign_player_num(num: int):
	print("assigning player num: ", num)
	Global.player_num = num
	var my_id = get_tree().get_network_unique_id()
	Global.players_by_id[my_id].num = num
	Global.player_ids_to_num[my_id] = num
	rpc("register_player", {name=Global.player_name, id=get_tree().get_network_unique_id(), num=Global.player_num})
	reset_lobby_ui()


remote func register_player(info):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	Global.players_by_id[id] = info
	Global.player_ids_to_num[id] = info.num
	print(Global.players_by_id)
	reset_lobby_ui()
	
	
func reset_lobby_ui():
	for n in lobby_players.get_children():
		lobby_players.remove_child(n)
	
	var curr_y = 350 
	var player_nums = []
	var player_num_to_id = {}
	for id in Global.players_by_id:
		var p_num = Global.players_by_id[id].num
		player_num_to_id[p_num] = id
		player_nums.append(p_num)
		
	player_nums.sort()
		
	for num in player_nums:
		var id = player_num_to_id[num]
		var info = Global.players_by_id[id]
		var entry = preload("res://scenes/lobby_entry.tscn").instance()
		entry.get_node("Player").text = info.name
		entry.get_node("ID").text = id as String
		entry.get_node("Num").text = info.num as String
		entry.rect_position.x = 50
		entry.rect_position.y = curr_y
		curr_y += 100
		lobby_players.add_child(entry)
		

remotesync func start_game():
	var err = get_tree().change_scene("res://scenes/level1.tscn")
	if err != OK:
		print(err)


func _on_StartGame_pressed():
	rpc("start_game")
