extends Timer

# Declare variables
var total_time = 60  # Total time in seconds for the level timer
var remaining_time = total_time  
@onready var timer_label: Label = $"../CanvasLayer/TimerLabel"
@onready var game_over_label: Label = $"../CanvasLayer/GameOverLabel"
@onready var game_manager = get_tree().get_nodes_in_group("GameManager")[0]


# Called when the node is ready
func _ready():
	# Update the label at the start
	update_timer_display()
	# Start the timer for every second
	start(1)  # The timer will tick every 1 second

# Update the timer each time the timer "ticks"
func _on_timeout():
	remaining_time -= 1  # Decrease remaining time by 1 second
	update_timer_display()

	if remaining_time <= 0:
		end_game()

# Function to update the timer label
func update_timer_display():
	timer_label.text = str(remaining_time) + "s"

# End game when the timer reaches 0
func end_game():
	stop()  # Stop the timer
	timer_label.hide()  # Hide the timer label
	game_over_label.text = "Soups On!\nYou Replicated " + str(game_manager.get_total_clones()) + " times."    # Set the text to "You Win"
	game_over_label.show()  # Show the You Win label
