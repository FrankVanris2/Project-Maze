extends Node
class_name StaminaComponent

# --- Stamina related information ---
const MAX_STAMINA = 100.0
var stamina = 100.0
var drain_rate = 40.0
var regen_rate = 30.0
var is_exhausted = false
var exhaustion_penalty_time = 2.0
var current_exhaustion_timer = 0.0

# --- This function runs the math for the Stamina logic needed
func process_stamina(delta: float, trying_to_sprint: bool, is_moving: bool):
	var is_currently_sprinting = false
		
	if is_exhausted:
		# Penalty: Count down the timer before we can regenerate
		current_exhaustion_timer -= delta
		if current_exhaustion_timer <= 0.0:
			is_exhausted = false
	else:
		if trying_to_sprint and is_moving:
			is_currently_sprinting = true
			stamina -= drain_rate * delta
			if stamina <= 0.0:
				stamina = 0.0
				is_exhausted = true
				current_exhaustion_timer = exhaustion_penalty_time
		else: 
			# Not Sprinting? Regenerate stamina smoothly
			if stamina < MAX_STAMINA:
				stamina += regen_rate * delta
				if stamina > MAX_STAMINA:
					stamina = MAX_STAMINA
					
	return is_currently_sprinting
		
				
