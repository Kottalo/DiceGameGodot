extends Control

class_name DiceContainer

@onready var Main = get_node("/root/Main")

@export var columnNum: int

@export var flowContainer: FlowContainer
@export var diceContainer: Node2D

var cellNum: int:
	get:
		return diceContainer.get_child_count()

var cellSize: Vector2:
	get:
		var hSeparation = flowContainer["theme_override_constants/h_separation"]
		var vSeparation = flowContainer["theme_override_constants/v_separation"]
		
		var totalHSeparation = (columnNum - 1) * hSeparation
		var diceLength = (flowContainer.size.x - totalHSeparation) / columnNum
		
		return Vector2(diceLength, diceLength)

var cellOffset: Vector2:
	get:
		return cellSize / 2

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().process_frame
	
	var collisionShape = $Area2D/CollisionShape2D as CollisionShape2D
	
	collisionShape.shape.size = get_rect().size
	collisionShape.position = get_rect().size / 2
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func GenerateGrid():
	for child in flowContainer.get_children():
		flowContainer.remove_child(child)
	
	for i in range(diceContainer.get_child_count()):
		var cell = Control.new()
		
		#cell.color = Color.BEIGE
		
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.custom_minimum_size = cellSize
		
		flowContainer.add_child(cell)

func SortGrid() -> Tween:
	var tween = create_tween()
	tween.pause()
	
	GenerateGrid()
	
	for i in range(2):
		await get_tree().process_frame
	
	for index in range(diceContainer.get_child_count()):
		tween.parallel().tween_property(diceContainer.get_child(index), "global_position", flowContainer.get_child(index).global_position + cellOffset, 0.2)
	
	tween.play()
	
	return tween

func GetCellPosition(cellIndex: int):
	return flowContainer.get_child(cellIndex).global_position + cellOffset

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
