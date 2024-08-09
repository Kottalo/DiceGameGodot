extends Node

var slotInterval: float = 100
var slotBoardSize: int = 2

var diceNumberPerType: int = 8
var dicePool: Array[Dice] = []
var drawPerTurn: int = 5
var diceLobby: Array[Dice] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().process_frame
	
	get_tree().get_root().size_changed.connect(_on_window_resized)
	
	var diceSlotModel = preload("res://Models/DiceSlot.tscn")
	
	var nodeLength: float = 20
	
	var diceSlots = $"HBoxContainer/MidPanel/VBoxContainer/DiceSlots"
	
	var centerNode = diceSlotModel.instantiate()
	centerNode.size = Vector2(nodeLength, nodeLength)
	centerNode.position = Vector2(0, 0)
	
	diceSlots.add_child(centerNode)
	
	var hexAngle = PI * 2 / 6
	
	for i in range(6):
		for j in range(1, slotBoardSize + 1):
			var x = cos(hexAngle * i) * slotInterval * j
			var y = sin(hexAngle * i) * slotInterval * j
			
			var rootNode = diceSlotModel.instantiate()
			
			rootNode.size = Vector2(nodeLength, nodeLength)
			rootNode.position = Vector2(x, y)
			
			diceSlots.add_child(rootNode)

			for k in range(j - 1):
				var childX = rootNode.position.x - (cos(hexAngle * i - hexAngle) * slotInterval)
				var childY = rootNode.position.y - (sin(hexAngle * i - hexAngle) * slotInterval)

				var childNode = ColorRect.new()
				childNode.size = Vector2(nodeLength, nodeLength)
				childNode.position = Vector2(childX, childY)
				
				diceSlots.add_child(childNode)
				
	var diceLobby = $"HBoxContainer/LeftPanel/VBoxContainer/Section4/HBoxContainer/DiceLobby"
	
	var gridSize = Vector2(8, 4)
	var spacing = Vector2(10, 10)
	
	var dividedSizeX = ( diceLobby.size.x - (spacing.x * (gridSize.x - 1)) ) / gridSize.x
	var dividedSizeY = ( diceLobby.size.y - (spacing.y * (gridSize.y - 1)) ) / gridSize.y
	
	var cellLength = min(dividedSizeX, dividedSizeY)
	
	for i in range(gridSize.y):
		for j in range(gridSize.x):
			var cell = ColorRect.new()
			
			cell.size = Vector2(cellLength, cellLength)
			cell.pivot_offset = cell.size / 2
			
			diceLobby.add_child(cell)
			
			var cellX = j * cellLength + (j * spacing.x)
			var cellY = i * cellLength + (i * spacing.y)
			
			cell.position = Vector2(cellX, cellY)
	
	var diceTypeFiles = DirAccess.open("res://Resources/DiceData").get_files()
	
	var diceTypes = []
	
	var diceModel: PackedScene = preload("res://Models/Dice.tscn")
	
	for file in diceTypeFiles:
		diceTypes.append(load("res://Resources/DiceData/"+file))
	
	
	for i in range(len(diceTypes)):
		var diceType = diceTypes[i]
		
		for j in range(diceNumberPerType):
			var dice = diceModel.instantiate()
			
			dice.Roll()
			dice.diceTypeData = diceType
			
			dicePool.append(dice)
	
	DrawDice()

	pass # Replace with function body.

func DrawDice():
	var diceLobbyNode = $"HBoxContainer/LeftPanel/VBoxContainer/Section4/HBoxContainer/DiceLobby"
	
	for i in range(drawPerTurn):
		var randomIndex = randf_range(0, len(dicePool))
		
		var dice: Dice = dicePool.pop_at(randomIndex)
		
		var targetCell: Control = diceLobbyNode.get_child(len(diceLobby))
		
		diceLobby.append(dice)
		diceLobbyNode.add_child(dice)
		
		dice.global_position = targetCell.global_position + targetCell.pivot_offset

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

# This function is called whenever the window is resized.
func _on_window_resized():
	pass
	
