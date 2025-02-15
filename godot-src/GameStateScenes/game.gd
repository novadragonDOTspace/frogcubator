extends CanvasLayer

@onready var debug_data: RichTextLabel = $DebugData
@export var PackedSceneFrog: PackedScene

@onready var Frog_Asset: Frog
var frogs_processed: int

@onready var score_keeper: Node = $ScoreKeeper

@onready var end_timer: Timer = $EndTimer
@onready var current_frog_timer: Control = $CurrentFrogTimer/TextureProgressBar
@onready var end_timer_bar: Control = $EndTimerBar/TextureProgressBar
@onready var EndTimer: Timer = $EndTimer

@export var FrogRessources: Array[FrogAssets]
@export var AllFrogs: Array[FrogAssets]
@export var sprüche: Array[AudioStream]


@export var EvilFrogs: Array[FrogAssets]

func _ready() -> void:
	FrogRessources.append_array(AllFrogs)
	FrogRessources.append(EvilFrogs.pick_random())
	FrogRessources.append(EvilFrogs.pick_random())

func Process(delta: float) -> void:
	if !Frog_Asset == null:
		$Schlauch.global_position = Frog_Asset.Schlauchpunkt.global_position
		current_frog_timer.value = Frog_Asset.VitalTimer.time_left / Frog_Asset.VitalTimer.wait_time * 100
		end_timer_bar.value = ceil($EndTimer.time_left)/ $EndTimer.wait_time * 100

func InstanceFrog():
	Frog_Asset = PackedSceneFrog.instantiate()
	Frog_Asset.scale = Vector2(5, 5)
	Frog_Asset.position = $FrogPos.position
	Frog_Asset.death.connect(_on_frog_base_scene_death.bind())
	Frog_Asset.vital.connect(_on_frog_base_scene_vital.bind())
	Frog_Asset.LungenKollapsPerSekunde += randf_range(-frogs_processed, frogs_processed/2) + frogs_processed/2
	Frog_Asset.initialize($FrogPos.position, FrogRessources.pick_random())
	add_child(Frog_Asset)
	
	
	
func _on_frog_base_scene_death(allegiance: bool, cause: Variant, names: String) -> void:
	print("BSCD")
	FrogRessources.append(AllFrogs.pick_random())

	frogs_processed += 1
	score_keeper.KilledAFrog(allegiance, cause)
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
	score_keeper.SavedAFrog(allegiance)

	var frog: FrogAssets = null
	for i in range(FrogRessources.size()-1):
		if frog==null:
			if FrogRessources[i].Name == names:
				frog = FrogRessources[i]
	
	FrogRessources.append(frog)

	frogs_processed += 1
	$Schlauch.hide()
	Frog_Asset.VitalTimer.stop()

func _on_splosion_timer_timeout() -> void:
	$Splosion.hide()
	InstanceFrog()

func _on_pop_2_finished() -> void:
	Frog_Asset.queue_free()
	InstanceFrog()
	$Game/Schlauch.show()
	
func Game_Start() -> void:
	if Frog_Asset != null:
		Frog_Asset.queue_free()
	frogs_processed = 0
	score_keeper.Reset()
	
	InstanceFrog()
	self.show()
	EndTimer.start()
