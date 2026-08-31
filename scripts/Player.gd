extends CharacterBody2D

@export var speed := 200.0

var carried_bubble = null
var last_direction := "down"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	add_to_group("player")
	play_animation("idle_down")


func _physics_process(_delta):
	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	velocity = direction * speed
	move_and_slide()

	# Визначаємо напрямок руху
	if direction != Vector2.ZERO:

		if abs(direction.x) > abs(direction.y):
			if direction.x < 0:
				last_direction = "left"
				play_animation("walk_left")
			else:
				last_direction = "right"
				play_animation("walk_right")
		else:
			if direction.y < 0:
				last_direction = "up"
				play_animation("walk_up")
			else:
				last_direction = "down"
				play_animation("walk_down")

	# Нічого не натиснуто
	else:
		play_animation("idle_" + last_direction)


func play_animation(animation_name: String):
	# Не перезапускаємо ту саму анімацію кожен кадр
	if animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)
