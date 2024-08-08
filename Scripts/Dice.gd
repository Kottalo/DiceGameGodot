extends Sprite2D

class_name Dice

var selected: bool:
	set(newValue):
		selected = newValue
		
		$Line2D.visible = selected
	get:
		return selected

var diceValue: int:
	set(newValue):
		diceValue = newValue
		
		frame = diceValue - 1
	
	get:
		return diceValue

var diceTypeData: DiceTypeData:
	set(newValue):
		diceTypeData = newValue
	
		self_modulate = diceTypeData.color
	get:
		return diceTypeData

func Roll():
	diceValue = randf_range(1, 7)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_control_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			selected = !selected
	pass # Replace with function body.
