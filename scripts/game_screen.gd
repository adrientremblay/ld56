extends Node2D

@export var landCreatureScene: PackedScene
@export var corpse_scene: PackedScene
@export var waterCreatureScene: PackedScene
@export var plantScene: PackedScene

@onready var contract_menu = $UI/ContractMenu
@onready var corpse_spawn1 = $Aquarium/CorpseSpawn1
@onready var corpse_spawn2 = $Aquarium/CorpseSpawn2
@onready var corpse_spawn3 = $Aquarium/CorpseSpawn3
@onready var corpse_spawn4 = $Aquarium/CorpseSpawn4
@onready var corpse_spawn5 = $Aquarium/CorpseSpawn5
@onready var corpse_spawn6 = $Aquarium/CorpseSpawn6
@onready var corpse_spawn7 = $Aquarium/CorpseSpawn7

@onready var corpse_spawn_list = [corpse_spawn1, corpse_spawn2, corpse_spawn3, corpse_spawn4, corpse_spawn5, corpse_spawn6, corpse_spawn7]

var game_over = false

# GAMEPLAY VARIABLES
var debug = true
var money = 2000 if debug else 50
var biomass_capacity = 200 # pounds
var ammonia_level = 0.0 # decimal %
var nitrate_level = 0.0 # decimal %
var corpses_eaten_count = 0
var total_corpses_eaten = 0

# LEVEL VARIABLES
var level = 0
var CORPSE_QUOTA_PER_LEVEL = [0, 1, 2, 3, 5, 7, 10, 15, 30, 50, 100] # index = level, value = quota

# MISC
var default_aquarium_color = Color(0, 0.30196078431, 0.43921568627, 0.2431372549)
var current_datetime: int # unix time

func _ready() -> void:
	randomize() # ensures randomness for randi() and randf()
	contract_menu.visible = false
	set_money_label()
	set_starting_game_datetime()
	update_corpse_eaten_label()
	dialogic_setup()
	$UI/TitleScreen.open()
	$Aquarium/Filters/SpongeFilter.play()
	$Aquarium/Filters/HangOnBackFilter.play()

func start_game():
	$Music.play()
	next_level()

func _process(delta: float) -> void:
	if game_over:
		return

func _on_buy_snail_pressed() -> void:
	if money < 5:
		return
	money -= 5
	set_money_label()
	
	var snail = landCreatureScene.instantiate()
	snail.set_species(Creature.Species.SNAIL)
	$Aquarium/Creatures.add_child(snail)
	creatures_find_corpses()
	
	$SpawnCreature.play()

func _on_contract_menu_should_spawn_corpse(person_name: Variant, weight: Variant, reward: Variant, appearance: Contract.Appearance, female: bool) -> void:
	# find a random available spawn
	var spawn_indexes_to_try = [0, 1, 2, 3, 4, 5, 6]
	spawn_indexes_to_try.shuffle()
	var spawn_point = null
	for spawn_index in spawn_indexes_to_try:
		if corpse_spawn_list[spawn_index].get_child_count() == 0:
			spawn_point = corpse_spawn_list[spawn_index]
	if spawn_point == null:
		return
	
	# spawn corpse
	var new_corpse = corpse_scene.instantiate()
	new_corpse.construct(person_name, weight, reward, appearance, female)
	new_corpse.connect("corpse_eaten", self.corpse_was_eaten)
	spawn_point.add_child(new_corpse)
	$Splash.play()
	
	# make creatures search for target
	creatures_find_corpses()

func corpse_was_eaten(reward):
	money += reward
	set_money_label()
	
	creatures_find_corpses()
	
	$CorpseEaten.play()
	
	corpses_eaten_count+=1
	total_corpses_eaten+=1
	update_corpse_eaten_label()

func update_corpse_eaten_label():
	var quota = CORPSE_QUOTA_PER_LEVEL[level]
	if corpses_eaten_count < quota:
		$UI/CorpsesDisposedLabel.add_theme_color_override("font_color", Color(1, 0, 0))
	else:
		$UI/CorpsesDisposedLabel.add_theme_color_override("font_color", Color(0, 1, 0))
	
	$UI/CorpsesDisposedLabel.text = "Corpses Disposed: " + str(corpses_eaten_count) + "/" + str(quota)

func compile_corpse_list(): 
	var corpse_list = []
	for corpse_spawn in corpse_spawn_list:
		if corpse_spawn.get_child_count() != 0:
			corpse_list.push_back(corpse_spawn.get_child(0))
	return corpse_list
	
func creatures_find_corpses():
	var corpse_list = compile_corpse_list()
	
	for creature in $Aquarium/Creatures.get_children():
		#find closet corpse
		var closet_corpse = null
		for corpse in corpse_list:
			if corpse.eaten:
				continue
			if closet_corpse == null || closet_corpse.global_position.distance_to(creature.global_position) > corpse.global_position.distance_to(creature.global_position):
				closet_corpse = corpse
		
		if closet_corpse != null:
			creature.set_target(closet_corpse)
		else:
			creature.change_idle_position()

func set_money_label():
	$UI/MoneyLabel.text = "Money: " + str(snappedf(money, 0.01)) + "$"

func _on_buy_fish_pressed() -> void:
	if money < 10:
		return
	money -= 10
	set_money_label()
	
	var creature = waterCreatureScene.instantiate()
	creature.set_species(Creature.Species.KILLIFISH)
	$Aquarium/Creatures.add_child(creature)
	creatures_find_corpses()

	$SpawnCreature.play()

func _on_buy_piranha_pressed() -> void:
	if money < 15:
		return
	money -= 15
	set_money_label()
	
	var creature = waterCreatureScene.instantiate()
	creature.set_species(Creature.Species.PIRANHA)
	$Aquarium/Creatures.add_child(creature)
	creatures_find_corpses()

	$SpawnCreature.play()

func _on_ui_contract_menu_opened() -> void:
	var corpse_list = compile_corpse_list()
	if corpse_list.size() == 7:# full
		$UI/ContractMenu.no_contracts_available()
	
func tick_nitrogen_levels():
	# Ammonia production from creatures
	for creature in $Aquarium/Creatures.get_children():
		self.ammonia_level += creature.bioload
	# Damage to fish based on ammonia level
	#	- Based on the nitrogen tolerance of each fish
	# 	- Threshold for ammonia poisoning is 25%
	if ammonia_level >= 0.25:
		var base_damage = ammonia_level * 5.0
		
		for creature in $Aquarium/Creatures.get_children():
			var creature_damage = base_damage * creature.nitrogen_coefficient
			creature.health -= creature_damage
			if creature.health <= 0:
				creature.queue_free()
			else:
				creature.update_health_bar()
	
	$UI/AmmoniaLevelBar.value = ammonia_level * 100.0
	$UI/NitrateLevelBar.value = nitrate_level * 100.0
	#var new_color = default_aquarium_color
	#new_color.g += (0.5 * (1.0-aquarium_health))
	#$Lighting/WaterRect.color = new_color

func _on_buy_stem_plant_pressed() -> void:
	if money < 15:
		return
	money -= 15
	set_money_label()
	
	$SpawnPlant.play()
	
	biomass_capacity += 20
	
	var new_plant = plantScene.instantiate()
	new_plant.global_position = Vector2(137 + (randf() * 966), 507 - (randf()*31))
	$Aquarium/Plants.add_child(new_plant)

func _on_retire_pressed() -> void:
	next_level()

func set_game_over():
	$UI/ContractMenu/NewContractTimer.stop()
	$UI/ContractMenu.visible = false
	$UI/CreatureMenu.visible = false
	get_tree().paused = true
	$UI/EndScreen.open(total_corpses_eaten)
	self.game_over = true

func open_win_screen():
	$UI/ContractMenu/NewContractTimer.stop()
	$UI/ContractMenu.visible = false
	$UI/CreatureMenu.visible = false
	get_tree().paused = true
	$UI/WinScreen.open(total_corpses_eaten)
	self.game_over = true

func _on_buy_crab_pressed() -> void:
	if money < 10:
		return
	money -= 10
	set_money_label()
	
	var creature = landCreatureScene.instantiate()
	creature.set_species(Creature.Species.CRAB)
	$Aquarium/Creatures.add_child(creature)
	creatures_find_corpses()

	$SpawnCreature.play()

func _on_dialogic_signal(action: String):
	if action == "pause":
		get_tree().paused = true
	if action == "end_game":
		set_game_over()
	if action == "win_game":
		open_win_screen()

func setup_new_level():
	corpses_eaten_count = 0
	delete_all_corpses()
	$UI/ContractMenu/NewContractTimer.wait_time = 1
	$UI/ContractMenu/NewContractTimer.start()
	$DateTimer.start()
	$NitrogenTimer.start()
	update_corpse_eaten_label()
	set_starting_game_datetime()
	set_money_label()
	$UI/LevelLabel.text = "Level: " + str(level)

func set_starting_game_datetime():
	var current_date_dict = Time.get_date_dict_from_system()
	current_date_dict.day += (level-1)
	current_date_dict.hour = 23
	current_date_dict.minute = 0
	current_date_dict.second = 0
	current_datetime = Time.get_unix_time_from_datetime_dict(current_date_dict)
	
func get_my_formatted_datetime_from_dict(datetime_unix : int):
	var datetime = Time.get_datetime_dict_from_unix_time(datetime_unix)
	
	var year_num = datetime.year
	var month_num = datetime.month
	var day_num = datetime.day
	var hour_num = datetime.hour
	var minute_num = datetime.minute
	
	if year_num == null || month_num == null || day_num == null || hour_num == null || minute_num == null:
		return "ERROR"
		
	var year_string = str(year_num)
	
	var month_string
	match month_num:
		1:
			month_string = "Jan"
		2:
			month_string = "Feb"
		3:
			month_string = "Mar"
		4:
			month_string = "Apr"
		5:
			month_string = "May"
		6:
			month_string = "Jun"
		7:
			month_string = "Jul"
		8:
			month_string = "Aug"
		9:
			month_string = "Sep"
		10:
			month_string = "Oct"
		11:
			month_string = "Nov"
		12:
			month_string = "Dec"
	
	var day_string = str(day_num)
	
	var hour_postfix = ""
	if hour_num >= 12:
		hour_postfix = "PM"
	else:
		hour_postfix = "AM"
	if hour_num > 12:
		hour_num -= 12
	var hour_string = str(hour_num)
	if hour_num == 0:
		hour_string = "12"
	
	var minute_string = ("0" if minute_num < 10 else "") + str(minute_num)
	
	var date_str =  month_string + " " + day_string + ", " + year_string + " - " + hour_string + ":" + minute_string + hour_postfix
	return date_str

func _on_date_timer_timeout_advance_time_one_minute() -> void:
	current_datetime += 60
	
	var datetime = Time.get_datetime_dict_from_unix_time(current_datetime)
	if datetime.hour == 7:
		next_level()
		return
	
	var new_date_string = get_my_formatted_datetime_from_dict(current_datetime)
	$UI/DateLabel.text = new_date_string

func _on_timeline_started():
	#print("Timeline started")
	#get_tree().paused = true
	pass

func _on_timeline_ended():
	#print("Timeline ended")
	if !game_over && level < 11:
		launch_level_screen()

func dialogic_setup():
	Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func next_level():
	level+=1
	var timeline_name = ""
	if corpses_eaten_count < CORPSE_QUOTA_PER_LEVEL[level-1]:
		timeline_name = "fail"
	elif level == 11:
		timeline_name = "ending"
	elif level == 1:
		timeline_name = "intro"
	else:
		timeline_name = "level" + str(level)
	
	var dialogicRootNode = Dialogic.start(timeline_name)
	dialogicRootNode.process_mode = Node.PROCESS_MODE_ALWAYS

func calculate_level_finish_bonus():
	if level == 1:
		return 0
	
	var datetime = Time.get_datetime_dict_from_unix_time(current_datetime)
	var hour = datetime.hour
	if hour == 23:
		hour = -1
	var hours_to_7am = 7 - hour
	
	return hours_to_7am * 10

func calculate_penalty():
	if level == 1:
		return 0
	
	var corpse_count = compile_corpse_list().size()
	return corpse_count * 50

func launch_level_screen():
	#match level:
	#1:
		#pass
	var bonus = calculate_level_finish_bonus()
	money += bonus
	var penalty = calculate_penalty()
	money -= penalty
	$UI/LevelScreen.open(level, "You sleep pretty soundly for a murderer...", CORPSE_QUOTA_PER_LEVEL[level], bonus, penalty)

func launch_level():
	get_tree().paused = false
	setup_new_level()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next_level"):
		next_level()
	elif $UI/TitleScreen.visible && event.is_action_pressed("dialogic_default_action"):
		$UI/TitleScreen.close()
		start_game()

func _on_level_screen_level_screen_closed() -> void:
	launch_level()

func delete_all_corpses():
	if (corpse_spawn1.get_child_count() != 0):
		corpse_spawn1.get_child(0).eaten = true
		corpse_spawn1.get_child(0).queue_free()
	if (corpse_spawn2.get_child_count() != 0):
		corpse_spawn2.get_child(0).eaten = true
		corpse_spawn2.get_child(0).queue_free()
	if (corpse_spawn3.get_child_count() != 0):
		corpse_spawn3.get_child(0).eaten = true
		corpse_spawn3.get_child(0).queue_free()
	if (corpse_spawn4.get_child_count() != 0):
		corpse_spawn4.get_child(0).eaten = true
		corpse_spawn4.get_child(0).queue_free()
	creatures_find_corpses()

func _on_buy_anglerfish_pressed() -> void:
	if money < 20:
		return
	money -= 20
	set_money_label()
	
	var creature = waterCreatureScene.instantiate()
	creature.set_species(Creature.Species.ANGLERFISH)
	$Aquarium/Creatures.add_child(creature)
	creatures_find_corpses()

	$SpawnCreature.play()

func _on_buy_dragonfish_pressed() -> void:
	if money < 25:
		return
	money -= 25
	set_money_label()
	
	var creature = waterCreatureScene.instantiate()
	creature.set_species(Creature.Species.DRAGONFISH)
	$Aquarium/Creatures.add_child(creature)
	creatures_find_corpses()

	$SpawnCreature.play()

func _on_buy_goblinshark_pressed() -> void:
	if money < 25:
		return
	money -= 25
	set_money_label()
	
	var creature = waterCreatureScene.instantiate()
	creature.set_species(Creature.Species.GOBLINSHARK)
	$Aquarium/Creatures.add_child(creature)
	creatures_find_corpses()

	$SpawnCreature.play()

func _on_buy_lobster_pressed() -> void:
	if money < 15:
		return
	money -= 15
	set_money_label()
	
	var creature = landCreatureScene.instantiate()
	creature.set_species(Creature.Species.LOBSTER)
	$Aquarium/Creatures.add_child(creature)
	creatures_find_corpses()

	$SpawnCreature.play()

func _on_buy_octopus_pressed() -> void:
	if money < 20:
		return
	money -= 20
	set_money_label()
	
	var creature = landCreatureScene.instantiate()
	creature.set_species(Creature.Species.OCTOPUS)
	$Aquarium/Creatures.add_child(creature)
	creatures_find_corpses()

	$SpawnCreature.play()

func _on_buy_turtle_pressed() -> void:
	if money < 100:
		return
	money -= 100
	set_money_label()
	
	var creature = landCreatureScene.instantiate()
	creature.set_species(Creature.Species.TURTLE)
	$Aquarium/Creatures.add_child(creature)
	creatures_find_corpses()

	$SpawnCreature.play()

func _on_spawn_species(species: Creature.Species) -> void:
	if money < Creature.species_stats[species].price:
		return
	money -= Creature.species_stats[species].price
	set_money_label()
	
	var creature: Creature
	if Creature.is_species_land_based(species):
		creature = landCreatureScene.instantiate()
	else:
		creature = waterCreatureScene.instantiate()
		
	creature.set_species(species)
	$Aquarium/Creatures.add_child(creature)
	creatures_find_corpses()

	$SpawnCreature.play()
