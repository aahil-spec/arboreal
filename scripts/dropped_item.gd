extends Area3D

var item_id:String=""
var time_alive:float=0.0
var spin_speed:float=0.0
var bob_speed:float=0.0
var bob_amount:float=0.0
var base_y:float=0.0

var has_been_picked_up:bool=false


const PICKUP_DELAY:float=0.6

@onready var visual_root:Node3D=$VisualRoot
@onready var model_holder:Node3D=$VisualRoot/ModelHolder
@onready var fallback_sphere:MeshInstance3D=$VisualRoot/FallbackSphere
@onready var glow:OmniLight3D=$Glow

func _ready():
	add_to_group("dropped_item")
	body_entered.connect(_on_body_entered)
	spin_speed=randf_range(1.0,2.0)
	bob_speed=randf_range(1.6,2.2)
	bob_amount=randf_range(0.07,0.14)
	visual_root.rotation.y=randf_range(0.0,TAU)
	base_y=position.y
	call_deferred("_setup_visuals")
func _setup_visuals():
	if item_id==""or not GameManager.items.has(item_id):
		_use_fallback(Color(0.8,0.8,0.8))
		return
	var item_type=GameManager.items[item_id]["type"]
	var glow_color=_get_glow_color(item_type)
	glow.light_color=glow_color
	
	if GameManager.item_models.has(item_id):
		var model_path=GameManager.item_models[item_id]
		if ResourceLoader.exists(model_path):
			var model_scene=load(model_path)
			var model_instance=model_scene.instantiate()
			model_holder.add_child(model_instance)
			model_holder.scale=Vector3(0.35,0.35,0.35)
			fallback_sphere.visible=false
			return
	_use_fallback(glow_color)
	
func _use_fallback(color:Color):
	fallback_sphere.visible=true
	var mat=fallback_sphere.get_active_material(0)
	if mat:
		mat.albedo_color=color
		mat.emission_enabled=true
		mat.emission=color*0.4
		
func _get_glow_color(item_type:String):
	match item_type:
		"weapon":
			return Color(1.0,0.25,0.15)
		"armor","helmet","leggings":
			return Color(0.25,0.55,1.0)
		"boots":
			return Color(0.3,1.0,0.45)
		"offhand":
			return Color(0.5,0.5,1.0)
		"wings":
			return Color(1.0,0.75,0.1)
		"consumable":
			return Color(0.4,1.0,0.3)
		"material":
			return Color(0.85,0.75,0.4)
		"ingredient":
			return Color(0.9,0.6,0.3)
		_:
			return Color(0.85,0.82,0.6)
			
func _process(delta):
	time_alive +=delta
	visual_root.rotation.y+=spin_speed*delta
	visual_root.position.y=sin(time_alive*bob_speed)*bob_amount
	
func _on_body_entered(body):
	if body.name =="Player" and time_alive >=PICKUP_DELAY and item_id:
		var grabbed_item=item_id
		
		item_id=""
		
		set_deferred("monitoring",false)
		
		GameManager.add_item(grabbed_item)
		_play_pickup_effect()
		
func _pickup():
	GameManager.add_item(item_id)
	_play_pickup_effect()
	
func _play_pickup_effect():
	var tween=create_tween()
	tween.tween_property(visual_root,"scale",Vector3(1.5,1.5,1.5),0.07)
	tween.tween_property(visual_root, "scale", Vector3(0.0, 0.0, 0.0), 0.09)
	tween.tween_callback(queue_free)
