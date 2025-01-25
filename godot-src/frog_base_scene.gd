extends Node2D


var FrogScalar: Vector2
var InputFloat: float
@onready var FrogBody: Area2D = $FrogBody
@onready var timer: Timer = $FrogBody/Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	InputFloat = Input.get_action_raw_strength("blow")
	
		
	if (timer.time_left != 0 and InputFloat == 0):
		FrogScalar = Vector2(timer.time_left / 2, timer.time_left / 2)
	else:
		FrogScalar = Vector2(InputFloat / 2, InputFloat / 2)
	
	FrogBody.scale = FrogBody.scale + (FrogScalar * Vector2(0.75, 1))
	if (FrogBody.scale > Vector2(1, 1)):
		FrogBody.scale = FrogBody.scale - Vector2(0.1 * 0.75, 0.1)
	if (FrogBody.scale < Vector2(1, 1)):
		FrogBody.scale = Vector2(1, 1)
	print(FrogScalar)
	
func _input(event: InputEvent) -> void:
	if event.is_action("single_pump"):
		timer.start()


func _on_frog_body_body_entered(body: Node2D) -> void:
	print(body.name)
