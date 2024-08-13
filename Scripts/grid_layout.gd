extends FlowContainer

class_name GridLayout

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
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func GenerateGrid(cellNum: int):
	for child in get_children():
		remove_child(child)
	
	for i in range(cellNum):
		var cell = Control.new()
		
		cell.custom_minimum_size = cellSize
		
		add_child(cell)

func SortGrid():
	var tween = create_tween()
	tween.pause()
	
	GenerateGrid(diceContainer.get_child_count())
	
	for i in range(2):
		await get_tree().process_frame
	
	for index in range(diceContainer.get_child_count()):
		tween.parallel().tween_property(diceContainer.get_child(index), "global_position", get_child(index).global_position + cellOffset, 0.2)
	
	tween.play()

func GetCellPosition(cellIndex: int):
	return get_child(cellIndex).global_position + cellOffset
