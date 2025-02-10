extends Node2D
@onready var Frog_Asset: Frog
@onready var label: RichTextLabel = $Game/RichTextLabel
@export var PackedSceneFrog: PackedScene
@export var adi: FrogAssets
@export var DeathPenalty: int
@export var VitalityIncrease: int
@export var FrogRessources: Array[FrogAssets]
@export var AllFrogs: Array[FrogAssets]

@export var sprüche: Array[AudioStream]
enum GlobalStateEnum {main, game, pause, result, credits}
var state: GlobalStateEnum
var prePauseState: GlobalStateEnum
@export var frogs_processed: int
@onready var timerProgress: TextureProgressBar = 		$Game/RadialBar/TextureProgressBar

var start_barrier: float = 50;
var starter = 0;
 

var score: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state = GlobalStateEnum.main
	$music.play()
	
	# InstanceFrog()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	match state:
		GlobalStateEnum.game:
			if !Frog_Asset == null:
				label.text = "Score:" + str(score) + "\n" + "Current: " + str(Frog_Asset.CurrentLungenKapazität) + "\n" + "Timer:" + str(Frog_Asset.VitalTimer.time_left)
				$Game/Schlauch.global_position = Frog_Asset.Schlauchpunkt.global_position
				timerProgress.value = Frog_Asset.VitalTimer.time_left / Frog_Asset.VitalTimer.wait_time * 100

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
			if !Frog_Asset == null:
				Frog_Asset.state = Frog_Asset.StateEnum.pause


func _on_end_timer_timeout() -> void:
		state = GlobalStateEnum.result
		if Frog_Asset != null:
			Frog_Asset.state = Frog_Asset.StateEnum.pause
			Frog_Asset.LungenKollapsierer.paused = true
			Frog_Asset.VitalTimer.paused = true
		$Game.hide()
		
		$VictoryScreen.show()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_button"):
		PauseSwitcher()
	if event.is_action_pressed("fullscreen"):
		FullScreenSwitcher()
		
func FullScreenSwitcher() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		
func PauseSwitcher() -> void:
	if state == GlobalStateEnum.pause:
		state = prePauseState
		Frog_Asset.state = Frog_Asset.PrePauseState
		Frog_Asset.LungenKollapsierer.paused = false
		Frog_Asset.VitalTimer.paused = false
		$PauseScreen.visible = false
		$Game/EndTimer.paused = false

	else:
		$Game/EndTimer.paused = true
		prePauseState = state
		state = GlobalStateEnum.pause
		Frog_Asset.PrePauseState = Frog_Asset.state
		Frog_Asset.state = Frog_Asset.StateEnum.pause
		Frog_Asset.LungenKollapsierer.paused = true
		Frog_Asset.LungenKollapsPerSekunde += frogs_processed
		$PauseScreen.visible = true
		Frog_Asset.VitalTimer.paused = true


func _on_frog_base_scene_death(allegiance: bool, cause: Variant, names: String) -> void:
	print("BSCD")


	var frog: int = -1
	for i in range(FrogRessources.size()-1):
		if frog==-1:
			if FrogRessources[i].Name == names:
				frog = i
	
	FrogRessources.remove_at(frog)
	FrogRessources.append(AllFrogs.pick_random())

	frogs_processed += 1
	
	if allegiance:
		score -= DeathPenalty
	else:
		score += VitalityIncrease
	if (cause == Frog.StateEnum.splode):
		$Game/Pop.play()
		$Game/Splosion.show()
		$Game/Splosion/Timer.start()
	else:
		InstanceFrog()

	
func _on_frog_base_scene_vital(allegiance: bool, names: String) -> void:
	print("BSCV")
	
	$Game/Pop2.stream = sprüche.pick_random()
	$Game/Pop2.play()
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
	$Game/Schlauch.hide()
	Frog_Asset.VitalTimer.stop()




func InstanceFrog():
	if state == GlobalStateEnum.game:
		Frog_Asset = PackedSceneFrog.instantiate()
		Frog_Asset.scale = Vector2(5, 5)
		Frog_Asset.position = $Game/FrogPos.position
		Frog_Asset.death.connect(_on_frog_base_scene_death.bind())
		Frog_Asset.vital.connect(_on_frog_base_scene_vital.bind())
		Frog_Asset.LungenKollapsPerSekunde += frogs_processed 
		Frog_Asset.initialize($Game/FrogPos.position, FrogRessources.pick_random())
		$Game.add_child(Frog_Asset)

func _on_splosion_timer_timeout() -> void:
	$Game/Splosion.hide()
	InstanceFrog()


func _on_button_pressed() -> void:
	if Frog_Asset != null:
		Frog_Asset.queue_free()
	pass # Replace with function body.
	frogs_processed = 0
	score = 0
	state = GlobalStateEnum.game
	$VictoryScreen.hide()
	InstanceFrog()
	$Game.show()
	$Game/EndTimer.start()


func _on_pop_2_finished() -> void:
	Frog_Asset.queue_free()
	InstanceFrog()
	$Game/Schlauch.show()


func _on_serial_stuffs_rpm_reader(ink: float) -> void:
	if state == GlobalStateEnum.game:
		Frog_Asset.Pump_rpm(ink)
	elif state == GlobalStateEnum.main:
		if ink > 2250:
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
