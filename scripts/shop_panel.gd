extends Panel


var current_trader=null

func populate(stock:Array,price_multiplier:float,trader):
	current_trader=trader
	var buy_list=$HBoxContainer/BuyList
	var sell_list=$HBoxContainer/SellList
	
	for child in buy_list.get_children():
		if child is Button:
			child.queue_free()
	for child in sell_list.get_children():
		child.queue_free()
		
	for item_id in stock:
		var item=GameManager.items[item_id]
		var price=_get_buy_price(item_id,price_multiplier)
		var btn=Button.new()
		btn.text=item["name"]+"_"+str(price)+"Timber"
		btn.disabled=GameManager.timber < price
		btn.pressed.connect(_buy_item.bind(item_id,price))
		buy_list.add_child(btn)
		
	for inv_slot in GameManager.inventory:
		if inv_slot is Dictionary and inv_slot.has("id"):
			var actual_id=inv_slot["id"]
			var item=GameManager.items[actual_id]
			var sell_price=_get_sell_price(actual_id)
			
			var btn=Button.new()
			btn.text=item["name"]+"(x"+str(inv_slot["count"])+")-+"+str(sell_price)
			btn.pressed.connect(_sell_item.bind(actual_id,sell_price))
			sell_list.add_child(btn)
			

	
@warning_ignore("unused_parameter")
func _get_buy_price(item_id:String,multiplier:float):
	@warning_ignore("unused_variable")
	var base_prices={
		"sword_iron":20,"sword_ember":60,"armor_leather":15,
		"boots_swift":18,"bandage":8,"helmet_leather":12,
		"leggings_leather":14,"shield_wood":16,
	}
	return int(base_prices.get(item_id,10)*multiplier)
	
func _get_sell_price(item_id:String):
	var base_prices={
		"sword_iron":8,"sword_ember":25,"armor_leather":6,
		"boots_swift":7,"raw_meat_bundle":3,"bandage":3,
	}
	return base_prices.get(item_id,2)
	
func _buy_item(item_id:String,price:int):
	if GameManager.spend_timber(price):
		GameManager.add_item(item_id)
		populate(current_trader.stock,current_trader.buy_price_multiplier,current_trader)
		
		
func _sell_item(item_id:String,sell_price:int):
	for i in range(GameManager.inventory.size()):
		var slot=GameManager.inventory[i]
		
		if slot is Dictionary and slot.has("id") and slot["id"]==item_id:
			slot["count"]-=1
			
			if slot["count"]<=0:
				GameManager.inventory[i]={}
				
			break
	GameManager.timber+=sell_price
	populate(current_trader.stock,current_trader.buy_price_multiplier,current_trader)
	GameManager.hotbar_changed.emit()
