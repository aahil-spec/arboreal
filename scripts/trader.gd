extends CharacterBody3D

@export var trader_name:String="Merchant"
@export var stock:Array=["sword_iron","armor_leather","boots_swift","bandage"]
@export var buy_price_multiplier: float = 1.0
var player_in_range:bool=false

func _on_trade_zone_body_entered(body):
	if body.name=="Player":
		player_in_range=true
		
func _on_trade_zone_body_exited(body):
	if body.name=="Player":
		player_in_range=false
		GameManager.shop_open=false
		
func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("interact"):
		GameManager.shop_open=!GameManager.shop_open
		if GameManager.shop_open:
			_open_shop()
		else:
			_close_shop()
			
func _open_shop():
	var shop_ui=get_tree().current_scene.get_node("CanvasLayer/ShopPanel")
	shop_ui.visible=true
	shop_ui.populate(stock,buy_price_multiplier,self)
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	
func _close_shop():
	var shop_ui=get_tree().current_scene.get_node("CanvasLayer/ShopPanel")
	shop_ui.visible=false
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	
	
