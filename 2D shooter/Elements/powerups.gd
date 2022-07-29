extends Area2D

signal power_upped(type)

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


func _on_Node2D_body_entered(body):
	if body.has_method("setArrowType"):
		body.setArrowType(pUpType)
		queue_free()
	pass # Replace with function body.
