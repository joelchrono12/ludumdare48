extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

onready var cam = $GoalCam
onready var goal = $Goal
onready var player = $Player
onready var tween = $CamTweener
onready var start_timer = $StartTimer
onready var lava = $Lava
onready var lava_tween = $LavaTweener

export onready var chosen_position = cam.limit_bottom
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cam.position = goal.position
	tween.interpolate_property(cam,"position",cam.position,player.position,.8,Tween.EASE_IN,Tween.EASE_OUT,0)
	tween.interpolate_property(cam,"zoom",cam.zoom,Vector2(1,1),1,Tween.EASE_IN,Tween.EASE_OUT,0)
	lava_tween.interpolate_property(lava,"position",lava.position,Vector2(0, chosen_position),21,Tween.TRANS_LINEAR,Tween.EASE_OUT,0.5)
	start_timer.start()

func _process(delta: float) -> void:
	if Input.is_action_just_released("restart"):
		get_tree().reload_current_scene()


func _on_StartTimer_timeout() -> void:
#	print("movimg to player")
	tween.start()


func _on_CamTweener_tween_all_completed() -> void:
	yield(get_tree().create_timer(0.4),"timeout")
	cam.current = false

	player.statemachine.set_physics_process(true)
	player.cam.current = true
	player.cam.enable_camera = true

	
	
