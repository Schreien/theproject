extends Node


func _ready():
	get_node("Control/NewGameButton").connect("pressed", self, "start_game")



func start_game():
	var gameScene = load("res://scenes/world.tscn").instance()
	self.add_child(gameScene)
	self.get_node("Control").queue_free()



