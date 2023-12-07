extends Control

@onready var _timer = %Timer;
@onready var _villagers_numbers: Control = $UI/VillagersNumbers;
@onready var _clock_ui: Control = $UI/Clock;

@onready var _total_number: Label = $UI/VillagersNumbers/TotalUnits/Total
@onready var _current_number: Label = $UI/VillagersNumbers/TotalUnits/Current
@onready var _sleeper_number: Label = $UI/VillagersNumbers/Sleeping

@onready var _red_number: Label = $UI/VillagersNumbers/UnitClasses/RedNumber
@onready var _green_number: Label = $UI/VillagersNumbers/UnitClasses/GreenNumber
@onready var _blue_number: Label = $UI/VillagersNumbers/UnitClasses/BlueNumber

@onready var _hour_number: Label = $UI/Clock/Digits/HourNumber
@onready var _minute_number: Label = $UI/Clock/Digits/MinuteNumber

@onready var _am_pm: Sprite2D = $UI/Clock/AmPm

@onready var _villagers_numbers_init_pos: Vector2 = _villagers_numbers.position;
@onready var _clock_ui_init_pos: Vector2 = _clock_ui.position;

var _time_elapsed = 300; # 5 am

func _process(delta) -> void:
	update_clock(delta);
	update_ui();

func _hide_ui() -> void:
	if _villagers_numbers.visible:
		var tween = create_tween().set_parallel(true);
		tween.tween_property(_villagers_numbers, "modulate", Color.TRANSPARENT, 0.2)
		tween.tween_property(_villagers_numbers, "position", _villagers_numbers.position + Vector2(_villagers_numbers.size.x , 0), 0.2)
		tween.chain().tween_callback(_villagers_numbers.hide)

	if _clock_ui.visible:
		var tween = create_tween().set_parallel(true);
		tween.tween_property(_clock_ui, "modulate", Color.TRANSPARENT, 0.2)
		tween.tween_property(_clock_ui, "position", _clock_ui.position + Vector2(_clock_ui.size.x , 0), 0.2)
		tween.chain().tween_callback(_clock_ui.hide)

	_timer.stop();

func _on_timer_timeout():
	# fade in the followers banner
	_hide_ui();

func display_ui() -> void:
	# if is not visible, show it
	if not _villagers_numbers.visible:
		_villagers_numbers.show();
		var tween = create_tween().set_parallel(true);
		tween.tween_property(_villagers_numbers, "modulate", Color.WHITE, 0.2)
		tween.tween_property(_villagers_numbers, "position", _villagers_numbers_init_pos, 0.2)

	# also display the clock
	if not _clock_ui.visible:
		_clock_ui.show();
		var tween = create_tween().set_parallel(true);
		tween.tween_property(_clock_ui, "modulate", Color.WHITE, 0.2)
		tween.tween_property(_clock_ui, "position", _clock_ui_init_pos, 0.2)

	_timer.start(1.2);

func update_clock(delta):
	# update the clock formating the time to hours and minutes
	_time_elapsed += delta;
	var hours = floor(_time_elapsed / 60);
	var minutes = floor(fmod(_time_elapsed, 60));

	# if the hours are greater than 12, then it's pm
	if hours >= 12:
		# move de region rect x -16
		_am_pm.region_rect = Rect2(-16, 0, 32, 32);
	else:
		_am_pm.region_rect = Rect2(0, 0, 32, 32);

	# if its 20:00, game over
	if hours >= 20:
		display_game_over();
	_hour_number.text = str(hours).pad_zeros(2);
	_minute_number.text = str(minutes).pad_zeros(2);

func update_ui():
	# update the clock
	#_clock_ui.get_node("Clock").text = str(_player.time).pad_zeros(2) + ":00";
	# update the villagers numbers
	_red_number.text = str(GameManager.get_player_followers(0)).pad_zeros(2);
	_green_number.text = str(GameManager.get_player_followers(1)).pad_zeros(2);
	_blue_number.text = str(GameManager.get_player_followers(2)).pad_zeros(2);

	_current_number.text = str(GameManager.get_following_villagers()).pad_zeros(2);
	_total_number.text = str(GameManager.get_total_villagers()).pad_zeros(2);
	_sleeper_number.text = str(GameManager.get_sleeping_villagers()).pad_zeros(2);

func display_game_over() -> void:
	# display the game over screen
	#_game_over_screen.show();
	# Exit application
	get_tree().quit();
	pass;
