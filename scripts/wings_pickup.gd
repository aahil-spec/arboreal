extends Area3D


@export var item_id:String="wings"
@export var amount:int=1


func _ready():
	body_entered.connect(_on_body_entered)
	
	if has_node("Model"):
		var tween=create_tween().set_loops()
		tween.tween_property($Model,"position:y",0.2,1.0).as_relative().set_trans(Tween.TRANS_SINE)
		tween.tween_property($Model, "position:y", -0.2, 1.0).as_relative().set_trans(Tween.TRANS_SINE)
		
func _process(delta):
	rotate_y(delta*1.5)
	
func _on_body_entered(body):
	if "Player" in body.name or "player" in body.name:
		_pickup()
	
func _pickup():
	var found =false
	for item in GameManager.inventory:
		if item["id"]==item_id:
			item["count"]+=amount
			found=true
			break
		
	if not found:
		GameManager.inventory.append({"id":item_id,"count":amount})
		
	GameManager.hotbar_changed.emit()
	queue_free()
