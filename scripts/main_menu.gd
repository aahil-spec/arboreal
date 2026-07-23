extends Control

@onready var fade_rect:ColorRect=$FadeRect
@onready var continue_btn:Button=$MenuContainer/VBoxContainer/ButtonContainer/ContinueButton
@onready var title_label:Label=$MenuContainer/VBoxContainer/TitleLabel
@onready var subtitle_label:Label=$MenuContainer/VBoxContainer/SubtitleLabel
@onready var version_label:Label=$VersionLabel
@onready var button_container:VBoxContainer=$MenuContainer/VBoxContainer/ButtonContainer

var buttons:Array=[]

func _ready():
	version_label.text="v0.1.0 - Early Access"
	continue_btn.disabled = not FileAccess.file_exists(SaveSystem.SAVE_PATH)
	buttons=button_container.get_children()
	for btn in buttons:
		if btn is Button:
			_style_button(btn)
	_play_intro_animation()
		
func _play_intro_animation():
	title_label.modulate.a=0.0
	subtitle_label.modulate.a=0.0
	for btn in buttons:
		btn.modulate.a=0.0
		
	var tween=create_tween().set_parallel(false)
	tween.tween_property(fade_rect,"color:a",0.0,1.2)
	tween.tween_interval(0.3)
	tween.tween_property(title_label,"modulate:a",1.0,0.8)
	tween.tween_interval(0.2)
	tween.tween_property(subtitle_label,"modulate:a",1.0,0.6)
	tween.tween_interval(0.3)
	for btn in buttons:
		tween.tween_property(btn,"modulate:a",1.0,0.2)
		tween.tween_interval(0.1)
		
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
	
func _fade_to_scene(path:String):
	var tween=create_tween()
	tween.tween_property(fade_rect,"color:a",1.0,0.4)
	await tween.finished
	get_tree().change_scene_to_file(path)
	
func _on_new_game_button_pressed():
	get_tree().change_scene_to_file("res://scenes/name_entry.tscn")
	
func _on_continue_button_pressed():
	var tree=get_tree()
	await _fade_to_scene("res://scenes/main.scn")
	await tree.process_frame
	await tree.process_frame
	SaveSystem.load_game()
	
func _on_settings_button_pressed():
	GameManager.settings_return_scene="res://scenes/main.scn"
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")
	
func _on_quit_button_pressed():
	var tween=create_tween()
	tween.tween_property(fade_rect,"color:a",1.0,0.3)
	await tween.finished
	get_tree().quit()
