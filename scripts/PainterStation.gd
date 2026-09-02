extends Node2D

var player_near := false

@export var interaction_distance := 100.0

@onready var color_panel: Sprite2D = $BubbleUI/SizePanel


func _ready():
	# Ховаємо меню на початку
	color_panel.visible = false


func _process(_delta):
	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	var distance: float = global_position.distance_to(player.global_position)

	player_near = distance <= interaction_distance

	if player_near and Input.is_action_just_pressed("interact"):
		open_color_menu()


func open_color_menu():
	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("Player not found!")
		return

	if player.carried_bubble == null:
		print("Player is not carrying a bubble!")
		return

	var bubble = player.carried_bubble

	print("Bubble radius: ", bubble.radius)
	print("Current shape: ", bubble.current_shape)
	print("Current color: ", bubble.current_color)

	color_panel.visible = true
	print("Color menu opened!")


func change_bubble_color(new_color: String):
	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("Player not found!")
		return

	var bubble = player.carried_bubble

	if bubble == null:
		print("No bubble!")
		return

	# Змінюємо назву кольору в бульбашці
	bubble.change_color(new_color)

	print("Bubble color changed to: ", new_color)
	print("Radius remains: ", bubble.radius)
	print("Shape remains: ", bubble.current_shape)

	# Закриваємо меню
	color_panel.visible = false


func _on_green_button_pressed():
	change_bubble_color("green")


func _on_yellow_button_pressed():
	change_bubble_color("yellow")


func _on_red_button_pressed():
	change_bubble_color("red")


func _on_close_button_pressed():
	color_panel.visible = false
	print("Color menu closed")


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
