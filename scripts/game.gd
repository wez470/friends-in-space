extends Node2D


# server vars
var driving_player: int = -1
var gun_top_player: int = -1
var gun_right_player: int = -1
var gun_bottom_player: int = -1
var gun_left_player: int = -1

remotesync func toggle_driving_module_use():
	if get_tree().is_network_server():
		var requestor_id = get_tree().get_rpc_sender_id()
		print("Rquested driving module use ", requestor_id)
		if driving_player == -1:
			# No driving player. Set the requester as the current driver
			driving_player = requestor_id
			Global.player_nodes_by_id[requestor_id].rpc_id(requestor_id, "set_driving_module_use", true)
		elif driving_player == requestor_id:
			# Current driver has toggled module use. Let them stop
			driving_player = -1
			Global.player_nodes_by_id[requestor_id].rpc_id(requestor_id, "set_driving_module_use", false)


remotesync func toggle_gun_top_use():
	var requestor_id = get_tree().get_rpc_sender_id()
	print("Rquested top gun module use ", requestor_id)
	if gun_top_player == -1:
		# No gun top player. Set the requester as the current
		gun_top_player = requestor_id
		Global.player_nodes_by_id[requestor_id].rpc_id(requestor_id, "set_gun_top_use", true)
	elif gun_top_player == requestor_id:
		# Current gun top player has toggled module use. Let them stop
		gun_top_player = -1
		Global.player_nodes_by_id[requestor_id].rpc_id(requestor_id, "set_gun_top_use", false)
		
		
remotesync func toggle_gun_right_use():
	var requestor_id = get_tree().get_rpc_sender_id()
	print("Rquested right gun module use ", requestor_id)
	if gun_right_player == -1:
		# No gun right player. Set the requester as the current
		gun_right_player = requestor_id
		Global.player_nodes_by_id[requestor_id].rpc_id(requestor_id, "set_gun_right_use", true)
	elif gun_right_player == requestor_id:
		# Current gun right player has toggled module use. Let them stop
		gun_right_player = -1
		Global.player_nodes_by_id[requestor_id].rpc_id(requestor_id, "set_gun_right_use", false)
		
		
remotesync func toggle_gun_bottom_use():
	var requestor_id = get_tree().get_rpc_sender_id()
	print("Rquested bottom gun module use ", requestor_id)
	if gun_bottom_player == -1:
		# No gun bottom player. Set the requester as the current
		gun_bottom_player = requestor_id
		Global.player_nodes_by_id[requestor_id].rpc_id(requestor_id, "set_gun_bottom_use", true)
	elif gun_bottom_player == requestor_id:
		# Current gun bottom player has toggled module use. Let them stop
		gun_bottom_player = -1
		Global.player_nodes_by_id[requestor_id].rpc_id(requestor_id, "set_gun_bottom_use", false)
		
		
remotesync func toggle_gun_left_use():
	var requestor_id = get_tree().get_rpc_sender_id()
	print("Rquested left gun module use ", requestor_id)
	if gun_left_player == -1:
		# No gun left player. Set the requester as the current
		gun_left_player = requestor_id
		Global.player_nodes_by_id[requestor_id].rpc_id(requestor_id, "set_gun_left_use", true)
	elif gun_left_player == requestor_id:
		# Current gun left player has toggled module use. Let them stop
		gun_left_player = -1
		Global.player_nodes_by_id[requestor_id].rpc_id(requestor_id, "set_gun_left_use", false)
