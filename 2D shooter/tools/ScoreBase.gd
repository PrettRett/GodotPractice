extends HBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var nameLabel = $CenterContainer2/Label
onready var stateLabel = $VBoxContainer/Label
onready var scoreLabel = $VBoxContainer/Label3

func setName(newName:String):
	nameLabel.text = newName

func setState(newName:String):
	stateLabel.text = newName

func setScore(Value):
	scoreLabel.text = ("Score: " + str(Value))

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
