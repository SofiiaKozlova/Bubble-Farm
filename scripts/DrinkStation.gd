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
@onready var menu_panel: Sprite2D = $BubbleUI/SizePanel


func _ready():

	remaining_price = price

	menu_panel.visible = false

	price_label.text = str(remaining_price)
	price_label.size = Vector2(60, 24)
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	update_price_position()

	update_station_state()


func _process(_delta):

	# Постійно перевіряємо стан станції
	update_station_state()


	# ==========================================
	# СТАНЦІЯ ЩЕ НЕ КУПЛЕНА
	# ==========================================

	if not GameManager.drink_shop_unlocked:

		# Якщо станція ще не доступна
		if not can_unlock_drink_station():
			return

		player_near_point = is_player_in_area(point_area)

		if player_near_point:

			if Input.is_action_just_pressed("interact"):

				print("E pressed on Drink Station point")

				buy_shop()

		return


	# ==========================================
	# СТАНЦІЯ ВЖЕ КУПЛЕНА
	# ==========================================

	player_near_shop = is_player_in_area(interaction_area)

	if player_near_shop:

		if Input.is_action_just_pressed("interact"):

			print("E pressed on Drink Station")

			open_menu()


# ==================================================
# ЧИ МОЖНА ВІДКРИТИ ТРЕТЮ СТАНЦІЮ
# ==================================================

func can_unlock_drink_station() -> bool:

	return (
		GameManager.shape_shop_unlocked
		and GameManager.color_shop_unlocked
	)


# ==================================================
# ЗАГАЛЬНИЙ СТАН
# ==================================================

func update_station_state():

	# ==========================================
	# ТРЕТЯ СТАНЦІЯ ВЖЕ КУПЛЕНА
	# ==========================================

	if GameManager.drink_shop_unlocked:

		show_shop()

		return


	# ==========================================
	# ПЕРШІ ДВІ СТАНЦІЇ ЩЕ НЕ КУПЛЕНІ
	# ==========================================

	if not can_unlock_drink_station():

		hide_everything()

		return


	# ==========================================
	# ПЕРШІ ДВІ СТАНЦІЇ КУПЛЕНІ
	# ==========================================

	show_purchase_point()


# ==================================================
# ПОВНІСТЮ ХОВАЄМО ТРЕТЮ СТАНЦІЮ
# ==================================================

func hide_everything():

	point.visible = false
	coin.visible = false
	price_label.visible = false
	shop.visible = false

	point_area.set_deferred("monitoring", false)
	point_area.set_deferred("monitorable", false)

	interaction_area.set_deferred("monitoring", false)
	interaction_area.set_deferred("monitorable", false)

	station_barrier.set_collision_layer_value(1, false)
	station_barrier.set_collision_mask_value(1, false)


# ==================================================
# ПОКАЗУЄМО ТОЧКУ ПОКУПКИ
# ==================================================

func show_purchase_point():

	# Не треба нічого робити, якщо магазин уже куплений
	if GameManager.drink_shop_unlocked:
		return


	print("Drink Station is now available!")


	# Point видно
	point.visible = true

	# Монетка видно
	coin.visible = true

	# Ціна видно
	price_label.visible = true

	price_label.text = str(remaining_price)

	update_price_position()


	# Shop ще прихований
	shop.visible = false


	# PointArea працює
	point_area.set_deferred("monitoring", true)
	point_area.set_deferred("monitorable", true)


	# InteractionArea вимкнена
	interaction_area.set_deferred("monitoring", false)
	interaction_area.set_deferred("monitorable", false)


	# Бар'єр вимкнений
	station_barrier.set_collision_layer_value(1, false)
	station_barrier.set_collision_mask_value(1, false)


# ==================================================
# ПОЗИЦІЯ ЦІНИ
# ==================================================

func update_price_position():

	if coin == null:
		return

	if price_label == null:
		return

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
# ПОКУПКА
# ==================================================

func buy_shop():

	print("Trying to buy Drink Station")

	if GameManager.money <= 0:

		print("No money to pay")

		return


	var payment = min(
		GameManager.money,
		remaining_price
	)

	GameManager.money -= payment
	remaining_price -= payment


	print("Paid: ", payment)
	print("Money left: ", GameManager.money)
	print("Remaining price: ", remaining_price)


	price_label.text = str(remaining_price)

	update_price_position()


	if remaining_price <= 0:

		remaining_price = 0

		GameManager.drink_shop_unlocked = true

		player_near_point = false

		print("Drink Station purchased!")

		show_shop()


# ==================================================
# ПОКАЗАТИ МАГАЗИН
# ==================================================

func show_shop():

	print("Drink Station: UNLOCKED")


	point.visible = false
	coin.visible = false
	price_label.visible = false

	shop.visible = true


	point_area.set_deferred("monitoring", false)
	point_area.set_deferred("monitorable", false)


	interaction_area.set_deferred("monitoring", true)
	interaction_area.set_deferred("monitorable", true)


	station_barrier.set_collision_layer_value(1, true)
	station_barrier.set_collision_mask_value(1, true)


# ==================================================
# ПЕРЕВІРКА AREA
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
# ВІДКРИТТЯ МЕНЮ
# ==================================================

func open_menu():

	var player = get_tree().get_first_node_in_group("player")

	if player == null:

		print("Player not found!")

		return


	print("OPENING DRINK STATION MENU")


	if player.carried_bubble != null:

		var bubble = player.carried_bubble

		print("Bubble size: ", bubble.get_size_name())
		print("Bubble radius: ", bubble.radius)
		print("Bubble shape: ", bubble.current_shape)
		print("Bubble color: ", bubble.current_color)

	else:

		print("Player is not carrying a bubble")


	# Меню відкривається
	menu_panel.visible = true


# ==================================================
# НАПІЙ
# ==================================================

func _on_drink_button_pressed():

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	if player.carried_bubble == null:
		return

	var bubble = player.carried_bubble

	if bubble.get_size_name() != "large":

		print("Drink requires LARGE bubble!")

		return

	print("DRINK CREATED!")

	player.set_carried_product("drink")

	menu_panel.visible = false


# ==================================================
# ЛІД
# ==================================================

func _on_ice_button_pressed():

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	if player.carried_bubble == null:
		return

	var bubble = player.carried_bubble

	if bubble.get_size_name() != "large":

		print("Ice requires LARGE bubble!")

		return

	print("ICE CREATED!")

	player.set_carried_product("ice")

	menu_panel.visible = false


# ==================================================
# ЗАКРИТТЯ
# ==================================================

func _on_close_button_pressed():

	menu_panel.visible = false

	print("Drink Station menu closed")
