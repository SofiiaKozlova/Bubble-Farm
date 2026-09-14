extends Node2D


@export var price := 10

const PRICE_GAP := 20.0


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

@onready var color_panel: Sprite2D = $BubbleUI/SizePanel


func _ready():

	# Початкова ціна
	remaining_price = price

	# Меню кольорів приховане
	color_panel.visible = false

	# Позиція ціни
	price_label.text = str(remaining_price)

	price_label.size = Vector2(60, 24)
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	update_price_position()


	# Встановлюємо початковий стан
	if GameManager.color_shop_unlocked:

		remaining_price = 0

		unlock_shop()

	else:

		lock_shop()


func _process(_delta):

	# Оновлюємо зони
	player_near_point = is_player_in_area(point_area)
	player_near_shop = is_player_in_area(interaction_area)


	# ==================================================
	# ДО ПОКУПКИ
	# ==================================================

	if not GameManager.color_shop_unlocked:

		if player_near_point:

			if Input.is_action_just_pressed("interact"):

				print("E pressed on Painter Shop point")

				buy_painter_shop()

		return


	# ==================================================
	# ПІСЛЯ ПОКУПКИ
	# ==================================================

	if player_near_shop:

		if Input.is_action_just_pressed("interact"):

			open_color_menu()


# ==================================================
# ПЕРЕВІРКА PLAYER В AREA
# ==================================================

func is_player_in_area(area: Area2D) -> bool:

	if area == null:
		return false

	if not area.monitoring:
		return false

	for body in area.get_overlapping_bodies():

		if body.is_in_group("player"):
			return true

	return false


# ==================================================
# ПОЗИЦІЯ ЦІНИ
# ==================================================

func update_price_position():

	if coin == null:
		return

	if price_label == null:
		return

	# Монетку не рухаємо.
	# Беремо її позицію зі сцени.

	var coin_left = coin.position.x

	if coin.texture != null:

		coin_left -= (
			coin.texture.get_width()
			* coin.scale.x
			/ 2.0
		)


	# Правий край напису
	# на 20 px лівіше монетки

	var text_right = coin_left - PRICE_GAP

	price_label.position.x = (
		text_right
		- price_label.size.x
	)


# ==================================================
# СТАН ДО ПОКУПКИ
# ==================================================

func lock_shop():

	print("Painter Shop: LOCKED")


	# Point видно
	point.visible = true


	# Shop прихований
	shop.visible = false


	# Ціна видно
	coin.visible = true

	price_label.visible = true

	price_label.text = str(remaining_price)

	update_price_position()


	# PointArea працює
	point_area.monitoring = true
	point_area.monitorable = true


	# InteractionArea не працює
	interaction_area.monitoring = false
	interaction_area.monitorable = false


	# Barrier вимкнений
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

func buy_painter_shop():

	print("Trying to buy Painter Shop")


	# Немає грошей
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


	# ==================================================
	# ВСЯ СУМА ОПЛАЧЕНА
	# ==================================================

	if remaining_price <= 0:

		remaining_price = 0

		GameManager.color_shop_unlocked = true

		player_near_point = false

		print("Painter Shop fully purchased!")

		unlock_shop()


# ==================================================
# ПІСЛЯ ПОКУПКИ
# ==================================================

func unlock_shop():

	print("Painter Shop: UNLOCKED")


	# Point зникає
	point.visible = false

	# Coin зникає
	coin.visible = false

	# Label зникає
	price_label.visible = false


	# Shop з'являється
	shop.visible = true


	# PointArea вимикається
	point_area.set_deferred(
		"monitoring",
		false
	)

	point_area.set_deferred(
		"monitorable",
		false
	)


	# InteractionArea вмикається
	interaction_area.set_deferred(
		"monitoring",
		true
	)

	interaction_area.set_deferred(
		"monitorable",
		true
	)


	# Barrier вмикається
	station_barrier.set_collision_layer_value(
		1,
		true
	)

	station_barrier.set_collision_mask_value(
		1,
		true
	)


# ==================================================
# ВІДКРИТТЯ МЕНЮ КОЛЬОРІВ
# ==================================================

func open_color_menu():

	var player = get_tree().get_first_node_in_group("player")

	if player == null:

		print("Player not found!")

		return


	# Гравець має тримати бульбашку
	if player.carried_bubble == null:

		print("Player is not carrying a bubble!")

		return


	var bubble = player.carried_bubble


	print("Opening Color Station")

	print(
		"Bubble radius: ",
		bubble.radius
	)

	print(
		"Current shape: ",
		bubble.current_shape
	)

	print(
		"Current color: ",
		bubble.current_color
	)


	color_panel.visible = true


# ==================================================
# ЗМІНА КОЛЬОРУ
# ==================================================

func change_bubble_color(new_color: String):

	var player = get_tree().get_first_node_in_group("player")

	if player == null:

		print("Player not found!")

		return


	var bubble = player.carried_bubble

	if bubble == null:

		print("No bubble!")

		return


	bubble.change_color(new_color)


	print(
		"Bubble color changed to: ",
		new_color
	)

	print(
		"Radius remains: ",
		bubble.radius
	)

	print(
		"Shape remains: ",
		bubble.current_shape
	)


	# Закриваємо меню
	color_panel.visible = false


func _on_green_button_pressed():

	change_bubble_color("green")


func _on_yellow_button_pressed():

	change_bubble_color("yellow")


func _on_red_button_pressed():

	change_bubble_color("red")


func _on_close_button_pressed():

	color_panel.visible = false

	print("Color menu closed")
