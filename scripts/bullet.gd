extends KinematicBody2D

var speed = 600


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = rotation - PI/2
	var vel = Vector2(cos(direction), sin(direction)) * speed
	move_and_slide(vel)


func _on_Lifetime_timeout():
	queue_free()
