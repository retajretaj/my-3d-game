extends Node3D

var toggle = false
var interactable = true
@onready var animation_player = $AnimationPlayer

func interact():
	if interactable == true:
		interactable = false
		toggle = !toggle
		if toggle == false:
			animation_player.play("close")
		if toggle == false:
			animation_player.play("open")
		await get_tree().create_timer(0.2731, false).timeout
		interactable = true
