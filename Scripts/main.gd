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
var difficulty
const MAX_DIFFICULTY : int = 2
var score : int
const SCORE_MODIFIER : int = 10
var high_score : int
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 5000
var screensize : Vector2i
var ground_y : int
var gamerunning : bool
var last_obs

func _ready() -> void:
	screensize = get_window().size
	ground_y = $TileMapLayer.position.y + 75
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	score = 0
	show_score()
	gamerunning = false
	get_tree().paused = false
	difficulty = 0
	$GameOver.hide()
	
	for obs in obstacle:
		obs.queue_free()
	obstacle.clear()
	
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
		adjust_difficulty()
		
		generate_obs()
		
		$player.position.x += speed
		$Camera2D.position.x += speed
		
		score += speed
		show_score()
		
		if $Camera2D.position.x - $TileMapLayer.position.x > screensize.x * 1.5:
			$TileMapLayer.position.x += screensize.x
		
		for obs in obstacle:
			if obs.position.x < ($Camera2D.position.x - screensize.x):
				remove_obs(obs)
	else:
		if Input.is_action_pressed("jump"):
			gamerunning = true
			$HUD.get_node("StartLabel").hide()

func generate_obs():
	if obstacle.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_type[randi() % obstacle_type.size()]
		var obs 
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screensize.x + score + 100 + (i * 100)
			var obs_y : int = screensize.y - ground_y - (obs_height * obs_scale.y / 2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				obs = bat_scene.instantiate()
				var obs_x : int = screensize.x + score + 100
				var obs_y : int = bird_heights[randi() % bird_heights.size()]
				add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacle.append(obs)

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func remove_obs(obs):
	obs.queue_free()
	obstacle.erase(obs)

func hit_obs(body):
	if body.name == "player":
		game_over()

func game_over():
	check_high_score()
	get_tree().paused = true
	gamerunning = false
	$GameOver.show()

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGHSCORE: " + str(score / SCORE_MODIFIER)
