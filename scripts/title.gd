extends Control


const DEFAULT_PORT: int = 28282
const MAX_CLIENTS: int = 4

var server: NetworkedMultiplayerENet = null
var client: NetworkedMultiplayerENet = null

onready var server_ip = $SetupUI/ServerIP
onready var username = $SetupUI/Username

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var err = get_tree().connect("connected_to_server", self, "_connected_to_server")
	if err != OK:
		print(err)
	err = get_tree().connect("server_disconnected", self, "_server_disconnected")
	if err != OK:
		print(err)
		

func create_server() -> void:
	server = NetworkedMultiplayerENet.new()
	var err = server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	if err != OK:
		print(err)
	get_tree().set_network_peer(server)
	
	
func join_server(ip: String) -> void:
	client = NetworkedMultiplayerENet.new()
	var err = client.create_client(ip, DEFAULT_PORT)
	if err != OK:
		print(err)
	get_tree().set_network_peer(client)
	
	
func _server_disconnected() -> void:
	print("disconnected from server title")
	
	
func _connected_to_server() -> void:
	print("connected to server title")


func _on_CreateServer_pressed():
	create_server()
	if username.text != "":
		Global.player_name = username.text
	Global.player_num = Global.player_nums.pop_front()
	Global.players_by_id[get_tree().get_network_unique_id()] = {name=Global.player_name, id=get_tree().get_network_unique_id(), num=Global.player_num}
	Global.player_ids_to_num[get_tree().get_network_unique_id()] = Global.player_num
	var err = get_tree().change_scene("res://scenes/lobby.tscn")
	if err != OK:
		print(err)


func _on_JoinServer_pressed():
	if server_ip.text != "":
		join_server(server_ip.text)
		if username.text != "":
			Global.player_name = username.text
		Global.players_by_id[get_tree().get_network_unique_id()] = {name=Global.player_name, id=get_tree().get_network_unique_id(), num=Global.player_num}
		var err = get_tree().change_scene("res://scenes/lobby.tscn")
		if err != OK:
			print(err)
