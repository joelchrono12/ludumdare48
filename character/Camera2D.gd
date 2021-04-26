extends Camera2D

var victory_zoom = false
var enable_camera = false


func _ready():
	enable_camera = true
	pass

func _process(delta):
	if enable_camera == true:
		zoom = zoom.linear_interpolate(Vector2(1,1),0.1)
	elif victory_zoom:
		zoom = zoom.linear_interpolate(Vector2(0.6,0.6),0.1)

func change_drag_margin(left,right):
	drag_margin_left = left
	drag_margin_right = right

func _on_Player_victory():
	change_drag_margin(0,0)
	enable_camera = false
	victory_zoom = true
	
