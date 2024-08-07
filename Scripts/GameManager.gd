extends Node

var slotInterval: float = 100
var slotBoardSize: int = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	var diceSlots = $"HBoxContainer/MidPanel/VBoxContainer/DiceSlots"
	
	var centerNode = ColorRect.new()
	centerNode.size = Vector2(20, 20)
	centerNode.anchor_top = 0.5
	centerNode.anchor_bottom = 0.5
	centerNode.anchor_left = 0.5
	centerNode.anchor_right = 0.5
	centerNode.position = Vector2(0, 0)
	
	diceSlots.add_child(centerNode)
	
	var hexAngle = PI * 2 / 6
	
	var diceModel: PackedScene = preload("res://Models/Dice.tscn")
	
	for i in range(6):
		for j in range(1, slotBoardSize + 1):
			var x = cos(hexAngle * i) * slotInterval * j
			var y = sin(hexAngle * i) * slotInterval * j
			
			var rootNode = ColorRect.new()
			
			rootNode.size = Vector2(20, 20)
			rootNode.anchor_top = 0.5
			rootNode.anchor_bottom = 0.5
			rootNode.anchor_left = 0.5
			rootNode.anchor_right = 0.5
			rootNode.position = Vector2(x, y)
			
			diceSlots.add_child(rootNode)

			for k in range(j - 1):
				var childX = rootNode.position.x - (cos(hexAngle * i - hexAngle) * slotInterval)
				var childY = rootNode.position.y - (sin(hexAngle * i - hexAngle) * slotInterval)

				var childNode = ColorRect.new()
				childNode.size = Vector2(20, 20)
				childNode.anchor_top = 0.5
				childNode.anchor_bottom = 0.5
				childNode.anchor_left = 0.5
				childNode.anchor_right = 0.5
				childNode.position = Vector2(childX, childY)
				
				diceSlots.add_child(childNode)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
