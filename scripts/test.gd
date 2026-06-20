extends Node

var greeting: String="hello,embermoor!"
var times_run:int=0

# Called when the node enters the scene tree for the first time.
func _ready():
	print(greeting)
	times_run +=1
	print("this node has been ready","time(s).")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
