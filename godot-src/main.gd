extends Node2D
@onready var label: RichTextLabel = $Game/DebugData
@export var adi: FrogAssets

enum GlobalStateEnum {main, game, pause, result, credits}
var state: GlobalStateEnum
var prePauseState: GlobalStateEnum

@onready var timerProgress: TextureProgressBar = 		$Game/RadialBar/TextureProgressBar

var start_barrier: float = 50;
var starter = 0;
 

var score: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SerialStuffs.RPMReader.connect(_on_serial_stuffs_rpm_reader)
	$TitleScreen/Button3.pressed.connect(Game_Start)
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
			$Game.Process(delta)
		GlobalStateEnum.result:
			pass
		GlobalStateEnum.main:
			$TitleScreen/RadialBar/TextureProgressBar.value = starter / start_barrier * 100
			if starter > start_barrier:
				Game_Start()
		_:
			if !$Game.Frog_Asset == null:
				$Game.Frog_Asset.state = $Game.Frog_Asset.StateEnum.pause


func _on_end_timer_timeout() -> void:
	state = GlobalStateEnum.result
	if $Game.Frog_Asset != null:
		$Game.Frog_Asset.state = $Game.Frog_Asset.StateEnum.pause
		$Game.Frog_Asset.LungenKollapsierer.paused = true
		$Game.Frog_Asset.VitalTimer.paused = true
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
		$Game.Frog_Asset.state = $Game.Frog_Asset.PrePauseState
		$Game.Frog_Asset.LungenKollapsierer.paused = false
		$Game.Frog_Asset.VitalTimer.paused = false
		$PauseScreen.visible = false
		$Game/EndTimer.paused = false

	else:
		$Game/EndTimer.paused = true
		prePauseState = state
		state = GlobalStateEnum.pause
		$Game.Frog_Asset.PrePauseState = $Game.Frog_Asset.state
		$Game.Frog_Asset.state = $Game.Frog_Asset.StateEnum.pause
		$Game.Frog_Asset.LungenKollapsierer.paused = true
		$PauseScreen.visible = true
		$Game.Frog_Asset.VitalTimer.paused = true









func _on_button_pressed() -> void:
	state = GlobalStateEnum.game
	Game_Start()





func _on_serial_stuffs_rpm_reader(ink: float) -> void:
	if state == GlobalStateEnum.game:
		$Game.Frog_Asset.Pump_rpm(ink)
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
	state = GlobalStateEnum.game
	$VictoryScreen.hide()
	$TitleScreen.hide()
	$Game.Game_Start()


func _on_timer_timeout() -> void:
	starter -= 1
