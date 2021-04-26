extends Area2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

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
		print("Player ded")
		body.die() 
		body.emit_signal("killed")
