extends CharacterBody2D

@export var speed := 80.0

var target_position := Vector2.ZERO
var exit_position := Vector2.ZERO

var order_size := "medium"
var order_shape := "circle"
var order_color := "blue"

var last_direction := "down"
var state := "going_to_counter"

var customer_counter = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var order_bubble = $OrderBubble


const SIZES = [
	"small",
	"medium",
	"large"
]

const SHAPES = [
	"circle",
	"heart",
	"star",
	"diamond"
]

const COLORS = [
	"blue",
	"green",
	"yellow",
	"red"
]


func _ready():
	generate_order()


func generate_order():
	order_size = SIZES.pick_random()
	order_shape = SHAPES.pick_random()
	order_color = COLORS.pick_random()

	order_bubble.setup_order(
		order_size,
		order_shape,
		order_color
	)

	order_bubble.visible = true

	print(
		"Customer order: ",
		order_size,
		" / ",
		order_shape,
		" / ",
		order_color
	)


func _physics_process(_delta):

	match state:

		"going_to_counter":
			move_to_counter()

		"waiting":
			velocity = Vector2.ZERO
			play_idle()

		"going_to_exit":
			move_to_exit()


func move_to_counter():

	if global_position.distance_to(target_position) <= 5.0:

		velocity = Vector2.ZERO

		state = "waiting"

		# Знаходимо CustomerCounter
		customer_counter = get_tree().get_first_node_in_group("customer_counter")

		if customer_counter:
			customer_counter.customer_arrived(self)

		print("Customer waiting for order")

		return

	var direction := global_position.direction_to(target_position)

	velocity = direction * speed

	move_and_slide()

	play_walk(direction)


func move_to_exit():

	if global_position.distance_to(exit_position) <= 5.0:

		velocity = Vector2.ZERO

		if customer_counter:
			customer_counter.customer_left(self)

		queue_free()

		return

	var direction := global_position.direction_to(exit_position)

	velocity = direction * speed

	move_and_slide()

	play_walk(direction)


func play_walk(direction: Vector2):

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


func play_idle():
	play_animation("idle_" + last_direction)


func play_animation(animation_name: String):

	if animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)


func receive_bubble(player, bubble) -> bool:

	# Перевіряємо РОЗМІР
	if bubble.get_size_name() != order_size:

		print("Wrong size!")
		print("Needed: ", order_size)
		print("Received: ", bubble.get_size_name())

		return false


	# Перевіряємо ФОРМУ
	if bubble.current_shape != order_shape:

		print("Wrong shape!")
		print("Needed: ", order_shape)
		print("Received: ", bubble.current_shape)

		return false


	# Перевіряємо КОЛІР
	if bubble.current_color != order_color:

		print("Wrong color!")
		print("Needed: ", order_color)
		print("Received: ", bubble.current_color)

		return false


	# Тут замовлення правильне
	print("CORRECT ORDER!")


	# Забираємо bubble у Player
	player.carried_bubble = null

	bubble.carried = false

	# Передаємо bubble клієнту
	bubble.reparent(self)

	if has_node("BubbleHoldPoint"):
		bubble.position = $BubbleHoldPoint.position
	else:
		bubble.position = Vector2(0, -40)


	# Ховаємо замовлення
	order_bubble.visible = false


	# Даємо гроші
	GameManager.money += 10

	print("Money: ", GameManager.money)


	# Клієнт іде до виходу
	state = "going_to_exit"

	return true
