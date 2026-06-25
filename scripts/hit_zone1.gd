extends Area3D


@export var damage:int=20
var can_hit:bool=true
const HIT_COOLDOWN:float=1.0

func _on_body_entered(body):
	if body.name=="Player" and can_hit:
		GameManager.damage_player(damage)
		can_hit=false
		await get_tree().create_timer(HIT_COOLDOWN).timeout
		can_hit=true
