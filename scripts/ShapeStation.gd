extends Node2D

var player_near := false

@export var interaction_distance := 100.0

@onready var shape_panel: Sprite2D = $BubbleUI/SizePanel


func _ready():
	# Ховаємо меню на початку
	shape_panel.visible = false


func _process(_delta):
	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	# Перевіряємо відстань до станції
	var distance := global_position.distance_to(player.global_position)
	player_near = distance <= interaction_distance

	# Натиснуто E
	if player_near and Input.is_action_just_pressed("interact"):
		open_shape_menu()


func open_shape_menu():
	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("Player not found!")
		return

	# Гравець повинен тримати бульбашку
	if player.carried_bubble == null:
		print("Player is not carrying a bubble!")
		return

	var bubble = player.carried_bubble

	print("Opening Shape Station")
	print("Current shape: ", bubble.current_shape)
	print("Current radius: ", bubble.radius)

	# Показуємо меню
	shape_panel.visible = true


func change_bubble_shape(shape: String):
	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("Player not found!")
		return

	var bubble = player.carried_bubble

	if bubble == null:
		print("No bubble!")
		return

	# Змінюємо форму вже існуючої бульбашки
	bubble.change_shape(shape)

	# Розмір бульбашки залишається без змін
	print("Bubble shape changed to: ", shape)
	print("Bubble radius: ", bubble.radius)

	# Закриваємо меню
	shape_panel.visible = false


func _on_star_button_pressed():
	change_bubble_shape("star")


func _on_heart_button_pressed():
	change_bubble_shape("heart")


func _on_diamond_button_pressed():
	change_bubble_shape("diamond")


func _on_close_button_pressed():
	shape_panel.visible = false
	print("Shape menu closed")


func _on_interaction_area_body_entered(body):
	print("ENTERED: ", body.name)

	if body.is_in_group("player"):
		player_near = true
		print("PLAYER NEAR = TRUE")


func _on_interaction_area_body_exited(body):
	print("EXITED: ", body.name)

	if body.is_in_group("player"):
		player_near = false
		print("PLAYER NEAR = FALSE")
