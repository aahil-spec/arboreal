extends Panel


signal slot_clicked(index,button)
signal slot_hovered(index)
signal slot_unhovered()

var slot_index:int=-1

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		slot_clicked.emit(slot_index,event.button_index)
		
func _on_mouse_entered():
	slot_hovered.emit(slot_index)

func _on_mouse_exited():
	slot_unhovered.emit()
