extends Control

# Time zones configuration (UTC offset in hours)
var timezones = {
	"UTC": 0,
	"New York (EST)": -5,
	"London (GMT)": 0,
	"Paris (CET)": 1,
	"Tokyo (JST)": 9,
	"Sydney (AEDT)": 11,
	"Los Angeles (PST)": -8,
	"Dubai (GST)": 4,
	"São Paulo (BRT)": -3,
	"India (IST)": 5.5
}

@onready var clock_container = VBoxContainer.new()
var clock_labels = {}
var update_timer = 0.0

func _ready():
	# Setup container
	clock_container.name = "ClockContainer"
	add_child(clock_container)
	
	# Create title
	var title = Label.new()
	title.text = "WORLD TIME"
	title.add_theme_font_size_override("font_size", 32)
	clock_container.add_child(title)
	
	# Create clock for each timezone
	for timezone_name in timezones.keys():
		var label = Label.new()
		label.name = timezone_name
		label.add_theme_font_size_override("font_size", 24)
		clock_container.add_child(label)
		clock_labels[timezone_name] = label
	
	# Styling
	modulate = Color.WHITE
	set_anchors_preset(Control.PRESET_CENTER)

func _process(delta):
	update_timer += delta
	
	# Update clock every 0.1 seconds
	if update_timer >= 0.1:
		update_clock()
		update_timer = 0.0

func update_clock():
	var current_time = Time.get_ticks_msec() / 1000.0
	var dict_time = Time.get_time_dict_from_system()
	
	for timezone_name in timezones.keys():
		var offset = timezones[timezone_name]
		
		# Calculate timezone time
		var tz_hour = dict_time["hour"] + int(offset)
		var tz_minute = int(offset * 60) % 60
		
		# Handle day overflow
		if tz_hour >= 24:
			tz_hour -= 24
		elif tz_hour < 0:
			tz_hour += 24
		
		# Format time string (HH:MM:SS)
		var time_string = "%02d:%02d:%02d" % [tz_hour, dict_time["minute"], dict_time["second"]]
		
		# Update label
		clock_labels[timezone_name].text = "%s: %s" % [timezone_name, time_string]

# Optional: Add ability to add custom timezones
func add_timezone(name: String, utc_offset: float):
	timezones[name] = utc_offset
	var label = Label.new()
	label.name = name
	label.add_theme_font_size_override("font_size", 24)
	clock_container.add_child(label)
	clock_labels[name] = label

# Optional: Remove timezone
func remove_timezone(name: String):
	if name in timezones:
		timezones.erase(name)
		if name in clock_labels:
			clock_labels[name].queue_free()
			clock_labels.erase(name)
