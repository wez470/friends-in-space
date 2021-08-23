extends KinematicBody2D
class_name Bullet

var speed = 15


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var direction = rotation - PI/2
	var vel = Vector2(cos(direction), sin(direction)) * speed
	var collision: KinematicCollision2D = move_and_collide(vel, false)
	
	if collision != null:
		if is_network_master():
			rpc("destroy", collision)
		get_node("Lifetime").stop()
		queue_free()


func _on_Lifetime_timeout():
	queue_free()


remotesync func destroy(collision: KinematicCollision2D):
	# TODO: Make this work for remote server/host. collision seems to be null
	# when this is called form a client that is not the host so the host is not
	# handling the amply impulse / hit properly
	if collision != null:
		var collider = collision.get_collider()
		if collider.has_method("apply_impulse"):
			collider.apply_central_impulse((collider.global_position - collision.position).normalized() * 100)
		if collider.has_method("hit"):
			collider.hit()
