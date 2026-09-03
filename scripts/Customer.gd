extends CharacterBody2D

@export var speed := 80.0

# Точка, де клієнт зупиняється
var target_position := Vector2.ZERO

# Точка виходу вниз
var exit_position := Vector2.ZERO

# Стани клієнта
var state := "walking_to_counter"

# Тип клієнта: 1, 2, 3 або 4
var customer_type := 1

# Замовлення
var order_size := ""
var order_shape := ""
var order_color := ""

# CustomerCounter
var customer_counter = null

# Анімації клієнтів
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

	# Визначаємо потрібну модель
	setup_customer_type()

	# Генеруємо замовлення
	generate_order()

	# Знаходимо стійку
	customer_counter = get_tree().get_first_node_in_group("customer_counter")

	# Замовлення спочатку приховане
	order_label.visible = false


# --------------------------------------------------
# ВИБІР МОДЕЛІ КЛІЄНТА
# --------------------------------------------------

func setup_customer_type():

	var sprites = [
		sprite1,
		sprite2,
		sprite3,
		sprite4
	]

	# Вимикаємо всі спрайти
	for sprite in sprites:
		sprite.visible = false
		sprite.stop()

	# Перевірка типу
	if customer_type < 1 or customer_type > 4:
		customer_type = 1

	# Вибираємо потрібного клієнта
	var selected_sprite = sprites[customer_type - 1]

	selected_sprite.visible = true

	# Починаємо з walk_right
	selected_sprite.play("walk_right")


# --------------------------------------------------
# АКТИВНИЙ СПРАЙТ
# --------------------------------------------------

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


# --------------------------------------------------
# ЗАМОВЛЕННЯ
# --------------------------------------------------

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


# --------------------------------------------------
# ОСНОВНИЙ ЦИКЛ
# --------------------------------------------------

func _physics_process(_delta):

	match state:

		"walking_to_counter":
			move_to_counter()

		"waiting":
			wait_at_counter()

		"walking_to_exit":
			move_to_exit()


# --------------------------------------------------
# ЙДЕ ДО СТІЙКИ
# --------------------------------------------------

func move_to_counter():

	# Відстань до точки зупинки
	var distance = global_position.distance_to(target_position)

	# Якщо дійшов
	if distance <= 3.0:

		# Точна позиція
		global_position = target_position

		# Повністю зупиняємо CharacterBody2D
		velocity = Vector2.ZERO

		# Змінюємо стан
		state = "waiting"

		# Вмикаємо idle_right
		play_idle_right()

		# Показуємо замовлення
		order_label.visible = true

		# Повідомляємо стійку
		if customer_counter != null:
			customer_counter.customer_arrived(self)

		print("Customer STOPPED at: ", global_position)

		return

	# Рухається вправо
	velocity = Vector2.RIGHT * speed

	move_and_slide()

	# Поки рухається — walk_right
	var sprite = get_active_sprite()

	if sprite.animation != "walk_right":
		sprite.play("walk_right")


# --------------------------------------------------
# КЛІЄНТ ЧЕКАЄ
# --------------------------------------------------

func wait_at_counter():

	# Ніякого руху
	velocity = Vector2.ZERO

	# Ніякого ковзання
	move_and_slide()

	# Постійно тримаємо idle_right
	play_idle_right()


# --------------------------------------------------
# IDLE RIGHT
# --------------------------------------------------

func play_idle_right():

	var sprite = get_active_sprite()

	if not sprite.sprite_frames.has_animation("idle_down"):
		print("ERROR: idle_down not found for ", sprite.name)
		return

	# Перемикаємо на idle_down
	sprite.animation = "idle_right"

	# Перший кадр
	sprite.frame = 0

	# Повністю зупиняємо
	sprite.stop()

func move_to_exit():

	# Вийшов за нижню межу
	if global_position.y > exit_position.y:

		velocity = Vector2.ZERO

		# Повідомляємо CustomerCounter
		if customer_counter != null:
			customer_counter.customer_left(self)

		# Повідомляємо CustomerManager
		var customer_manager = get_tree().get_first_node_in_group("customer_manager")

		if customer_manager != null:
			customer_manager.customer_left(self)

		# Видаляємо клієнта
		queue_free()

		return

	# Йде вниз
	velocity = Vector2.DOWN * speed

	move_and_slide()

	# Анімація walk_down
	var sprite = get_active_sprite()

	if sprite.animation != "walk_down":
		sprite.play("walk_down")


# --------------------------------------------------
# ПЕРЕВІРКА БУЛЬБАШКИ
# --------------------------------------------------

func receive_bubble(player, bubble) -> bool:

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

	# Все правильно
	print("CORRECT ORDER!")

	# Прибираємо бульбашку з рук
	player.carried_bubble = null
	bubble.carried = false

	# Передаємо бульбашку клієнту
	bubble.reparent(self)

	if has_node("BubbleHoldPoint"):
		bubble.position = $BubbleHoldPoint.position
	else:
		bubble.position = Vector2(0, -40)

	# Прибираємо текст замовлення
	order_label.visible = false

	# Даємо гроші
	GameManager.money += 10

	print("Money: ", GameManager.money)

	# Клієнт іде вниз
	state = "walking_to_exit"

	return true
