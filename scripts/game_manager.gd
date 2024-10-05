extends Node

# Variables
var total_nutrients: int = 0  # Start with 0 nutrients
@export var nutrient_scene_path: String = "res://scenes/nutrient.tscn"  # Path to the nutrient scene
@export var spawn_interval: float = 2.0  # Time interval between spawns (in seconds)
@onready var tilemap: TileMap = %TileMap  # Reference to your TileMap
@onready var player = get_tree().get_nodes_in_group("Player")[0]  # Assuming the player is in the "Player" group


# Internal timer to spawn nutrients
var spawn_timer: float = 0.0

func _process(delta):
	# Timer to spawn nutrients at intervals
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_nutrient()
		spawn_timer = 0.0

# Function to add one to the total nutrients and make the player grow
func add_nutrient():
	total_nutrients += 1
	
	# Find the player node and increase its size
	if player:
		player.grow()

# Function to spawn a nutrient at a random ID 0 tile
func spawn_nutrient():
	var nutrient_scene = load(nutrient_scene_path) as PackedScene
	if nutrient_scene == null:
		print("Failed to load nutrient scene")
		return

	var possible_tiles = []
	var map_size = tilemap.get_used_rect()  # Get the area of the tilemap
	
	# Iterate through the tilemap to find all tiles with ID 0
	for x in range(map_size.position.x, map_size.position.x + map_size.size.x):
		for y in range(map_size.position.y, map_size.position.y + map_size.size.y):
			var tile_pos = Vector2(x, y)
			if tilemap.get_cell_source_id(0, tile_pos) == 0:  # Check for tile ID 0
				possible_tiles.append(tile_pos)
	
	if possible_tiles.size() > 0:
		var random_tile = possible_tiles[randi() % possible_tiles.size()]  # Pick a random tile
		var world_position = tilemap.map_to_local(random_tile)  # Convert tile position to world position
		
		# Instance the nutrient and add it to the scene
		var nutrient = nutrient_scene.instantiate()
		nutrient.position = world_position
		add_child(nutrient)
