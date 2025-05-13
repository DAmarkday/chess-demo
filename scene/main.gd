extends Node2D
@onready var chess = preload("res://scene/chess/chess/chess.tscn")

@onready var 车 = preload("res://scene/chess/rook/rook.tscn")
@onready var 马 = preload("res://scene/chess/knight/knight.tscn")
@onready var 象 = preload("res://scene/chess/Bishop/bishop.tscn")
func _ready() -> void:
	#生成棋盘
	var chess_instance=chess.instantiate()
	add_child(chess_instance)
	
	#生成棋子
	#var arr=chess_instance.createRandomPosition(3)
	#print(arr)
	## 生成棋子
	#for index in range(0,arr[1].size()):
		#var piece = [车,马,象][randi() % 3]
		#var inst=piece.instantiate()
		#chess_instance.生成棋子(inst,arr[0][index],arr[1][index])
	
	pass
