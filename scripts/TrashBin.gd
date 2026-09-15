extends Area2D


var player_near := false


func _ready():

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta):

	if player_near and Input.is_action_just_pressed("interact"):

		throw_item_away()


func throw_item_away():

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return


	# ==================================================
	# БУЛЬБАШКА
	# ==================================================

	if player.carried_bubble != null:

		var bubble = player.carried_bubble

		player.carried_bubble = null

		bubble.queue_free()

		print("Бульбашку викинуто")
		print("Руки гравця порожні")

		return


	# ==================================================
	# ГОТОВИЙ ПРОДУКТ
	# ==================================================

	if player.carried_product != "":

		print(
			"Викинуто: ",
			player.carried_product
		)

		player.clear_carried_product()

		print("Руки гравця порожні")

		return


	# ==================================================
	# НІЧОГО НЕМАЄ
	# ==================================================

	print("Гравець нічого не тримає")


func _on_body_entered(body):

	if body.is_in_group("player"):

		player_near = true

		print("Player near trash bin")


func _on_body_exited(body):

	if body.is_in_group("player"):

		player_near = false

		print("Player left trash bin")
