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

var game_over = false

var money = 20
var biomass_capacity = 200 # pounds
var biomass_usage = 0.0 # decimal %
var aquarium_health = 1.0 #decimal %
var corpses_eaten_count = 0

var default_aquarium_color = Color(0, 0.30196078431, 0.43921568627, 0.2431372549)

var current_datetime: int # unix time

func _ready() -> void:
	contract_menu.visible = false
	set_money_label()
	Dialogic.start('intro')
	Dialogic.signal_event.connect(_on_dialogic_signal)
	set_starting_game_datetime()

func _process(delta: float) -> void:
	if game_over:
		return
		
	calculate_biomass_capacity_percent(delta)

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
	# find available spawn
	var spawn_point = null
	if (corpse_spawn1.get_child_count() == 0):
		spawn_point = corpse_spawn1
	elif (corpse_spawn2.get_child_count() == 0):
		spawn_point = corpse_spawn2
	elif (corpse_spawn3.get_child_count() == 0):
		spawn_point = corpse_spawn3
	elif (corpse_spawn4.get_child_count() == 0):
		spawn_point = corpse_spawn4
	if (spawn_point == null):
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
	$UI/CorpsesDisposedLabel.text = "Corpses Disposed: " + str(corpses_eaten_count)

func compile_corpse_list(): 
	var corpse_list = []
	if (corpse_spawn1.get_child_count() != 0):
		corpse_list.push_back(corpse_spawn1.get_child(0))
	if (corpse_spawn2.get_child_count() != 0):
		corpse_list.push_back(corpse_spawn2.get_child(0))
	if (corpse_spawn3.get_child_count() != 0):
		corpse_list.push_back(corpse_spawn3.get_child(0))
	if (corpse_spawn4.get_child_count() != 0):
		corpse_list.push_back(corpse_spawn4.get_child(0))
	return corpse_list
	
func creatures_find_corpses():
	var corpse_list = compile_corpse_list()
	
	for creature in $Aquarium/Creatures.get_children():
		#find closet corpse
		var closet_corpse = null
		for corpse in corpse_list:
			if corpse.eaten:
				continue
			if closet_corpse == null || closet_corpse.position.distance_to(creature.position) > corpse.position.distance_to(creature.position):
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
	$Aquarium/Creatures.add_child(creature)
	creatures_find_corpses()

	$SpawnCreature.play()

func _on_ui_contract_menu_opened() -> void:
	var corpse_list = compile_corpse_list()
	if corpse_list.size() == 4: # full
		$UI/ContractMenu.no_contracts_available()

func calculate_biomass_capacity_percent(delta: float):
	var actual_biomass = 0
	
	var corpse_list = compile_corpse_list()
	for corpse in corpse_list:
		actual_biomass += corpse.weight
	
	# TODO: Vary the creature weight
	actual_biomass += $Aquarium/Creatures.get_child_count() * 5.0
	biomass_usage = snappedf(actual_biomass / biomass_capacity, 0.0001)
	
	$UI/BiomassBar.value = biomass_usage * 100
	
	# tick aquarium health
	tick_aquarium_health(delta, biomass_usage)
	
func tick_aquarium_health(delta: float, biomass_usage: float):
	var health_difference = (1.0 - biomass_usage) * 0.5 * delta
	aquarium_health += snappedf(health_difference, 0.0001)
	aquarium_health = clamp(aquarium_health, 0.0, 1.0)
	$UI/HealthBar.value = aquarium_health * 100
	
	var new_color = default_aquarium_color
	new_color.g += (0.5 * (1.0-aquarium_health))
	$Lighting/WaterRect.color = new_color
	
	if aquarium_health == 0.0:
		set_game_over()

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
	set_game_over()

func set_game_over():
	$UI/ContractMenu/NewContractTimer.stop()
	$UI/ContractMenu.visible = false
	$UI/CreatureMenu.visible = false
	$EndScreen.open(corpses_eaten_count)
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
	start_game()

func start_game():
	$UI/ContractMenu/NewContractTimer.start()
	$DateTimer.start()

func set_starting_game_datetime():
	var current_date_dict = Time.get_date_dict_from_system()
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
	
	if !year_num || !month_num || !day_num || !hour_num || !minute_num:
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
	
	var minute_string = ("0" if minute_num < 10 else "") + str(minute_num)
	
	return month_string + " " + day_string + ", " + year_string + " - " + hour_string + ":" + minute_string + hour_postfix

func _on_date_timer_timeout_advance_time_one_minute() -> void:
	current_datetime += 60
	
	var new_date_string = get_my_formatted_datetime_from_dict(current_datetime)
	$UI/DateLabel.text = new_date_string
