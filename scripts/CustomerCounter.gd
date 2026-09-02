extends Node2D

var player_near := false
var current_customer = null


func _process(_delta):
	if player_near and Input.is_action_just_pressed("interact"):
		serve_current_customer()


func serve_current_customer():
	if current_customer == null:
		print("No customer at counter")
		return

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("Player not found")
		return

	if player.carried_bubble == null:
		print("Player has no bubble")
		return

	var bubble = player.carried_bubble

	if current_customer.receive_bubble(player, bubble):
		print("Order completed!")
	else:
		print("Wrong bubble! Customer doesn't accept it.")


func customer_arrived(customer):
	current_customer = customer

	print("Customer arrived at counter")
	print(
		"Order: ",
		customer.order_size,
		" / ",
		customer.order_shape,
		" / ",
		customer.order_color
	)


func customer_left(customer):
	if current_customer == customer:
		current_customer = null

		print("Customer left counter")


func _on_interaction_area_body_entered(body):
	if body.is_in_group("player"):
		player_near = true


func _on_interaction_area_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
