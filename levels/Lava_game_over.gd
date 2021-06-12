extends Area2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var trigger = $LavaTrigger
onready var collision = $CollisionShape2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Lava_body_entered(body: Node) -> void:

	if body.name == "Player":
		collision.set_deferred("disabled",true)
#		print("Player ded")
		body.die() 
		body.emit_signal("killed")


func _on_LavaTrigger_body_entered(body: Node) -> void:
	if body.name == "Player":
		get_parent().lava_tween.start()
		get_parent().player.cam_shake.play("cam_shake (copy)")
		trigger.queue_free()
		get_parent().cam.get_node("Label").hide()
