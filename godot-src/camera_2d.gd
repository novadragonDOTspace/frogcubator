extends Camera2D

@export var scroll_sensitivity = 0.1
@export var goal_zoom = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	zoom = zoom.move_toward(Vector2(goal_zoom, goal_zoom), 1 + scroll_sensitivity)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_in"):
		goal_zoom *= 1 + scroll_sensitivity
	if event.is_action_pressed("scroll_out"):
		goal_zoom /= 1 + scroll_sensitivity
	if event.is_action_pressed("scroll_reset"):
		goal_zoom = 1
