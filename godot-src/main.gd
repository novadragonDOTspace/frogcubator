extends Node2D
@onready var Frog: Frog
@onready var label: RichTextLabel = $RichTextLabel
@export var PackedSceneFrog: PackedScene
@export var adi: FrogAssets
@export var DeathPenalty: int
@export var VitalityIncrease: int
@export var FrogRessources: Array[FrogAssets]
@export var sprüche: Array[AudioStream]
enum GlobalStateEnum {main, game, pause, result, credits}
var state: GlobalStateEnum
var prePauseState: GlobalStateEnum
@export var frogs_processed: int
@onready var timerProgress: TextureProgressBar = 		$RadialBar/TextureProgressBar

var start_barrier: float = 50;
var starter = 0;
 

var score: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state = GlobalStateEnum.main
	
	# InstanceFrog()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	match state:
		GlobalStateEnum.game:
			if !Frog == null:
				label.text = "Score:" + str(score) + "\n" + "Current: " + str(Frog.CurrentLungenKapazität) + "\n" + "Timer:" + str(Frog.VitalTimer.time_left)
				$Schlauch.global_position = Frog.Schlauchpunkt.global_position
				timerProgress.value = Frog.VitalTimer.time_left / Frog.VitalTimer.wait_time * 100

			else:
				label.text = "Score:" + str(score)

			$VictoryScreen/Label.text = "Score:" + str(score)
		GlobalStateEnum.result:
			pass
		GlobalStateEnum.main:
			$TitleScreen/RadialBar/TextureProgressBar.value = starter / start_barrier * 100
			if starter > start_barrier:
				Game_Start()
		_:
			Frog.state = Frog.StateEnum.pause


func _on_end_timer_timeout() -> void:
		state = GlobalStateEnum.result
		Frog.queue_free()
		$VictoryScreen.show()


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
		$EndTimer.paused = false

	else:
		$EndTimer.paused = true
		prePauseState = state
		state = GlobalStateEnum.pause
		Frog.PrePauseState = Frog.state
		Frog.state = Frog.StateEnum.pause
		Frog.LungenKollapsierer.paused = true
		Frog.LungenKollapsPerSekunde += frogs_processed
		$PauseScreen.visible = true
		Frog.VitalTimer.paused = true


func _on_frog_base_scene_death(allegiance: bool, cause: Variant, names: String) -> void:
	print("BSCD")


	var frog: int = -1
	for i in range(FrogRessources.size()-1):
		if frog==-1:
			if FrogRessources[i].Name == names:
				frog = i
	
	FrogRessources.remove_at(frog)

	frogs_processed += 1
	
	if allegiance:
		score -= DeathPenalty
	else:
		score += VitalityIncrease
	if (cause == Frog.StateEnum.splode):
		$Pop.play()
		$Splosion.show()
		$Splosion/Timer.start()
	else:
		InstanceFrog()

	
func _on_frog_base_scene_vital(allegiance: bool, names: String) -> void:
	print("BSCV")
	
	$Pop2.stream = sprüche.pick_random()
	$Pop2.play()
	if allegiance:
		score += VitalityIncrease
	else:
		score -= DeathPenalty

	var frog: FrogAssets = null
	for i in range(FrogRessources.size()-1):
		if frog==null:
			if FrogRessources[i].Name == names:
				frog = FrogRessources[i]
	
	FrogRessources.append(frog)

	frogs_processed += 1
	$Schlauch.hide()
	Frog.VitalTimer.stop()




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


func _on_button_pressed() -> void:
	pass # Replace with function body.
	frogs_processed = 0
	score = 0
	state = GlobalStateEnum.game
	$VictoryScreen.hide()
	InstanceFrog()
	$EndTimer.start()


func _on_pop_2_finished() -> void:
	Frog.queue_free()
	InstanceFrog()
	$Schlauch.show()


func _on_serial_stuffs_rpm_reader(ink: float) -> void:
	if state == GlobalStateEnum.game:
		Frog.Pump_rpm(ink)
	elif state == GlobalStateEnum.main:
		if ink > 2500:
			starter += ink/100


func _on_button_2_pressed() -> void:
	state = GlobalStateEnum.credits
	$CreditsScreen.show()
	$VictoryScreen.hide()


func _on_close_button_pressed() -> void:
	state = GlobalStateEnum.result
	$CreditsScreen.hide()
	$VictoryScreen.show()


func Game_Start() -> void:
	state = GlobalStateEnum.game
	$TitleScreen.hide()
	InstanceFrog()


func _on_timer_timeout() -> void:
	starter -= 1
