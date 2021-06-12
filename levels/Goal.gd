extends Node2D


export var path = "res://levels/World2.tscn"
func _ready() -> void:
	pass # Replace with function body.


func _on_Area2D_body_entered(body: Node) -> void:
	if body.name == "Player":
		body.victory()
		body.emit_signal("victory")
		$ChangeScene.start()
		

func _on_ChangeScene_timeout() -> void:
	get_tree().change_scene(path)
	pass # Replace with function body.
