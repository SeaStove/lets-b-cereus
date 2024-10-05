extends Node

# Variables
var total_nutrients: int = 0  # Start with 0 nutrients
@export var nutrient_scene_path: String = "res://scenes/nutrient.tscn"  # Path to the nutrient scene
@export var clone_scene_path: String = "res://scenes/clone.tscn"  # Path to the clone scene
@export var spawn_interval: float = 2.0  # Time interval between spawns (in seconds)
@onready var tilemap: TileMap = %TileMap
@onready var player: CharacterBody2D = %player
@onready var camera: Camera2D = %Camera2D

# Internal timer to spawn nutrients
var spawn_timer: float = 0.0

func _ready():
	# Assign the camera and tilemap to the player dynamically
	if player:
		player.camera = camera
		player.tilemap = tilemap

func _process(delta):
	# Timer to spawn nutrients at intervals
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_nutrient()
		spawn_timer = 0.0

	# Check if the player is outside the soup, and if so, spawn clones
	if not player.is_in_soup and total_nutrients > 0:
		spawn_clones()  # Spawn clones if the player has collected nutrients and is outside the soup
		total_nutrients = 0  # Reset nutrients to 0 after spawning clones

# Function to add one to the total nutrients
func add_nutrient():
	total_nutrients += 1

# Function to spawn clones based on the player's position and the number of nutrients collected
func spawn_clones():
	var clone_scene = load(clone_scene_path) as PackedScene
	if clone_scene == null:
		print("Failed to load clone scene")
		return

	for i in range(total_nutrients):
		# Spawn a clone near the player
		var clone = clone_scene.instantiate() as CharacterBody2D
		clone.position = player.global_position + Vector2(randf() * 50 - 25, randf() * 50 - 25)  # Randomize position around the player
		
		# Assign the player reference to the clone so it can follow
		clone.player = player

		add_child(clone)

func is_overlapping_nutrient(new_position: Vector2) -> bool:
	for existing_nutrient in get_tree().get_nodes_in_group("Nutrient"):
		if existing_nutrient.global_position.distance_to(new_position) < 16:  # Adjust the distance threshold as needed
			return true
	return false

# Function to spawn a nutrient at a random ID 0 tile
func spawn_nutrient():
	var nutrient_scene = load(nutrient_scene_path) as PackedScene
	if nutrient_scene == null:
		print("Failed to load nutrient scene")
		return

	var possible_tiles = []
	var map_size = tilemap.get_used_rect()

	# Find all tiles with ID 0
	for x in range(map_size.position.x, map_size.position.x + map_size.size.x):
		for y in range(map_size.position.y, map_size.position.y + map_size.size.y):
			var tile_pos = Vector2(x, y)
			if tilemap.get_cell_source_id(0, tile_pos) == 0:
				possible_tiles.append(tile_pos)

	# If there are no possible tiles, do nothing
	if possible_tiles.size() == 0:
		print("No valid tiles to spawn nutrients.")
		return

	# Function to check if a new nutrient will overlap with an existing one


	var nutrient_spawned = false
	while not nutrient_spawned and possible_tiles.size() > 0:
		# Choose a random tile
		var random_tile = possible_tiles[randi() % possible_tiles.size()]
		var world_position = tilemap.map_to_local(random_tile)

		# Check if this position overlaps with any existing nutrient
		if is_overlapping_nutrient(world_position):
			# If it overlaps, remove the tile from the list of possible tiles and try again
			possible_tiles.erase(random_tile)
		else:
			# Spawn the nutrient if it doesn't overlap
			var nutrient = nutrient_scene.instantiate()
			nutrient.position = world_position
			add_child(nutrient)
			nutrient_spawned = true

	if not nutrient_spawned:
		print("Failed to spawn a nutrient without overlap.")
