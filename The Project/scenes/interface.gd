extends Control

onready var world = get_node("/root/world") #to replace with /root/main/world
onready var selectionPanel = get_node("SelectionBar")
onready var resourceBar = get_node("ResourceBar/HBoxContainer")



func _ready():
	get_node("EndTurn").connect("pressed", world, "end_turn")



func update_selection_panel(prevObj, newObj):
	var typeLabel = get_node("SelectionBar/UnitInfo/VBoxContainer/Type")
	var mp = get_node( "SelectionBar/UnitInfo/VBoxContainer/MP" )
	var assignButton = get_node("SelectionBar/CityInfo/Assign")
	var cityName = get_node("SelectionBar/CityInfo/CityName")
	var cityInfoPanel = get_node("SelectionBar/CityInfo")
	
	
	if prevObj != null and newObj != null:
		if prevObj.TYPE != newObj.TYPE:
			if prevObj.TYPE == "unit":
				typeLabel.text = "---"
				mp.text = "MP: -/-"
				for i in range(prevObj.baseParams["abilities"].size()):
					var button = get_node("SelectionBar/AbilitiesPanel/button" + str(i+1))
					button.visible = false
					button.texture_normal = null
					button.disconnect("pressed", prevObj, prevObj.baseParams["abilities"][i])
				
				
			if prevObj.TYPE == "structure":
				cityInfoPanel.visible = false
				world.assign_mode(false)
				assignButton.disconnect("pressed", world, "assign_mode")
				prevObj.show_assigned_pops(false)
	
	
	if newObj == null:
		if prevObj != null:
			if prevObj.TYPE == "unit":
				#to remove unit stats
				typeLabel.text = "---"
				mp.text = "MP: -/-"
				for i in range(prevObj.baseParams["abilities"].size()):
					var button = get_node("SelectionBar/AbilitiesPanel/button" + str(i+1))
					button.visible = false
					#button.disabled = true
					button.texture_normal = null
					button.disconnect("pressed", prevObj, prevObj.baseParams["abilities"][i])
					print("disconnected")
					
			elif prevObj.TYPE == "structure":
				cityInfoPanel.visible = false
				world.assign_mode(false)
				assignButton.disconnect("pressed", world, "assign_mode")
				prevObj.show_assigned_pops(false)
				#assignButton.visible = false
				
				
	
	elif newObj.TYPE == "unit":
		typeLabel.text = str(newObj.unitType)
		mp.text = "MP: " + str(newObj.curPoints["movement"]) + "/" + str(newObj.baseParams["movement"]["points"])
		if prevObj != null and prevObj != newObj:
			#to update unit stats
			#mp.text = "MP: " + str(newObj.curPoints["movement"]) + "/" + str(newObj.baseParams["movement"]["points"])
			if prevObj.TYPE == "unit":
				for i in range(prevObj.baseParams["abilities"].size()):
					var button = get_node("SelectionBar/AbilitiesPanel/button" + str(i+1))
					button.visible = false
					if button.is_connected("pressd", prevObj, prevObj.baseParams["abilities"][i]):
						button.disconnect("pressed", prevObj, prevObj.baseParams["abilities"][i])
				
		for i in range(newObj.baseParams["abilities"].size()):
			var button = get_node("SelectionBar/AbilitiesPanel/button" + str(i+1))
			button.texture_normal = load(global.assets["buttons"][newObj.baseParams["abilities"][i]]["normal"])
			button.texture_pressed = load(global.assets["buttons"][newObj.baseParams["abilities"][i]]["pressed"])
			button.visible = true
			
			if not button.is_connected("pressed", newObj, newObj.baseParams["abilities"][i]):
				button.connect("pressed", newObj, newObj.baseParams["abilities"][i])
				print("Connected")
	
	elif newObj.TYPE == "structure":
		typeLabel.text = "structure"
		mp.text = "MP: -/-"
		cityInfoPanel.get_node("Population").text = "Pops: " + str(newObj.pops["amount"])
		cityInfoPanel.get_node("Growth").text = "Growth: " + str(newObj.pops["newPop"])
		cityInfoPanel.visible = true
		
		assignButton.connect("pressed", world, "assign_mode")
		
		newObj.show_assigned_pops(true)
	


func update_resource_bar():
	for res in resourceBar.get_children():
		res.get_node("number").text = str(world.resources[res.get_name()])
	pass




