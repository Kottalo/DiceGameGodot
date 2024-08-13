extends Node

@export var diceLobbyColumn: int
@export var drawPerTurn: int

var slotInterval: float = 100
var slotBoardSize: int = 2

var drawDuration: float = 0.3

var diceNumberPerType: int = 8
var dicePool: Array[Dice] = []

var diceSlots: Array[DiceSlot] = []

var firstPlaced: bool
var discardable: bool:
	set(newValue):
		discardable = newValue
		
		discardButton.disabled = !discardable
	get:
		return discardable

@onready var diceLobbyNode: Control = $"HBoxContainer/LeftPanel/VBoxContainer/Section4/HBoxContainer/DiceLobby/GridContainer"
@onready var lobbyDiceNode: Node2D = $Canvas/LobbyDice
@onready var slotDiceNode: Node2D = $Canvas/SlotDice
@onready var discadedDiceNode: Node2D = $Canvas/DiscardedDice
@onready var discardButton = $HBoxContainer/LeftPanel/VBoxContainer/Section5/HBoxContainer/DiscardButton
@onready var discardSectionControl = $HBoxContainer/LeftPanel/VBoxContainer/Section5/HBoxContainer/DiscardSection

@onready var tween: Tween

var selectedDice: Dice = null:
	set(newValue):
		selectedDice = newValue
		
		if selectedDice != null:
			selectedDice.selected = true
		
		discardable = selectedDice != null
	get:
		return selectedDice

var controllable: bool:
	set(newValue):
		controllable = newValue
	get:
		return controllable

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().process_frame
	
	get_tree().get_root().size_changed.connect(_on_window_resized)
	
	discardable = false
	
	var diceSlotModel = preload("res://models/dice_slot.tscn")
	
	var nodeLength: float = 20
	
	var diceSlotsNode = $"HBoxContainer/MidPanel/VBoxContainer/DiceSlots"
	var slotsNode = $Canvas/Slots
	
	var centerNode = diceSlotModel.instantiate()
	centerNode.size = Vector2(nodeLength, nodeLength)
	centerNode.position = Vector2(0, 0)
	
	#diceSlots.add_child(centerNode)
	diceSlots.append(centerNode)
	
	var hexAngle = PI * 2 / 6
	
	for i in range(6):
		for j in range(1, slotBoardSize + 1):
			var x = cos(hexAngle * i) * j
			var y = sin(hexAngle * i) * j
			
			var rootNode = diceSlotModel.instantiate()
			
			rootNode.size = Vector2(nodeLength, nodeLength)
			rootNode.coordinate = Vector2(x, y)
			rootNode.placable = j == slotBoardSize
			
			diceSlots.append(rootNode)

			for k in range(j - 1):
				var childX = rootNode.coordinate.x - cos(hexAngle * i - hexAngle)
				var childY = rootNode.coordinate.y - sin(hexAngle * i - hexAngle)

				var childNode = diceSlotModel.instantiate()
				childNode.size = Vector2(nodeLength, nodeLength)
				childNode.coordinate = Vector2(childX, childY)
				
				diceSlots.append(childNode)
	
	# Generate dice slots
	for diceSlot: DiceSlot in diceSlots:
		var slotOffset = diceSlot.size / 2
		var offset = diceSlotsNode.size / 2
		
		slotsNode.add_child(diceSlot)
		var locationPosition: Vector2 = diceSlot.coordinate * slotInterval + offset - slotOffset
		diceSlot.global_position = diceSlotsNode.global_position + locationPosition
	
	# Get the outer slots
	var outerSlots = diceSlots.filter(
		func(diceSlot: DiceSlot) -> bool:
			return diceSlot.coordinate.distance_to(Vector2.ZERO) > slotBoardSize - 1
	)

	# Connect the outer slots
	for slot: DiceSlot in outerSlots:
		for slot2: DiceSlot in outerSlots:
			if slot == slot2:
				continue
			
			if slot2.coordinate.distance_to(slot.coordinate) <= 1:
				slot.connectedSlots.append(slot2)

	# Get the inner slots
	var innerSlots = diceSlots.filter(
		func(diceSlot: DiceSlot) -> bool:
			return diceSlot.coordinate.distance_to(Vector2.ZERO) <= slotBoardSize - 1 and diceSlot.coordinate != Vector2.ZERO
	)

	# Connect the inner slots
	for slot: DiceSlot in innerSlots:
		for slot2: DiceSlot in innerSlots:
			if slot == slot2 or slot.coordinate.y == slot2.coordinate.y:
				continue
			
			if slot2.coordinate.distance_to(slot.coordinate) <= 1:
				slot.connectedSlots.append(slot2)
	
	# Get the mid horizontal slots
	var midHorizontalSlots = diceSlots.filter(
		func(diceSlot: DiceSlot) -> bool:
			return floor(diceSlot.coordinate.y * 10) == 0
	)
	
	# Connect mid horizontal slots
	for slot: DiceSlot in midHorizontalSlots:
		for slot2: DiceSlot in midHorizontalSlots:
			if slot == slot2:
				continue
			
			if slot2.coordinate.distance_to(slot.coordinate) <= 1:
				slot.connectedSlots.append(slot2)
	
	# Get the mid vertical slots
	var midVerticalSlots = diceSlots.filter(
		func(diceSlot: DiceSlot) -> bool:
			return floor(diceSlot.coordinate.x * 10) == 0
	)
	
	# Connect mid vertical slots
	for slot: DiceSlot in midVerticalSlots:
		for slot2: DiceSlot in midVerticalSlots:
			if slot == slot2:
				continue
			
			if slot2.coordinate.distance_to(slot.coordinate) <= slotBoardSize:
				slot.connectedSlots.append(slot2)
	
	var irregularSlotCoordinates = ["1.00,1.73", "0.00,1.73", "0.50,0.87"]
	
	# Get the irregular slots
	var irregularSlots = diceSlots.filter(
		func(diceSlot: DiceSlot) -> bool:
			var coordinate = diceSlot.coordinate
			var coordinateStr = "%1.2f,%1.2f" % [abs(coordinate.x), abs(coordinate.y)]
			
			return coordinateStr in irregularSlotCoordinates
	)
	
	# Connect irregular slots
	for slot: DiceSlot in irregularSlots:
		for slot2: DiceSlot in irregularSlots:
			if slot == slot2 or floor(slot.coordinate.y * 10) == floor(slot2.coordinate.y * 10):
				continue
			
			if slot2.coordinate.distance_to(slot.coordinate) <= 1:
				slot.connectedSlots.append(slot2)
	
	for slot: DiceSlot in diceSlots:
		for connectedSlot in slot.connectedSlots:
			var line = Line2D.new()
			line.width = 1
			line.add_point(slot.centerPosition)
			line.add_point(connectedSlot.centerPosition)
			$Canvas/ConnectLines.add_child(line)
	
	var gridSize = Vector2(8, 4)
	var spacing = Vector2(10, 10)
	
	var dividedSizeX = ( diceLobbyNode.size.x - (spacing.x * (gridSize.x - 1)) ) / gridSize.x
	var dividedSizeY = ( diceLobbyNode.size.y - (spacing.y * (gridSize.y - 1)) ) / gridSize.y
	
	var cellLength = min(dividedSizeX, dividedSizeY)
	
	var diceTypeFiles = DirAccess.open("res://resources/dice_data").get_files()
	
	var diceTypes = []
	
	var diceModel: PackedScene = preload("res://models/dice.tscn")
	
	for file in diceTypeFiles:
		diceTypes.append(ResourceLoader.load("resources/dice_data/"+file))
	
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
	#controllable = false
	#
	#tween = create_tween()
	#
	#tween.pause()
	#
	#var dicePoolButton = $HBoxContainer/LeftPanel/VBoxContainer/Section2/HBoxContainer/Left/VBoxContainer/DicePoolButton
	#var startPosition = dicePoolButton.global_position + (dicePoolButton.size / 2)
	#
	#var hSeparation = 5
	#var vSeparation = 5
	#var totalHSeparation = (diceLobbyColumn - 1) * hSeparation
	#var diceLength = (diceLobbyNode.size.x - totalHSeparation) / diceLobbyColumn
	#var diceSize = Vector2(diceLength, diceLength)
	#var diceOffset = diceSize / 2
	#
	#for i in range(drawPerTurn):
		#var randomIndex = randf_range(0, len(dicePool))
		#var dice: Dice = dicePool.pop_at(randomIndex)
		#
		#
		#dice.visible = false
		#dice.scale = diceSize / dice.get_rect().size
		#dice.global_position = startPosition
		#
		#var diceCoordinateX: int = lobbyDiceNode.get_child_count() % diceLobbyColumn
		#var diceCoordinateY: int = lobbyDiceNode.get_child_count() / diceLobbyColumn
		#
		#var position: Vector2 = Vector2(diceCoordinateX * diceSize.x, diceCoordinateY * diceSize.y)
		#position += diceLobbyNode.global_position + diceOffset
		#var spacingX = diceCoordinateX * hSeparation
		#var spacingY = diceCoordinateY * vSeparation
		#position += Vector2(spacingX, spacingY)
		#tween.tween_property(dice, "visible", true, 0)
		#tween.tween_property(dice, "global_position", position, drawDuration)
		#
		#lobbyDiceNode.add_child(dice)
		#
	#tween.play()
		#
	#tween.tween_property(self, "controllable", true, 0)
	
	var tween = create_tween()
	
	tween.pause()
	
	diceLobbyNode.GenerateGrid(drawPerTurn)
	
	await get_tree().process_frame
	
	var dicePoolButton = $HBoxContainer/LeftPanel/VBoxContainer/Section2/HBoxContainer/Left/VBoxContainer/DicePoolButton
	var startPosition = dicePoolButton.global_position + (dicePoolButton.size / 2)
	
	for i in range(drawPerTurn):
		var randomIndex = randf_range(0, len(dicePool))
		var dice: Dice = dicePool.pop_at(randomIndex)
		
		lobbyDiceNode.add_child(dice)
		dice.global_position = startPosition
		dice.visible = false
		
		var position: Vector2 = diceLobbyNode.GetCellPosition(dice.get_index())
		
		tween.tween_property(dice, "visible", true, 0)
		tween.tween_property(dice, "global_position", position, drawDuration)
	
	tween.play()
	pass

func DiscardDice():
	var tween = create_tween().set_parallel(true)
	
	var position: Vector2 = discardSectionControl.global_position
	
	tween.tween_property(selectedDice, "global_position", position, 0.3)
	var targetDice = lobbyDiceNode.get_child(selectedDice.get_index())
	lobbyDiceNode.remove_child(targetDice)
	discadedDiceNode.add_child(targetDice)
	SortDiceLobby()
	

func SortDiceLobby():
	tween = get_tree().create_tween()
	
	for index in range(lobbyDiceNode.get_child_count()):
		var offset = diceLobbyNode.get_child(index).size / 2
		tween.parallel().tween_property(lobbyDiceNode.get_child(index), "global_position", diceLobbyNode.get_child(index).global_position + offset, 0.2)
	
	tween.play()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

# This function is called whenever the window is resized.
func _on_window_resized():
	pass
	
