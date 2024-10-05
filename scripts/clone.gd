extends CharacterBody2D

# Clone variables
var speed = 100.0  # Speed at which the clones follow the player
var avoid_distance = 10.0  # Distance at which clones should avoid the player

@onready var player: Node2D = null  # Reference to the player

func _process(delta):
	# Recalculate the player's position each frame
	if player == null:
		# Find the player if not already assigned
		player = get_tree().get_nodes_in_group("Player")[0]

	if player != null:
		if(!avoid_player_if_too_close()):
			follow_player()

	# Move the clone using move_and_slide()
	move_and_slide()

func follow_player():
	# Move towards the player
	var direction = (player.global_position - global_position).normalized()
	# Set velocity towards the player at 50% of the player speed
	velocity = direction * (speed * 0.5)

func avoid_player_if_too_close():
	# Check if clone is too close to the player
	var clone_to_player_vector = player.global_position - global_position
	if clone_to_player_vector.length() < avoid_distance:
		# Apply force to move away from the player
		var push_direction = clone_to_player_vector.rotated(PI / 2).normalized()
		# Adjust the velocity to push the clone away
		velocity += push_direction * 100 * get_process_delta_time()
		return true
	else:
		return false
