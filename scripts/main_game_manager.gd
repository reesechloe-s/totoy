extends Node

# Node References (Verify node names with your Integrator!)
@onready var timer_label: Label = $PhysicalViewport/PisoTimerLabel 
@onready var barya_label: Label = $PhysicalViewport/BaryaCountLabel

var is_game_active: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Update UI with starting values on load
	update_ui()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_game_active:
		return
		
	# Decrement Piso Timer every frame
	if GlobalData.piso_timer > 0:
		GlobalData.piso_timer -= delta
		update_timer_display()
	else:
		GlobalData.piso_timer = 0
		trigger_game_over()

func update_timer_display() -> void:
	# Convert seconds into MM:SS format
	var total_seconds: int = int(GlobalData.piso_timer)
	@warning_ignore("integer_division")
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func update_ui() -> void:
	update_timer_display()
	barya_label.text = str(GlobalData.barya_coins)

func trigger_game_over() -> void:
	is_game_active = false
	print("GAME OVER: Piso Time expired!")
	
func on_scenario_resolved(is_correct: bool, _tip_text: String) -> void:
	if is_correct:
		# Award Barya and bonus time
		GlobalData.barya_coins += 10
		GlobalData.piso_timer += 15.0
		print("Correct choice! +10 Barya, +15s Time")
	else:
		# Apply time penalty
		GlobalData.piso_timer -= 30.0
		print("Incorrect choice! -30s Time")
		
	update_ui()
