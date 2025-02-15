extends Node

var frogs_killed: int = 0
var frogs_saved: int = 0
var nazis_killed: int = 0
var nazis_saved: int = 0


@export var DeathPenalty: int
@export var VitalityIncrease: int

var score: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func KilledAFrog(Allegiance: bool, cause):
	if(Allegiance):
		frogs_killed += 1
		score -= DeathPenalty
	else:
		nazis_killed += 1
		if cause != Frog.StateEnum.asphyxiation:
			score += VitalityIncrease
			
func SavedAFrog(Allegiance: bool):
	if(Allegiance):
		frogs_saved += 1
		score += VitalityIncrease
	else:
		nazis_saved += 1
		score -= DeathPenalty

func Reset():
	frogs_killed  = 0
	frogs_saved  = 0
	nazis_killed  = 0
	nazis_saved  = 0
	score = 0
