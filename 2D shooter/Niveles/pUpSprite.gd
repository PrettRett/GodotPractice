extends Sprite

enum powerUpType {
	DEFAULT,
	LONG,
	EXPLOSIVE,
	MULTIPLE,
}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func connectSignals(obj):
	if get_tree().has_network_peer():
		if is_network_master():
			obj.connect("changeSym", self, "_change_pUpSymbol")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _change_pUpSymbol(type):
	if type == powerUpType.DEFAULT:
		frame_coords = Vector2(3,6)
	elif type == powerUpType.LONG:
		frame_coords = Vector2(5,2)
	elif type == powerUpType.EXPLOSIVE:
		frame_coords = Vector2(15,3)
	elif type == powerUpType.MULTIPLE:
		frame_coords = Vector2(4,3)
	
