extends Node


const SERVER_ID = 1

var player_name: String = ""
var player_num: int = 0

var player_nums = [1,2,3,4]
var player_ids_to_num = {}
var players_by_id = {}
var player_nodes_by_id = {}

enum Input {LEFT, RIGHT, NONE}
