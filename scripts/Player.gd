extends CharacterBody2D

@export var speed := 200.0

var carried_bubble = null

func _ready():
	add_to_group("player")

func _physics_process(delta):
	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	velocity = direction * speed
	move_and_slide()
