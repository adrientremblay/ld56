extends Node2D

@export var landCreatureScene: PackedScene
@export var corpse_scene: PackedScene
@export var waterCreatureScene: PackedScene
@export var filterWrapperScene: PackedScene

@onready var contract_menu = $UI/ContractMenu
@onready var assistant = $UI/Assistant

@onready var corpse_spawn1 = $Aquarium/CorpseSpawn1
@onready var corpse_spawn2 = $Aquarium/CorpseSpawn2
@onready var corpse_spawn3 = $Aquarium/CorpseSpawn3
@onready var corpse_spawn4 = $Aquarium/CorpseSpawn4
@onready var corpse_spawn5 = $Aquarium/CorpseSpawn5
@onready var corpse_spawn6 = $Aquarium/CorpseSpawn6
@onready var corpse_spawn7 = $Aquarium/CorpseSpawn7
@onready var corpse_spawn_list = [corpse_spawn1, corpse_spawn2, corpse_spawn3, corpse_spawn4, corpse_spawn5, corpse_spawn6, corpse_spawn7]

@onready var filter_spawn1 = $Aquarium/Filters/FilterSpawn1
@onready var filter_spawn2 = $Aquarium/Filters/FilterSpawn2
@onready var filter_spawn3 = $Aquarium/Filters/FilterSpawn3
@onready var filter_spawn4 = $Aquarium/Filters/FilterSpawn4
@onready var filter_spawn_list = [filter_spawn1, filter_spawn2, filter_spawn3, filter_spawn4]

@onready var plants = $Aquarium/Plants

var game_over = false

# GAMEPLAY VARIABLES
var debug = true
var money = 90000 if debug else 45
var biomass_capacity = 200 # pounds
var ammonia_level = 0.0 # decimal %
var nitrate_level = 0.0 # decimal %
var corpses_eaten_count = 0
var total_corpses_eaten = 0
var feasting_frenzy = false

# LEVEL VARIABLES
var level = 0
var quota = 0

# MISC
var default_aquarium_color = Color(0, 0.30196078431, 0.43921568627, 0.2431372549)
var current_datetime: int # unix time
var GLOBAL_NITROGEN_MODIFIER = 0.3
var FEASTING_FRENZY_COLOR = Color(0.5, 0.5, 1, 1)

func _ready() -> void:
	randomize() # ensures randomness for randi() and randf()
	contract_menu.visible = false
	set_money_label()
	set_starting_game_datetime()
	update_corpse_eaten_label()
	dialogic_setup()
	$UI/TitleScreen.visible = true
	$SpokesmanMusic.process_mode = Node.PROCESS_MODE_ALWAYS

func start_game():
	$Music.play()
	next_level()

func _process(delta: float) -> void:
	if game_over:
		return

	var feeding_frenzy_boost = 1.5 if feasting_frenzy else 1.0
	for corpse in compile_corpse_list():
		for creature in corpse.feeding_area.get_overlapping_bodies():
			corpse.weight -= creature.damage * delta * 0.2 * feeding_frenzy_boost

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

func _on_ui_contract_menu_opened() -> void:
	var corpse_list = compile_corpse_list()
	if corpse_list.size() == 7:# full
		$UI/ContractMenu.no_contracts_available()
	if !assistant.contract_noob_timer_used:
		if assistant.contract_warning_active:
			assistant._on_dismiss_button_pressed()
		assistant.contract_noob_timer_used = true
		$UI/Assistant/NoobTimerHasNotOpenedContractMenu.stop()
	
func tick_nitrogen_levels():
	# Ammonia production from creatures
	for creature in $Aquarium/Creatures.get_children():
		self.ammonia_level += creature.bioload * GLOBAL_NITROGEN_MODIFIER
	# Ammonia conversion -> Nitrate from filters
	if ammonia_level > 0:
		for filter_spawn in $Aquarium/Filters.get_children():
			if filter_spawn.get_child_count() != 0:
				var filter_wrapper: FilterWrapper = filter_spawn.get_child(0)
				var filter = filter_wrapper.filter
				# Increase filter performance (bacteria colony grows)
				#if filter.current_performance < filter.max_performance:
				#	filter.current_performance += Filter.PERFORMANCE_GROWTH_PER_SECOND
				#	filter.current_performance = min(filter.current_performance, filter.max_performance)
				# Convert Ammonia to Nitrate
				var ammonia_level_to_consume = min(ammonia_level, filter.max_performance * GLOBAL_NITROGEN_MODIFIER)
				ammonia_level -= ammonia_level_to_consume
				nitrate_level += ammonia_level_to_consume
	# Nitrate uptake by plants
	if nitrate_level > 0:
		for plant in $Aquarium/Plants.get_children():
			var nitrate_level_to_consume = min(nitrate_level, plant.performance * GLOBAL_NITROGEN_MODIFIER)
			nitrate_level -= nitrate_level_to_consume
	
	# Clamp ammonia and nitrate levels
	ammonia_level = clamp(ammonia_level, 0.0, 1.0)
	nitrate_level = clamp(nitrate_level, 0.0, 1.0)
	
	# Check if assistant should warn player
	if !assistant.player_has_bought_a_filter && !assistant.filter_warning_given && ammonia_level >= 0.25:
		assistant.open_ammonia_warning()
	elif !assistant.neutralizer_warning_given && ammonia_level >= 0.5:
		assistant.open_severe_ammonia_warning()
	elif !assistant.player_has_bought_a_plant && !assistant.plant_warning_active && !assistant.plant_warning_given && nitrate_level >= 0.25:
		assistant.open_nitrate_warning()
	elif !assistant.nn_warning_active && !assistant.nn_warning_given && nitrate_level > 0.5:
		assistant.open_severe_nitrate_warning()
		
	# Check if we should dismiss the assistant
	if assistant.filter_warning_active && ammonia_level < 0.25:
		assistant._on_dismiss_button_pressed()
	elif assistant.neutralizer_warning_active && ammonia_level < 0.5:
		assistant._on_dismiss_button_pressed()
	elif assistant.plant_warning_active && nitrate_level < 0.25:
		assistant._on_dismiss_button_pressed()
	elif assistant.nn_warning_active && nitrate_level < 0.5:
		assistant._on_dismiss_button_pressed()
	
	# Damage to fish based on ammonia level
	#	- Based on the nitrogen tolerance of each fish
	# 	- Threshold for ammonia poisoning is 25%
	if ammonia_level >= 0.25:
		var base_damage = ammonia_level * 5.0
		
		var all_creatures_healthy = true
		for creature in $Aquarium/Creatures.get_children():
			var creature_damage = base_damage * creature.nitrogen_coefficient
			creature.health -= creature_damage
			if all_creatures_healthy && creature.health < 50:
				all_creatures_healthy = false
			if creature.health <= 0:
				creature.queue_free()
				$CreatureDeathsound.play()
			elif !assistant.health_warning_given && creature.health <= 50:
				assistant.open_health_warning()
			
			creature.update_health_bar()
		if assistant.health_warning_active && all_creatures_healthy:
			assistant._on_dismiss_button_pressed()
	# Damage to fish based on nitrate level
	if nitrate_level >= 0.25:
		var base_damage = nitrate_level * 2.0
		
		for creature in $Aquarium/Creatures.get_children():
			var creature_damage = base_damage * creature.nitrogen_coefficient
			creature.health -= creature_damage
			if creature.health <= 0:
				creature.queue_free()
			else:
				creature.update_health_bar()
	# Healing fish when the water conditions are good
	if nitrate_level < 0.25 && ammonia_level < 0.25:
		for creature in $Aquarium/Creatures.get_children(): 
			creature.health += Creature.CREATURE_HEALING_RATE
			creature.health = min(100.0, creature.health)
			creature.update_health_bar()
			
	# Update UI
	$UI/AmmoniaLevelBar.value = ammonia_level * 100.0
	$UI/NitrateLevelBar.value = nitrate_level * 100.0
	#var new_color = default_aquarium_color
	#new_color.g += (0.5 * (1.0-aquarium_health))
	#$Lighting/WaterRect.color = new_color

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
	if !assistant.contract_noob_timer_used:
		$UI/Assistant/NoobTimerHasNotOpenedContractMenu.start()

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
	$SpokesmanMusic.play()

func _on_timeline_ended():
	$SpokesmanMusic.stop()
	if !game_over && level < 11:
		launch_level_screen()

func dialogic_setup():
	Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func next_level():
	level+=1
	
	# Starting the Dialogic Timeline
	var timeline_name = ""
	if money >= 100000:
		timeline_name = "ending"
	elif level == 1:
		timeline_name = "intro"
	elif corpses_eaten_count < quota:
		timeline_name = "fail"
	elif level >= 10:
		timeline_name = "level9"
	else:
		timeline_name = "level" + str(level)
	
	# Quota Calculation (capped at 300)
	quota = min(level ** 2, 300)
	
	var dialogicRootNode = Dialogic.start(timeline_name)
	dialogicRootNode.process_mode = Node.PROCESS_MODE_ALWAYS
	
	if assistant.visible:
		assistant.visible = false
		assistant.dismiss()
	
	contract_menu.should_refresh_contracts = true

func calculate_level_finish_bonus():
	if level == 1:
		return 0
	
	var datetime = Time.get_datetime_dict_from_unix_time(current_datetime)
	var hour = datetime.hour
	if hour == 23:
		hour = -1
	var hours_to_7am = 7 - hour
	
	return hours_to_7am * 100

func calculate_penalty():
	if level == 1:
		return 0
	
	var corpse_count = compile_corpse_list().size()
	return corpse_count * 100

func launch_level_screen():
	#match level:
	#1:
		#pass
	var bonus = calculate_level_finish_bonus()
	money += bonus
	var penalty = calculate_penalty()
	money -= penalty
	$UI/LevelScreen.open(level, quota, bonus, penalty, determine_contract_timeout_for_level(), money)

func launch_level():
	get_tree().paused = false
	setup_new_level()
	
func _input(event: InputEvent) -> void:
	if debug && event.is_action_pressed("next_level"):
		next_level()
	elif $UI/TitleScreen.visible && event.is_action_pressed("dialogic_default_action"):
		$UI/TitleScreen.visible = false
		$UI/InfographicScreen.visible = true
	elif $UI/InfographicScreen.visible == true && event.is_action_pressed("dialogic_default_action"):
		$UI/InfographicScreen.visible = false
		start_game()
		$ThemeMusic.stop()

func _on_level_screen_level_screen_closed() -> void:
	launch_level()

func delete_all_corpses():
	for spawn in corpse_spawn_list :
		if spawn.get_child_count() != 0:
			spawn.get_child(0).queue_free()
	creatures_find_corpses()

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
	
	assistant.player_has_bought_a_creature = true

func _on_spawn_filter(filter: Filter.FilterType) -> void:
	# find a random available spawn
	var spawn_indexes_to_try = [0, 1, 2, 3]
	spawn_indexes_to_try.shuffle()
	var spawn_point = null
	for spawn_index in spawn_indexes_to_try:
		if filter_spawn_list[spawn_index].get_child_count() == 0:
			spawn_point = filter_spawn_list[spawn_index]
	if spawn_point == null:
		return
	
	# check and do money subtraction
	if money < Filter.filter_stats[filter].price:
		return
	money -= Filter.filter_stats[filter].price
	set_money_label()
	
	# create the filter node
	var filter_wrapper = filterWrapperScene.instantiate()
	filter_wrapper.connect("sell_filter", self.filter_sold)
	
	var filter_node: Filter = Filter.filter_stats[filter].sprite_scene.instantiate()
	filter_wrapper.add_filter(filter_node)
	filter_node.set_type(filter)
	filter_node.play()
	spawn_point.add_child(filter_wrapper)
	$Splash.play()
	
	assistant.player_has_bought_a_filter = true

func _on_spawn_plant(type: Plant.PlantType) -> void:
	# check and do money subtraction
	if money < Plant.plant_stats[type].price:
		return
	money -= Plant.plant_stats[type].price
	set_money_label()
	
	# create the plant node
	var plant: Plant = Plant.plant_stats[type].sprite_scene.instantiate()
	plant.set_type(type)
	plant.play()
	plants.add_child(plant)
	plant.random_position()
	$Splash.play()
	
	assistant.player_has_bought_a_plant = true

func filter_sold(value: int):
	var sell_value = value / 2
	money += sell_value
	set_money_label()
	$CorpseEaten.play()

func determine_contract_timeout_for_level():
	var contract_timeout
	if level <= 2:
		contract_timeout = 30
	elif level <= 4:
		contract_timeout = 20
	elif level <= 6:
		contract_timeout = 10
	elif level <= 8:
		contract_timeout = 5
	else:
		contract_timeout = 5
	return contract_timeout

func _on_contract_menu_contract_menu_closed() -> void:
	if contract_menu.accepted_a_contract:
		var contract_timeout = determine_contract_timeout_for_level()
		$UI/ContractMenu/NewContractTimer.wait_time = contract_timeout
		$UI/ContractMenu/NewContractTimer.start()
	
	if !assistant.creature_noob_timer_used:
		assistant.creature_noob_timer_used = true
		$UI/Assistant/NoobTimerHasNotBoughtCreature.start()

func _on_buy_ammonia_neutralizer_button_pressed() -> void:
	if money < 50:
		return
	money -= 50
	set_money_label()
	
	ammonia_level = clamp(ammonia_level - 0.25, 0.0, 1.0)
	$UI/AmmoniaLevelBar.value = ammonia_level * 100.0
	
	$ItemSound.play()

func _on_buy_nitrate_neutralizer_button_pressed() -> void:
	if money < 50:
		return
	money -= 50
	set_money_label()
	
	nitrate_level = clamp(nitrate_level - 0.25, 0.0, 1.0)
	$UI/NitrateLevelBar.value = nitrate_level * 100.0

	$ItemSound.play()

func _on_buy_health_booster_button_pressed() -> void:
	if money < 50:
		return
	money -= 50
	set_money_label()
	
	for creature in $Aquarium/Creatures.get_children():
		creature.health = clamp(creature.health + (creature.max_health/2), 0, 100)

	$ItemSound.play()

func _on_buy_appetite_booster_button_pressed() -> void:
	if money < 100 || feasting_frenzy:
		return
	money -= 100
	set_money_label()
	
	feasting_frenzy = true
	$AppetiteBoosterTimeout.start()
	
	$ItemSound.play()
	
	# turn all the animals orange = POWER
	for creature: Creature in $Aquarium/Creatures.get_children():
		creature.modulate = FEASTING_FRENZY_COLOR

func _on_appetite_booster_timeout_timeout() -> void:
	feasting_frenzy = false
	for creature: Creature in $Aquarium/Creatures.get_children():
		creature.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_contract_menu_button_pressed() -> void:
	$UI/ContractMenu.open_contract_menu(level)
