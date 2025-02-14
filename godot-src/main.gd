extends Node2D
@onready var Frog_Asset: Frog
@onready var label: RichTextLabel = $Game/DebugData
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
var frogs_killed: int = 0
var frogs_saved: int = 0
var nazis_killed: int = 0
var nazis_saved: int = 0
@onready var timerProgress: TextureProgressBar = 		$Game/RadialBar/TextureProgressBar

var start_barrier: float = 50;
var starter = 0;
 

var score: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SerialStuffs.RPMReader.connect(_on_serial_stuffs_rpm_reader)
	$TitleScreen/Button3.pressed.connect(Game_Start)
	$Game/Splosion/Timer.timeout.connect(_on_splosion_timer_timeout)
	$Game/Pop2.finished.connect(_on_pop_2_finished)
	$Game/EndTimer.timeout.connect(_on_end_timer_timeout)
	$VictoryScreen/Button.pressed.connect(_on_button_pressed)
	$VictoryScreen/Button2.pressed.connect(_on_button_2_pressed)
	$CreditsScreen/Button.pressed.connect(_on_close_button_pressed)
	state = GlobalStateEnum.main
	$music.play()
	
	# InstanceFrog()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match state:
		GlobalStateEnum.game:
			if !Frog_Asset == null:
				label.text = "EndTimer:" + str(ceil($Game/EndTimer.time_left)) +  "\n Score:" + str(score) + "\n" + "Current: " + str(Frog_Asset.CurrentLungenKapazität) + "\n" + "Timer:" + str(Frog_Asset.VitalTimer.time_left) + "\n" + "Frogs Processed:" + str(frogs_processed) + "\n" + "Frogs killed:" + str(frogs_killed) + "\n Frogs Saved:" + str(frogs_saved) + "\n Nazis killed: " + str(nazis_killed) + "\n Nazis saved: " + str(nazis_saved)
				$Game/Schlauch.global_position = Frog_Asset.Schlauchpunkt.global_position
				timerProgress.value = Frog_Asset.VitalTimer.time_left / Frog_Asset.VitalTimer.wait_time * 100
				$Game/RadialBar2/TextureProgressBar.value = ceil($Game/EndTimer.time_left)/ $Game/EndTimer.wait_time * 100
			else:
				label.text = "EndTimer:" + str(ceil($Game/EndTimer.time_left)) + "Score:" + str(score) + "\n" + "Frogs Processed:" + str(frogs_processed) + "\n" + "Frogs killed:" + str(frogs_killed) + " Nazis killed: " + str(nazis_killed) + "\n Frogs Saved:" + str(frogs_saved) + " Nazis Saved:" + str(nazis_saved)

			$VictoryScreen/Label.text = "Score:" + str(score) + "\n" + "Frogs Processed:" + str(frogs_processed) + "\n" + "Frogs killed:" + str(frogs_killed) + " Nazis killed: " + str(nazis_killed) + "\n Frogs Saved:" + str(frogs_saved) + " Nazis Saved:" + str(nazis_saved)
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
		Frog_Asset.LungenKollapsPerSekunde += randi_range(0, frogs_processed)
		$PauseScreen.visible = true
		Frog_Asset.VitalTimer.paused = true


func _on_frog_base_scene_death(allegiance: bool, cause: Variant, names: String) -> void:
	print("BSCD")
	FrogRessources.append(AllFrogs.pick_random())

	frogs_processed += 1
	if allegiance:
		score -= DeathPenalty
		frogs_killed += 1
	else:
		score += VitalityIncrease
		nazis_killed += 1
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
		frogs_saved += 1
	else:
		score -= DeathPenalty
		nazis_saved += 1

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
		Frog_Asset.LungenKollapsPerSekunde += randf_range(-frogs_processed, frogs_processed/2) + frogs_processed/2
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
	frogs_saved = 0
	frogs_killed = 0
	nazis_killed = 0
	nazis_saved = 0
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
		if ink > 1750:
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
	frogs_processed = 0
	frogs_saved = 0
	frogs_killed = 0
	nazis_killed = 0
	nazis_saved = 0
	$Game/EndTimer.start()
	state = GlobalStateEnum.game
	$TitleScreen.hide()
	InstanceFrog()


func _on_timer_timeout() -> void:
	starter -= 1
