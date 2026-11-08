extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	$MenuBackground/VBoxContainer/ResumeButton.pressed.connect(resume)
	$MenuBackground/VBoxContainer/QuitButton.pressed.connect(get_tree().quit)
	
	for button in $MenuBackground/VBoxContainer.get_children():
		if button is Button:
			button.pressed.connect($ClickSound.play)
			button.mouse_entered.connect($Scroll1.play)
			button.focus_entered.connect($Scroll1.play)
	
func resume():
	get_tree().paused = false
	$Minimize.play()
	hide()
	
func pause():
	get_tree().paused = true
	show()
	$Maximize.play()
	$MenuBackground/VBoxContainer/ResumeButton.grab_focus()
	
func toggle():
	if get_tree().paused:
		resume()
	else:
		pause()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle()
		get_viewport().set_input_as_handled()
