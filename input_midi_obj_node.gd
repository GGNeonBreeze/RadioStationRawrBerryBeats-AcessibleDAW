extends Node2D

@onready var barX : float = 0.0

func _draw():
	var default_font = ThemeDB.fallback_font
	draw_string(default_font, Vector2(0, -90),str(barX),0, 60, 24)	
	draw_string(default_font, Vector2(0, -60),str(get_node("PlayingNode").global_position.x),0, 60, 24)	

func _process(delta):
	barX = get_node("PlayingNode").global_position.x
	
	
