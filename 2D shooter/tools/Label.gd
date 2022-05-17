extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var minutos : int = 0
var segundos = 0

func addToTime(timeToAdd):
	segundos += timeToAdd
	if segundos >= 60.0:
		segundos -= 60.0
		minutos +=1
	var auxStr = "%06.3f" % segundos
	text = String(minutos) + ":" + auxStr
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalInfo.global_time = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	GlobalInfo.global_time += delta
	addToTime(delta)
	pass
