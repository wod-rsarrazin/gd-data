@tool
extends FileEditorContainer


@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var play_button: Button = %PlayButton
@onready var stop_button: Button = %StopButton


func init_control():
	texture_rect.visible = false
	
	play_button.icon = get_theme_icon("Play", "EditorIcons")
	play_button.pressed.connect(self.on_play_button_pressed)
	
	stop_button.icon = get_theme_icon("Stop", "EditorIcons")
	stop_button.pressed.connect(self.on_stop_button_pressed)
	
	super.init_control()


func on_play_button_pressed():
	audio_stream_player.play(0)


func on_stop_button_pressed():
	audio_stream_player.stop()


func update_value_no_signal():
	var value = sheet.values[lines[0].key][column.key]
	
	if value.split(".")[-1] in Properties.FILE_TYPES["Audio"]:
		audio_stream_player.stream = load(value)
		play_button.visible = true
		stop_button.visible = true
	else:
		audio_stream_player.stream = null
		play_button.visible = false
		stop_button.visible = false
