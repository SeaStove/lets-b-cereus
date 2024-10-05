extends Area2D

@onready var game_manager = get_tree().get_nodes_in_group("GameManager")[0]

func _on_body_entered(body):
	if body.is_in_group("Player"):  # Assuming your player is in the "Player" group
		game_manager.add_nutrient()  # Add one nutrient
		queue_free()  # Remove the nutrient from the scene
