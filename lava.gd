extends Area2D
var game_started = false
func _ready() -> void:
	pass # Replace with function body.
onready var collision = $CollisionShape2D
func _process(delta: float) -> void:
	pass


func _on_lava_body_entered(body: Node) -> void:
	if body.name == "Player":
		collision.set_deferred("disabled",true)
		print("Player ded")
		body.die() 
		body.emit_signal("killed")
