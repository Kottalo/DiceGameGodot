extends FlowContainer

class_name GridLayout

@onready var Main = get_node("/root/Main")

@export var columnNum: int

@export var diceContainer: Node2D

var cellNum: int:
	set(newValue):
		cellNum = newValue
		
		GenerateGrid(cellNum)
	get:
		return cellNum

var cellSize: Vector2:
	get:
		var hSeparation = self["theme_override_constants/h_separation"]
		var vSeparation = self["theme_override_constants/v_separation"]
		
		var totalHSeparation = (columnNum - 1) * hSeparation
		var diceLength = (size.x - totalHSeparation) / columnNum
		
		return Vector2(diceLength, diceLength)

var cellOffset: Vector2:
	get:
		return cellSize / 2

# Called when the node enters the scene tree for the first time.
func _ready():
	#connect("child_entered_tree", SortGrid)
	#connect("child_exiting_tree", SortGrid)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func GenerateGrid(cellNum: int):
	for child in get_children():
		remove_child(child)
	
	for i in range(cellNum):
		var cell = Control.new()
		
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.custom_minimum_size = cellSize
		
		add_child(cell)

func SortGrid() -> Tween:
	var tween = create_tween()
	tween.pause()
	
	GenerateGrid(diceContainer.get_child_count())
	
	for i in range(2):
		await get_tree().process_frame
	
	for index in range(diceContainer.get_child_count()):
		tween.parallel().tween_property(diceContainer.get_child(index), "global_position", get_child(index).global_position + cellOffset, 0.2)
	
	tween.play()
	
	return tween

func GetCellPosition(cellIndex: int):
	return get_child(cellIndex).global_position + cellOffset

func JoinDice(dice: Dice):
	var diceParent : Node2D = dice.get_parent()
	
	diceParent.remove_child(dice)
	diceContainer.add_child(dice)
	
	var sortGrid = await SortGrid()
	
	await sortGrid.finished
	

func _on_area_2d_mouse_entered():
	Main.targetContainer = self
	print("Dice entered")
	pass # Replace with function body.

func _on_area_2d_mouse_exited():
	Main.targetContainer = null
	print("Dice exited")
	pass # Replace with function body.
