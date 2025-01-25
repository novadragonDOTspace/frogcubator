extends Node2D
class_name Frog

@export var Legs: Array[CompressedTexture2D]
@export var Eyes: Array[Texture2D]
@onready var LungenKollapsierer: Timer = $LungenKollapsierer


signal death(allegiance: bool, state: StateEnum)
signal vital(allegiance: bool)

var FrogScalar: float
var MaxLungenKapazität: float = 500
var MinLungenKapazität: float = 100
var CurrentLungenKapazität: float
var MaxGoldiLocks: float
var MinGoldiLocks: float
var LungenKollapsPerSekunde: float = 2
var InputFloat: float
var Allegiance: bool = true
enum StateEnum {goldilocks, splode, asphyxiation, vital, pause}
var state: StateEnum
var PrePauseState: StateEnum
@onready var VitalTimer: Timer = $VitalTimer


@onready var EyeLeft = $EyeLeft
@onready var EyeRight = $EyeRight
@onready var FrogBody: Area2D = $FrogBody

func initialize(pos):
	position = pos
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CurrentLungenKapazität = randf_range(MinLungenKapazität, MaxLungenKapazität)
	state = StateEnum.goldilocks


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	match state:
		StateEnum.goldilocks:
			EyeLeft.global_position = $FrogBody/EyeLeft.global_position
			EyeRight.global_position = $FrogBody/EyeRight.global_position

			CurrentLungenKapazität += InputFloat * 15
			if CurrentLungenKapazität > MaxLungenKapazität:
				print("Splode Size")
				state = StateEnum.splode
			if CurrentLungenKapazität < MinLungenKapazität:
				state = StateEnum.asphyxiation
			FrogScalar = CurrentLungenKapazität / (MinLungenKapazität + MaxLungenKapazität / 2) * 3
			FrogBody.scale = Vector2(FrogScalar / 0.75, FrogScalar)
			InputFloat = 0
		StateEnum.splode:
			print("StateSplode")
			death.emit(Allegiance, state)
			queue_free()
			# state = StateEnum.goldilocks
		StateEnum.asphyxiation:
			print("StateAsphyx")
			death.emit(Allegiance, state)
			queue_free()
			# state = StateEnum.goldilocks
		StateEnum.pause:
			print("StatePause")
			pass
		StateEnum.vital:
			print("VitalTimer")
			vital.emit(Allegiance)
			queue_free()

		
func _input(event: InputEvent) -> void:
	if state == StateEnum.goldilocks:
		if event.is_action("single_pump"):
			InputFloat = 1
		if event.is_action("blow"):
			InputFloat = Input.get_action_raw_strength("blow")


func _on_lungen_kollapsierer_timeout() -> void:
	if state == StateEnum.goldilocks:
		CurrentLungenKapazität -= LungenKollapsPerSekunde


func _on_frog_body_area_entered(area: Area2D) -> void:
	if (area.name == "Gurke"):
		print("Splode Gurke")
		state = StateEnum.splode


func _on_vital_timer_timeout() -> void:
	state = StateEnum.vital
	vital.emit()
