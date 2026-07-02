extends Area3D



var player_in_range:bool=false


func _on_body_entered(body):
	if body.name=="Player":
		player_in_range=true

func _on_body_exited(body):
	if body.name=="Player":
		player_in_range=false
		
func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("sleep"):
		_attempt_sleep()
		
func _attempt_sleep():
	var is_safe=GameManager.is_sheltered and GameManager.warmth>30.0
	var nearby_threat=false
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if global_position.distance_to(enemy.global_position)<10.0:
			nearby_threat=true
			break
	if is_safe and not nearby_threat:
		GameManager.time_of_day=7.0
		GameManager.heal_player(GameManager.MAX_PLAYER_HEALTH)
		GameManager.stamina=GameManager.MAX_STAMINA
		print("You sleep peeacefully and wake at dawn")
	elif nearby_threat:
		print("something is too close you cant sleep safe")
	else:
		print("youre not sheltedred enough to rest safely")
