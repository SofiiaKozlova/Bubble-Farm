extends Node2D


@export var price := 10

const PRICE_GAP := 5.0


var player_near_point := false
var player_near_shop := false

var remaining_price := 0


@onready var point: Sprite2D = $Point
@onready var shop: Sprite2D = $Shop
@onready var coin: Sprite2D = $Coin
@onready var price_label: Label = $Label

@onready var point_area: Area2D = $PointArea
@onready var interaction_area: Area2D = $InteractionArea

@onready var station_barrier: StaticBody2D = $StationBarrier

@onready var shape_panel: Sprite2D = $BubbleUI/SizePanel


func _ready():

	# --------------------------------------------------
	# ПОЧАТКОВА ЦІНА
	# --------------------------------------------------

	remaining_price = price


	# --------------------------------------------------
	# МЕНЮ ФОРМ
	# --------------------------------------------------

	shape_panel.visible = false


	# --------------------------------------------------
	# ТЕКСТ ЦІНИ
	# --------------------------------------------------

	price_label.text = str(remaining_price)

	# Текст вирівняний вправо
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	# ВАЖЛИВО:
	# НЕ задаємо position.y,
	# щоб він залишався таким,
	# як ти поставила Label у сцені.

	price_label.size = Vector2(60, 24)

	update_price_position()


	# --------------------------------------------------
	# ВСТАНОВЛЮЄМО ПОЧАТКОВИЙ СТАН
	# --------------------------------------------------

	if GameManager.shape_shop_unlocked:

		# Магазин уже куплений
		remaining_price = 0
		unlock_shop()

	else:

		# Магазин ще не куплений
		lock_shop()


func _process(_delta):

	# Оновлюємо знаходження Player у PointArea
	if not GameManager.shape_shop_unlocked:

		player_near_point = is_player_in_area(point_area)

	else:

		player_near_shop = is_player_in_area(interaction_area)


	# --------------------------------------------------
	# ДО ПОКУПКИ
	# --------------------------------------------------

	if not GameManager.shape_shop_unlocked:

		if player_near_point:

			if Input.is_action_just_pressed("interact"):

				print("E pressed on Shape Shop point")

				buy_shape_shop()

		return


	# --------------------------------------------------
	# ПІСЛЯ ПОКУПКИ
	# --------------------------------------------------

	if player_near_shop:

		if Input.is_action_just_pressed("interact"):

			open_shape_menu()


# ==================================================
# ПЕРЕВІРКА PLAYER В AREA
# ==================================================

func is_player_in_area(area: Area2D) -> bool:

	if area == null:
		return false

	if not area.monitoring:
		return false

	var bodies = area.get_overlapping_bodies()

	for body in bodies:

		if body.is_in_group("player"):
			return true

	return false


# ==================================================
# ПОЗИЦІЯ ЦІНИ ВІДНОСНО МОНЕТКИ
# ==================================================

func update_price_position():

	if coin == null:
		return

	# Coin НЕ РУХАЄМО.
	# Беремо її позицію з редактора.

	# Правий край Label буде на 20 px
	# лівіше за лівий край Coin.

	var coin_left = coin.position.x

	if coin.texture != null:

		coin_left -= (
			coin.texture.get_width()
			* coin.scale.x
			/ 2.0
		)

	var text_right = coin_left - PRICE_GAP

	price_label.position.x = (
		text_right
		- price_label.size.x
	)


# ==================================================
# ДО ПОКУПКИ
# ==================================================

func lock_shop():

	print("Shape Shop: LOCKED")


	# --------------------------------------------------
	# POINT
	# --------------------------------------------------

	point.visible = true


	# --------------------------------------------------
	# SHOP
	# --------------------------------------------------

	shop.visible = false


	# --------------------------------------------------
	# ЦІНА
	# --------------------------------------------------

	coin.visible = true

	price_label.visible = true

	price_label.text = str(remaining_price)

	update_price_position()


	# --------------------------------------------------
	# POINT AREA
	# --------------------------------------------------

	point_area.monitoring = true
	point_area.monitorable = true


	# --------------------------------------------------
	# INTERACTION AREA
	# --------------------------------------------------

	interaction_area.monitoring = false
	interaction_area.monitorable = false


	# --------------------------------------------------
	# BARRIER
	# --------------------------------------------------

	station_barrier.set_collision_layer_value(
		1,
		false
	)

	station_barrier.set_collision_mask_value(
		1,
		false
	)


# ==================================================
# ПОКУПКА МАГАЗИНУ
# ==================================================

func buy_shape_shop():

	print("Trying to buy Shape Shop")


	# Якщо грошей немає
	if GameManager.money <= 0:

		print("No money to pay")

		return


	# Скільки можемо заплатити зараз
	var payment = min(
		GameManager.money,
		remaining_price
	)


	# Віднімаємо гроші
	GameManager.money -= payment


	# Зменшуємо залишок
	remaining_price -= payment


	print("Paid: ", payment)
	print("Money left: ", GameManager.money)
	print("Remaining price: ", remaining_price)


	# Оновлюємо напис
	price_label.text = str(remaining_price)

	update_price_position()


	# --------------------------------------------------
	# ВСЮ СУМУ ОПЛАЧЕНО
	# --------------------------------------------------

	if remaining_price <= 0:

		remaining_price = 0

		GameManager.shape_shop_unlocked = true

		player_near_point = false

		print("Shape Shop fully purchased!")

		unlock_shop()


# ==================================================
# ПІСЛЯ ПОКУПКИ
# ==================================================

func unlock_shop():

	print("Shape Shop: UNLOCKED")


	# --------------------------------------------------
	# POINT ЗНИКАЄ
	# --------------------------------------------------

	point.visible = false

	coin.visible = false

	price_label.visible = false


	# --------------------------------------------------
	# SHOP З'ЯВЛЯЄТЬСЯ
	# --------------------------------------------------

	shop.visible = true


	# --------------------------------------------------
	# POINT AREA ВИМИКАЄМО
	# --------------------------------------------------

	point_area.set_deferred(
		"monitoring",
		false
	)

	point_area.set_deferred(
		"monitorable",
		false
	)


	# --------------------------------------------------
	# INTERACTION AREA ВМИКАЄМО
	# --------------------------------------------------

	interaction_area.set_deferred(
		"monitoring",
		true
	)

	interaction_area.set_deferred(
		"monitorable",
		true
	)


	# --------------------------------------------------
	# BARRIER ВМИКАЄМО
	# --------------------------------------------------

	station_barrier.set_collision_layer_value(
		1,
		true
	)

	station_barrier.set_collision_mask_value(
		1,
		true
	)


# ==================================================
# ВІДКРИТТЯ МЕНЮ ФОРМ
# ==================================================

func open_shape_menu():

	var player = get_tree().get_first_node_in_group(
		"player"
	)

	if player == null:

		print("Player not found!")

		return


	# Без бульбашки меню не відкриваємо
	if player.carried_bubble == null:

		print("Player is not carrying a bubble!")

		return


	var bubble = player.carried_bubble


	print("Opening Shape Station")

	print(
		"Current shape: ",
		bubble.current_shape
	)

	print(
		"Current radius: ",
		bubble.radius
	)


	shape_panel.visible = true


# ==================================================
# ЗМІНА ФОРМИ
# ==================================================

func change_bubble_shape(shape: String):

	var player = get_tree().get_first_node_in_group(
		"player"
	)

	if player == null:
		return


	var bubble = player.carried_bubble

	if bubble == null:

		print("No bubble!")

		return


	bubble.change_shape(shape)


	print(
		"Bubble shape changed to: ",
		shape
	)

	print(
		"Bubble radius: ",
		bubble.radius
	)


	shape_panel.visible = false


# ==================================================
# КНОПКИ
# ==================================================

func _on_star_button_pressed():

	change_bubble_shape("star")


func _on_heart_button_pressed():

	change_bubble_shape("heart")


func _on_diamond_button_pressed():

	change_bubble_shape("diamond")


func _on_close_button_pressed():

	shape_panel.visible = false

	print("Shape menu closed")
