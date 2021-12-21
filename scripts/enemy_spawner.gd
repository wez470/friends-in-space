extends Node2D

const spawn_locations = [Vector2(-1060, -640), Vector2(-354, -640), Vector2(354, -640), Vector2(1060, -640), Vector2(1060, 0), Vector2(-1060, 640), Vector2(-354, 640), Vector2(354, 640), Vector2(1060, 640), Vector2(-1060, 0)]
const MAX_ENEMIES: int = 5

#var spawn_rate: int = 5000000 # 5 seconds
var spawn_rate: int = 1000000 # 1 second for testing
var ticks_since_spawn: int = 0
var rng = RandomNumberGenerator.new()
var ship: RigidBody2D
var enemy_id: int = 0

func _ready():
	ship = get_node("/root/root/Ship")
	if is_network_master():
		get_node("SpawnIncrease").start()


func _process(_delta):
	if is_network_master():
		var curr_ticks = OS.get_ticks_usec()
		if curr_ticks - ticks_since_spawn > spawn_rate:
			ticks_since_spawn = curr_ticks
			if get_child_count() < MAX_ENEMIES:
				var location = spawn_locations[randi() % len(spawn_locations)]
				location += ship.position
				enemy_id += 1
				rpc("spawn_enemy", location, enemy_id)


remotesync func spawn_enemy(location: Vector2, id: int):
	var enemy: KinematicBody2D = preload("res://scenes/enemy.tscn").instance()
	enemy.global_position = location
	enemy.set_name("enemy-%d" % id)
	add_child(enemy)


func _on_SpawnIncrease_timeout():
	spawn_rate = clamp(spawn_rate * 0.9, float(500000), float(spawn_rate))
