extends Area3D

@export var location_name:String="Unknown Place"
@export var location_type:String="friendly"
var triggered:bool=false

func _ready():
	body_entered.connect(_on_body_entered)
	if location_name in GameManager.discovered_locations:
		triggered=true
		
func _on_body_entered(body):
	if body.name=="Player" and not triggered:
		triggered=true
		GameManager.discovered_locations.append(location_name)
		_show_discovery()
		
func _show_discovery():
	var label=get_tree().current_scene.get_node("CanvasLayer/LocationLabel")
	label.text=location_name
	if location_type=="hostile":
		label.modulate=Color(1,0.3,0.3)
	else:
		label.modulate=Color(0.9,0.85,0.6)
	label.visible=true
	var tween=create_tween()
	tween.tween_interval(2.5)
	tween.tween_property(label,"modulate:a",0.0,1.0)
	tween.tween_callback(func(): label.visible = false)
	
