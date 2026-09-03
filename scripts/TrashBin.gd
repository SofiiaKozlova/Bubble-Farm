extends Area2D


var player_near := false


func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta):

	if player_near and Input.is_action_just_pressed("interact"):
		throw_bubble_away()


func throw_bubble_away():

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	if player.carried_bubble == null:
		print("У гравця немає бульбашки")
		return

	var bubble = player.carried_bubble

	# Прибираємо бульбашку
	player.carried_bubble = null

	# Видаляємо її зі сцени
	bubble.queue_free()

	print("Бульбашку викинуто")
	print("Руки гравця порожні")


func _on_body_entered(body):

	if body.is_in_group("player"):
		player_near = true
		print("Player near trash bin")


func _on_body_exited(body):

	if body.is_in_group("player"):
		player_near = false
		print("Player left trash bin")
