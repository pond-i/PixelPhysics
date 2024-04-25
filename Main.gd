extends Node2D

onready var tile_map = $TileMap
onready var text_label = $Tool_text

export var brush_size = 1

var can_draw = true

const Eraser = -1
const WallID = 0
const SandID = 1
const WaterID = 2
const RockID = 3
const GrassID = 4
const LavaID = 5
const AcidID = 6
const MetalID = 7
const IceID = 8
const SaltID = 9
const WoodID = 10
const VirusID = 11

const RustID = 0.5

const empty_cell = -1

var current_tool = 1
var up
var extended_up
var down 
var extended_down
var left 
var extended_left
var right 
var extended_right
var down_left 
var down_right 
var cellIndex
var cells = []
var xd = ""


# Extremely rough prototype
# Code is extremely rough and needs a large amount of work. Needs optimisation throughout.
# Performance at around 150 fps, can be better.

func _ready() -> void:
	#$ConfirmationDialog.popup()
	pass

func _physics_process(_delta: float) -> void:
	toolSelection()
	$Fps_text.set_text(str(Engine.get_frames_per_second()) + xd)
	update()
	cellInstance()
	tile_map.update_dirty_quadrants()

func checkCellEmpty(x,y):
	if(tile_map.get_cell(x,y) == empty_cell):
		return true
	else:
		return false
		
func getCellType(x,y):
	return tile_map.get_cell(x,y)
	
func leftRightExchange():
	if(right == empty_cell && left == empty_cell):
		if randi() % 2:
			left = 0
			right = -1

func cellInstance():   
	cells = tile_map.get_used_cells()
	
	for cell in cells:
		
		cellIndex = tile_map.get_cell(cell.x, cell.y)
		down = getCellType(cell.x, cell.y +1)
		left = getCellType(cell.x -1, cell.y +1)
		right = getCellType(cell.x +1, cell.y +1)

		match cellIndex:
			
			SandID:	
				if(getCellType(cell.x, cell.y) != 0):
					down_left = getCellType(cell.x -1, cell.y +1)
					down_right = getCellType(cell.x +1, cell.y +1)
					
					if(down == WaterID) && down != 0:
						tile_map.set_cell(cell.x, cell.y, -1)
						tile_map.set_cell(cell.x, cell.y + 1, SandID)
				
					if(down == LavaID) && down != 0:
						tile_map.set_cell(cell.x, cell.y, -1)
						tile_map.set_cell(cell.x, cell.y + 1, LavaID)
								
					if(down == empty_cell) && down != 0:
						tile_map.set_cell(cell.x, cell.y, -1)
						tile_map.set_cell(cell.x, cell.y + 1, SandID)
					elif(left == empty_cell && down_left == empty_cell):
						tile_map.set_cell(cell.x, cell.y, -1)
						tile_map.set_cell(cell.x -1, cell.y +1, SandID)
					elif(right == empty_cell && down_right == empty_cell):
							tile_map.set_cell(cell.x, cell.y, -1)
							tile_map.set_cell(cell.x +1, cell.y +1, SandID)
					
			WaterID:	
				left = getCellType(cell.x -1, cell.y)
				right = getCellType(cell.x +1, cell.y)
				leftRightExchange()
				
				if(down == SaltID) && down != 0:
					var water_melt = rand_range(0.05, 0.2)
					yield(get_tree().create_timer(water_melt), "timeout")
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x, cell.y + 1, WaterID)
				
				if(down == empty_cell) && down != 0:
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x, cell.y + 1, WaterID)
				
				elif(left == empty_cell):
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x -1, cell.y, WaterID)
				elif(right == empty_cell):
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x +1, cell.y, WaterID)
					
			GrassID:
				pass
				
			LavaID:	
				up = getCellType(cell.x, cell.y -1)
				left = getCellType(cell.x -1, cell.y)
				right = getCellType(cell.x +1, cell.y)
				leftRightExchange()
						
								
				if(up == WaterID):
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x, cell.y - 1, RockID)
				if(down == WaterID):
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x, cell.y + 1, RockID)
				if(left == WaterID):
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x -1, cell.y, RockID)
				if(right == WaterID):
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x +1, cell.y, RockID)
				
				if(down == empty_cell):
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x, cell.y + 1, LavaID)
				elif(left == empty_cell):
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x -1, cell.y, LavaID)
				elif(right == empty_cell):
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x +1, cell.y, LavaID)
				elif(down == IceID) && down != 0:
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x, cell.y + 1, WaterID)
				
			
			AcidID:
				up = getCellType(cell.x, cell.y -1)
				left = getCellType(cell.x -1, cell.y)
				right = getCellType(cell.x +1, cell.y)
				leftRightExchange()
				
				if(down == empty_cell):
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x, cell.y + 1, AcidID)		
				
				if(up >= 1) && up != AcidID:
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x, cell.y + 1, AcidID)
				if(down >= 1) && down != AcidID:
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x, cell.y + 1, AcidID)
					yield(get_tree().create_timer(0.1), "timeout")
					tile_map.set_cell(cell.x, cell.y, -1)
				if(left >= 1) && left != AcidID:
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x -1, cell.y, AcidID)
					yield(get_tree().create_timer(0.1), "timeout")
					tile_map.set_cell(cell.x, cell.y, -1)
				if(right >= 1) && right != AcidID:
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x +1, cell.y, AcidID)
					yield(get_tree().create_timer(0.1), "timeout")
					tile_map.set_cell(cell.x, cell.y, -1)
									
			
				
			MetalID:
				pass
			IceID:
				up = getCellType(cell.x, cell.y -1)
				left = getCellType(cell.x -1, cell.y)
				right = getCellType(cell.x +1, cell.y)
				
				extended_up = getCellType(cell.x, cell.y -2)
				extended_down = getCellType(cell.x, cell.y -2)
				extended_right = getCellType(cell.x +2, cell.y)
				extended_left = getCellType(cell.x -2, cell.y)				
				
			RustID:
				pass
			SaltID:
				up = getCellType(cell.x, cell.y -1)
				left = getCellType(cell.x -1, cell.y)
				right = getCellType(cell.x +1, cell.y)
				leftRightExchange()
				
				if(down == LavaID):
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x, cell.y + 1, LavaID)
					
				if(down == WaterID) && down != 0:
						tile_map.set_cell(cell.x, cell.y, -1)
						tile_map.set_cell(cell.x, cell.y + 1, SaltID)

				if(down == empty_cell):
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x, cell.y + 1, SaltID)
				elif(down == IceID) && down != 0:
					var ice_melt = rand_range(0.05, 0.2)
					yield(get_tree().create_timer(ice_melt), "timeout")
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x, cell.y + 1, WaterID)
					
			VirusID:
				
				up = getCellType(cell.x, cell.y -1)
				left = getCellType(cell.x -1, cell.y)
				right = getCellType(cell.x +1, cell.y)
				leftRightExchange()
				var acid_count = rand_range(5, 12)
				
				if(down == empty_cell) && down != 0:
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x, cell.y + 1, VirusID)		

				if(up >= 1) && up != VirusID:
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x, cell.y - 1, VirusID)
				if(down >= 1) && down != VirusID:
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x, cell.y + 1, VirusID)
				elif(left >= 1) && left != VirusID:
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x -1, cell.y, VirusID)
				elif(right >= 1) && right != VirusID:
					tile_map.set_cell(cell.x, cell.y, -1)
					tile_map.set_cell(cell.x +1, cell.y, VirusID)
	
	
func toolSelection():
	match current_tool:
		-1:
			$Tool_text.set_text("Tool: Eraser")
		0:
			$Tool_text.set_text("Tool: Wall")
		1:
			$Tool_text.set_text("Tool: Sand")
		2:
			$Tool_text.set_text("Tool: Water")
		3:
			$Tool_text.set_text("Tool: Rock")
		4:
			$Tool_text.set_text("Tool: Grass")
		5:
			$Tool_text.set_text("Tool: Lava")
		6:
			$Tool_text.set_text("Tool: Acid")
		7:
			$Tool_text.set_text("Tool: Metal")
		8:
			$Tool_text.set_text("Tool: Ice")
		9:
			$Tool_text.set_text("Tool: Salt")
		10:
			$Tool_text.set_text("Tool: Wood")
		11:
			$Tool_text.set_text("Tool: Virus")

func _input(_event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("key_1"):
		current_tool = 1
		
	if Input.is_action_just_pressed("key_2"):
		current_tool = 2
		
	if Input.is_action_just_pressed("key_4"):
		current_tool = 3
		
	if Input.is_action_just_pressed("key_3"):
		current_tool = 4
	
	if Input.is_action_just_pressed("key_q"):
		current_tool = -1
	
	if Input.is_action_pressed("right_click"):
		if(can_draw):
			if(getCellType(get_global_mouse_position().x, get_global_mouse_position().y) != 0):
				tile_map.set_cell(get_global_mouse_position().x, get_global_mouse_position().y, current_tool)

	if Input.is_action_pressed("left_click"):
		if(can_draw):
			tile_map.set_cell(get_global_mouse_position().x, get_global_mouse_position().y, RockID)

func _on_Button_pressed() -> void:
	tile_map.clear()
	
	for i in range(0, 200):
		print(i)
		tile_map.set_cell(i + 0.1, 99, WallID)   
		 
	for i in range(0, 100):
		print(i)
		tile_map.set_cell(0, i + 0.1, WallID)   

	for i in range(0, 200):
		print(i)
		tile_map.set_cell(i + 0.1, 99, WallID)   

	for i in range(100, 0):
		print(i)
		tile_map.set_cell(0, i + 0.1, WallID)   

func _on_ItemList_item_selected(index: int) -> void:
	if(index == 0):
		index = 1
	current_tool = index

func _on_ItemList_mouse_entered() -> void:
	can_draw = false

func _on_ItemList_mouse_exited() -> void:
	can_draw = true

