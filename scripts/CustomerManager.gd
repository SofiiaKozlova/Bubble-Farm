extends Node2D

@export var customer_scene: PackedScene

# Точка появи зліва
@export var spawn_position := Vector2(-650, 16)

# На скільки пікселів клієнт проходить вправо
@export var approach_distance := 170.0

# Точка виходу вниз
@export var exit_position := Vector2(-478, 380)

# Час до появи наступного клієнта
@export var min_spawn_time := 3.0
@export var max_spawn_time := 7.0

var spawn_timer: Timer
var current_customer = null


func _ready():

	randomize()

	add_to_group("customer_manager")

	spawn_timer = Timer.new()
	add_child(spawn_timer)

	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	# Перший клієнт одразу
	spawn_customer()


func spawn_customer():

	# Якщо клієнт ще існує — нового не створюємо
	if current_customer != null:
		return

	if customer_scene == null:
		print("ERROR: Customer.tscn is not assigned!")
		return

	# Створюємо клієнта
	var customer = customer_scene.instantiate()

	# ВИПАДКОВО ВИБИРАЄМО ТИП ДО add_child()
	customer.customer_type = randi_range(1, 4)

	print("Selected customer type: ", customer.customer_type)

	# Тільки тепер додаємо в сцену
	add_child(customer)

	current_customer = customer

	# Позиція появи
	customer.global_position = spawn_position

	# Точка зупинки
	customer.target_position = spawn_position + Vector2(approach_distance, 0)

	# Точка виходу
	customer.exit_position = exit_position

	print("NEW CUSTOMER")


func _on_spawn_timer_timeout():

	spawn_timer.stop()

	spawn_customer()


func customer_left(customer):

	if current_customer != customer:
		return

	print("Customer completely left")

	current_customer = null

	# Наступний клієнт через 3–7 секунд
	spawn_timer.wait_time = randf_range(
		min_spawn_time,
		max_spawn_time
	)

	spawn_timer.start()

	print(
		"Next customer in ",
		spawn_timer.wait_time,
		" seconds"
	)
