extends CanvasLayer

const GAP := 20.0

@onready var money_label: Label = $MoneyLabel
@onready var coin: Sprite2D = $Coin


func _ready():

	# Число вирівнюємо по правому краю
	money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	# Фіксована ширина для Label,
	# щоб він міг показувати різну кількість цифр
	money_label.size.x = 100

	update_money()


func _process(_delta):

	update_money()


func update_money():

	# Оновлюємо число
	money_label.text = str(GameManager.money)

	# Ліва межа монетки
	var coin_left = coin.position.x

	if coin.texture != null:
		coin_left -= (coin.texture.get_width() * coin.scale.x) / 2.0

	# Правий край тексту = 20 px лівіше монетки
	var text_right = coin_left - GAP

	# Оскільки текст вирівняний вправо,
	# рухаємо весь Label так, щоб його правий край був тут
	money_label.position.x = text_right - money_label.size.x
