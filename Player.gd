extends KinematicBody2D

export (int) var speed = 130
export (int) var jump_speed = -250
export (int) var gravity = 700
export (float, 0, 1.0) var friction = 0.1
export (float, 0, 1.0) var acceleration = 0.25


onready var anim_player = $AnimationPlayer
onready var camera = $Camera2D

var velocity = Vector2.ZERO
var dir = 0.0
var can_glide = false

func _ready() -> void:
	anim_player.play("cam_shaking")

func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_speed
	
	if Input.is_action_just_pressed("jump") and !is_on_floor() and velocity.y > 0:
		print("glide")
		velocity.y = 60
		gravity = 13
		
	if is_on_floor():
		gravity = 700


func get_input():
	velocity.x = 0
	dir = Input.get_action_strength("right") - Input.get_action_strength("left")
	velocity.x = dir * speed
	
	

