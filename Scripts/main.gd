extends Node

var tree_scene = preload("res://Scenes/stump.tscn")
var rock_scene = preload("res://Scenes/rock.tscn")
var barrel_scene = preload("res://Scenes/barrel.tscn")
var bat_scene = preload("res://Scenes/bat.tscn")
var obstacle_type := [tree_scene, rock_scene, barrel_scene]
var obstacle : Array
var bird_heights := [200, 390]

const DINO_START_POS := Vector2i(150,485)
const CAM_START_POS := Vector2i(576, 324)
var score : int
const SCORE_MODIFIER : int = 10
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 5000
var screensize : Vector2i
var gamerunning : bool

func _ready() -> void:
	screensize = get_window().size
	new_game()

func new_game():
	score = 0
	show_score()
	gamerunning = false
	$player.position = DINO_START_POS
	$player.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$TileMapLayer.position = Vector2i(0, 0)
	$HUD.get_node("StartLabel").show()

func _physics_process(delta: float) -> void:
	if gamerunning:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		
		$player.position.x += speed
		$Camera2D.position.x += speed
		
		score += speed
		show_score()
		
		if $Camera2D.position.x - $TileMapLayer.position.x > screensize.x * 1.5:
			$TileMapLayer.position.x += screensize.x
	else:
		if Input.is_action_pressed("jump"):
			gamerunning = true
			$HUD.get_node("StartLabel").hide()

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)
