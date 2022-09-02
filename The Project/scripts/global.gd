extends Node

#onready var world = get_node("/root/world")

var assets = {
	"ui" : {
		"food" : "res://images/token_food_1.png",
		"wood" : "res://images/token_wood.png"
	},
	"tilemap" : {
		"grass" : "res://images/tile_grass.png",
		"water" : "res://images/tile_water.png",
		"empty" : "res://images/tile_empty.png",
		
		"forest" : "res://images/forest.png",
		
		"selFrame" : "res://images/selection_frame.png"
	},
	"buttons" : {
		"settle" : {
			"normal" : "res://images/button_settle_normal.png",
			"pressed" : "res://images/button_settle_pressed.png"
		}
	}
}



var tileTypes = {
	"temperate" : {
		"plain"  : "res://images/plain1.png",
		"forest" : "res://images/grass_forest.png",
		"hills"  : "res://images/grass_hills.png",
		"water"  : "res://images/tile_water.png",
		"plain2" : "res://images/plain2.png",
		"plain3" : "res://images/plain3.png",
		"plain4" : "res://images/plain4.png"
		},
	"cold" : {}
}



var structTypes = {
	"camp" : {
		"onMapImg" : "res://images/camp.png"
	}
}



var unitTypes = {
	"settler" : {
		"attr" : {
			"movement" : {
				"points" : 4,
				"costs" : {
					"plain" : 1,
					"forest" : 2,
					"hills" : 2,
					"water" : -1
				}
			},
			"sight" : {},
			"abilities" : [
				"settle"
			]
		},
		"onMapImg" : "res://images/pop_settler.png"
	}
}


#camp -> village -> town -> city -> metropolis

var pop = {
	"production" : {
		"urban" : {
			"gold" : 0.2,
			'science' : 0.2
		},
		"plain" : {
			"food" : 3
		}
	},
	"consumption" : {
		"food" : 1
	}
}

var RNG = RandomNumberGenerator.new()

func _ready():
	RNG.randomize()



func is_in_range(origHex, selHex, rng = int(1)):
	var origHexCoords = origHex.coords
	var selHexCoords = selHex.coords
	if selHexCoords.r <= origHexCoords.r + rng and selHexCoords.r >= origHexCoords.r - rng:
		if selHexCoords.q <= origHexCoords.q + rng and selHexCoords.q >= origHexCoords.q - rng:
			if selHexCoords.s <= origHexCoords.s + rng and selHexCoords.s >= origHexCoords.s - rng:
				return true
	return false


#func in_range(origHex, selHex, rng = int(1)): #remake 1st arg to take objects
#	print("rng func start")
#	for child in world.tilemap.get_children():
#		if child.coords.r <= curCoords.r + rng and child.coords.r >= curCoords.r - rng:
#			if child.coords.q <= curCoords.q + rng and child.coords.q >= curCoords.q - rng:
#				if child.coords.s <= curCoords.s + rng and child.coords.s >= curCoords.s - rng:
#					return true
#	return false
	
