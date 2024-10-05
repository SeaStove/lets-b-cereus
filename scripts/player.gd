extends CharacterBody2D

# Movement variables
var speed = 100.0  # Speed at which the bacteria moves initially
var rotation_speed = 5.0  # Speed at which the bacteria rotates while tumbling
var moving_direction = Vector2.RIGHT  # Direction in which the bacteria will move
var deceleration = 50.0  # How quickly the bacteria slows down

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = %Camera2D  # Reference to Camera2D node

# State variables
var is_tumbling = false

func _process(delta):
	if Input.is_action_pressed("tumble"):  # Holding space to tumble
		is_tumbling = true
		animated_sprite_2d.play("tumble")
		# Rotate the bacteria while holding space
		rotation += rotation_speed * delta
		# Keep moving in the current direction while tumbling
	else:
		if is_tumbling:  # Released the space bar, shoot in the current direction
			is_tumbling = false
			animated_sprite_2d.play("run")
			# Set the forward direction based on the current rotation
			moving_direction = Vector2.UP.rotated(rotation)
			velocity = moving_direction * speed
		else:
			# Slow down by reducing velocity over time until it reaches zero
			if velocity.length() > 0:
				velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
				if(!animated_sprite_2d.is_playing()):
					animated_sprite_2d.play("idle")

	# Apply movement in the chosen direction
	if velocity != Vector2.ZERO:
		move_and_slide()

	# Keep the camera locked on the player's position
	camera.position = global_position
	camera.rotation = 0  # Ensure the camera's rotation is always zero
