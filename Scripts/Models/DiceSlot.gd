extends ColorRect

class_name DiceSlot

var coordinate: Vector2:
	set(newValue):
		coordinate = newValue
	get:
		return coordinate

var placable: bool:
	set(newValue):
		placable = newValue
		
		color = Color.GREEN if placable else Color.WHITE
	get:
		return placable

var centerPosition: Vector2:
	get:
		var offset = size / 2
		
		return global_position + offset

var connectedSlots: Array[DiceSlot] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if !placable or !Main.controllable: return
			
			if Main.selectedDice != null:
				var tween = get_tree().create_tween()
				
				tween.tween_property(Main.selectedDice, "global_position", centerPosition, 0.3)
				#Main.slotDiceNode.append(Main.lobbyDice.pop_at(Main.lobbyDice.find(self)))
				#var target = get_node("/root/Main/Canvas/LobbyDice/"+Main.selectedDice.name)
				var target = Main.lobbyDiceNode.get_child(Main.selectedDice.get_index())
				Main.lobbyDiceNode.remove_child(target)
				Main.slotDiceNode.add_child(target)
				
				Main.SortDiceLobby()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _set(property, value):
	if property == 'position':
		UpdateOffset()

func UpdateOffset():
	pivot_offset = size / 2
