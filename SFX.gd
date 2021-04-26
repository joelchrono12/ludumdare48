extends Node


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var glide = $glide
onready var jump = $jump
onready var die = $die

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$music.play()
	pass # Replace with function body.
func jump():
	jump.play()
	
func glide():
	glide.play()

func die():
	die.play()

func grab():
	$Grab.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_music_finished() -> void:
	$music.play()
