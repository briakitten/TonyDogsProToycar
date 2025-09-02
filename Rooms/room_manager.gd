extends Node

@export var current_room:String = ""
var current_room_index:int

# Load the new level from disk

@export var rooms_dictionary = {
    "title": preload("res://Rooms/room_title_screen.tscn").instantiate(),
    "town": preload("res://Rooms/room_town_smol.tscn").instantiate()
}

func switch_room(node_key:String) -> void:
    # unload current room
    get_tree().root.get_child(current_room_index).free()
    
    # get new room
    var node:Node = rooms_dictionary.get(node_key)
    current_room_index = node.get_index()
    current_room = node_key

    # add new room to scene
    get_tree().root.add_child(node)
    
    return