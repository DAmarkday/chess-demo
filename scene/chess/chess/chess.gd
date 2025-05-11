extends Node2D

var grid_size = Vector2i(8, 10)
var cell_size = 64
var grid_nodes = []
var grid_pieces = [] # 棋子位置
var selected_cell = Vector2i(-1, -1)
var selected_piece = null
var highlight_lines = []
@onready var Grid = $Grid

func _ready():
	randomize()
	for x in range(grid_size.x):
		var node_row = []
		var piece_row = []
		for y in range(grid_size.y):
			node_row.append(null)
			piece_row.append(null)
		grid_nodes.append(node_row)
		grid_pieces.append(piece_row)
	
	create_visual_grid()
	
	# 生成河流 山川
	for rowIndex in range(grid_nodes.size()):
		for j in range(grid_nodes[rowIndex].size()):
			
			if(grid_nodes[rowIndex].size() % 2 ==0):
				var seaIndex=(grid_nodes[rowIndex].size()) /2
				var cell=grid_nodes[rowIndex][seaIndex]
				var sprite = Sprite2D.new()
				#sprite.texture = preload('res://texture/Chess/chess1.png')
				sprite.texture = preload('res://icon.svg')
				sprite.position=Vector2(cell.position.x + cell_size / 2, cell.position.y - cell_size / 2)
				sprite.scale = Vector2(0.5,0.5)
				add_child(sprite)
				
				var cell2=grid_nodes[rowIndex][seaIndex+1]
				var sprite2 = Sprite2D.new()
				sprite2.texture = preload("res://icon.svg")
				sprite2.position=Vector2(cell2.position.x + cell_size / 2, cell2.position.y - cell_size / 2)
				sprite2.scale = Vector2(0.5,0.5)
				add_child(sprite2)
			#pass
			else:
				#奇数行
				var seaIndex=(grid_nodes[rowIndex].size()+1) /2
				var cell=grid_nodes[rowIndex][seaIndex]
				var sprite = Sprite2D.new()
				sprite.texture = preload("res://icon.svg")
				sprite.position=Vector2(cell.position.x + cell_size / 2, cell.position.y - cell_size / 2)
				sprite.scale = Vector2(0.5,0.5)
				add_child(sprite)
				
			pass
			
			
	
	
	
	
	setup_camera()
	Grid.position = Vector2(0, 0)
	print("Grid position: ", Grid.position)

func setup_camera():
	var camera = Camera2D.new()
	camera.position = Vector2(grid_size.x * cell_size / 2, grid_size.y * cell_size / 2)
	camera.zoom = Vector2(1, 1)
	add_child(camera)
	camera.make_current()

func create_visual_grid():
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var cell = ColorRect.new()
			cell.size = Vector2(cell_size, cell_size)
			cell.position = Vector2(x * cell_size, y * cell_size)
			cell.color = Color(0.2, 0.2, 0.2)
			Grid.add_child(cell)
			grid_nodes[x][y] = cell

	for x in range(grid_size.x + 1):
		var line = Line2D.new()
		line.add_point(Vector2(x * cell_size, 0))
		line.add_point(Vector2(x * cell_size, grid_size.y * cell_size))
		line.width = 2
		line.default_color = Color(0.5, 0.5, 0.5)
		Grid.add_child(line)

	for y in range(grid_size.y + 1):
		var line = Line2D.new()
		line.add_point(Vector2(0, y * cell_size))
		line.add_point(Vector2(grid_size.x * cell_size, y * cell_size))
		line.width = 2
		line.default_color = Color(0.5, 0.5, 0.5)
		Grid.add_child(line)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var cell_x = int(mouse_pos.x / cell_size)
		var cell_y = int(mouse_pos.y / cell_size)
		if cell_x >= 0 and cell_x < grid_size.x and cell_y >= 0 and cell_y < grid_size.y:
			handle_click(Vector2i(cell_x, cell_y))

func handle_click(cell: Vector2i):
	if selected_piece != null:
		if selected_piece.is_valid_move(cell):
			move_piece(selected_piece, cell)
		clear_selection()
	elif grid_pieces[cell.x][cell.y] != null:
		select_piece(cell)

func select_piece(cell: Vector2i):
	clear_selection()
	selected_cell = cell
	selected_piece = grid_pieces[cell.x][cell.y]
	grid_nodes[cell.x][cell.y].color = Color(0, 1, 0)
	highlight_cell_lines(cell)

func move_piece(piece, target: Vector2i):
	var old_pos = piece.pos
	piece.set_piece_position(target)
	grid_pieces[old_pos.x][old_pos.y] = null
	grid_pieces[target.x][target.y] = piece

func clear_selection():
	if selected_cell != Vector2i(-1, -1):
		grid_nodes[selected_cell.x][selected_cell.y].color = Color(0.2, 0.2, 0.2)
		clear_highlight_lines()
	selected_cell = Vector2i(-1, -1)
	selected_piece = null

func highlight_cell_lines(cell: Vector2i):
	var x = cell.x
	var y = cell.y
	var points = [
		[Vector2(x * cell_size, y * cell_size), Vector2((x + 1) * cell_size, y * cell_size)],
		[Vector2(x * cell_size, (y + 1) * cell_size), Vector2((x + 1) * cell_size, (y + 1) * cell_size)],
		[Vector2(x * cell_size, y * cell_size), Vector2(x * cell_size, (y + 1) * cell_size)],
		[Vector2((x + 1) * cell_size, y * cell_size), Vector2((x + 1) * cell_size, (y + 1) * cell_size)]
	]

	for point_pair in points:
		var line = Line2D.new()
		line.add_point(point_pair[0])
		line.add_point(point_pair[1])
		line.width = 4
		line.default_color = Color(1, 1, 0)
		Grid.add_child(line)
		highlight_lines.append(line)

func clear_highlight_lines():
	for line in highlight_lines:
		line.queue_free()
	highlight_lines.clear()
	
	
func 生成棋子(piece:Node2D,chessPosition:Vector2,pos:Vector2):
	piece.grid_size = grid_size
	piece.grid_pieces = grid_pieces
	
	Grid.add_child(piece)  # 先添加到场景树
	piece.z_index=2
	piece.set_piece_position(chessPosition)  # 最后设置位置
	grid_pieces[chessPosition.x][chessPosition.y] = piece
	print("Piece added at pixel position: ", piece.position)
	pass
	
func createRandomPosition(count:int):
	var placed_positions = []
	for i in count:
		var pos = Vector2i(randi() % grid_size.x, randi() % grid_size.y)
		var attempts = 0
		while pos in placed_positions and attempts < 100:
			pos = Vector2i(randi() % grid_size.x, randi() % grid_size.y)
			attempts += 1
			if attempts >= 100:
				push_error("Failed to find unique position for piece")
				continue
		placed_positions.append(pos)
		print("Spawning piece at grid position: ", pos)
	var temp = []
	#temp: 实际位置
	#placed_positions： 棋盘位置
	for new_pos in placed_positions:
		var np = Vector2(new_pos.x * cell_size + cell_size / 2, new_pos.y * cell_size + cell_size / 2)
		temp.append(np)
	return [placed_positions,temp]
	
