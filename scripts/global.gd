extends Node


const SERVER_ID = 1
const DEFAULT_PORT: int = 28282
# TODO: Make configurable
const USE_UPNP: bool = false

var player_name: String = ""
var player_num: int = 0

var player_nums = [1,2,3,4]
var player_ids_to_num = {}
var players_by_id = {}
var player_nodes_by_id = {}

enum Input {LEFT, RIGHT, NONE}

var upnp: UPNP = null

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		print("QUITTING")
		if USE_UPNP and upnp != null:
			upnp.delete_port_mapping(DEFAULT_PORT)
		get_tree().quit() # default behavior
