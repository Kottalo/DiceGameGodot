extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = create_tween()
	
	for i in range(5):
		
		tween.tween_callback(
			func():
				
				var colorRect = ColorRect.new()
			
				colorRect.custom_minimum_size = Vector2(100, 100)
				
				$Control/FlowContainer.add_child(colorRect)
		).set_delay(1)
		
		var startPosition = Vector2(500, 500)
		
		tween.tween_callback(
			func():
				$Control/FlowContainer.remove_child($Control/FlowContainer.get_child(0))
		).set_delay(1)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
