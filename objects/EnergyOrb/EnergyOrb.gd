extends Area2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var anim_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 
func _on_EnergyOrb_body_entered(body: Node) -> void:
	if body.name == "Player":
		var available_space = 1.5 - body.jetpack_limit.wait_time 
		if available_space > .6:
			body.jetpack_limit.wait_time += .6
			body.gas_meter.value += .6
		else:
			body.jetpack_limit.wait_time += available_space
			body.gas_meter.value += available_space
		body.has_gas = true
		anim_player.play("fade")
