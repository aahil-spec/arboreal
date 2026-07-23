extends Control

@onready var master_slider:HSlider=$VBoxContainer/SettingsTabs/Audio/HBoxContainer/MasterSlider
@onready var music_slider:HSlider=$VBoxContainer/SettingsTabs/Audio/HBoxContainer2/MusicSlider
@onready var sfx_slider:HSlider=$VBoxContainer/SettingsTabs/Audio/HBoxContainer3/SFXSlider
@onready var ambient_slider:HSlider=$VBoxContainer/SettingsTabs/Audio/HBoxContainer4/AmbientSlider
@onready var shadow_option:OptionButton=$VBoxContainer/SettingsTabs/Graphics/HBoxContainer2/ShadowOption
@onready var fog_toggle:CheckButton=$VBoxContainer/SettingsTabs/Graphics/HBoxContainer3/FogToggle
@onready var bloom_toggle:CheckButton=$VBoxContainer/SettingsTabs/Graphics/HBoxContainer4/BloomToggle

@export var return_scene:String="res://scenes/main_menu.tscn"
func _ready():
	var keybinds = [
	["Move", "WASD"],
	["Sprint", "Shift"],
	["Jump", "Space"],
	["Attack", "Left Click"],
	["Build Mode", "B"],
	["Rotate Piece", "Q / E"],
	["Place Piece", "Left Click"],
	["Interact", "E"],
	["Sleep", "Z"],
	["Inventory", "I"],
	["Quest Log", "J"],
	["Map", "M"],
	["Pause", "Escape"],
	["Save", "F5"],
	["Load", "F9"],
	["Gravity Down", "↓"],
	["Gravity Up", "↑"],
	["Gravity Left", "←"],
	["Gravity Right", "→"],
	]
	var keybinds_tab=$VBoxContainer/SettingsTabs/KeyBinds
	for bind in keybinds:
		var row=HBoxContainer.new()
		
		var action_label=Label.new()
		action_label.text=bind[0]
		action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var key_label=Label.new()
		key_label.text=bind[1]
		
		row.add_child(action_label)
		row.add_child(key_label)
		keybinds_tab.add_child(row)
	_load_settings()
	master_slider.value_changed.connect(func(v):AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear_to_db(v)))
	music_slider.value_changed.connect(func(v): AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(v)))
	sfx_slider.value_changed.connect(func(v): AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(v)))
	ambient_slider.value_changed.connect(func(v): AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambient"), linear_to_db(v)))
	fog_toggle.toggled.connect(func(on): _set_fog(on))
	bloom_toggle.toggled.connect(func(on): _set_bloom(on))
	
func _set_fog(enabled:bool):
	var env=get_tree().root.get_node_or_null("Main/WorldEnvironment")
	if env:
		env.environment.fog_enabled=enabled
		
func _set_bloom(enabled:bool):
	var env=get_tree().root.get_node_or_null("Main/WorldEnvironment")
	if env:
		env.environment.glow_enabled=enabled
		
func _load_settings():
	var path="user://settings.cfg"
	if not FileAccess.file_exists(path):
		return
	var file=FileAccess.open(path,FileAccess.READ)
	var data=JSON.parse_string(file.get_as_text())
	file.close()
	if data.has("master"):master_slider.value=data["master"]
	if data.has("music"):music_slider.value=data["music"]
	if data.has("sfx"):sfx_slider.value=data["sfx"]
	if data.has("ambient"):ambient_slider.value=data["ambient"]
	if data.has("fog"):fog_toggle.button_pressed=data["fog"]
	if data.has("bloom"):bloom_toggle.button_pressed=data["bloom"]
	
func _save_settings():
	var data={
		"master":master_slider.value,
		"music":music_slider.value,
		"sfx":sfx_slider.value,
		"ambient":ambient_slider.value,
		"fog":fog_toggle.button_pressed,
		"bloom":bloom_toggle.button_pressed,
	}
	var file=FileAccess.open("user://settings.cfg",FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	
func _on_back_button_pressed():
	_save_settings()
	get_tree().change_scene_to_file(GameManager.settings_return_scene)
