extends Node2D


# =========================================================
# НАЛАШТУВАННЯ
# =========================================================

@export var speed := 120.0

# Звідки приїжджає машина
@export var spawn_position := Vector2(-650, 300)

# Де машина зупиняється
@export var stop_position := Vector2(-300, 300)

# Куди їде після виконання замовлень
@export var exit_position := Vector2(1300, 300)

# Час між приїздами машин
@export var min_wait_time := 8.0
@export var max_wait_time := 15.0


const DRINK_PRICE := 10
const ICE_PRICE := 9


# =========================================================
# ПОСИЛАННЯ НА ВУЗЛИ
# =========================================================

@onready var moving_ahead: AnimatedSprite2D = $Moving_ahead
@onready var moving_back: AnimatedSprite2D = $Moving_back
@onready var stopped_car: AnimatedSprite2D = $Stopped_car

@onready var delivery_area: Area2D = $Area2D

@onready var cloud: Node2D = $Cloud

@onready var drinks: Node2D = $Cloud/Drinks
@onready var drink_icon: AnimatedSprite2D = $Cloud/Drinks/Icon
@onready var drink_count_label: Label = $Cloud/Drinks/CountLabel

@onready var ice: Node2D = $Cloud/Ice
@onready var ice_icon: AnimatedSprite2D = $Cloud/Ice/Icon
@onready var ice_count_label: Label = $Cloud/Ice/CountLabel

@onready var cloud_sprite: Sprite2D = $Cloud/cloud_sprite


# =========================================================
# СТАН МАШИНИ
# =========================================================

enum MachineState {
	WAITING,
	DRIVING_IN,
	STOPPED,
	DRIVING_OUT
}

var state := MachineState.WAITING

var player_near := false

var drink_order_amount := 0
var ice_order_amount := 0

var machine_started := false

var wait_timer: Timer


# =========================================================
# READY
# =========================================================

func _ready():
	randomize()

	# Спочатку машина схована
	visible = false

	# Хмарка схована
	cloud.visible = false

	# Усі три варіанти машини
	moving_ahead.visible = false
	moving_back.visible = false
	stopped_car.visible = false

	# Таймер
	wait_timer = Timer.new()
	wait_timer.one_shot = true
	add_child(wait_timer)

	wait_timer.timeout.connect(_on_wait_timer_timeout)

	# Перевіряємо, чи вже куплений магазин
	if GameManager.drink_shop_unlocked:
		start_machine()
	else:
		state = MachineState.WAITING


# =========================================================
# PROCESS
# =========================================================

func _process(delta):
	# Якщо магазин ще не куплений
	# машина нічого не робить
	if not GameManager.drink_shop_unlocked:
		visible = false
		machine_started = false
		return

	# Якщо магазин щойно купили
	if not machine_started:
		start_machine()
		return

	match state:

		MachineState.DRIVING_IN:
			move_inside(delta)

		MachineState.STOPPED:
			check_delivery()

		MachineState.DRIVING_OUT:
			move_outside(delta)


# =========================================================
# ЗАПУСК МАШИНИ
# =========================================================

func start_machine():
	if machine_started:
		return

	machine_started = true

	visible = true

	global_position = spawn_position

	generate_orders()

	show_driving_ahead()

	state = MachineState.DRIVING_IN


# =========================================================
# СТВОРЕННЯ 2 ЗАМОВЛЕНЬ
# =========================================================

func generate_orders():

	# Одне замовлення Drink
	drink_order_amount = randi_range(1, 3)

	# Одне замовлення Ice
	ice_order_amount = randi_range(1, 3)

	print("--------------------------------")
	print("НОВА МАШИНА")
	print("Drink: ", drink_order_amount)
	print("Ice: ", ice_order_amount)
	print("--------------------------------")

	update_order_cloud()

	cloud.visible = true


# =========================================================
# ОНОВЛЕННЯ ХМАРКИ
# =========================================================

func update_order_cloud():

	# -------------------------
	# DRINK
	# -------------------------

	if drink_order_amount > 0:
		drinks.visible = true
		drink_count_label.visible = true
		drink_count_label.text = str(drink_order_amount)
	else:
		drinks.visible = false


	# -------------------------
	# ICE
	# -------------------------

	if ice_order_amount > 0:
		ice.visible = true
		ice_count_label.visible = true
		ice_count_label.text = str(ice_order_amount)
	else:
		ice.visible = false


	# Якщо все виконано
	if drink_order_amount <= 0 and ice_order_amount <= 0:
		cloud.visible = false


# =========================================================
# РУХ ВПРАВО
# =========================================================

func move_inside(delta):

	global_position.x += speed * delta

	if global_position.x >= stop_position.x:

		global_position.x = stop_position.x

		show_stopped()

		state = MachineState.STOPPED

		print("Машина приїхала")


# =========================================================
# РУХ НАЗАД / ВЛІВО
# =========================================================

func move_outside(delta):

	global_position.x += speed * delta

	# Тут ми використовуємо від'ємний speed,
	# тому машина їде вліво

	global_position.x -= speed * delta

	if global_position.x <= exit_position.x:
		finish_machine()


# =========================================================
# АНІМАЦІЇ
# =========================================================

func show_driving_ahead():

	moving_ahead.visible = true
	moving_back.visible = false
	stopped_car.visible = false

	moving_ahead.play("default")


func show_stopped():

	moving_ahead.visible = false
	moving_back.visible = false
	stopped_car.visible = true

	stopped_car.play("default")


func show_driving_back():

	moving_ahead.visible = false
	moving_back.visible = true
	stopped_car.visible = false

	moving_back.play("default")


# =========================================================
# ПЕРЕВІРКА ПРИНЕСЕНОГО ПРЕДМЕТА
# =========================================================

func check_delivery():

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	# Якщо гравець нічого не тримає
	if player.carried_product == "":
		return

	# Що зараз у руках
	var product: String = player.carried_product


	# =====================================================
	# DRINK
	# =====================================================

	if product == "drink":

		if drink_order_amount > 0:

			# Забираємо напій
			player.clear_carried_product()

			# Зменшуємо замовлення
			drink_order_amount -= 1

			# Гроші
			GameManager.money += DRINK_PRICE

			print("Drink доставлено!")
			print("+", DRINK_PRICE, " грошей")
			print("Залишилось Drink: ", drink_order_amount)

			update_order_cloud()

			check_orders_completed()

			return

		else:
			print("Машина зараз не просить Drink")
			return


	# =====================================================
	# ICE
	# =====================================================

	if product == "ice":

		if ice_order_amount > 0:

			# Забираємо лід
			player.clear_carried_product()

			# Зменшуємо замовлення
			ice_order_amount -= 1

			# Гроші
			GameManager.money += ICE_PRICE

			print("Ice доставлено!")
			print("+", ICE_PRICE, " грошей")
			print("Залишилось Ice: ", ice_order_amount)

			update_order_cloud()

			check_orders_completed()

			return

		else:
			print("Машина зараз не просить Ice")
			return


# =========================================================
# ПЕРЕВІРКА, ЧИ ВСІ ЗАМОВЛЕННЯ ВИКОНАНІ
# =========================================================

func check_orders_completed():

	if drink_order_amount <= 0 and ice_order_amount <= 0:

		print("--------------------------------")
		print("ВСІ ЗАМОВЛЕННЯ ВИКОНАНІ!")
		print("--------------------------------")

		cloud.visible = false

		start_leaving()


# =========================================================
# ПОЧАТОК ВИЇЗДУ
# =========================================================

func start_leaving():

	state = MachineState.DRIVING_OUT

	show_driving_back()

	print("Машина їде назад")


# =========================================================
# ЗАВЕРШЕННЯ
# =========================================================

func finish_machine():

	print("Машина виїхала")

	visible = false

	state = MachineState.WAITING

	machine_started = false

	# Новий приїзд через випадковий час
	var wait_time := randf_range(min_wait_time, max_wait_time)

	wait_timer.start(wait_time)

	print("Наступна машина через ", wait_time, " секунд")


# =========================================================
# ТАЙМЕР
# =========================================================

func _on_wait_timer_timeout():

	if GameManager.drink_shop_unlocked:

		start_machine()
