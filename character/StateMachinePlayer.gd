extends "res://scripts/baseSM.gd"

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
		if event.is_action_pressed("jump") and parent.has_gas:
			parent.wall_jump()
			set_state(states.jump)

func _state_logic(delta):
	parent.sm.text = str(states.keys()[state])
	parent._apply_gravity(delta)
	if state == states.glide:
		parent.glide(delta)
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
			if parent.wall_direction !=0 and parent.wall_slide_cooldown.is_stopped() and !parent.is_on_edge and Input.is_action_pressed("climb"):# and parent.has_gas: # and Input.is_action_pressed("dash"):
				return states.wall_slide
			elif parent.is_on_floor():
				return states.idle
			elif parent.velocity.y>=0:
				return states.fall
		states.fall:
			if parent.wall_direction !=0 and parent.wall_slide_cooldown.is_stopped() and !parent.is_on_edge and parent.move_direction != 0 and Input.is_action_pressed("climb"):# and parent.has_gas:# and Input.is_action_pressed("dash"):
				return states.wall_slide
			elif parent.is_on_floor():
				squash()
				return states.idle
			elif parent.velocity.y<0:
				return states.jump 
		states.wall_slide:
			if parent.is_on_floor() or parent.slide_velocity == 0:
				return states.idle
			elif parent.wall_direction == 0 or parent.is_on_edge:
				return states.fall
		states.glide:
			if parent.is_on_floor() or !parent.has_gas:
				return states.idle
	return null


func _enter_state(new_state,old_state):

	match new_state:
		states.idle:
			parent.snap = Vector2.DOWN*2
			parent.anim_player.play("idle")
		states.move:
			parent.snap = Vector2.DOWN*2
			parent.anim_player.play("move")
		states.jump:
			if old_state == states.wall_slide:
				if parent.jetpack_limit.wait_time < 0.6:
					parent.has_gas = false
					parent.gas_meter.value = 0
				parent.jetpack_limit.wait_time -= 0.3
				parent.gas_meter.value -= 0.3
			else:
				Sfx.jump()
				
			parent.anim_player.play("jump")
		states.fall:
			parent.anim_player.play("fall")
		states.wall_slide:
			Sfx.grab()
			parent._stick_to_moving_walls()
			parent.emit_signal("wall_slide_state")
			parent.velocity.y = -20
			parent.cam.change_drag_margin(0.1,0.1)
			parent.anim_player.play("grab")
			parent.body.scale.x = parent.wall_direction
		states.dead:
			Sfx.die()
			parent.die()
			parent.velocity.x = 0.0
			parent.anim_player.play("dead")
		states.victory:
			parent.velocity.x = 0.0
			parent.anim_player.play("victory")
		states.glide:
			Sfx.glide()
			parent.anim_player.play("glide")
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
			parent.jp_acceleration = -900
			parent.jetpack_limit.wait_time = parent.jetpack_limit.time_left
			parent.jetpack_limit.stop()
			parent.propulsion.emitting = false



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
