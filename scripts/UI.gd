extends CanvasLayer

@onready var money_label: Label = $MoneyLabel

func _ready():
	money_label.text = "$" + str(GameManager.money)

func _process(_delta):
	money_label.text = "$" + str(GameManager.money)
