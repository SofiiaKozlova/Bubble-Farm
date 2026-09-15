extends Node2D


# =========================================================
# НАЛАШТУВАННЯ
# =========================================================

@export var speed: float = 120.0

# На скільки пікселів машина приїжджає вправо
@export var travel_distance: float = 150.0

# Час очікування ДО НАСТУПНОЇ МАШИНИ
@export var min_wait_time: float = 10.0
@export var max_wait_time: float = 15.0


# =========================================================
# ЦІНИ
# =========================================================

const DRINK_PRICE: int = 10
const ICE_PRICE: int = 9


# =========================================================
# ВУЗЛИ
# =========================================================

@onready var moving_back: AnimatedSprite2D = $Moving_back
@onready var stopped_car: AnimatedSprite2D = $Stopped_car
@onready var moving_ahead: AnimatedSprite2D = $Moving_ahead

@onready var delivery_area: Area2D = $Area2D

@onready var cloud: Node2D = $Cloud

@onready var drinks: Node2D = $Cloud/Drinks
@onready var drink_count_label: Label = $Cloud/Drinks/CountLabel

@onready var ice: Node2D = $Cloud/Ice
@onready var ice_count_label: Label = $Cloud/Ice/CountLabel

@onready var cloud_sprite: Sprite2D = $Cloud/cloud_sprite


# =========================================================
# СТАНИ
# =========================================================

enum MachineState
{
	WAITING,
	DRIVING_IN,
	STOPPED,
	DRIVING_OUT
}

var state: MachineState = MachineState.WAITING


# =========================================================
# ПОЗИЦІЇ
# =========================================================

# Місце, де машина стоїть у редакторі
var start_position: Vector2

# Місце, куди вона приїжджає
var stop_position: Vector2


# =========================================================
# ЗАМОВЛЕННЯ
# =========================================================

var drink_order_amount: int = 0
var ice_order_amount: int = 0

# Загальна виплата за все замовлення
var total_payment: int = 0


# =========================================================
# ІНШІ ЗМІННІ
# =========================================================

# Чи зараз машина активна
var machine_started: bool = false

# Чи знаходиться гравець біля машини
var player_near: bool = false

# Чи очікуємо наступну машину
var waiting_for_next_machine: bool = false

# Таймер
var wait_timer: Timer


# =========================================================
# READY
# =========================================================

func _ready():

	randomize()

	# -----------------------------------------------------
	# ЧОРНИЙ ТЕКСТ
	# -----------------------------------------------------

	drink_count_label.add_theme_color_override(
		"font_color",
		Color.BLACK
	)

	ice_count_label.add_theme_color_override(
		"font_color",
		Color.BLACK
	)


	# -----------------------------------------------------
	# ЗАПАМ'ЯТОВУЄМО ПОЗИЦІЮ З РЕДАКТОРА
	# -----------------------------------------------------

	start_position = global_position

	stop_position = start_position + Vector2(
		travel_distance,
		0.0
	)


	# -----------------------------------------------------
	# ПОЧАТКОВИЙ СТАН
	# -----------------------------------------------------

	visible = false

	cloud.visible = false

	moving_ahead.visible = false
	stopped_car.visible = false
	moving_back.visible = false


	# -----------------------------------------------------
	# ТАЙМЕР
	# -----------------------------------------------------

	wait_timer = Timer.new()

	wait_timer.one_shot = true

	add_child(wait_timer)

	wait_timer.timeout.connect(
		_on_wait_timer_timeout
	)


	# -----------------------------------------------------
	# ЯКЩО МАГАЗИН ВЖЕ КУПЛЕНИЙ
	# -----------------------------------------------------

	if GameManager.drink_shop_unlocked:

		start_machine()


# =========================================================
# PROCESS
# =========================================================

func _process(delta):


	# =====================================================
	# DRINK STATION ЩЕ НЕ КУПЛЕНИЙ
	# =====================================================

	if not GameManager.drink_shop_unlocked:

		visible = false

		machine_started = false

		waiting_for_next_machine = false

		state = MachineState.WAITING

		global_position = start_position

		return


	# =====================================================
	# МАШИНА НЕ АКТИВНА
	# =====================================================

	if not machine_started:

		# Якщо ми просто чекаємо наступну машину,
		# НЕ запускаємо її раніше таймера
		if waiting_for_next_machine:

			return

		# Якщо таймер не працює і треба почати нову машину
		start_machine()

		return


	# =====================================================
	# СТАН МАШИНИ
	# =====================================================

	match state:


		# -------------------------------------------------
		# ЇДЕ ВПРАВО
		# -------------------------------------------------

		MachineState.DRIVING_IN:

			move_inside(delta)


		# -------------------------------------------------
		# СТОЇТЬ
		# -------------------------------------------------

		MachineState.STOPPED:

			update_player_near()

			# Передача ТІЛЬКИ після E
			if player_near:

				if Input.is_action_just_pressed("interact"):

					check_delivery()


		# -------------------------------------------------
		# ЇДЕ НАЗАД
		# -------------------------------------------------

		MachineState.DRIVING_OUT:

			move_outside(delta)


# =========================================================
# ПОЧАТОК ПРИЇЗДУ
# =========================================================

func start_machine():

	if machine_started:

		return

	if waiting_for_next_machine:

		return


	# Машина тепер активна
	machine_started = true

	# Вона починає з початкової точки
	global_position = start_position

	# Показуємо машину
	visible = true

	# Створюємо замовлення
	generate_orders()

	# Запускаємо рух вперед
	show_moving_ahead()

	# Змінюємо стан
	state = MachineState.DRIVING_IN

	print("Машина почала їхати вперед")


# =========================================================
# СТВОРЕННЯ ЗАМОВЛЕННЯ
# =========================================================

func generate_orders():

	# Drink від 1 до 3
	drink_order_amount = randi_range(1, 3)

	# Ice від 1 до 3
	ice_order_amount = randi_range(1, 3)


	# -----------------------------------------------------
	# РАХУЄМО ЗАГАЛЬНУ ВИПЛАТУ
	# -----------------------------------------------------

	total_payment = (
		drink_order_amount * DRINK_PRICE
		+ ice_order_amount * ICE_PRICE
	)


	# Оновлюємо вміст хмарки
	# але сама хмарка поки прихована
	update_order_cloud()


	print("--------------------------------")
	print("НОВЕ ЗАМОВЛЕННЯ МАШИНИ")
	print("Drink: ", drink_order_amount)
	print("Ice: ", ice_order_amount)
	print("Загальна виплата: ", total_payment)
	print("--------------------------------")


# =========================================================
# ОНОВЛЕННЯ ХМАРКИ
# =========================================================

func update_order_cloud():

	# =====================================================
	# DRINK
	# =====================================================

	if drink_order_amount > 0:

		drinks.visible = true

		drink_count_label.visible = true

		drink_count_label.text = str(
			drink_order_amount
		)

	else:

		drinks.visible = false

		drink_count_label.visible = false


	# =====================================================
	# ICE
	# =====================================================

	if ice_order_amount > 0:

		ice.visible = true

		ice_count_label.visible = true

		ice_count_label.text = str(
			ice_order_amount
		)

	else:

		ice.visible = false

		ice_count_label.visible = false


	# =====================================================
	# ЯКЩО ВСЕ ВИКОНАНО
	# =====================================================

	if drink_order_amount <= 0:

		if ice_order_amount <= 0:

			cloud.visible = false


# =========================================================
# МАШИНА ЇДЕ ВПРАВО
# =========================================================

func move_inside(delta):

	global_position.x += speed * delta


	if global_position.x >= stop_position.x:

		# Точно ставимо машину на потрібну позицію
		global_position = stop_position

		# Перемикаємо на стоячу машину
		show_stopped()

		# Тепер хмарка з'являється
		cloud.visible = true

		# Машина тепер стоїть
		state = MachineState.STOPPED

		print("Машина зупинилась")


# =========================================================
# МАШИНА ЇДЕ НАЗАД
# =========================================================

func move_outside(delta):

	global_position.x -= speed * delta


	# Повернулася у вихідну точку
	if global_position.x <= start_position.x:

		global_position = start_position

		finish_machine()


# =========================================================
# АНІМАЦІЯ РУХУ ВПЕРЕД
# =========================================================

func show_moving_ahead():

	moving_ahead.visible = true
	stopped_car.visible = false
	moving_back.visible = false

	# Запускаємо анімацію
	moving_ahead.play()


# =========================================================
# АНІМАЦІЯ СТОЯННЯ
# =========================================================

func show_stopped():

	moving_ahead.visible = false
	stopped_car.visible = true
	moving_back.visible = false

	# Запускаємо анімацію
	stopped_car.play()


# =========================================================
# АНІМАЦІЯ РУХУ НАЗАД
# =========================================================

func show_moving_back():

	moving_ahead.visible = false
	stopped_car.visible = false
	moving_back.visible = true

	# Запускаємо анімацію
	moving_back.play()


# =========================================================
# ПЕРЕВІРКА ГРАВЦЯ
# =========================================================

func update_player_near():

	player_near = false

	var bodies = delivery_area.get_overlapping_bodies()


	for body in bodies:

		if body.is_in_group("player"):

			player_near = true

			return


# =========================================================
# ПЕРЕДАЧА ПРЕДМЕТА
# =========================================================

func check_delivery():

	var player = get_tree().get_first_node_in_group("player")


	if player == null:

		return


	# -----------------------------------------------------
	# ГРАВЕЦЬ НІЧОГО НЕ ТРИМАЄ
	# -----------------------------------------------------

	if player.carried_product == "":

		print("Гравець нічого не тримає")

		return


	var product: String = player.carried_product


	# =====================================================
	# DRINK
	# =====================================================

	if product == "drink":

		if drink_order_amount <= 0:

			print("Машина більше не просить Drink")

			return


		# Прибираємо напій з рук
		player.clear_carried_product()

		# Зменшуємо кількість
		drink_order_amount -= 1


		print("Drink доставлено!")

		print(
			"Drink залишилось: ",
			drink_order_amount
		)


		# Оновлюємо хмарку
		update_order_cloud()


		# Перевіряємо, чи все виконано
		check_orders_completed()


		return


	# =====================================================
	# ICE
	# =====================================================

	if product == "ice":

		if ice_order_amount <= 0:

			print("Машина більше не просить Ice")

			return


		# Прибираємо лід з рук
		player.clear_carried_product()

		# Зменшуємо кількість
		ice_order_amount -= 1


		print("Ice доставлено!")

		print(
			"Ice залишилось: ",
			ice_order_amount
		)


		# Оновлюємо хмарку
		update_order_cloud()


		# Перевіряємо, чи все виконано
		check_orders_completed()


		return


	# =====================================================
	# ІНШИЙ ПРЕДМЕТ
	# =====================================================

	print("Цей предмет машина не замовляла")


# =========================================================
# ПЕРЕВІРКА ВИКОНАННЯ
# =========================================================

func check_orders_completed():

	if drink_order_amount <= 0:

		if ice_order_amount <= 0:

			print("--------------------------------")
			print("ВСІ ЗАМОВЛЕННЯ ВИКОНАНІ!")
			print(
				"Виплата: ",
				total_payment
			)
			print("--------------------------------")


			# -------------------------------------------------
			# ГРОШІ ВИДАЮТЬСЯ ТІЛЬКИ ЗАРАЗ
			# -------------------------------------------------

			GameManager.money += total_payment


			print(
				"Отримано грошей: ",
				total_payment
			)


			# Ховаємо хмарку
			cloud.visible = false


			# Машина починає їхати назад
			start_leaving()


# =========================================================
# ПОЧАТОК ВИЇЗДУ
# =========================================================

func start_leaving():

	state = MachineState.DRIVING_OUT

	show_moving_back()

	print("Машина їде назад")


# =========================================================
# МАШИНА ПОВЕРНУЛАСЯ У СТАРТОВУ ТОЧКУ
# =========================================================

func finish_machine():

	print("Машина повністю виїхала")


	# -----------------------------------------------------
	# ХОВАЄМО МАШИНУ
	# -----------------------------------------------------

	visible = false


	# -----------------------------------------------------
	# СКИДАЄМО СТАН
	# -----------------------------------------------------

	machine_started = false

	state = MachineState.WAITING

	player_near = false


	# -----------------------------------------------------
	# ПОВЕРТАЄМО В ПОЧАТКОВУ ПОЗИЦІЮ
	# -----------------------------------------------------

	global_position = start_position


	# -----------------------------------------------------
	# ТЕПЕР ПОЧИНАЄМО ОЧІКУВАННЯ
	# -----------------------------------------------------

	waiting_for_next_machine = true


	# Випадково від 10 до 15 секунд
	var wait_time: float = randf_range(
		min_wait_time,
		max_wait_time
	)


	wait_timer.start(wait_time)


	print("--------------------------------")
	print(
		"Машина виїхала.",
		" Наступна приїде через ",
		wait_time,
		" секунд."
	)
	print("--------------------------------")


# =========================================================
# ТАЙМЕР
# =========================================================

func _on_wait_timer_timeout():

	# Тепер очікування закінчилося
	waiting_for_next_machine = false


	# Якщо Drink Station все ще куплений
	if GameManager.drink_shop_unlocked:

		start_machine()
