extends ColorRect

class_name DiceSlot

@onready var Main = get_node("/root/Main")

var coordinate: Vector2:
	set(newValue):
		coordinate = newValue
		
		$Label.text = "%1.2f,%1.2f" % [coordinate.x, coordinate.y]
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

var occupiedBy: Dice = null:
	set(newValue):
		occupiedBy = newValue
		print(connectedSlots)
		for slot in connectedSlots:
			slot.placable = true
	get:
		return occupiedBy

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
				
				if !Main.firstPlaced:
					for slot in Main.diceSlots:
						slot.placable = false
					
					Main.firstPlaced = true
				
				var target: Dice = Main.lobbyDiceNode.get_child(Main.selectedDice.get_index())
				Main.lobbyDiceNode.remove_child(target)
				Main.slotDiceNode.add_child(target)
				
				occupiedBy = target
				target.selected = false
				target.selectable = false
				
				Main.selectedDice = null
				
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
