extends Node2D

@export var bubble_scene: PackedScene

var player_near := false

@onready var size_panel: Sprite2D = $BubbleUI/SizePanel


func _ready():
	size_panel.visible = false
	
	# Центр екрана
	size_panel.position = get_viewport_rect().size / 2


func _process(_delta):
	if player_near and Input.is_action_just_pressed("interact"):
		print("OPEN MENU")
		size_panel.visible = true


func create_bubble(radius: float):
	if bubble_scene == null:
		print("ERROR: Bubble.tscn is not assigned!")
		return

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("Player not found!")
		return

	# Перевіряємо, чи гравець вже щось несе
	if player.carried_bubble != null:
		print("Player already has a bubble!")
		return

	# Створюємо бульбашку
	var bubble = bubble_scene.instantiate()

	# Встановлюємо її розмір
	bubble.radius = radius

	# Додаємо бульбашку до Player
	player.add_child(bubble)

	# Ставимо її в точку, де персонаж тримає бульбашку
	bubble.position = player.get_node("BubbleHoldPoint").position

	# Позначаємо, що гравець її несе
	player.carried_bubble = bubble
	bubble.carried = true

	# Закриваємо меню
	size_panel.visible = false

	print("Bubble created and picked up. Radius: ", radius)


func _on_small_button_pressed():
	create_bubble(8.0)


func _on_medium_button_pressed():
	create_bubble(14.0)


func _on_large_button_pressed():
	create_bubble(20.0)


func _on_close_button_pressed():
	print("CLOSE BUTTON PRESSED")
	size_panel.visible = false


func _on_interaction_area_body_entered(body):
	print("ENTERED: ", body.name)

	if body.name == "Player":
		player_near = true
		print("PLAYER NEAR = TRUE")


func _on_interaction_area_body_exited(body):
	print("EXITED: ", body.name)

	if body.name == "Player":
		player_near = false
		print("PLAYER NEAR = FALSE")
