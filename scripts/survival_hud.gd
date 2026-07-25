extends Node

@onready var health_row:HBoxContainer=$HealthRow
@onready var hunger_row:HBoxContainer=$HungerRow
@onready var thirst_row:HBoxContainer=$ThirstRow
@onready var warmth_row:HBoxContainer=$WarmthRow
@onready var breath_row:HBoxContainer=$BreathRow

var pulse_tween:Tween=null
@warning_ignore("unused_parameter")
func _process(delta):
	health_row.update_value(GameManager.player_health,GameManager.MAX_PLAYER_HEALTH)
	hunger_row.update_value(GameManager.hunger,GameManager.MAX_HUNGER)
	thirst_row.update_value(GameManager.thirst,GameManager.MAX_THRIST)
	warmth_row.update_value(GameManager.warmth,GameManager.MAX_WARMTH)
	breath_row.visible=GameManager.in_water
	if GameManager.in_water:
		breath_row.update_value(GameManager.breath,GameManager.MAX_BREATH)
		
	var stamina_bar=get_tree().current_scene.get_node_or_null("CanvasLayer/StaminaBar")
	if stamina_bar:
		stamina_bar.value=GameManager.stamina
		stamina_bar.visible=GameManager.stamina<GameManager.MAX_STAMINA
		
	_update_low_health_pulse()
	
	var flight_bar=get_tree().current_scene.get_node_or_null("CanvasLayer/FlightBar")
	if flight_bar:
		flight_bar.value=GameManager.flight_energy
		flight_bar.visible=GameManager.has_wings()
	
	var flight_label=get_tree().current_scene.get_node_or_null("CanvasLayer/FlightBar/Flight_label")
	if flight_label:
		flight_label.visible=GameManager.has_wings()
		if GameManager.flight_energy<=0.0:
			flight_label.text="✦ Recharging..."
			flight_label.modulate=Color(0.7,0.5,0.2)
		elif GameManager.is_flying:
			flight_label.text="✦ Flying"
			flight_label.modulate=Color(1.0,0.85,0.3)
		else:
			flight_label.text="✦ Emberwing"
			flight_label.modulate=Color(0.9,0.75,0.3)
func _update_low_health_pulse():
	var health_pct=float(GameManager.player_health)/float(GameManager.MAX_PLAYER_HEALTH)
	if health_pct<0.3 and (pulse_tween==null or not pulse_tween.is_running()):
		pulse_tween=create_tween().set_loops()
		pulse_tween.tween_property(health_row,"scale",Vector2(1.1,1.1),0.3)
		pulse_tween.tween_property(health_row,"scale",Vector2(1.0,1.0),0.3)
	elif health_pct>=0.3:
		if pulse_tween:
			pulse_tween.kill()
			pulse_tween=null
		health_row.scale=Vector2(1.0,1.0)
