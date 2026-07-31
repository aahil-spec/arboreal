extends StaticBody3D


var opened:bool=false
@onready var anim_player:AnimationPlayer=$Sketchfab_Scene/AnimationPlayer

const WINGS_PICKUP=preload("res://scenes/wings_pickup.tscn")

func _on_chest_zone_body_entered(body):
	if ("Player" in body.name or "player" in body.name) and not opened:
		opened =true
		if anim_player:
			anim_player.play("Armature|ArmatureAction")
			
		_toss_item()
func _toss_item():
	await get_tree().create_timer(0.4).timeout
	
	var pickup=WINGS_PICKUP.instantiate()
	get_tree().current_scene.add_child(pickup)
	
	pickup.global_position=global_position+Vector3(0,0.5,0)
	
	var random_offset = Vector3(randf_range(-3.5, 3.5), 0, randf_range(-3.5, 3.5))
	var landing_target=pickup.global_position+random_offset
	
	var arc_tween=create_tween()
	arc_tween.tween_property(pickup,"global_position:y",global_position.y+2.5,0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	arc_tween.tween_property(pickup, "global_position:y", global_position.y + 1.2, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	var slide_tween=create_tween()
	slide_tween.tween_property(pickup, "global_position:x", landing_target.x, 0.7)
	slide_tween.tween_property(pickup, "global_position:z", landing_target.z, 0.7)
