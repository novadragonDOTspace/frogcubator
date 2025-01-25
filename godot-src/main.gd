extends Node2D
@onready var Frog: Frog
@onready var label: RichTextLabel = $RichTextLabel
@export var PackedSceneFrog: PackedScene
@export var DeathPenalty: int
@export var VitalityIncrease: int
@export var FrogRessources: Array[FrogAssets]
enum GlobalStateEnum {main, game, pause, result}
var state: GlobalStateEnum
var prePauseState: GlobalStateEnum
@export var frogs_processed: int

var score: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(str(FrogRessources.size()))
	InstanceFrog()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	print(str(FrogRessources.size()))

	if !Frog == null:
		label.text = "Score:" + str(score) + "\n" + "Current: " + str(Frog.CurrentLungenKapazität) + "\n" + "Timer:" + str(Frog.VitalTimer.time_left)
		$Schlauch.global_position = Frog.Schlauchpunkt.global_position

	else:
		label.text = "Score:" + str(score)

	$VictoryScreen/Label.text = "Score:" + str(score)

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
		Frog.VitalTimer.paused = false
		$PauseScreen.visible = false
	else:
		prePauseState = state
		state = GlobalStateEnum.pause
		Frog.PrePauseState = Frog.state
		Frog.state = Frog.StateEnum.pause
		Frog.LungenKollapsierer.paused = true
		Frog.LungenKollapsPerSekunde += frogs_processed
		$PauseScreen.visible = true
		Frog.VitalTimer.paused = true


	
func _on_frog_base_scene_death(allegiance: bool, cause: Variant) -> void:
	print("BSCD")
	frogs_processed+=1

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
	frogs_processed+=1
	InstanceFrog()

func InstanceFrog():
	Frog = PackedSceneFrog.instantiate()
	Frog.scale = Vector2(5, 5)
	Frog.position = $FrogPos.position
	Frog.death.connect(_on_frog_base_scene_death.bind())
	Frog.vital.connect(_on_frog_base_scene_vital.bind())
	Frog.initialize($FrogPos.position, FrogRessources.pick_random())
	add_child(Frog)

func _on_splosion_timer_timeout() -> void:
	$Splosion.hide()
	InstanceFrog()
