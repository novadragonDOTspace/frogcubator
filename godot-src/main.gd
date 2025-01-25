extends Node2D
@onready var Frog: Frog
@onready var label: RichTextLabel = $RichTextLabel
@export var PackedSceneFrog: PackedScene
@export var DeathPenalty: int
@export var VitalityIncrease: int
enum GlobalStateEnum {main, game, pause, result}
var state: GlobalStateEnum
var prePauseState: GlobalStateEnum

var score: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	InstanceFrog()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !Frog == null:
		label.text = "Score:" + str(score) + "\n" + "Current: " + str(Frog.CurrentLungenKapazität) + "\n" + "Timer:" + str(Frog.VitalTimer.time_left)
	else:
		label.text = "Score:" + str(score)

func _on_end_timer_timeout() -> void:
		state = GlobalStateEnum.result

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_button"):
		PauseSwitcher()
		
		
func PauseSwitcher() -> void:
	if state == GlobalStateEnum.pause:
		state = prePauseState
		Frog.state = Frog.PrePauseState
		Frog.LungenKollapsierer.paused = false
		$PauseScreen.visible = false
	else:
		prePauseState = state
		state = GlobalStateEnum.pause
		Frog.PrePauseState = Frog.state
		Frog.state = Frog.StateEnum.pause
		Frog.LungenKollapsierer.paused = true
		$PauseScreen.visible = true

	
func _on_frog_base_scene_death(allegiance: bool, cause: Variant) -> void:
	print("BSCD")
	if allegiance:
		score -= DeathPenalty
	else:
		score += VitalityIncrease
	if (cause == Frog.StateEnum.splode):
		$Splosion.show()
		$Splosion/Timer.start()
	else:
		InstanceFrog()

	
func _on_frog_base_scene_vital(allegiance: bool) -> void:
	print("BSCV")
	if allegiance:
		score += VitalityIncrease
	else:
		score -= DeathPenalty
	InstanceFrog()

func InstanceFrog():
	Frog = PackedSceneFrog.instantiate()
	Frog.scale = Vector2(5, 5)
	Frog.position = $FrogPos.position
	Frog.death.connect(_on_frog_base_scene_death.bind())
	Frog.vital.connect(_on_frog_base_scene_vital.bind())
	add_child(Frog)


func _on_splosion_timer_timeout() -> void:
	$Splosion.hide()
	InstanceFrog()
