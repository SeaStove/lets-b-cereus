extends CharacterBody2D

# Movement variables
var speed = 100.0  # Speed at which the bacteria moves initially
var rotation_speed = 5.0  # Speed at which the bacteria rotates while tumbling
var moving_direction = Vector2.RIGHT  # Direction in which the bacteria will move
var deceleration = 50.0  # How quickly the bacteria slows down
var gravity = 170.0  # Gravity to apply when out of the soup

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = %Camera2D  # Reference to Camera2D node
@onready var tilemap: TileMap = %TileMap  # Reference to the TileMap for soup boundary

# State variables
var is_tumbling = false
var is_in_soup = true  # State to track if the player is inside the soup

func _process(delta):
	# Check if bacteria is in the soup area by detecting tile collision
	is_in_soup = is_in_soup_area()

	if Input.is_action_pressed("tumble"):  # Holding space to tumble
		is_tumbling = true
		animated_sprite_2d.play("tumble")
		# Rotate the bacteria while holding space
		rotation += rotation_speed * delta
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
				if not animated_sprite_2d.is_playing():
					animated_sprite_2d.play("idle")

	# Apply gravity if the bacteria is out of the soup
	if not is_in_soup:
		velocity.y += gravity * delta  # Apply downward force to simulate gravity

	# Apply movement in the chosen direction
	if velocity != Vector2.ZERO:
		move_and_slide()

	# Keep the camera locked on the player's position
	camera.position = global_position
	camera.rotation = 0  # Ensure the camera's rotation is always zero

# Function to check if the bacteria is inside the soup area
func is_in_soup_area() -> bool:
	# Ensure the tilemap is not null
	if tilemap == null:
		print("TileMap is not assigned!")
		return false
		
	# Convert the bacteria's world position to the TileMap grid position
	var tile_pos = tilemap.local_to_map(global_position)

	# Get the tile ID at the bacteria's position on layer 0 (assuming you're using the first layer)
	var tile_id = tilemap.get_cell_source_id(0, tile_pos)

	# If the tile ID is -1, there's no tile (out of bounds or empty space)
	if tile_id == -1:
		return false
		
	# Assuming tile ID 0 represents soup tiles. You can modify this check.
	if tile_id == 0:  # Assuming tile 0 represents soup
		return true  # Inside the soup area
	return false  # Outside the soup area
