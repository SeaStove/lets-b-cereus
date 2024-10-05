extends CharacterBody2D

# Movement variables
var speed = 100.0  # Speed at which the player moves initially
var rotation_speed = 5.0  # Speed at which the player rotates while tumbling
var moving_direction = Vector2.RIGHT  # Direction in which the player will move
var deceleration = 50.0  # How quickly the player slows down
var gravity = 170.0  # Gravity to apply when out of the soup

# Dynamic references for camera and tilemap, assigned by game_manager
var camera: Camera2D = null
var tilemap: TileMap = null

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager = get_tree().get_nodes_in_group("GameManager")[0]
@onready var area2d: Area2D = $Area2D  # The Area2D node added to detect overlaps

# State variables
var is_tumbling = false
var is_in_soup = true  # State to track if the player is inside the soup
var nutrients_collected = 0

func _ready():
	# Connect the signal to detect when a body enters the Area2D (used for detecting nutrients)
	area2d.connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	# Update the state to check if the player is in the soup area
	is_in_soup = is_in_soup_area()

	# Handle player-specific movement logic
	if Input.is_action_pressed("tumble"):  # Holding space to tumble
		is_tumbling = true
		animated_sprite_2d.play("tumble")
		rotation += rotation_speed * delta  # Rotate while tumbling
	elif(is_in_soup and is_tumbling):
		# Released the space bar, shoot in the current direction
		is_tumbling = false
		animated_sprite_2d.play("run")
		moving_direction = Vector2.UP.rotated(rotation)
		velocity = moving_direction * speed

	# Apply gravity if the player is outside of the soup
	if not is_in_soup:
		velocity.y += gravity * delta  # Apply gravity to the vertical velocity

	# Handle deceleration when not tumbling
	if velocity.length() > 0:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	# Apply movement
	move_and_slide()

	# Ensure the camera stays positioned at the player's location
	if camera != null:
		camera.position = global_position

# Function to check if the player is in the soup area using the tilemap
func is_in_soup_area() -> bool:
	if tilemap == null:
		print("TileMap is not assigned!")
		return false
		
	# Get the player's current position in the tilemap grid
	var tile_pos = tilemap.local_to_map(global_position)

	# Get the tile ID at the player's position (layer 0)
	var tile_id = tilemap.get_cell_source_id(0, tile_pos)

	# Check if the tile ID is 0 (representing the soup area)
	if tile_id == 0:  # Assuming tile 0 represents soup
		return true  # Player is inside the soup area

	return false  # Player is outside the soup area

# Detect the overlap when a body enters the Area2D
func _on_body_entered(body):
	if body.is_in_group("Nutrient"):
		# If it's a nutrient, collect it
		body.queue_free()  # Remove the nutrient from the scene
		nutrients_collected += 1
		game_manager.add_nutrient()  # Inform game manager of the nutrient collection
