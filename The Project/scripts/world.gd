extends Node2D

onready var camera  = get_node("Camera2D")
onready var tilemap = get_node("tilemap")
onready var units   = get_node("units")
onready var structures = get_node("structures")
onready var UI = get_node("InterfaceLayer/Interface")

signal end_turn

var turnCounter = int(1)

var assignMode = false
var selFrame
var selObject: Node2D

var resources = {
	"science" : 0,
	"food" : 0,
	"gold" : 0
}


var tileStack = { 
	"tile" : null,
	"idx" : 0
}


func _ready():
	
	selFrame = Sprite.new()
	selFrame.texture = load("res://images/selection_frame.png")
	selFrame.z_index = 1
	selFrame.self_modulate = Color(1,1,1,0.5)
	selFrame.position = Vector2(-100, -100)
	self.add_child(selFrame)
	
	create_tilemap()
	var rndHex = tilemap.get_child(global.RNG.randi_range(0, tilemap.get_child_count()))
	while rndHex.relief == "water":
		rndHex = tilemap.get_child(global.RNG.randi_range(0, tilemap.get_child_count()))
	create_unit(rndHex)
	
	camera.position = rndHex.position
	self.scale = Vector2(1.4,1.4)



func _process(_delta):
	if Input.is_action_pressed("w"):
		camera.position += Vector2(0, -12)
	
	if Input.is_action_pressed("a"):
		camera.position += Vector2(-12, 0)
	
	if Input.is_action_pressed("s"):
		camera.position += Vector2(0, 12)
	
	if Input.is_action_pressed("d"):
		camera.position += Vector2(12, 0)
	
	if Input.is_action_just_released("scroll_up"):
		if self.scale < Vector2(4,4):
			self.scale += Vector2(0.2, 0.2)
	
	if Input.is_action_just_released("scroll_down"):
		if self.scale > Vector2(0.2, 0.2):
			self.scale += Vector2(-0.2, -0.2)
			print(scale)


var vegetation = preload("res://images/forest.png")
func create_tilemap(sizeX = 260, sizeY = 130): #58, 27
	#var nzLand = OpenSimplexNoise.new()
	var vegMap = OpenSimplexNoise.new()
	vegMap.seed = global.RNG.randi()
	vegMap.octaves = 3
	vegMap.lacunarity = 4
	vegMap.persistence = 0.215 #0.215
	vegMap.period = 8 #14 / 20
	
	var nzHeight = OpenSimplexNoise.new()
	nzHeight.seed = global.RNG.randi()
	nzHeight.octaves = 3
	nzHeight.lacunarity = 4
	nzHeight.persistence = 0.215 #0.215
	nzHeight.period = 50 #14 / 20
	
	var tileScene = load("res://scenes/tile.tscn")
	
	var stepH = int(26)
	var stepV = int(29) #to make relative to the size of a tile
	var coords = {"r" : int(0), "q" : int(0), "s" : int(0)}
	var topTileCoords = {"r" : int(0), "q" : int(0), "s" : int(0)}
	var origTilePos = Vector2(20,18)
	var tilePos = Vector2(origTilePos)
	
	for x in range(sizeX):
		coords = topTileCoords.duplicate()
		#print("coords", coords)
		
		for y in range(sizeY):
			create_tile(tilePos, coords, tileScene.instance(), nzHeight.get_noise_2d(x, y), vegMap.get_noise_2d(x, y))
			coords.r += 1
			coords.s -= 1
			tilePos.y += stepV
		
		if (x+1)%2 == 0:
			topTileCoords.r -= 1
			topTileCoords.q += 1
			tilePos.y = origTilePos.y 
		
		else:
			topTileCoords.s -= 1
			topTileCoords.q += 1
			tilePos.y = origTilePos.y + stepV /2
		
		tilePos.x += stepH



func create_tile(pos, coords, tile, nzHeight, vegVal):
	
	var vv = (vegVal - (nzHeight))
	var veg = bool()
	var waterLvl = 0.2
	var step = 0.12
	
	tile.position = pos
	
	if nzHeight <= waterLvl:
		tile.init({"climate" : "temperate", "relief" : "water"})
	elif nzHeight <= waterLvl + step:
		tile.init({"climate" : "temperate", "relief" : "plain"})
	elif nzHeight <= waterLvl + step*2:
		tile.init({"climate" : "temperate", "relief" : "plain2"})
	elif nzHeight <= waterLvl + step*3:
		tile.init({"climate" : "temperate", "relief" : "plain3"})
	else: 
		tile.init({"climate" : "temperate", "relief" : "plain4"})
	
	if vv > 0 and tile.relief != "water":
		tile.get_node("veg").texture = vegetation
	
	tile.coords = coords.duplicate()
	tilemap.add_child(tile)



func create_unit(tile, unitType = "settler"): #random tile
	var unit = load("res://scenes/units/unit.tscn").instance()
	unit.init(unitType, tile)
	unit.position = tile.position
	self.get_node("units").add_child(unit)



func end_turn():
	emit_signal("end_turn")
	for unit in units.get_children():
		unit.end_turn()
	turnCounter += 1
	get_node("InterfaceLayer/Interface/EndTurn/TurnCount").text = "Turn: " + str(turnCounter) 
	select_object(null)






func select_object(object): #update_unit_info_panel(object)
	UI.update_selection_panel(selObject, object)
	
	if object == null:
		selFrame.visible = false
		selObject = null
	
	elif object.TYPE == "unit":
		selFrame.position = object.position
		selFrame.visible = true
		selObject = object
	
	elif object.TYPE == "structure":
		selFrame.position = object.position
		selFrame.visible = true
		selObject = object
	
	
	
	if selObject != null: 
		print("sel object = ", selObject.TYPE)



func assign_mode(mode = true):
	if mode != false:
		assignMode = true
	elif mode == false:
		assignMode = false
