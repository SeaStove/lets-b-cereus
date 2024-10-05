extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	print("You died!")
	body.get_node("CollisionShape2D").queue_free()
	if(body.is_in_group("Player")):
		timer.start()
		Engine.time_scale = 0.5
	else:
		body.queue_free()


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
