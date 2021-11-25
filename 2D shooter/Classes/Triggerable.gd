class_name Triggerable
extends Node

enum trigType {
    ALL_TRUE,
    ALL_FALSE,
    ORDER_TRUE,
    ORDER_FALSE,
    }

onready var triggArrays = []

var triggerType = trigType.ALL_TRUE
var triggered = false
var enabled = false
var arrSuccFuncResponse = []
var arrFailFuncResponse = []

func _init():
    enabled = false
    triggered = false
    arrSuccFuncResponse.clear()
    arrFailFuncResponse.clear()

func _process():
    if enabled:
        pass
        match(triggerType):
            trigType.ALL_TRUE:
                pass
            trigType.ALL_FALSE:
                pass
            trigType.ORDER_FALSE:
                pass
            trigType.ORDER_TRUE:
                pass

func isTriggered():
    return triggered

func addTriggerCondition(trigCheckFuncStr,src):
    triggArrays.push_back(funcref(src,trigCheckFuncStr))

func addSuccessResponse(successFuncStr,src):
    arrSuccFuncResponse.push_back(funcref(src,successFuncStr))

func addFailResponse(failFuncStr,src):
    arrFailFuncResponse.push_back(funcref(src,failFuncStr))

func disableTrigger():
    enable = false

func enableTrigger():
    enable = true
