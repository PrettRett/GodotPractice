extends Area2D

enum powerUpType {
	DEFAULT,
	LONG,
	EXPLOSIVE,
	MULTIPLE,
}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var pUpSprite = $Sprite

var pUpType = powerUpType.LONG

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setPowerUpType(type):
	pUpType = type
	if type == powerUpType.DEFAULT:
		pass
	elif type == powerUpType.LONG:
		pUpSprite.frame_coords = Vector2(5,2)
		pass
	elif type == powerUpType.EXPLOSIVE:
		pUpSprite.frame_coords = Vector2(15,3)
		pass
	elif type == powerUpType.MULTIPLE:
		pUpSprite.frame_coords = Vector2(4,3)
		pass
	pass

func getPowerUpType(type):
	return pUpType
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
