extends Node2D

var player_near := false

@export var interaction_distance := 100.0

@onready var shape_panel: Panel = $ShapeUI/ShapePanel


func _ready():
	shape_panel.visible = false


func _process(_delta):
	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	# Перевіряємо відстань до гравця
	var distance = global_position.distance_to(player.global_position)

	player_near = distance <= interaction_distance

	if Input.is_action_just_pressed("interact"):
		print("E PRESSED")
		print("Distance: ", distance)
		print("Player near: ", player_near)
		print("Carried bubble: ", player.carried_bubble)

		if player_near:
			open_shape_menu()


func open_shape_menu():
	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("Player not found!")
		return

	if player.carried_bubble == null:
		print("Player is not carrying a bubble!")
		return

	shape_panel.visible = true
	print("Shape menu opened!")


func _on_star_button_pressed():
	change_bubble_shape("star")


func _on_heart_button_pressed():
	change_bubble_shape("heart")


func _on_diamond_button_pressed():
	change_bubble_shape("diamond")


func change_bubble_shape(shape: String):
	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	var bubble = player.carried_bubble

	if bubble == null:
		print("No bubble!")
		return

	bubble.change_shape(shape)

	shape_panel.visible = false

	print("Bubble shape changed to: ", shape)
	print("Bubble radius: ", bubble.radius)


func _on_close_button_pressed():
	shape_panel.visible = false
