extends Node2D

const TYPE = "structure" #change type to urban

var world

var posHex

var params = {
	"housing" : int(3),
	"storage" : {
		"current" : {
			"food" : 0,
			"gold" : 0,
			"science" : 0
		},
		"max" : {
			"food" : 0,
			"gold" : 0,
			"science" : 0
		}
	}
}
var cityBaseParams = {}
var storage = {
	"food" : 0,
	"gold" : 0,
	"science" : 0
}

var pops = {
	"amount" : int(1),
	"happiness" : float(0),
	"newPop" : float(0),
	"assignment" : []
}

var buildings = {
	"houses" : {}
	
}

var basePopStats = {
	"production" : {
		"labor" : 1,
		"urban" : {
			"gold" : 0.2,
			"science" : 0.2
		},
		"plain" : {
			"food" : 3
		}
	},
	"consumption" : {
		"food" : 1
	},
	"growth" : float(0.05)
}

var productionMods 
var cityRange = 1 #camp (1) -> village (2) -> town (3) -> city (4) -> metropolis (5)
var assignedPopsIcons = []



func _ready():
	pass


func init(type, tile, worldRef):
	world = worldRef
	get_node("Sprite").texture = load(global.structTypes[type]["onMapImg"])
	world.connect("end_turn", self, "end_turn")
	posHex = tile



func produce():
	var unassignedPops = pops["amount"] - pops["assignment"].size()
	for pop in range(unassignedPops):
		for res in global.pop["production"]["urban"]:
			world.resources[res] += global.pop["production"]["urban"][res] #to replace with city storage
			storage[res] += basePopStats["production"]["urban"][res]
			
	for tile in pops["assignment"]:
		for res in global.pop["production"][tile.relief]:
			world.resources[res] += global.pop["production"][tile.relief][res] #to replace with city storage
			storage[res] += basePopStats["production"][tile.relief][res]
	
	#consume
	for res in basePopStats["consumption"]:
		storage[res] -= basePopStats["consumption"][res] * pops["amount"]
		world.resources[res] -= basePopStats["consumption"][res] * pops["amount"] #to remove
	
	#growth
	pops["newPop"] += basePopStats["growth"] * pops["amount"]
	if pops["newPop"] >= 1:
		pops["newPop"] -= 1
		pops["amount"] += 1
	
	
	world.UI.update_resource_bar()



func end_turn():
	produce()



func assign(tile):
	var unassignedPops = pops["amount"] - pops["assignment"].size()
	if unassignedPops > 0:
		if tile != posHex:
			if global.is_in_range(posHex, tile, cityRange):
				pops["assignment"].append(tile)
				show_assigned_pops(false)
				show_assigned_pops(true)
			else:
				print("Tile is out of city's range.")
		else:
			print("You can't assign pop.")
	else:
		print("No free pops.")



func show_assigned_pops(mode):
	if mode == true:
		var icon = Sprite.new()
		icon.texture = load("res://images/assigned_pop.png")
		for hex in pops["assignment"]:
			var popIcon = icon.duplicate()
			popIcon.position = hex.position
			popIcon.z_index = 10
			assignedPopsIcons.append(popIcon)
			world.get_node("other").add_child(popIcon)
	elif mode == false:
		#var i = int(assignedPopsIcons.size())
		while assignedPopsIcons.empty() == false:
			assignedPopsIcons[0].queue_free()
			assignedPopsIcons.remove(0)
			#assignedPopsIcons.erase(popIcon)



