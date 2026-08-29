extends Node2D

var player_near := false

func _process(_delta):
	if player_near and Input.is_action_just_pressed("interact"):
		sell_bubble()

func sell_bubble():
	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	if player.carried_bubble == null:
		print("No bubble")
		return

	player.carried_bubble.queue_free()
	player.carried_bubble = null

	GameManager.money += 10
	print(GameManager.money)

func _on_interaction_area_body_entered(body):
	if body.name == "Player":
		player_near = true

func _on_interaction_area_body_exited(body):
	if body.name == "Player":
		player_near = false
