# this is a separate obj node whatever u wanna call it that
# controls the hud/gui elements since otherwise there's kinda a
# lot going on in one of them


extends Area2D

# this keeps track of the playing bar itself (which managed everything
# else for the most part when it comes to settings except for drawing)
@onready var playingBar = get_parent().get_node("PlayingNode");

# this stores each of the keys' sprites on the
# computer keyboard for showing your own inputs (these get edited as you
# remap controls, but the array gets populated in this node's ready function below)
@onready var compyKeyboardSprites = []
# this stores the position to draw each key based on which
# keyboard button is assigned to it
@onready var keyboardChords = []

# this is a 3D array, where the first val is the menu that stores the button,
# the 2nd is the sprite, and the 3rd is the label for what gets 
# drawn on screen (then this gets indexed using hashkeys since I 
# needed some way to iterate for initialization and also map ~, but
# leaving this mark here incase I want to change this)
# (these are what value in the first index maps to what menu)
# [0] = main
# [1] = remap
# [2] = tracks
# [3] = save
# [4] = load
# [5] = selecting notes
# [6] = editing (selected) notes
@onready var actionsForEachMenu = [[],[],[],[],[],[],[]]


# this dictionary (hashmap) stored each keycode for each key on the keyboard
# and the array index for the sprite that actually gets drawn

# basic idea behind where the names for the dictionary came from:
	# if the input has a left and right version (like shift or ctrl), the
	# input's name in the dictionary is "[input's keycode] [1/2, 1 for left 2 for right]"
	# like "Shift 1" is left shift (inputs without them are just their own name)
	# would normally use only the name's of each key, but pausebreak's
	# physical key is interpreted as numlock (which is a different key)
	# and if we just use the unicode without the location, then
	# both shifts n ctrls or whatever are interpreted as the same input
	# (this method gives u the most amount of keys to use, while making
	# it easy for me to add more keyboards later)
	
	# ~ [bug] slight update on this, godot don't work with adding action's
	# directions durring run time (leaving this comment here to remind
	# myself to report, and the map that obeys what is described above
	# is at the bottom of this file, using a different map for now
	# b/c this). 
	# ~ trying to get it to be
	# where the dictionary stores the sprite that gets loaded, and
	# the maybe the label that actually gets drawn since we just
	# need to iterate thru the actions and map based on that. Considering
	# also doing the number for the keyboard's key position initially
	# as well, but maybe we just have something else set that manually
	# or store it as a 3rd val (either way need to change stuff in both
	# scripts, and also there's a bug with remapping rn (but that
	# might b from these changes))
	# ^ nvm just made it so the array that stores the two drawables
	# can be indexed by these: next is prob to make text more readable
	# and maybe try to see if u can use symbols instead (prob just a switch
	# check for if its a word and what symbol to use)
@onready var hashKeys = {
	"Escape" : 0,
	"F1" : 1,
	"F2" : 2,
	"F3" : 3,
	"F4" : 4,
	"F5" : 5,
	"F6" : 6,
	"F7" : 7,
	"F9" : 8,
	"F10" : 9,
	"F11" : 10,
	"F12" : 11,
	"ScrollLock" : 12,
	"QuoteLeft" : 13,
	"1" : 14,
	"2" : 15,
	"3" : 16,
	"4" : 17,
	"5" : 18,
	"6" : 19,
	"7" : 20,
	"8" : 21,
	"9" : 22,
	"0" : 23,
	"Minus" : 24,
	"Equal" : 25,
	"Backspace" : 26,
	"Insert" : 27,
	"Home" : 28,
	"PageUp" : 29,
	"NumLock" : 30,
	"Kp Divide" : 31,
	"Kp Multiply" : 32,
	"Kp Subtract" : 33,
	"Tab" : 34,
	"Q" : 35,
	"W" : 36,
	"E" : 37,
	"R" : 38,
	"T" : 39,
	"Y" : 40,
	"U" : 41,
	"I" : 42,
	"O" : 43,
	"P" : 44,
	"BracketLeft" : 45,
	"BracketRight" : 46,
	"BackSlash" : 47,
	"Delete" : 48,
	"End" : 49,
	"PageDown" : 50,
	"Kp 7" : 51,
	"Kp 8" : 52,
	"Kp 9" : 53,
	"Kp Add" : 54,
	"CapsLock" : 55,
	"A" : 56,
	"S" : 57,
	"D" : 58,
	"F" : 59,
	"G" : 60,
	"H" : 61,
	"J" : 62,
	"K" : 63,
	"L" : 64,
	"Semicolon" : 65,
	"Apostrophe" : 66,
	"Enter" : 67,
	"Kp 4" : 68,
	"Kp 5" : 69,
	"Kp 6" : 70,
	"Shift" : 71,
	"Z" : 72,
	"X" : 73,
	"C" : 74,
	"V" : 75,
	"B" : 76,
	"N" : 77,
	"M" : 78,
	"Comma" : 79,
	"Period" : 80,
	"Slash" : 81,
	"Up" : 82,
	"Kp 1" : 83,
	"Kp 2" : 84,
	"Kp 3" : 85,
	"Kp Enter" : 86,
	"Ctrl" : 87,
	"Windows" : 88,
	"Alt" : 89,
	"Space" : 90,
	"Menu" : 91,
	"Left" : 92,
	"Down" : 93,
	"Right" : 94,
	"Kp 0" : 95,
	"Kp Period" : 96
}

# this dictionary has each of the sprites that are assigned to each
# of the different Actions, the compyKeyboardSprites array will parse
# this dictionary as inputs get remapped and refrence these for what
# sprite to draw

 # ~ adding these in rn, this stores the sprite for the action
# and keeps track of which menus the action (more specficically 
# the on screen button) needs to be drawn for (instead of filling
# up the whole screen with a bunch of keyboard keys)
# [0] = main
# [1] = remap
# [2] = tracks
# [3] = save
# [4] = load
# [5] = selecting notes
# [6] = editing (selected) notes
@onready var VariablesForActions = {
	"TeleportPlayingBar" : ["Assets/Sprites/IconSprites/invisiblegrapes.png", [0]] ,
	"LeftAction" : ["Assets/Sprites/IconSprites/left.png", [0,1,2,5,6]] ,
	"RightAction" : ["Assets/Sprites/IconSprites/right.png", [0,1,2,5,6]] ,
	"SaveAction" : ["Assets/Sprites/IconSprites/save.png", [0]] ,
	"EnterAction" : ["Assets/Sprites/IconSprites/enter.png", [0,1,2,3,4,5,6]] ,
	"LeftClick" : ["Assets/Sprites/IconSprites/invisiblegrapes.png", [0]] ,
	"UpAction" : ["Assets/Sprites/IconSprites/up.png", [0,1,2,5,6]] ,
	"DownAction" : ["Assets/Sprites/IconSprites/down.png", [0,1,2,5,6]] ,
	"DecSizeAction" : ["Assets/Sprites/IconSprites/decreaseNoteLength.png", [0,2,6]] ,
	"IncSizeAction" : ["Assets/Sprites/IconSprites/increaseNoteLength.png", [0,2,6]] ,
	"CopyAction" : ["Assets/Sprites/IconSprites/copy.png", [0]] ,
	"ForteAction" : ["Assets/Sprites/IconSprites/forte.png", [0,2,6]] ,
	"PianoAction" : ["Assets/Sprites/IconSprites/piano.png", [0,2,6]] ,
	"trackUpAction" : ["Assets/Sprites/IconSprites/trackAbove.png", [0,6]] ,
	"trackDownAction" : ["Assets/Sprites/IconSprites/trackBelow.png", [0,6]] ,
	"MoveToAction" : ["Assets/Sprites/IconSprites/moveto1.png", [0,6]] ,
	"SelectAll" : ["Assets/Sprites/IconSprites/selectAll1.png", [0]] ,
	"SelectPast" : ["Assets/Sprites/IconSprites/selectPast1.png", [0]] ,
	"TransposeAction" : ["Assets/Sprites/IconSprites/invisiblegrapes.png", [0]] ,
	"Note C" : ["Assets/Sprites/IconSprites/noteC.png", [0]] ,
	"Note C Sharp" : ["Assets/Sprites/IconSprites/noteCsh.png", [0]] ,
	"Note D" : ["Assets/Sprites/IconSprites/noteD.png", [0]] ,
	"Note D Sharp" : ["Assets/Sprites/IconSprites/noteDsh.png", [0]] ,
	"Note E" : ["Assets/Sprites/IconSprites/noteE.png", [0]] ,
	"Note F" : ["Assets/Sprites/IconSprites/noteF.png", [0]] ,
	"Note F Sharp" : ["Assets/Sprites/IconSprites/noteFsh.png", [0]] ,
	"Note G" : ["Assets/Sprites/IconSprites/noteG.png", [0]] ,
	"Note G Sharp" : ["Assets/Sprites/IconSprites/noteGsh.png", [0]] ,
	"Note A" : ["Assets/Sprites/IconSprites/noteA.png", [0]] ,
	"Note A Sharp" : ["Assets/Sprites/IconSprites/noteAsh.png", [0]] ,
	"Note B" : ["Assets/Sprites/IconSprites/noteB.png", [0]] ,
	"Remap" : ["Assets/Sprites/IconSprites/invisiblegrapes.png", [0]] ,
	"tempoUp" : ["Assets/Sprites/IconSprites/invisiblegrapes.png", [0]] ,
	"tempoDown" : ["Assets/Sprites/IconSprites/invisiblegrapes.png", [0]] ,
	"RecordAction" : ["Assets/Sprites/IconSprites/invisiblegrapes.png", [0,3]] ,
	"ExitAction" : ["Assets/Sprites/IconSprites/exit.png", [0,1,2,3,4,5,6]] ,
	"PauseAction" : ["Assets/Sprites/IconSprites/pause.png", [0]] ,
	"ReturnAction" : ["Assets/Sprites/IconSprites/return1.png", [0]] ,
	"SwitchTrackAction" : ["Assets/Sprites/IconSprites/switchTracks.png", [0]] ,
	"SelectAdjustAction" : ["Assets/Sprites/IconSprites/selectAll1.png", [0]] ,
	"LoadAction" : ["Assets/Sprites/IconSprites/save.png", [0]] ,
	"TactileAction" : ["Assets/Sprites/IconSprites/invisiblegrapes.png", [0]] 
}

# the sprite (not the image file, but the data on what to draw for 
# the icon (like ye the image but also coords n colors)) and the
# button label are put in their own map (to know which label coresponds
# to which icon)
@onready var mappingsSpritesNText = {}

# this var keeps track of which button should have focus
@onready var focusKeyIterator = 0

# this function changes which of the keys are onscreen when
# you switch menus
func _switch_menu():
	pass

func _ready():
	var keyDrawYOffset = 60
	var keyDrawXOffset = 0
	for ii in range(55):
		

		
		# default textures are invisible unless assigned to an action
		# (described below on start up, and in the remapping code in 
		# the PlayingNote script)
		var image = Image.load_from_file("Assets/Sprites/IconSprites/invisiblegrapes.png")
		# this stores the text (a bit below) for each of the keys
		# to tell the computer what to draw (for each input)
		var buttonText = ""
		
		# if the key is already mapped then find what action its
		# mapped to and load up the correct sprite (instead of
		# the blank one ~ for future me this can prob be 
		# optimized a bit with an extra array or somth, but since
		# its being called only on boot up its pretty ok tbh)
		#var inputShortcut = InputEventKey.new()
		var actionShortcut = null#InputEventKey.new()
		
		var inputShortcut = null

		# ~ [bug] Want to find a more permanent fix for making it so 
		# this iterate doesn't have to be manually changed with each 
		# update to Godot that adds new default inputs (this for loop iterate
		# through the custom inputs used by this project)


		# check each of the actions (these are the ones defined at the
		# start of the project, changed from the godot menu/read from
		# the settings save file (when thats added, not rn))
		inputShortcut = InputMap.action_get_events(InputMap.get_actions()[78 + ii])[0]
		# if the action is a key (to check the keycode) and matches the
		# current sprite we are trying to set the image of, then look up
		# which sprite is used for the assigned action
		if inputShortcut is InputEventKey:
			if hashKeys.get( inputShortcut.as_text_physical_keycode() ) != null:
				# this stores the name of the action that is assigned to the input
				# which is used later for the onscreen buttons
				# (action shortcut gets set after checking if the input exists
				# since we use this var below after the for loop)
				actionShortcut = InputMap.get_actions()[78 + ii]
				# we then actually get the image to load for the button
				image = Image.load_from_file(VariablesForActions.get(actionShortcut)[0])
				# aside from getting the image, we also get the button label here.
				buttonText = inputShortcut.as_text_physical_keycode()

				# ~[feature] this determines the position to place the buttons at by
				# default. Would like to make it so they can be customized (also
				# marking this as a feature since the idea is that any changes a musician
				# makes to the on screen positions should be saved in the config file)
				var keyPosition = hashKeys.get( inputShortcut.as_text_physical_keycode() )
				if keyPosition <= 13:
						keyDrawYOffset = -50
						keyDrawXOffset = keyPosition
				if 13 <= keyPosition && keyPosition < 34:
						keyDrawYOffset = 100
						keyDrawXOffset = keyPosition - 13	
				if 34 <= keyPosition && keyPosition < 55:
						keyDrawYOffset = 250
						keyDrawXOffset = keyPosition - 34
				if 55 <= keyPosition && keyPosition < 71:
						keyDrawYOffset = 400
						keyDrawXOffset = keyPosition - 55
				if 71 <= keyPosition && keyPosition < 87:
						keyDrawYOffset = 550
						keyDrawXOffset = keyPosition - 71
				if 87 <= keyPosition && keyPosition <= 96:
						keyDrawYOffset = 700
						keyDrawXOffset = keyPosition - 87




		# once the texture has been determined, then it gets set
		# to the corresponding sprite / other deets like the position
		# of the sprites are also set
		var texture = ImageTexture.create_from_image(image)
		var hudTest = Sprite2D.new()
		hudTest.texture = texture
		
		# the text for the buttons is set here
		var buttonLabel = Label.new()
		# ~ investigate with using theme properties for this instead
		# of setting it here (saw that that was an option on the docs
		# but like unsure if its computationally cheaper than this rn)
		buttonLabel.modulate = Color(0, 0, 0, 1)
		buttonLabel.scale.x = 4
		buttonLabel.scale.y = 4
		# this make the text the coresponding symbol if necessary
		# since otherwise it just prints the word and it looks a bit wack
		# (godot titles the inputs as the respective words, which is
		# what we index them by normally, but for display I like
		# some of these since they are a bit more readable than the full
		# words)
		match buttonText:
			"Semicolon":
				buttonText = ";"
			"Escape":
				buttonText = "Esc"	
			"ScrollLock":
				buttonText = "ScrlLock"
			"QuoteLeft":
				buttonText = "`"
			"Minus":
				buttonText = "-"
			"Equal":
				buttonText = "="
			"BracketLeft":
				buttonText = "["
			"BracketRight":
				buttonText = "]"	
			"Comma":
				buttonText = ","				
			#"BackSlash":
				#buttonText ="\\"			
		
		buttonLabel.text = buttonText
		
		# this creates the selectable buttons for each of the actions
		# (as in the ones you can press via mouse or with focus)
		var focusButton = Button.new()
		
		

		# this stores the coords for the key so if a user
		# remaps an action, the position as to where it gets 
		# drawn is stored
		keyboardChords.append([keyDrawXOffset,keyDrawYOffset])
		
		# then the X and Y for each of these gets set
		hudTest.global_position.x = -1450 + (keyDrawXOffset * 210)
		hudTest.global_position.y = keyDrawYOffset 
		
		buttonLabel.global_position.x = hudTest.global_position.x
		buttonLabel.global_position.y = hudTest.global_position.y
		
		focusButton.global_position.x = hudTest.global_position.x
		focusButton.global_position.y = hudTest.global_position.y 
		# ` ~ [feature] would like some option to make buttons invisible when they arent
		# being used since obv it makes the screen look more busy (this was
		# also just test text to see that every button was being put on screen)
		focusButton.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		focusButton.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			
		# this is just a failsafe to make sure the actionShortcut
		# exists (and was originally included since this looped 
		# for each key instead of each action)
		if actionShortcut != null:
			focusButton.text = actionShortcut
			focusButton.icon = texture
			focusButton.visible = true
			# after the positions for both get set then they get stored 
			# (as children which loads them in, and to this array which
			# makes them easier to index later when u change inputs)
			#add_child(hudTest)
			add_child(buttonLabel)
			add_child(focusButton)
			
			# this sets the on screen button's functionality so you can
			# use those instead of needing to have access to each keyboard key
			# (can be pressed with mouse or itreated with focus, these functions
			# are defined below the on ready one here)
			focusButton.button_down.connect(_on_gui_button_pressed.bind(actionShortcut))
			focusButton.button_up.connect(_on_gui_button_released.bind(actionShortcut))
			
			# this sets the screen reader text for the focus button
			focusButton.accessibility_description = str(actionShortcut) + " mapped to " + str(InputMap.action_get_events(actionShortcut)[0].as_text())
			
			# adds the button to the list of menu buttons so when
			# drawing all of them the program knows which ones to 
			# peak at (this first if checks if the key has an associated
			# action or not)
			compyKeyboardSprites.append([hudTest,buttonLabel,focusButton])



# this is the function that gets called when the on screen buttons are
# pressed (aka if you focus thru the screen inputs or click them with a mouse
# tho the code for each of these actions is in the playingNode)
func _on_gui_button_pressed(guiActionName):
	if guiActionName != null:
		Input.action_press(guiActionName)

# same idea as above, but for the releasing of a button
func _on_gui_button_released(guiActionName):
	Input.action_release(guiActionName)
	

# this moves the sprites to keep up with the playing bar (so they stay on screen)
func _process(delta: float) -> void:
	position.x = playingBar.position.x
	position.y = playingBar.position.y

	# this is used to let you iterate n focus thru all of the buttons
	# ` putting a checkpoint here since I would like to use focus_next
	# above (or at least consider it), but unsure if it is bugged or something
	# I'm not quite understanding. Either way, part of the motivation
	# for using this array method anyways is that otherwise you would
	# have to iterate through every key in every menu, but not every
	# menu uses every key, and we would have to reset the focus_next for
	# each button upon doing that so instead these lists only have the buttons
	# for each action
	# ` also putting this here to sum the above part and say that instead of
	# using the compyKeyboardarray exactly, we should try to index using a similar
	# data structure to the narration player since that uses each of the menus
	# anyways (maybe can be literally the same structure, but making another
	# for intuitiveness/readability wouldn't hurt since they use like the
	# same amount of storing of nodes anyways)
	# ^ in the middle of implementing this, made compyKeyboard a 3d array
	# next thing is to keep track of the menu that the user is in/
	# make the other keys invisible, but for now, just do the
	# screen reader to proof of concept that part
	# Taking a break for a bit, but the idea is instead of having
	# an array of each of the keyboard buttons, just having an
	# array of the keyboard keys and letting you remap those
	# (likely needs another array to store the cords of all
	# the keyboard keys for drawing them on screen, but this
	# means we store much less and remapping just changes where
	# the on screen button is and what key does the action
	# of the newly mapped option)
	# ^ problem is that the way how we index the action is thru
	# the keyboard key pressed, so indexing the smaller
	# array causes errors (would need a way to find the key
	# associated with the input being switched for this
	# to work, which might not be easily possible unless
	# kinda doing what's already in place so unsure if 
	# we do this, really depends on if there is an easy
	# way to do it or not)
	if Input.is_action_just_released("FocusAction"):
		if compyKeyboardSprites[focusKeyIterator][2].visible == true:
			compyKeyboardSprites[focusKeyIterator][2].grab_focus()
			focusKeyIterator += 1
			if focusKeyIterator >= compyKeyboardSprites.size():
				focusKeyIterator = 0

# this code below is unused, but keeping it here incase we change
# what's up with the mappings n stuff



#func _draw():
	# this draws the sprites for each of the inputs that the user has based on
	# whatever menu they are currently in
	
	# mainMenu (not in any specific menu)
	#if playingBar.inMenu == false:
		# this iterates through all of the actions and displays them
		#for i in range(40):
			# first it gets the keycode of the action (the ID for which keyboard
			# key you have the action mapped to) ...
			#if InputMap.action_get_events(InputMap.get_actions()[78 + i])[0] is InputEventKey:
				#print(  InputMap.action_get_events(InputMap.get_actions()[78 + i])[0].get_physical_keycode()  )

				# ^use maps instead of array since some of these are large (map contains coords for where
				# the sprite is drawn, and name of actions can also be mapped to the sprite itself)
			# ... and then it draws the sprite based on which action is being asigned
			# and the coords are determined by where it is positioned on a keyboard
			# (using mine as a refrence so if there are any discrepencies thats why)

			# check out these (the docs for what I'm trying to do, these are dictionaries
			# or hashmaps if u want more info)
			# https://docs.godotengine.org/en/stable/tutorials/best_practices/data_preferences.html
			# https://docs.godotengine.org/en/stable/classes/class_dictionary.html
			# ^ I think the dictionary also has to be updated on remap so make sure to add that too


			#draw_texture(texture,Vector2(-800 + (i * 20), position.y - 40),Color(0,0,0,0.5))

			#texture._draw(self,Vector2(-800 + (i * 20),position.y - 40),Color(1,1,1,0.5),false)

#@onready var hashKeys = {
	#"Escape 4194305 0" : 0,
	#"F1 4194332 0" : 1,
	#"F2 4194333 0" : 2,
	#"F3 4194334 0" : 3,
	#"F4 4194335 0" : 4,
	#"F5 4194336 0" : 5,
	#"F6 4194337 0" : 6,
	#"F7 4194338 0" : 7,
	#"F9 4194340 0" : 8,
	#"F10 4194341 0" : 9,
	#"F11 4194342 0" : 10,
	#"F12 4194343 0" : 11,
	#"ScrollLock 4194331 0" : 12,
	#"NumLock 4194313 0" : 13,
	#"QuoteLeft 96 0" : 14,
	#"1 49 0" : 15,
	#"2 50 0" : 16,
	#"3 51 0" : 17,
	#"4 52 0" : 18,
	#"5 53 0" : 19,
	#"6 54 0" : 20,
	#"7 55 0" : 21,
	#"8 56 0" : 22,
	#"9 57 0" : 23,
	#"0 48 0" : 24,
	#"Minus 45 0" : 25,
	#"Equal 61 0" : 26,
	#"Backspace 4194308 0" : 27,
	#"Insert 4194311 0" : 28,
	#"Home 4194317 0" : 29,
	#"PageUp 4194323 0" : 30,
	#"NumLock 4194330 0" : 31,
	#"Kp Divide 4194434 0" : 32,
	#"Kp Multiply 4194433 0" : 33,
	#"Kp Subtract 4194435 0" : 34,
	#"Tab 4194306 0" : 35,
	#"Q 81 0" : 36,
	#"W 87 0" : 37,
	#"E 69 0" : 38,
	#"R 82 0" : 39,
	#"T 84 0" : 40,
	#"Y 89 0" : 41,
	#"U 85 0" : 42,
	#"I 73 0" : 43,
	#"O 79 0" : 44,
	#"P 80 0" : 45,
	#"BracketLeft 91 0" : 46,
	#"BracketRight 93 0" : 47,
	#"BackSlash 92 0" : 48,
	#"Delete 4194312 0" : 49,
	#"End 4194318 0" : 50,
	#"PageDown 4194324 0" : 51,
	#"Kp 7 4194445 0" : 52,
	#"Kp 8 4194446 0" : 53,
	#"Kp 9 4194447 0" : 54,
	#"Kp Add 4194437 0" : 55,
	#"CapsLock 4194329 0" : 56,
	#"A 65 0" : 57,
	#"S 83 0" : 58,
	#"D 68 0" : 59,
	#"F 70 0" : 60,
	#"G 71 0" : 61,
	#"H 72 0" : 62,
	#"J 74 0" : 63,
	#"K 75 0" : 64,
	#"L 76 0" : 65,
	#"Semicolon 59 0" : 66,
	#"Apostrophe 39 0" : 67,
	#"Enter 4194309 0" : 68,
	#"Kp 4 4194442 0" : 69,
	#"Kp 5 4194443 0" : 70,
	#"Kp 6 4194444 0" : 71,
	#"Shift 4194325 1" : 72,
	#"Z 90 0" : 73,
	#"X 88 0" : 74,
	#"C 67 0" : 75,
	#"V 86 0" : 76,
	#"B 66 0" : 77,
	#"N 78 0" : 78,
	#"M 77 0" : 79,
	#"Comma 44 0" : 80,
	#"Period 46 0" : 81,
	#"Slash 47 0" : 82,
	#"Shift 4194325 2" : 83,
	#"Up 4194320 0" : 84,
	#"Kp 1 4194439 0" : 85,
	#"Kp 2 4194440 0" : 86,
	#"Kp 3 4194441 0" : 87,
	#"Kp Enter 4194310 0" : 88,
	#"Ctrl 4194326 1" : 89,
	#"Windows 4194327 1" : 90,
	#"Alt 4194328 1" : 91,
	#"Space 32 0" : 92,
	#"Alt 4194328 2" : 93,
	#"Windows 4194327 2" : 94,
	#"Menu 4194370 0" : 95,
	#"Ctrl 4194326 2" : 96,
	#"Left 4194319 0" : 97,
	#"Down 4194322 0" : 98,
	#"Right 4194321 0" : 99,
	#"Kp 0 4194438 0" : 100,
	#"Kp Period 4194436 0" : 101
#}

#@onready var hashKeys = {
	#"Escape" : 0,
	#"F1" : 1,
	#"F2" : 2,
	#"F3" : 3,
	#"F4" : 4,
	#"F5" : 5,
	#"F6" : 6,
	#"F7" : 7,
	#"F9" : 8,
	#"F10" : 9,
	#"F11" : 10,
	#"F12" : 11,
	#"ScrollLock" : 12,
	#"QuoteLeft" : 13,
	#"1" : 14,
	#"2" : 15,
	#"3" : 16,
	#"4" : 17,
	#"5" : 18,
	#"6" : 19,
	#"7" : 20,
	#"8" : 21,
	#"9" : 22,
	#"0" : 23,
	#"Minus" : 24,
	#"Equal" : 25,
	#"Backspace" : 26,
	#"Insert" : 27,
	#"Home" : 28,
	#"PageUp" : 29,
	#"NumLock" : 30,
	#"Kp Divide" : 31,
	#"Kp Multiply" : 32,
	#"Kp Subtract" : 33,
	#"Tab" : 34,
	#"Q" : 35,
	#"W" : 36,
	#"E" : 37,
	#"R" : 38,
	#"T" : 39,
	#"Y" : 40,
	#"U" : 41,
	#"I" : 42,
	#"O" : 43,
	#"P" : 44,
	#"BracketLeft" : 45,
	#"BracketRight" : 46,
	#"BackSlash" : 47,
	#"Delete" : 48,
	#"End" : 49,
	#"PageDown" : 50,
	#"Kp 7" : 51,
	#"Kp 8" : 52,
	#"Kp 9" : 53,
	#"Kp Add" : 54,
	#"CapsLock" : 55,
	#"A" : 56,
	#"S" : 57,
	#"D" : 58,
	#"F" : 59,
	#"G" : 60,
	#"H" : 61,
	#"J" : 62,
	#"K" : 63,
	#"L" : 64,
	#"Semicolon" : 65,
	#"Apostrophe" : 66,
	#"Enter" : 67,
	#"Kp 4" : 68,
	#"Kp 5" : 69,
	#"Kp 6" : 70,
	#"Shift" : 71,
	#"Z" : 72,
	#"X" : 73,
	#"C" : 74,
	#"V" : 75,
	#"B" : 76,
	#"N" : 77,
	#"M" : 78,
	#"Comma" : 79,
	#"Period" : 80,
	#"Slash" : 81,
	#"Up" : 82,
	#"Kp 1" : 83,
	#"Kp 2" : 84,
	#"Kp 3" : 85,
	#"Kp Enter" : 86,
	#"Ctrl" : 87,
	#"Windows" : 88,
	#"Alt" : 89,
	#"Space" : 90,
	#"Menu" : 91,
	#"Left" : 92,
	#"Down" : 93,
	#"Right" : 94,
	#"Kp 0" : 95,
	#"Kp Period" : 96
#}
