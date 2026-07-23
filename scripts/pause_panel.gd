extends Control


@onready var resume_btn:Button=$CenterContainer/VBoxContainer/ButtonContainer/ResumeButton
@onready var save_btn:Button=$CenterContainer/VBoxContainer/ButtonContainer/SaveButton
@onready var settings_btn:Button=$CenterContainer/VBoxContainer/ButtonContainer/SettingsButton
@onready var quit_btn:Button=$CenterContainer/VBoxContainer/ButtonContainer/QuitButton
@onready var save_notification:Label=$SaveNotification

var notification_tween:Tween=null


func _ready():
	save_notification.visible=false
	for btn in [resume_btn,save_btn,settings_btn,quit_btn]:
		_style_button(btn)
		
func _style_button(btn:Button):
	var normal=StyleBoxFlat.new()
	normal.bg_color=Color(0.08,0.05,0.03,0.85)
	normal.border_color=Color(0.6,0.45,0.15)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(3)
	normal.content_margin_left=40
	normal.content_margin_right=40
	normal.content_margin_top=10
	normal.content_margin_bottom=10
	var hover=normal.duplicate()
	hover.bg_color=Color(0.18,0.12,0.05,0.95)
	hover.border_color=Color(1.0,0.75,0.25)
	hover.set_border_width_all(2)
	btn.add_theme_stylebox_override("normal",normal)
	btn.add_theme_stylebox_override("hover",hover)
	btn.add_theme_stylebox_override("pressed",hover)
	btn.add_theme_color_override("font_color",Color(0.9,0.8,0.5))
	btn.add_theme_color_override("font_hover_color",Color(1.0,0.92,0.6))
	btn.add_theme_font_size_override("font_size",18)
	
func show_pause():
	visible=true
	get_tree().paused=true
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	_animate_in()
	
func hide_pause():
	_animate_out()
	
func _animate_in():
	modulate.a=0.0
	var tween=create_tween()
	tween.tween_property(self,"modulate:a",1.0,0.2)
	
func _animate_out():
	var tween=create_tween()
	tween.tween_property(self,"modulate:a",0.0,0.15)
	await tween.finished
	visible=false
	get_tree().paused=false
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	
func _on_resume_button_pressed():
	hide_pause()

func _on_save_button_pressed():
	SaveSystem.save_game()
	_show_save_notification()
	
func _show_save_notification():
	save_notification.modulate.a=1.0
	save_notification.visible=true
	if notification_tween:
		notification_tween.kill()
	notification_tween=create_tween()
	notification_tween.tween_interval(1.5)
	notification_tween.tween_property(save_notification,"modulate:a",0.0,0.6)
	notification_tween.tween_callback(func():save_notification.visible=false)
	
func _on_settings_button_pressed():
	get_tree().paused=false
	GameManager.settings_return_scene="res://scenes/main.scn"
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")
	
func _on_quit_button_pressed():
	get_tree().paused=false
	var fade=get_tree().current_scene.get_node_or_null("CanvasLayer/FadeRect")
	if fade:
		var tween=create_tween()
		tween.tween_property(fade,"color:a",1.0,0.4)
		await tween.finished
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
