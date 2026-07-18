extends Node3D

@export var target_scene:String="res://scenes/parkour_world.tscn"
@export var is_return_portal:bool=false

@onready var portal_zone:Area3D=$PortalZone
@onready var vortex_mesh:MeshInstance3D=$VortexMesh

var player_inside:bool=false
var teleport_timer:float=0.0
const TELEPORT_DELAY:float=0.0

func _ready():
	portal_zone.body_entered.connect(_on_body_entered)
	portal_zone.body_exited.connect(_on_body_exited)
	
func _process(delta):
	vortex_mesh.rotate_y(delta*1.2)
	if player_inside:
		teleport_timer+=delta
		if teleport_timer>=TELEPORT_DELAY:
			_teleport()
			
func _on_body_entered(body):
	if body.name=="Player":
		player_inside=true
		teleport_timer=0.0

func _on_body_exited(body):
	if body.name=="Player":
		player_inside=false
		teleport_timer=0.0
		
func _teleport():
	player_inside=false
	var transition=get_tree().current_scene.get_node_or_null("CanvasLayer/FadeRect")
	if transition:
		var tween=create_tween()
		tween.tween_property(transition,"color:a",1.0,0.3)
		await tween.finished
	get_tree().change_scene_to_file(target_scene)
