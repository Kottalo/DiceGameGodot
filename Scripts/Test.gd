extends Node

var list = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var a = ColorRect.new()
	a.custom_minimum_size = Vector2(100, 100)
	list.append(a)
	
	$Control/FlowContainer.add_child(a)
	
	list[0].custom_minimum_size = Vector2(10, 100)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
