extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = Vector2(global_position.x, get_viewport_rect().get_center().y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
