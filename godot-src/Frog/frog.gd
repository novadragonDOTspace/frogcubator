extends Area2D
class_name Frog

var nomen: String


@onready var Eyes = $Eyes
@onready var FrogBody: Area2D = $FrogBody
@onready var Schlauchpunkt: Marker2D = $Schlauchpunkt
@onready var Happy: Sprite2D = $Happy
@onready var HappyTimer: Timer = $Happy/Timer

enum StateEnum {goldilocks, splode, asphyxiation, vital, happy, pause}
var state: StateEnum
var PrePauseState: StateEnum

signal death(allegiance: bool, state: StateEnum, name: String)
signal vital(allegiance: bool, name: String)

var FrogScalar: float
var MaxLungenKapazität: float = 500
var MinLungenKapazität: float = 100
var CurrentLungenKapazität: float
var MaxGoldiLocks: float
var MinGoldiLocks: float
var LungenKollapsPerSekunde: float = 2
var InputFloat: float
var Allegiance: bool = true

@onready var VitalTimer: Timer = $VitalTimer
@onready var LungenKollapsierer: Timer = $LungenKollapsierer


func initialize(pos, frogres: FrogAssets):
	print(frogres.Name)
	position = pos
	var body: Sprite2D = $Body
	body.texture = frogres.Body
	Allegiance = frogres.Allegiance
	nomen = frogres.Name
	$Eyes.texture = frogres.Augen
	$ArmLeft.texture = frogres.ArmLef
	$ArmRight.texture = frogres.ArmRight
	$LegLeft.texture = frogres.LegLeft
	$LegRight.texture = frogres.LegRight
	$Nase2.texture = frogres.Nose
	$Accesoire1.texture = frogres.Accesoire1
	$Happy.texture = frogres.Happy
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	global_position = Vector2(get_viewport_rect().get_center().x, global_position.y)

	CurrentLungenKapazität = randf_range(MinLungenKapazität, MaxLungenKapazität)
	VitalTimer.start(randi_range(5,10))
	state = StateEnum.goldilocks


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	match state:
		StateEnum.goldilocks:
	
			CurrentLungenKapazität += InputFloat * 15
			if CurrentLungenKapazität > MaxLungenKapazität:
				print("Splode Size")
				state = StateEnum.splode
			if CurrentLungenKapazität < MinLungenKapazität:
				state = StateEnum.asphyxiation
			FrogScalar = CurrentLungenKapazität / (MinLungenKapazität + MaxLungenKapazität / 2) * 2.5
			scale = Vector2(FrogScalar, FrogScalar)
			InputFloat = 0
		StateEnum.splode:
			print("StateSplode")
			death.emit(Allegiance, state, nomen)
			queue_free()
			# state = StateEnum.goldilocks
		StateEnum.asphyxiation:
			death.emit(Allegiance, state, nomen)
			queue_free()
			# state = StateEnum.goldilocks
		StateEnum.pause:
			pass
		StateEnum.vital:
			vital.emit(Allegiance, nomen)
			state = StateEnum.happy
			FrogIshappy()
		StateEnum.happy:
			pass

		
func _input(event: InputEvent) -> void:
	if state == StateEnum.goldilocks:
		if event.is_action("single_pump"):
			InputFloat = 1
		if event.is_action("blow"):
			InputFloat = Input.get_action_raw_strength("blow")

func Pump_rpm(rpm_size: float):
	if (rpm_size > 0):
		InputFloat = rpm_size / 500

func _on_lungen_kollapsierer_timeout() -> void:
	if state == StateEnum.goldilocks:
		CurrentLungenKapazität -= LungenKollapsPerSekunde


func _on_vital_timer_timeout() -> void:
	state = StateEnum.vital
	vital.emit()

func _on_body_entered(body: Node2D) -> void:
	if (body.name == "Gurke"):
		print("Splode Gurke")
		state = StateEnum.splode

func FrogIshappy():
	$Body.hide()
	$Eyes.hide()
	$ArmLeft.hide()
	$ArmLeft.hide()
	$LegLeft.hide()
	$LegRight.hide()
	$Nase2.hide()
	$Accesoire1.hide()
	$Happy.show()
	

func _on_serial_stuffs_rpm_reader(ink: float) -> void:
	if ink > 3000:
		InputFloat = (ink - 3000) / 100