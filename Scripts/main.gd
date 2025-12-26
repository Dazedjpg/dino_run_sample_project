extends Node

const DINO_START_POS := Vector2i(150,485)
const CAM_START_POS := Vector2i(576, 324)
var score : int
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
var screensize : Vector2i

func _ready() -> void:
	screensize = get_window().size
	new_game()

func new_game():
	score = 0
	$player.position = DINO_START_POS
	$player.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$TileMapLayer.position = Vector2i(0, 0)

func _physics_process(delta: float) -> void:
	speed = START_SPEED
	$player.position.x += speed
	$Camera2D.position.x += speed
	
	score += speed
	
	if $Camera2D.position.x - $TileMapLayer.position.x > screensize.x * 1.5:
		$TileMapLayer.position.x += screensize.x
