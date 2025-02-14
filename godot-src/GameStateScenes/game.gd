extends CanvasLayer

@onready var debug_data: RichTextLabel = $DebugData
var score: int
@onready var Frog_Asset: Frog
var frogs_processed: int
var frogs_killed: int = 0
var frogs_saved: int = 0
var nazis_killed: int = 0
var nazis_saved: int = 0
@onready var end_timer: Timer = $EndTimer
@onready var current_frog_timer: Control = $CurrentFrogTimer/TextureProgressBar
@onready var end_timer_bar: Control = $EndTimerBar/TextureProgressBar

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !Frog_Asset == null:
		$Schlauch.global_position = Frog_Asset.Schlauchpunkt.global_position
		current_frog_timer.value = Frog_Asset.VitalTimer.time_left / Frog_Asset.VitalTimer.wait_time * 100
		end_timer_bar.value = ceil($Game/EndTimer.time_left)/ $EndTimer.wait_time * 100
	else:
		debug_data.text = "EndTimer:" + str(ceil($Game/EndTimer.time_left)) + "Score:" + str(score) + "\n" + "Frogs Processed:" + str(frogs_processed) + "\n" + "Frogs killed:" + str(frogs_killed) + " Nazis killed: " + str(nazis_killed) + "\n Frogs Saved:" + str(frogs_saved) + " Nazis Saved:" + str(nazis_saved)
