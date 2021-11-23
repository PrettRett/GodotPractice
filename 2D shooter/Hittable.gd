class_name Hittable
extends Node

onready var Health = 100.0
var dmgMultiplier = 1.0
var deadFunc
var pushFunc

func _init():
    Health = 100.0
    
func setDeathCall(deathFuncStr,srcObj)
    deadFunc = funcref(srcObj, deathFuncStr)

func setPushCall(pushFuncStr,srcObj)
    pushFunc = funcref(srcObj, pushFuncStr)
    
func death():
    print("object without death")
    if deadFunc.is_valid():
        deadFunc.call_func()
    pass

func push(push_val,src,collision):
    print("object without push")
    if pushFunc.is_valid():
        var pushVector = Vector2(1,1)
        var arrAux = [pushVector]
        pushFunc.call_funcv(arrAux)
    pass

func hitted(dmg,src,collision):
    Health -= dmg*dmgMultiplier
    if Health <= 0.0:
        death()
