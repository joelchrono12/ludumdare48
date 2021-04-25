extends "res://Statemachine.gd"

func _ready():
	add_state("idle")
	add_state("move")
	add_state("jump")
	add_state("glide")
	add_state("fall")
	add_state("dash")
	add_state("wall_slide")
	add_state("dead")
	add_state("victory")
	call_deferred("set_state",states.idle)


func _input(event):
	if [states.idle,states.move,states.fall].has(state):
		if event.is_action_pressed("jump") and parent.move_speed!=0:
			parent.snap = Vector2.ZERO
			if parent.is_on_floor() or !parent.coyote_timer.is_stopped():
				parent.coyote_timer.stop()
				parent.jump()
	if [states.fall,states.jump].has(state) and parent.has_gas:
		if event.is_action_pressed("glide"):
			set_state(states.glide)
	if state == states.glide:
		if event.is_action_released("glide"):
			set_state(states.fall)
	if state == states.jump:
		if event.is_action_released("jump"):
			parent.cut_jump()
	if state == states.wall_slide:
		print(parent.is_on_floor(), parent.has_gas)
		if event.is_action_pressed("jump") and parent.has_gas:
			print("Jumping from wall slide")
			parent.wall_jump()
			set_state(states.jump)
		if !parent.has_gas:
			set_state(states.fall)

func _state_logic(delta):
	parent._apply_gravity(delta)
	if state == states.glide:
		parent.glide()
	if state != states.dead and state !=states.victory:
		parent._update_move_direction()
	parent._update_wall_direction()
	if state!=states.wall_slide and state != states.victory and state !=states.dead:
		parent._handle_move_input()
		
	if state == states.wall_slide:
		parent._apply_wall_stick()
		parent._cap_gravity_wall_slide()
		parent._handle_wall_slide_stickyness()
	parent._apply_movement(delta)



func _get_transition(delta):
	parent.emit_signal("state_change",states,state)
	match state:
		states.idle:
			if !parent.is_on_floor():
				if parent.velocity.y<0:
					return states.jump
				elif parent.velocity.y>=0:
					return states.fall
			elif abs(parent.velocity.x) >= 5:
				return states.move
		states.move:
			if !parent.is_on_floor():
				if parent.velocity.y<0:
					return states.jump
				elif parent.velocity.y>=0:
					return states.fall
			elif abs(parent.velocity.x) <5:
				return states.idle
		states.jump:
			if parent.wall_direction !=0 and parent.wall_slide_cooldown.is_stopped() and !parent.is_on_edge and parent.has_gas: # and Input.is_action_pressed("dash"):
				return states.wall_slide
			elif parent.is_on_floor():
				return states.idle
			elif parent.velocity.y>=0:
				return states.fall
		states.fall:
			if parent.wall_direction !=0 and parent.wall_slide_cooldown.is_stopped() and !parent.is_on_edge and parent.has_gas:# and Input.is_action_pressed("dash"):
				return states.wall_slide
			elif parent.is_on_floor():
				squash()
				return states.idle
			elif parent.velocity.y<0:
				return states.jump 
		states.wall_slide:
			if parent.is_on_floor() and parent.slide_velocity == 0:
				return states.idle
			elif parent.wall_direction == 0 or parent.is_on_edge:
				return states.fall
		states.glide:
			if parent.is_on_floor() or !parent.has_gas:
				return states.idle
	return null


func _enter_state(new_state,old_state):
	print(states.keys()[state])
	match new_state:
		states.idle:
			parent.snap = Vector2.DOWN*12
			parent.anim_player.play("idle")
		states.move:
			parent.snap = Vector2.DOWN*12
			parent.anim_player.play("move")
		states.jump:
			if old_state == states.wall_slide:
				if parent.jetpack_limit.wait_time >= 0:
					parent.jetpack_limit.wait_time -= 0.7
			parent.anim_player.play("jump")
		states.fall:
			parent.anim_player.play("fall")
		states.wall_slide:
			if parent.stick_to_wall:
				pass 
			elif !parent.stick_to_wall: 
				pass
			parent._stick_to_moving_walls()
			parent.emit_signal("wall_slide_state")
			parent.velocity.y = -20
			parent.cam.change_drag_margin(0.1,0.1)
			parent.anim_player.play("grab")
			parent.body.scale.x = parent.wall_direction
		states.dead:
			parent.die()
			parent.velocity.x = 0.0
			parent.anim_player.play("dead")
		states.victory:
			parent.velocity.x = 0.0
			parent.anim_player.play("victory")
		states.glide:
			parent.jetpack_limit.start()


func _exit_state(old_state,new_state):
	match old_state:
		states.wall_slide:
			parent.moving_rightcast.set_deferred("enabled",false)
			parent.moving_leftcast.set_deferred("enabled",false)
			parent.emit_signal("wall_slide_exited")
			parent.cam.change_drag_margin(0.2,0.2)
			#parent.grabbing_shape.set_deferred("disabled",true)
			parent.wall_slide_cooldown.start()
		states.glide:
			parent.jetpack_limit.wait_time = parent.jetpack_limit.time_left


func set_state(new_state):
	previous_state = state
	state=new_state
	
	if previous_state!=null:
		_exit_state(previous_state,new_state)
	if new_state!=null:
		_enter_state(new_state,previous_state)


func squash():
	parent.effect_player.stop()
	parent.effect_player.play("land")


func _on_WallslideStick_timeout():
	if state == states.wall_slide:
		set_state(states.fall)


func _on_Player_killed():
	set_state(states.dead)


func _on_Player_victory():
	set_state(states.victory)



func _on_JetpackLimit_timeout() -> void:
	if state == states.wall_slide:
		set_state(states.fall)
