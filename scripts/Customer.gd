extends CharacterBody2D

@export var speed := 80.0

# Точка, де клієнт зупиняється біля стійки
var target_position := Vector2.ZERO

# Точка виходу
var exit_position := Vector2.ZERO

# Поточний стан клієнта
var state := "walking_to_counter"

# Номер типу клієнта: 1, 2, 3 або 4
var customer_type := 0

# Останній напрямок
var last_direction := "right"

# Замовлення
var order_size := ""
var order_shape := ""
var order_color := ""

# Посилання на CustomerCounter
var customer_counter = null

# 4 картинки клієнтів
@onready var sprite1: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite2: AnimatedSprite2D = $AnimatedSprite2D2
@onready var sprite3: AnimatedSprite2D = $AnimatedSprite2D3
@onready var sprite4: AnimatedSprite2D = $AnimatedSprite2D4

# Текст замовлення
@onready var order_label: Label = $Label


const SIZES = [
	"small",
	"middle",
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
	"yellow",
	"green",
	"red"
]


func _ready():

	# Випадковий тип клієнта
	customer_type = randi_range(1, 4)

	setup_customer_type()

	# Випадкове замовлення
	generate_order()

	# Знаходимо CustomerCounter
	customer_counter = get_tree().get_first_node_in_group("customer_counter")

	if customer_counter != null:

		# Клієнт зупиняється зліва від столика
		target_position = customer_counter.global_position + Vector2(-110, 0)

	# Замовлення спочатку приховане
	order_label.visible = false


func setup_customer_type():

	var sprites = [
		sprite1,
		sprite2,
		sprite3,
		sprite4
	]

	# Вимикаємо всіх клієнтів
	for sprite in sprites:
		sprite.visible = false
		sprite.stop()

	# Вмикаємо випадкового
	var selected_sprite = sprites[customer_type - 1]

	selected_sprite.visible = true

	# Починаємо з ходьби вправо
	selected_sprite.play("walk_right")


func get_active_sprite() -> AnimatedSprite2D:

	match customer_type:

		1:
			return sprite1

		2:
			return sprite2

		3:
			return sprite3

		4:
			return sprite4

	return sprite1


func generate_order():

	order_size = SIZES.pick_random()
	order_shape = SHAPES.pick_random()
	order_color = COLORS.pick_random()

	order_label.text = (
		order_size
		+ ", "
		+ order_shape
		+ ", "
		+ order_color
	)

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

		"walking_to_counter":
			move_to_counter()

		"waiting":
			velocity = Vector2.ZERO

			play_idle_right()

		"walking_to_exit":
			move_to_exit()


func move_to_counter():

	# Дійшов до стійки
	if global_position.distance_to(target_position) <= 5.0:

		global_position = target_position

		velocity = Vector2.ZERO

		state = "waiting"

		play_idle_right()

		# Показуємо замовлення
		order_label.visible = true

		# Повідомляємо CustomerCounter
		if customer_counter != null:
			customer_counter.customer_arrived(self)

		print("Customer arrived at counter")

		return

	# Рухаємося тільки вправо
	velocity = Vector2.RIGHT * speed

	move_and_slide()

	get_active_sprite().play("walk_right")


func play_idle_right():

	var sprite = get_active_sprite()

	if sprite.animation != "idle_right":
		sprite.play("idle_right")


func move_to_exit():

	# Клієнт вийшов за нижню частину екрану
	if global_position.y > exit_position.y:

		velocity = Vector2.ZERO

		# Повідомляємо Counter
		if customer_counter != null:
			customer_counter.customer_left(self)

		# Повідомляємо Manager
		var customer_manager = get_tree().get_first_node_in_group("customer_manager")

		if customer_manager != null:
			customer_manager.customer_left(self)

		queue_free()

		return

	# Рух вниз
	velocity = Vector2.DOWN * speed

	move_and_slide()

	get_active_sprite().play("walk_down")


func receive_bubble(player, bubble) -> bool:

	# Отримуємо характеристики бульбашки
	var bubble_size = bubble.get_size_name()
	var bubble_shape = bubble.current_shape
	var bubble_color = bubble.current_color

	print("========== CHECK ORDER ==========")
	print("Customer wants:")
	print("Size: ", order_size)
	print("Shape: ", order_shape)
	print("Color: ", order_color)

	print("Bubble has:")
	print("Size: ", bubble_size)
	print("Shape: ", bubble_shape)
	print("Color: ", bubble_color)

	# Перевірка розміру
	if bubble_size != order_size:
		print("WRONG SIZE")
		return false

	# Перевірка форми
	if bubble_shape != order_shape:
		print("WRONG SHAPE")
		return false

	# Перевірка кольору
	if bubble_color != order_color:
		print("WRONG COLOR")
		return false

	# Якщо всі три параметри правильні
	print("CORRECT ORDER!")

	# Забираємо бульбашку у гравця
	player.carried_bubble = null
	bubble.carried = false

	# Бульбашка переходить до клієнта
	bubble.reparent(self)

	if has_node("BubbleHoldPoint"):
		bubble.position = $BubbleHoldPoint.position
	else:
		bubble.position = Vector2(0, -40)

	# Ховаємо замовлення
	order_label.visible = false

	# Даємо гроші
	GameManager.money += 10

	print("Money: ", GameManager.money)

	# Клієнт виходить
	state = "walking_to_exit"

	return true
