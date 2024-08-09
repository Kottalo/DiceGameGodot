extends ColorRect

class_name DiceSlot

var connectedSlots: Array[DiceSlot] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _set(property, value):
	if property == 'position':
		UpdateOffset()

func UpdateOffset():
	pivot_offset = size / 2
