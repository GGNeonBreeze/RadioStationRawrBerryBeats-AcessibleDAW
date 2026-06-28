extends Area2D
class_name PlayBar2
# *Key * key ~ key ~key:

# ctrl f "`" for the most recently worked on thing
# and ctrl f "~" for known bugs (its okay to tag something as both)

# *user input
# *remap
# *fileRead *file *read *Read *load * load * read * Read
# *fileWrite *write Write *save * save *fileSave
# *undo
# *switch tracks *switchtracks *track *volume
# *select *delete
# *Play *PlayMusic * playing * play *playing * playMusic *play music * play music
# *mind

# * unsure if I need the ones above anymore, but keeping them incase
# this is an array that stores all of the noted being played currently (as
# in the midi instrument button for these notes is currently being held down
@onready var currentNotes = [];



# this keeps track of all the notes for when we wanna save to a file (each time escape is pressed)
@onready var saveNotes = [];
# this keeps track of each index for the note (for the save list, namely for note deletion
@onready var NoteID = 0;


# this gets the info for the audioplayer (maybe okay to remove this, cuz I'm having the
# notes play their own sfx now)
@onready var _AudioStreamPlayer = $AudioStreamPlayer
# this sets the audio bus, this is where the audio files actually come from
# and where different effects (eq, recording (to audio file), etc.) can be applies
@onready var masterBus = AudioServer.get_bus_index("Master")



# this saves the HUDnGUI node so its easier to access later (whenever u
# wanna change the HUDnGUI stuff)
@onready var HUDnGUI = get_parent().get_node("HUDnGUI");
# same idea but for the narration stuff
@onready var NarrationAudioPlayer = get_parent().get_node("NarrationAudioPlayer");



# this gets the camera for the cursor
@onready var _Camera = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# play / rec
	OS.open_midi_inputs()
	print(OS.get_connected_midi_inputs())
	 # layer the playing bar is on
	set_collision_layer_value(1, true)
	# the layer the bar is checking (more for seeing if notes are loaded correctly)
	set_collision_mask_value(2, true) 
	
	# sets the focus to the node used for
	# screen reader support
	$FocusReset.grab_focus()
	
	# this initializes the array of notes, expand it (make the range greater) if needed
	# (idk how many for my keyboard haven't counted yet oops)
	for i in range(105):
		currentNotes.append(null);

	# this sets the selector's collision to check for just notes (not 
	# get the playing bar in it, as well as not making it detectable
	# in other collision layers)
	# what the selector is checking for
	$TheSelector.set_collision_mask_value(2, true) 
	# what layer the selector is on
	$TheSelector.set_collision_layer_value(3, true) 	
	# removes the selector from the first layer
	$TheSelector.set_collision_layer_value(1, false) 
	

	
	
	
# this var checks if you are in any of the editing menus (like if ur trying to 
# save a file, remap, etc). The idea is when this is false u can enter new menus
# and when this is true it prevents you from typing normally from entering a new menu
@onready var inMenu: bool = false;
# checks if the user is recording the track
@onready var RecordingInProgress: bool = false;
# this is a bool to play back the track
@onready var PlayingInProgress: bool = false;
# gets the time that the track/midi note should be played (before accounting for
# changes due to time signatures)
@onready var PreSigUniversalTimer: int = 0;
# tempo (playback speed beets per min)
@onready var Tempo: int = 120;
# Time signature (how many beets per measure, more just for the metronome and
# keeping stuff on beet, notes can techincally be started/stopped in whatever
# the godot time intervals are
@onready var TimeSigNumer: int = 4;
@onready var TimeSigDenom: int = 4;
# this is the list for each of the universal times (frames) that 
# each pitch started playing
@onready var pitchRecStartList = [];
# this is the list for each of the universal times (frames) that 
# each pitch stopped playing
@onready var pitchRecStopList = [];
# more for debug / skimming through a song, but this can be changed to 
# go thru a song faster
@onready var PlayBackSpeed: int = 1;
# this checks if you are playing so you can pause (more specifically when enter has
# been released so a subsequent press unpauses)
@onready var ableToPause: bool = false;
# this stores each of the computer keyboard values if the user is playing
# with that keyboard
#@onready var CompKeyboardNoteMapping = [KEY_A,KEY_W,KEY_S,KEY_E,KEY_D,KEY_F,KEY_T,KEY_G,KEY_Y,KEY_H,KEY_U,KEY_J];
@onready var CompKeyboardNoteMapping = ["Note C","Note C Sharp","Note D","Note D Sharp","Note E","Note F","Note F Sharp","Note G","Note G Sharp","Note A","Note A Sharp","Note B"];



# load

# this loads the note objects (calling instantiate on this spawns then)
@onready var loadedNote = preload("res://Note.tscn")
# this checks if the (midi) file was loaded (true means no midi to load)
@onready var midiLoadCheck : bool = true
# checks if u are in the loading midi file menu
@onready var shiftingMidis : bool = false
# shifts the starting character for loading midi files (cuz its hard to
# tell when the instrument part ends, more of a debug/early build thing)
@onready var substringSkip : int = 8   

# save

# this is where the wav file gets saved to when u are trying to save it (
# this is what actually captures the audio and is the buffer that stores it
# pretty much ...
@onready var recordToFile
@onready var TheAudioEffectThatRecords = AudioEffectRecord
# ... and this controls the audio file itself after being written to a buffer
@onready var fileBeingRecorded = AudioStreamWAV
# this var checks if you are trying to enter in the name of a file to save
@onready var inSavingMenu: bool = false;
# this var checks specifically what u are trying to save 
# 0 meanssaving project
# 1 means saving to wav
@onready var saveFileType : int = 0
# this checks if the program is currently in the process of saving (prevents u
# from doing other actions while its saving)
@onready var isSaving : bool = false
# this stores the wav in runtime that you are saving to
@onready var saveToWav



# tracks

# This checks if ur in the trak shifting menu
@onready var shiftingTracks : bool = false
# this stores the tracks that you can shift thru
# (each value is each track, but the string stored is the instrument for each)
@onready var tracks = ["res://GenA3.mp3"];
# this checks if u are editing the name of the instrument (so as to not interrupt u)
@onready var searchForStrument : bool = false

# this keeps track of the current track
@onready var currentTrack = 0
# each track has a list that stores all the notes in it (used for quickly muting
# a track)
@onready var notesInTrack = [null]
# these are all of the color values for each of the tracks (not putting 
# a way to change them rn, just a means of giving them colors) evry
# three vals represents the rbg for each track
@onready var TrackColors = [0,1,1, 0.188,0.188,0.812 ,0.25,0.45,0 ,0.6,0.1,0.8 ,0.6,0.8,0, 0.24,0.1,0.98]
# this controls the volume of each track
@onready var TrackVolume = [-4.0]

# selector


# this stores the starting x vals of the selector (where u first left click)
@onready var StartXSelectCorner : int = 0
# this stores the starting y vals of the selector (where u first left click)
@onready var StartYSelectCorner : int = 0
# this stores all of the notes that have been selected
@onready var selNotes = []
# this determines if the player is adjusting the selector box itself 
@onready var adjustingSelector : bool = false
# this determines when which of the selected notes should be replayed
@onready var replaySelect : float = 0.0
# this is if u are editing the select box by typing in inputs, this var determines
# which of the dimensions you are changing
@onready var dimensionIterator : int = 0


# settings

# this is the var that lets you iterate through all of the actions 
# for when you want to remap them
@onready var remapIterator : int = 91
# this bool checks if you are in the remappingActions event (you are iterating 
# thru the actions to choose which one to remap)
@onready var remappingActions : bool = false;
# if this bool is true then the code will wait for your next input and map it
# to the one you selected
@onready var mapDisPleas : bool = false;



# misc

# this determines what the notes should display for transposing (see the note obj's 
# _draw event for more
@onready var transpose = 0
# this determines if the device (andriod only for now) should vibrate
# as notes are being played
@onready var tactileSound = false
# this bool determines if you are inputing values for the quick nav
@onready var quickNav : bool = false;
# this is used for a debug thing for printing the keys for assigning them
# to values for drawing the array of them (unused for user purposes)
@onready var countKeysForDebugVar : int = 0;
# this loads a dummy texture (just a blank one) for various clean up 
# stuff (namely to remove the previous input's icon when u remap)
@onready var invisibleLoad = Image.load_from_file( "res://Assets/Sprites/IconSprites/invisiblegrapes.png" )
@onready var invisibleGrapes = ImageTexture.create_from_image(invisibleLoad)
# this is a string that gets added to the front of the accessible
# description for the main menu if there are any additional details
# to be said when you return to the menu (namely for stuff like if
# a file was successfully loaded)
@onready var toAddToDescription : String = "";

# this function is for a couple of events that draw text (namely track shifting
# and file loading)
func _draw():
	
	# fixed the problem with the mouse controller stuff, but unsure whats up
	# with the tracks (try switching tracks while farther out)
	var default_font = ThemeDB.fallback_font
	if shiftingTracks == true:
		draw_string(default_font, Vector2(0 + 50, global_position.y - 40), str(currentTrack),0, 90, 22)

	draw_string(default_font, Vector2(0, global_position.y - 90), str(global_position.x),0, 90, 22)

	# if you are remapping actions
	if remappingActions == true:
		draw_string(default_font, Vector2(0, global_position.y + 40), str(InputMap.get_actions()[remapIterator]),0, -1, 22)
		draw_string(default_font, Vector2(0, global_position.y + 60), str(remapIterator - 91),0, -1, 22)
		

# *user input (part 1, midi keyboard)
# this event gets called each time there is an input ....
func _input(musician_input):
	# .. and specifically this if statement when
	# the input is from a midi device (keyboard inputs are handeled below in delta)
	# (main syntax for this is from:
	# https://docs.godotengine.org/en/stable/classes/class_inputeventmidi.html
	# )
	if musician_input is InputEventMIDI:

		# when the velocity = 0, that means that the note was released
		# so I start by saving an event when the note is first pressed (for
		# my keyboard, this is velocity = 90 * note to change this when making
		# a general release version of it), and saving the universal time (frame)
		# when the note was pressed
		
		# as I understand this funciton is only being ran when new inputs are detected
		# (not every frame), so I'm making a new array to store note's pitch
		# and frame it was played
		var NoteBundle = [musician_input.pitch, PreSigUniversalTimer];
		# based on if a note was pressed or released, the note bundle gets stored
		# into a different array (one for release and one for press, not in that order 
		# tho lol)
		if RecordingInProgress == true:

			if musician_input.velocity != 0:
				var a_note = loadedNote.instantiate();
				get_parent().add_child(a_note);
				a_note.growing = true;
				NoteID += 1
				a_note.MyNoteID = NoteID
				a_note.summonedX = position.x
				# the 12 is an offset to not make pitches too low for me
				a_note.pitch = -musician_input.pitch - 12
				a_note.volume = TrackVolume[currentTrack]
				# trying to pass in notes into tracks n stuff
				# also trying to figure this out (tired rn ctrlf ->, @onready var notesInTrack = [null])
				a_note.Instrument = tracks[currentTrack]
				a_note.track = currentTrack	
				a_note.noteColor = Color(TrackColors[( currentTrack * 3 ) % TrackColors.size()], TrackColors[( (currentTrack * 3) + 1 ) % TrackColors.size()], TrackColors[( (currentTrack * 3) + 2 ) % TrackColors.size()])							
				print(a_note.pitch)
				a_note.canPlay = true
				# maybe wanna toy around with the pitch stuff more to make it sound better obv
				# but otherwise started working on saving files (maybe wanna implement that other pitch
				# stuff too like in the demo as well)
				currentNotes[musician_input.pitch] = a_note
				saveNotes.append(a_note)
			# when the key is not being held
			if musician_input.velocity == 0:		
				currentNotes[musician_input.pitch].growing = false;
				pitchRecStopList.append(NoteBundle)
	elif musician_input is InputEventKey:
		
		# *remap

		# if u press the remapping actions button it puts you in the remapping menu
		if Input.is_action_just_pressed("Remap") && inMenu == false:
			$SubMenuScreenRead.accessibility_description = "you are now in the remap menu, actions:
				iterate forward by pressing " + str(InputMap.action_get_events("LeftAction")[0].as_text()) + " or backward by pressing " + str(InputMap.action_get_events("RightAction")[0].as_text()) + " through the different actions you can remap.
				press record, which is currently mapped to " + str(InputMap.action_get_events("RecordAction")[0].as_text()) + " or enter which is currently mapped to " + str(InputMap.action_get_events("EnterAction")[0].as_text()) + ", to select the action you want to remap.
				After selecting an action, the next button you press will be remapped to the one you assigned it to.
				Exit and return to the main menu by pressing " + str(InputMap.action_get_events("ExitAction")[0].as_text())
			$SubMenuScreenRead.grab_focus()
			remappingActions = true;
			inMenu = true;
		
		if remappingActions == true:
			# if the remappingActions is true when u have selected an input to remap, then
			# the next input pressed remaps that action
			if mapDisPleas == true:
				# if the musician iterates to the input, then they can remap it
				# this gets the name of the key from the previous event before it changes...
				var prevInputKeyPart = OS.get_keycode_string(InputMap.action_get_events(InputMap.get_actions()[remapIterator])[0].get_physical_keycode_with_modifiers())
				
				# this stores the key (keyboard button) for the prev action ...
				var prevInputEventKey = InputMap.action_get_events(InputMap.get_actions()[remapIterator])[0]
				# ... if the key that you are assinging an input to was used
				# by another input, then the two get swapped. This is done by
				# first finding the input (if there is one) and saving it ...
				var prevAction = ""
				var whichAction = 0
				var prevButtonIndex = -1
				for ii in InputMap.get_actions().size():
					# checks if ii is greater than 78 since the first 78 actions are
					# godot defaults, and I'm only concerned with remapping our own
					# that the music maker uses
					if (ii > 91) && (InputMap.action_has_event(InputMap.get_actions()[ii],musician_input) == true):
						prevAction = InputMap.get_actions()[ii]
						prevButtonIndex = ii - 91
					
				# .. if there is an action than swap it ...
				if prevAction != "":
					InputMap.action_erase_events(prevAction)
					InputMap.action_add_event(prevAction,prevInputEventKey)
				# .. regardless of if the new key was previously asigned to an
				# action, the new key is set to the action you want to map
				# it to
				InputMap.action_erase_events(InputMap.get_actions()[remapIterator]);
				InputMap.action_add_event(InputMap.get_actions()[remapIterator],musician_input)
				
				# this updates the visuals on the HUD n GUI
				# and swtich the on screen buttons
				
				#print(remapIterator - 91)
				#print(musician_input.as_text_physical_keycode())
				
				# the HUDnGUI has a method for calculating the 
				# position on screen to place the button based
				# on an index assigned to each button (using a 
				# dictionary for this instead of ascii codes since
				# its kinda larger, but might change it)
				var keyPosition = HUDnGUI.hashKeys.get( musician_input.as_text_physical_keycode() )
				var keyDrawYOffset = 0
				var keyDrawXOffset = 0
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
				
				keyDrawXOffset = -1450 + (keyDrawXOffset * 210)
				
				# ~ [feature] (The actual position is somewhat arbitrary
				# and based on my keyboard, so down to make
				# a feature where you can move them to any position, but I
				# like this for now for helping indicate which keyboard key maps
				# to which action)
				
				# after the position is found, we save the X to switch, and
				# move the new input to the previous one...
				var toSwitchX = HUDnGUI.compyKeyboardSprites[ remapIterator - 91  ][1].position.x
				HUDnGUI.compyKeyboardSprites[ remapIterator - 91  ][2].position.x = keyDrawXOffset
				
				# ... then if there is an input assigned to the previous button
				# that one gets moved to the X we saved just above ...
				if prevButtonIndex != -1:
					HUDnGUI.compyKeyboardSprites[ prevButtonIndex  ][2].position.x = toSwitchX				
					
				# ... after the X values get switched we do the same
				# thing again for the Y values.
				var toSwitchY = HUDnGUI.compyKeyboardSprites[ remapIterator - 91  ][1].position.y
				HUDnGUI.compyKeyboardSprites[ remapIterator - 91  ][2].position.y = keyDrawYOffset
				
				if prevButtonIndex != -1:				
					HUDnGUI.compyKeyboardSprites[ prevButtonIndex  ][2].position.y = toSwitchY				

				# resets vars that keep track of you remapping and being in
				# a menu (so as to let you use the buttons that you now remapped)
				mapDisPleas = false;
				remappingActions = false;
				inMenu = false;

			# pressing exit takes u out of the remapping actions window
			if Input.is_action_just_pressed("ExitAction"):
					mapDisPleas = false;
					inMenu = false;
					remappingActions = false;
		
		
		# [bug] Want to find a more permanent fix for making it so 
		# this iterate doesn't have to be manually changed with each  update to Godot that adds new default inputs (this for loop iterate
		# through the custom inputs used by this project)
		# ~ one known bug is newer versions of godot change the amount of
		# default inputs so if you try to make the project in a newer version
		# this will mess with a couple of things regarding the GUI buttons
		# so planning on changing this to instead iterate and check for the
		# first of our own specified inputs (investigating if there is a way
		# to just get a list with ONLY inputs made for the program, if not then
		# just gonna go with the aformentioned idea)
		
		 #after the first 77 (in this version of godot 4.4) we reach the actions
		 #for the midi making program, these were manually set my meh in dah project
		 #mapping for the project (the remapiterator var is set to 77 by default above
		 #and the max amount of actions is 116)		
			if Input.is_action_just_pressed("LeftAction"):
				remapIterator -= 1;
				HUDnGUI.compyKeyboardSprites[ remapIterator - 91  ][2].grab_focus()
				if remapIterator < 91:	
					remapIterator = 131		
			if Input.is_action_just_pressed("RightAction"):
				remapIterator += 1;
				HUDnGUI.compyKeyboardSprites[ remapIterator - 91  ][2].grab_focus()
				if remapIterator > 131:	
					remapIterator = 91	
			if Input.is_action_just_released("RecordAction") || Input.is_action_just_released("EnterAction"):
				mapDisPleas = true;
			
# this is a debug funciton from the midi example on the godot docs
# (leaving this in for testing pruposes as I only have a few midi
# devices to test with and this can help with figuring out problems on 
# your own. You need to call it in the Input function above if the _input(
# is a InputEventMIDI
func _print_midi_info(midi_event):
	print(midi_event)
	print("Channel ", midi_event.channel)
	print("Message ", midi_event.message)
	print("Pitch ", midi_event.pitch)
	print("Velocity ", midi_event.velocity)
	print("Instrument ", midi_event.instrument)
	print("Pressure ", midi_event.pressure)
	print("Controller number: ", midi_event.controller_number)
	print("Controller value: ", midi_event.controller_value)
	

# this function returns the user to the main menu and adds any additional
# info to the main menu description
func returnToMainMenu():
	# ` [bug] some screen readers read the keys that the user
	# is pressing outloud (which is fine on its own), but it 
	# makes the rest of the computer audio quieter (by default).
	# So while there will be full screen reader support,
	# I'm good to go back to the other audio idea here soon 
	# (wanna finish this up first since not all audio is 
	# recorded for that and it takes up a lot more file space)
	$FocusReset.clear()
	$FocusReset.accessibility_description = toAddToDescription + "you are now in the main menu, you can press/hold/toggle keys to play notes, this will create a note where the playing bar is currently located.
		You can also enter other menus here to adjust the settings/properties of the project. 
		You can use " + str(InputMap.action_get_events("FocusAction")[0].as_text()) + " to iterate through the different actions 
		and " + str(InputMap.action_get_events("EnterAction")[0].as_text()) + " to perform the action, or you can press the corresponding
		keyboard key that they are mapped to"
	$FocusReset.grab_focus()
	toAddToDescription = ""		
	pass

	
	# *fileRead *file *read *Read *load * load * read * Read	
func fileLoad():
		# big ideas with this is it lets the program read both midi files and
		# rawr berry project files (made it so the rawr berry files are mostly
		# formatted the same), its a little unfinished with full functionality
		# and it's possible that some midis might not work (or at least might
		# not be fully read), but this does get the note charting down
		position.x = 0

		# this stores info for all of the notes so they can be made (keeps track of the delta
		# start times for each note as they get played and subtracts it from the
		# delta end times when those get called)	
		var MidiNotes = [[]];
		
		# this is just for saving it to the customAssets directory
		# so you don't have to type that every time
		var loadFileName = "customAssets/" + $MidiFile.text
		
		for j in range(300):
			MidiNotes[0].append(null)

		# * if it crashes at some other points (beyond negative notes, still working on
		# ) might be a problem of different note events potentially (some do have pitch bend)
		var isMidi : int = loadFileName.rfind(".mid")
		
		# this stores the info of the music as a string right down dere
		var hexStringVer : String = ""
		
		# if the file is a midi file
		if isMidi != -1:
			var content = FileAccess.get_file_as_bytes(loadFileName)
			hexStringVer = content.hex_encode()
		# if the file is a project file (hex encoded with csv info on tracks)
		if isMidi == -1:
			var FileAsString = FileAccess.get_file_as_string(loadFileName)
		
			# this checks that the file exists, if it doesn't (or you just
			# don't type in anything I guess) then you exit the load menu
			if FileAsString == "":
				inMenu = false
				midiLoadCheck = true
				shiftingMidis = false
				toAddToDescription = FileAsString + " File not found in customAssets directory"
				returnToMainMenu()
				$MidiFile.clear()
				pass				
			

		# this makes it so mid files can be read, but for project files
		# their extra detail gets stored in csv (comma separated value) style
		# and if it is a project file, we wanna check out those extra deets
		# for them (tracks and volume sliders namely) before loading the notes
			FileAsString = FileAsString.split(",",true,0)
		# [0] = midi track info (notes)
		# [1] = volume sliders
		# [x] = if the size greater than or equal to 3 then the 
		# remaining items beyond [0] and [1] are the instrument 
		# file names


		# this sets the current track to be the new one
			currentTrack = tracks.size() - 1
	

			if FileAsString.size() >= 3:
				for i in range(FileAsString.size()):
					# this skips the first two items (the note and volume parts
					# of the file get skipped, to just count the amount of tracks, or 
					# rather every csv item after those two), just skipping them
					# for now to look at note data will consider looking at them later
					# (the biggest thing is we would need instrument audio files for
					# the program to use and don't really have a whole lot of those rn
					# ~ biggest thing to note is this means not every midi is gauranteed
					# to work, but all of the ones I have tested do)
				
					if i >= 2:
						if i > 2:
							# adds to teh prexisting tracks
							tracks.append("")
							TrackVolume.append(-1.0)


							# for each track added there is a new set of 
							# notes that can be placed on it
							MidiNotes.append([])
							for j in range(300):
								MidiNotes[MidiNotes.size() - 1].append(null);
						
						# if there is a file name then load it
						if FileAsString[i] != "":
							# this saves the files for each track
							tracks[i - 2] = FileAsString[i]
						# if there is no track load the default one
						else:
							tracks[i - 2] = "res://GenA.mp3"



			hexStringVer = FileAsString[0]
		# this converts each of the ascii chars into hex (useful for parsing the midi)

		# this is used to check when we reach the chars that indicate the end of the midi
		# * endString[0] is the equivalent of i-1, endString[1] = i-2, and so on
		# (in otherwords the farther it is in endString, the farther from the iterator)
		#var endString = ["0","0","0","0","0","0","0","0","0","0"]
		var TopTenChars: String = "___________"
		# based on the different track events, kinda want to get rid of 
		# the 00c0 ("A" with hiphen) or more specifically copy the track from
		# beyond that point and mess with the EventEnd vals cuz I think its off a bit
		# with 1,3 example I was using and not parsing that the same way for the
		# other files (also watch for the spacing on other events and such). FIXING
		# this might not make it work immediately after (cuz i'm just setting
		# x to delta time, and might need a bit more research as to that, but I think
		# theres a calc needed there (as I think its measuring ticks after the last event, but
		# relative to beats per min)
		
		# ~ (this might not be super relavent and was from me misinterpreting
		# how to read midis at first, but still technically another area where
		# I would like to test for midi support) 
			# problem is that the delta time vals in some files are greater than the largest
			# int val possible for godot (I suspect that it might mean I'm reading the ticks
			# incorrectly a bit, but based on the max possible time division vals it still looks
			# massive tbh) and what's happening is that they are looping around b/c their size
			# for now tempted to make each note have some default gap and size (ignoring the exact
			# times and going for more of a pitch n position thing (essentialy only checking for
			# times that are 0 for chords otherwise every new note is separated)) otherwise the
			# gameplan would be to break the files into chunks (deltarune mod by the max int size, to
			# store notes into chunk array) and when the playing bar is close to the next chunk it starts
			# loading notes for that chunk (might be nice for optimizing too)
		
		# ~ [bug] if files are not loading correctly its prob b/c the weebit string
		# is not splitting at the right spot (p sure this should be right for my files)
		# but might require some more manual checks for midis esp with their headers)
		# said in a comment above, but not every midi file is gauranteed to work
		# for these early pre alpha baby step builds
		var weebitShorterString = hexStringVer.substr(hexStringVer.find("00c0"))
		# this is for counting the delta time inbetween events
		var deltaTimeCountList = []
		# for delta time refrence, 240 is a quarter note in 120 time (4/4)
		var deltarune: float = 0.0
		# this checks for when we reach the first delta time while iterating thru 
		# the file (since the delta times are accumulative)
		var deltaStart = true
		# this checks where the last event ended (for knowing when to start
		# iterating for the neckts)
		var LastTrackEventEndedHere = 0
		# this is for checking if we are at the end of an event (not the position)
		var EventEnd = 0
		
		# iterator for going through the midi string (specifically storing the
		# last 4 chars, which is mostly for the ending, but also for initializing notes
		# n stuff
		var iterMidi = 0
		
		# mutes the audio while loading (cuz it kinda loudph)
		AudioServer.set_bus_mute(masterBus,true)
		
		TopTenChars = weebitShorterString.substr(0,10)

		# ~ entering the main file reading loop

		# for debug
		var eventCounter = 0
		
		
		# while the first
		

		# if we have not reached the end of the file
		while iterMidi < weebitShorterString.length():
			TopTenChars = weebitShorterString.substr(iterMidi,10)

			# if we have not reached the end of the file (cont, mayb slightly better way
			# to do but whatever)
			
			# delta time calc comes from here:
			# https://www.ccarh.org/courses/253/handout/vlv/
			
			# understanding the midi formatting comes from here:
			# https://web.archive.org/web/20141227205754/http://www.sonicspot.com:80/guide/midifiles.html
	
			
			if TopTenChars.length() >= 10:
				# the idea for midi files is that there are numbers that indicate
				# how long to wait between each event (note starts, note stops, pitch
				# bend, etc ~ not all events are implemented and are a possible area 
				# where some midis might not be read correctly in this build) ...
				var endOfDeltaChec = (TopTenChars[0].hex_to_int() * 16) + TopTenChars[1].hex_to_int()
				# ...  and to determine when we have reached the end of the time gap,
				# we check if the last two bytes add up to less than 128 (the idea is 
				# this lets us store larger and more variable size values while not
				# taking up as much space)
				if (EventEnd == 0) && (endOfDeltaChec < 128):
					var whichPitch = -TopTenChars[4].hex_to_int() * 16
					whichPitch -= TopTenChars[5].hex_to_int()

					# adds the last two vals
					deltaTimeCountList.append(TopTenChars[0].hex_to_int())
					deltaTimeCountList.append(TopTenChars[1].hex_to_int())

					# this calculates the deltarune for when the event needs to be played
					var toAdd: float = 0.0		
								
					# full explanation:	
					# i hex to int each byte, subtract 128 (continuation bit’s val) from that, and multiply by 128 for each byte this byte is from the last one (the last byte gets multiplied by 128^0, the 2nd to last byte gets multiplied by 128^1, etc).
					var calcingTime: float = 0.0;					
					for i in range(deltaTimeCountList.size()):
						# iterator increases again to skip over them for similar reasonse
						# explained below when the deltaTimeList is getting appended
						if (i % 2 == 0):
						# the math for this is that for each character it gets multipied by
						# 16 to the power of whatever and added to the sum
							calcingTime = 0
							calcingTime = (deltaTimeCountList[i] * 16)
							calcingTime += (deltaTimeCountList[i + 1])	
							# if not the final byte then subtract 128 (iteration bit)
							if i < deltaTimeCountList.size() - 2:					
								calcingTime -= 128

							# multiply based on where this byte is positioned
							calcingTime = calcingTime * (128 ** (((deltaTimeCountList.size() - i) / 2) - 1))

							toAdd += calcingTime
							
					# ~ [bug] not super fixating on this rn, but p sure this is where
					# there is a rounding problem with saving to files (the debating
					# test midi's first 5 delta times are 83d51b 8549 0 9059 8232 
					# while when saving them they are 83d51b 8549 0 9059 8231
					# its possible it could be b/c this (dividing by 250, just picked a number
					# to make it so the notes fit on the page well lol) but
					# either way when found, I think the best way to round up
					# would just be to subtract the int version of the time from
					# the float and if the result is >0 then add 1 to the float
					# (so if it rounds down then then it actually rounds up)
					# but I'm just suspecting its something here, may be else where
					toAdd = toAdd / 250

					# in hindsight could maybe change this var name, but 
					# it's funny (this determines the x position in the world
					# to spawn the note after running the calcs that read the 
					# difference from the file)
					deltarune += toAdd
				
					# * note on event
					if TopTenChars[2] == "9":
						eventCounter += 1

						# the notes aren't actually created here (they get made in the note off
						# event), but the time at which they are played gets saved as a refrence
						# for then (we can't make them as quickly now without the note end)

						# this stotes the time for when a note is being played
						MidiNotes[int(TopTenChars[3])][whichPitch] = deltarune

						# this counts the amount of chars included in this event
						# (important for finding the next event's delta time)
						EventEnd = 7
						# if this was the first event then we can start counting the delta
						# times (done below)
						deltaStart = false
						
						deltaTimeCountList.clear()
						# if this is NOT the start of the track events, the counter for where the 
						# previous track chunk ended also gets set here
						LastTrackEventEndedHere = iterMidi
						

					# *note off event
					elif TopTenChars[2] == "8":
						eventCounter += 1
						
						# double checks that the file is being read correctly and that
						# there actually was a note on event for the current pitch that 
						# is recieving a note off event
						if MidiNotes[int(TopTenChars[3])][whichPitch] != null:
							var a_note = loadedNote.instantiate();
							get_parent().add_child(a_note);
							# sets the pitch based on the two values
							# (the 12 is an offset that makes it so the pitches
							# aren't so low they can't be heard)
							a_note.pitch = whichPitch
							
							# this sets the time of the note based on the accumulated
							# delta times							
							a_note.length = (deltarune - MidiNotes[int(TopTenChars[3])][whichPitch])
							a_note.summonedX = MidiNotes[int(TopTenChars[3])][whichPitch]
							
							#if currentTrack + int(TopTenChars[3]) > tracks.size():
								#tracks.size()
							# puts the notes on the track relative to the current
							# track (if the current track is 2 when loading a note that's
							# on track 0 (according to the file) then that note gets loaded
							# to the 2nd track)
							#a_note.track = currentTrack + int(TopTenChars[3])
							# this just puts it on the default tracks (for now commenting as needed)
							a_note.track = int(TopTenChars[3])							
							a_note.Instrument = tracks[a_note.track]
							a_note.noteColor = Color(TrackColors[( a_note.track * 3 ) % TrackColors.size()], TrackColors[( (a_note.track * 3) + 1 ) % TrackColors.size()], TrackColors[( (a_note.track * 3) + 2 ) % TrackColors.size()])							

							
							# ~ [bug] (marking b/c not formally tested) gonna try volume stuff again here, for now making it so
							# FF = 0 and 00 = -19 (so midis can just have 1 as the volume
							# as their velocities by default are going to be 00 cuz thats
							# what I'm reading this as for now)
							var whichVol = TopTenChars[6].hex_to_int() * 16
							whichVol += TopTenChars[7].hex_to_int()
							
							# converts the hex val accordingly (FF = 255 -> gets converted
							# to (255/255 * 11) + 1)
							whichVol = whichVol / 255
							whichVol = (whichVol * 19) - 19
							a_note.volume = whichVol
							
							a_note.canPlay = false
							
							# this stores the notes for writing to a file
							saveNotes.append(a_note)
						
						# this counts the amount of chars included in this event
						# (important for finding the next event's delta time)
						EventEnd = 7
						# ig it needs this here anyways, but ig thats fine too
						deltaStart = false
					# put other events in their own if statemnts here

						deltaTimeCountList.clear()

						# if this is NOT the start of the track events, the counter for where the 
						# previous track chunk ended also gets set  here
						#if StartOfTrackEvents == false:
						LastTrackEventEndedHere = iterMidi
					# misc midi events with 2 params
					elif TopTenChars[2] == "a" || TopTenChars[2] == "b" || TopTenChars[2] == "e":
						EventEnd = 7
						# ig it needs this here anyways, but ig thats fine too
						deltaStart = false
						
						# ~ once all the events are done (copying an pasting
						# into statements cuz there can be instances of 002 (for an example)
						# which is not a midi event: 
						# this resets the count of the delta time number values
						deltaTimeCountList.clear()

						# if this is NOT the start of the track events, the counter for where the 
						# previous track chunk ended also gets set  here
						LastTrackEventEndedHere = iterMidi
						
					# ~ [feature/bug] (makring b/c not formally tested) same idea as above but for different sized events (both of these
					# will have more when we add these events, rn it just tries to 
					# skip them both and read the notes
					elif TopTenChars[2] == "d" || TopTenChars[2] == "c":
						EventEnd = 5
						deltaStart = false
						
						deltaTimeCountList.clear()

						LastTrackEventEndedHere = iterMidi

			# until we reach a transition (byte less than 128) in the file, we add up all of the values to
			# count up our detla time (technically this part happens b4 the part above, but
			# this is just for organization)
				else:
					# if we have reached the first event, we can accumulate the delta times now
					if deltaStart == false:
							# if this is 0 that means we have iterated past all of the event
							# chars and can start appending new chars into the deltaTimeList
						if EventEnd == 0:
							# since the delta time is a variable length, and the length is
							# determined each byte, I have to append each byte (two chars)...
							deltaTimeCountList.append(TopTenChars[0].hex_to_int())
							deltaTimeCountList.append(TopTenChars[1].hex_to_int())
							EventEnd = 1
						else:
							# if we have not fully iterated past the event, then we keep going
							# until we reach the delta time of the next event
							EventEnd -= 1
			iterMidi += 1

			# lets the notes know they can play now
			
			# ~ [bug] bug here where if u ctrl a and delete a track's notes and
			# then try loading stuff to the track it gets all messed up (think
			# its from the child nodes being deleted, but not being removed from 
			# the array
			for child in saveNotes:
				child.canPlay = true
			
		# these last statements finish loading the file
		midiLoadCheck = true
		# this unmutes the program to not make a crazy loud noise after
		# the notes all get placed (and moves the playing bar juuust in case
		# it were to play any of the loaded notess)
		while position.x < deltarune:
			position.x += 5000
		AudioServer.set_bus_mute(masterBus,false)
		position.x = 0
		$MidiFile.clear()
		toAddToDescription = "File Successfully Loaded"
		returnToMainMenu()

		print("finished loading file")




 # *save * save *filesave
func fileSave():
	# creates the file 
		var file = FileAccess.open("customAssets/" + $ProjectSave.text, FileAccess.WRITE)
	# this is the string we are going to write to the file (gets started here)
		var fileSaveString = "00c000"
	# this keeps track of data to determine what we write to the string above
		var savingArray = []
	
		for child in get_parent().get_children():

			if child is NoteClass:
			# ~ to save the file as a midi file (since I lokey already have
			# something that reads those), might need a means of making 
			# something check for track numbers, so kinda unsure on this
			# (depends on if u think making a separate file reader, or adding
			# some separation for tracks would be easier), my tip for separate
			# tracks would be to store each note's time in an array as preusual
			# but have an array of arrays for the track, so like
			# trackArray[_indexed_by_track_ [_indexed_by_note_[ _indexed_by_pitch ]]
			# ^ to get the vals
			#saveNotes.sort_custom(func(a,b): return (saveNotes[a].summonedX - (saveNotes[a].length / 2)) < (saveNotes[b].summonedX - (saveNotes[b].length / 2)))
			
			# slight update kinda just saving the time differently below
			# also make sure to change deltarune and the timecounter vars
			# to be doubles
			
			# this stores each note's on and off events
			# *the order of these is delta time (time relative to last event)

				# [0 = delta time (time relative to last event)]
				# [1 = note on (9) or off (8)]
				# [2 = track] * this is where midi channels are but for now just putting the track here ig
				# [3 = pitch]
				# [4 = x pos (real time when event takes place for ordering)]
				# [5 = volume, velocity (note off event only)	
						
				var saveEventOn = [0,9,0,0,0]
				var saveEventOff = [0,8,0,0,0,0]
						# note on event
				saveEventOn[4] = child.summonedX #+ (saveNotes[i].length / 2)
				saveEventOn[3] = String.num_int64( -child.pitch, 16)
				saveEventOn[2] = child.track
				savingArray.append(saveEventOn)
						
						# note off event
				saveEventOff[4] = child.summonedX + child.length
				saveEventOff[3] = String.num_int64( -child.pitch, 16)
				saveEventOff[2] = child.track
				# * for now saving volume as a note off event, but should
				# probably be saved as a note on thing (makes loading notes easier)
				saveEventOff[5] = child.volume
				
				savingArray.append(saveEventOff)
					# this sorts the events in order of which is first (using the x vals
					# smallest comes first)
				savingArray.sort_custom(func(a,b): return a[4] < b[4])
				# with all of the events sorted, the delta times from each event
				# is calculated
				
		var previousRealTime = 0;
		for i in range (savingArray.size()):
					# https://docs.godotengine.org/en/stable/classes/class_string.html#class-string-method-num-int64
					# use this to convert back into bits and just edit the string
					# like that (I think this can also turn a bino string into hex too ?)
					var versionOfdeltaSave: int = 0;
					versionOfdeltaSave = (savingArray[i][4] * 250) - previousRealTime

					var hexDeltaSave = String.num_int64(versionOfdeltaSave,2)
					# this saves the initial hex length so the for loop iterates
					# the correct amount of times
					var initialHexLength = hexDeltaSave.length()
					# ~ gets the time from the event to write into the file
					# marking this b/c the 250 comes from something I'm debating on
					# in the file read that has to do with the note sizes
					previousRealTime = (savingArray[i][4] * 250)
			
			
					# flips the bino string (iterates from right to left)		
					hexDeltaSave = hexDeltaSave.reverse()
					var every8 = 0
					for j in range(initialHexLength):
						# for every 8th bit from the back (we start at 0 so this
						# means when j is divisible by 7
						if every8 % 7 == 0 && every8 != 0:
							# ~ possible this could be off by one
							# in case something looks wrong double check
							if every8 < hexDeltaSave.length():
									# if this is the first set of 8 bits, insert a 0
									# (not continuation bit)
								if every8 == 7:

									hexDeltaSave = hexDeltaSave.insert(every8 ,"0")
									# if this is a different set of 8 put in a 1
									# (continuation bit, remember this is reveresed)
								else:# (j > 7) && ((j - 1) % 7 == 0):
									
									# remember we have to index every 8 bits
									# so while the 8th bit is 7, the next 8th bit
									# after is 15 so thats why there is a plus bitoffset
									# (literally just a problem b/c index counter starts at 0
									# also why I'm using every8 cuz apparently j += doesn't
									# work cuz its the iterator
									
										var bitOffset = every8 / 7
										hexDeltaSave = hexDeltaSave.insert(every8 + (bitOffset - 1),"1")
						every8 += 1	
					# if the total size of the bits is not divisible by 8 
					# add 0s to front (right side for now, but left side when
					# it gets reversed back) until it is
					while hexDeltaSave.length() % 8 != 0:
						hexDeltaSave = hexDeltaSave + "0"
					# set the first bit to be the continuation bit
					# if the total length is not 8
					if hexDeltaSave.length() > 8:
						hexDeltaSave[hexDeltaSave.length() - 1] = "1"
			
					# delta time is now in variable length value form, but is
					# in bits so this converts it back to hex, could not
					# find a built in thing for this in godot, so just doing it
					# the old fashioned way
					var binoTointToHexTime = 0
					for twoInt in range(hexDeltaSave.length()):
						if hexDeltaSave[twoInt] == "1":
							binoTointToHexTime += 2 ** twoInt
							
					# converting bino int to hex for writing
					binoTointToHexTime = String.num_int64(binoTointToHexTime,16)
					# makes sure that this is a byte
					if binoTointToHexTime.length() < 2:
						binoTointToHexTime = "0" + binoTointToHexTime
						
					# reverses back to correct way (debug)
					#hexDeltaSave = hexDeltaSave.reverse()

					# this saves the delta time				
					savingArray[i][0] = binoTointToHexTime

					
					# this prepares the string to write to the file
					# [0 = delta time (time relative to last event)]	
					fileSaveString = fileSaveString + savingArray[i][0]
					# [1 = note on (9) or off (8)]
					fileSaveString = fileSaveString + String.num_int64(savingArray[i][1],10)		
					# [2 = track] * this is where midi channels are but for now just putting the track here ig
					fileSaveString = fileSaveString + String.num_int64(savingArray[i][2],10)	
					# [3 = pitch]
					fileSaveString = fileSaveString + savingArray[i][3]							
					# these last two are for velocity, but I'm doing something
					# different for that tbh
					if savingArray[i][1] == 9:
						fileSaveString += "5a"
					if savingArray[i][1] == 8:
						
						# ~ worth noting that when changing this the max vol
						# is 0 and min is -19, def want some boundaries, but
						# lett u know in case for now so easier editing
						
						# this saves the volume of the note, using a reverse of
						# the reading algorithm. Note that this is currently in the
						# note off event, but in the release version should be
						# in note on cuz that's where midis normally store the 
						# velocity(volume) of the note (its just easier this way for now)
						var storeVol = savingArray[i][5]
						# this sets the bounds first for saving the vol
						# (not that it should be much greater than this tho tbh)
						if storeVol > 0:
							storeVol = 0
						if storeVol < -19:
							storeVol = -19
						
						# (spacing this out so the steps are easier to read, cuz order
						# of operations can be wacky sometimes)
						storeVol = storeVol + 19
						storeVol = storeVol / 11
						storeVol = storeVol * 255
						
						# this converts the now hex but actually decimal value into 
						# hex character
						var hexVol = String.num_int64(storeVol,16)
						
						# this makes sure that there's no one digit 
						# volumes
						if hexVol.length() == 1:
							hexVol = "0" + hexVol
						# just caps it incase something gets messed up
						# (was having some problems with this)
						# ~ idk if this works definatively, but def can save
						# the boobacking after adjusting teh volume (unusre if 
						# vol vals match tho)
						if hexVol.length() > 2:
							hexVol = "FF"
							
						fileSaveString = fileSaveString + hexVol
	
		# ends the file
		fileSaveString += "00ff2f00"

		# `~ (this is unimplemented rn) started some fileWrite stuff for tracks have not tested this
		# yet, but it looks like it works so yay (make sure u spell the file
		# correctly "tracktest1.txt", after this gets implemented wanna try putting
		# volum sliders in and then note mouse selection
		
		# this stores the info for volume sliders
		fileSaveString += ",,"
		
		# this stores the info for the track's instruments
		for i in range(tracks.size()):
				fileSaveString += tracks[i]
				# put a comma after the instruments get appended
				if i != tracks.size() - 1:
					fileSaveString += ","
		
		# wraps up the file save
		file.store_string(fileSaveString)
		get_node("FocusReset").grab_focus();
		isSaving = false
		inSavingMenu = false
		inMenu = false		
		$ProjectSave.clear()
		print("savingArrayfinished saving")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	# *fileRead *file *read *Read *load * load * read * Read

	# ~ uncomment for ref for midi reading
	
	# change this for debug
	#midiLoadCheck = true
	
	# toggle midi/project selecting menu
	if Input.is_action_just_pressed("LoadAction") && inMenu == false:
		shiftingMidis = true
		inMenu = true
		$MidiFile.accessibility_description = "You are now in the load file menu, 
			type the name of the file you wish to load up (the program currently works with midis (which are dot M I D files),
			and radio station rawr berry beats projects (which are dot R S R B T Z files)). 
			You can use control and V if it is copied to your clipboard. 
			Make sure the file is in the customAssets folder before trying to load it. 
			Once you have entered the name of the file press the enter action, which is currently mapped to" + str(InputMap.action_get_events("EnterAction")[0].as_text()) + " . 
			To exit this menu, You can press the exit action, which is currently mapped to " + str(InputMap.action_get_events("ExitAction")[0].as_text()) + " to exit the menu. 
			After loading a file, wait until you hear the file has been loaded, before continuing to edit, as it may take a bit."
		$MidiFile.grab_focus()
		
		
	# this lets you adjust the starting substring a bit cuz I'm unsure when some tracks
	# start exactly
	if shiftingMidis == true:
		# press esc to exit the menu
		if Input.is_action_just_pressed("ExitAction"):
			shiftingMidis = false
			inMenu = false
			$MidiFile.clear()
			$FocusReset.grab_focus()

	# when you have typed in the midi file it gets loaded
	if Input.is_action_just_pressed("EnterAction") && shiftingMidis == true: 
		midiLoadCheck = false
		shiftingMidis = false
		inMenu = false

	# if you are opening a file
	if midiLoadCheck == false:
		fileLoad()




	 # *undo
	
	# quickly undo the last set of saveNotes (includes undoing a midi file)
	#if Input.is_key_pressed(KEY_DELETE):
	if Input.is_key_pressed(KEY_CTRL) && Input.is_key_pressed(KEY_Z):	
		for i in range(saveNotes.size()):
			if saveNotes[i] != null && saveNotes[i].track == currentTrack:
				saveNotes[i].queue_free();	
		saveNotes.clear()
	
	
	# *fileWrite *write Write
	
	# press space to start recording, and esc to stop 
	# * might b better to set a different var to check what u are attempting
	# to use the record button for (like a var that checks if u are in a state to 
	# start recieving notes), my only worry is some actions require u to be in
	# multiple menus (using quickNav + select), so idk
	if Input.is_action_just_pressed("RecordAction") && inMenu == false:
		RecordingInProgress = true
	if Input.is_action_just_pressed("ExitAction") && RecordingInProgress == true:
		RecordingInProgress = false
		inMenu == false


	# checks if u are recording
	if RecordingInProgress == true:
		PreSigUniversalTimer += 1
		PlayingInProgress = true
		$AnimatedSprite2D.play("run")
		
		# ~ some weird limitations, pressing g and h doens't et u press
		# f as well, and u also can't press more than 6 keys which I think
		# are godot restrictions, but reasearch taht abit to see forsure. also the
		# reason why this i sin the delta event instead is b/c it don't work
		# in the other one
		
		# playing with keyboard keys
		
		# ~ could maybe be more optimized since this is using code
		# from above (in the InputEventMIDI check) but for the sake
		# of proof of concept this works
		for i in range(CompKeyboardNoteMapping.size()):
			if (Input.is_action_just_pressed(CompKeyboardNoteMapping[i]) == true):
				var a_note = loadedNote.instantiate();
				get_parent().add_child(a_note);
				a_note.growing = true;
				NoteID += 1
				a_note.MyNoteID = NoteID
				a_note.summonedX = position.x
				# the 12 is an offset to not make pitches too low for me
				a_note.pitch = -60 - i
				a_note.volume = TrackVolume[currentTrack]
				# trying to pass in notes into tracks n stuff
				# also trying to figure this out (tired rn ctrlf ->, @onready var notesInTrack = [null])
				a_note.Instrument = tracks[currentTrack]
				a_note.track = currentTrack	
				a_note.noteColor = Color(TrackColors[( currentTrack * 3 ) % TrackColors.size()], TrackColors[( (currentTrack * 3) + 1 ) % TrackColors.size()], TrackColors[( (currentTrack * 3) + 2 ) % TrackColors.size()])							

				a_note.canPlay = true

				currentNotes[a_note.pitch + 12] = a_note
				saveNotes.append(a_note)			
			# when the key is not being held
			if (Input.is_action_just_released(CompKeyboardNoteMapping[i]) == true):		
				currentNotes[-60 - i + 12].growing = false;

	
 # *save * save *filesave
	# basic recording thingy
	
	# refrenced these for allowing wav recording capture
		# ~ tldr: like u can write to a wav file by just capturing the music as
		# its being played back, still need some work for writing to other file types 
		# (tbf midi is basically done aside from other small functionality), but yeah
			# https://docs.godotengine.org/en/stable/classes/class_audioeffectcapture.html
			# https://docs.godotengine.org/en/stable/classes/class_audiostreamwav.html
			# https://docs.godotengine.org/en/stable/classes/class_audioeffectrecord.html#class-audioeffectrecord

	# this specific part saves to a project file 
	if Input.is_action_just_pressed("SaveAction") && inMenu == false:
		$SubMenuScreenRead.accessibility_description = "You are now in the save file menu,
			press " + str(InputMap.action_get_events("EnterAction")[0].as_text()) + " to save the file as a rawr berry beats project you wish to edit later
			or press " + str(InputMap.action_get_events("RecordAction")[0].as_text()) + " to go through the process of recording and exporting the track
			as a wav file. press " + str(InputMap.action_get_events("ExitAction")[0].as_text()) + " to return to the main menu"
		$SubMenuScreenRead.grab_focus()
		inSavingMenu = true
		inMenu = true
		
	if inSavingMenu == true:
		# lets u enter a file to save (for saving the project as a project file)
		if Input.is_action_pressed("EnterAction") && isSaving == false:
			$ProjectSave.accessibility_description = "I'd reccomend making backup files (by making copies of the projects you are working on) for the time being as the program is experimental,
				and a little early so in case something gets corrupted, you can have some progress saved. Otherwise, type the name of the file you wish to save to, and press enter
				to save it, you need to wait until you hear the file has finished saving before editing again"
			$ProjectSave.grab_focus()
			
			
			# this determines what type of file u are trying to save to
			# where true means u are saving the project file ...
			saveFileType = 0
			# ~ this lets u use enter now as a button for entering
			# the name, and not for deciding the file type, maybe
			# consider using a different input to check for, for both
			# (will prob do anyways when more file types are added, but since
			# its two now this is okay)
			isSaving = true
		# ... lets u save the project/record it as a wav ...
		if Input.is_action_just_pressed("RecordAction") && isSaving == false:
			$ProjectSave.accessibility_description = "right now, in this early build of the program, 
				the method for saving the project as a dot W A V file is done by having the program record and save it's own audio. 
				Right now the track is playing from where the playing bar was at and will record the audio until 
				you press " + str(InputMap.action_get_events("ExitAction")[0].as_text()) + " button. After you do, then you can enter 
				a name for the track and it will be saved as a dot W A V file in the customAssets folder. "
				# [feature] TODO, make it so you are automatically prompted to save as a wav
				# after the last note is recorded (even tho this method of recording might not
				# be the only option, it makes it easier for now)
				# By default, it will automatically stop a couple seconds after the last note in the track has finished playing."
			$ProjectSave.grab_focus()
			# ... and for wavs, this var gets set to false (lets the program
			# know which saving functions to go thru as these are two different
			# file types)
			saveFileType = 1
			# same reason as above, makes it so when u press enter to enter
			# the name of the file it doens't also change which file its being
			# saved to
			isSaving = true
			
			recordToFile = AudioServer.get_bus_effect(masterBus,0)
			PlayingInProgress = true
			print(recordToFile)
			recordToFile.set_recording_active(true)	
		# pressing exit stops the wav recording and you can enter in 
		# a file name to save it ... ~ [feature] want to eventually make it so combing
		# through and recording audio is an option, but also want to 
		# make it so you can just write to a file without having to iterate through
		# the audio and instead just have the code iterate through the
		# notes (which would b much faster, but also idk how hard so this
		# one is kinda on the backburner rn aside from doing research)
		if Input.is_action_just_pressed("ExitAction") && (isSaving == true) && recordToFile != null:
			saveToWav = recordToFile.get_recording()
			recordToFile.set_recording_active(false)	
			PlayingInProgress = false	
			_AudioStreamPlayer.set_stream(saveToWav)
			isSaving = true
			$ProjectSave.accessibility_description = "type the name that you would like to save the audio file as."
			$ProjectSave.grab_focus()
			
	
			
	# ... after typing in the name of the wav and pressing enter the
	# file is saved (this is for wav files)
	if saveFileType == 1 && isSaving == true && $ProjectSave.text != "" && Input.is_action_just_pressed("EnterAction"):
		$ProjectSave.text = "customAssets/" + $ProjectSave.text + ".wav"
		saveToWav.save_to_wav($ProjectSave.text)
		isSaving = false
		inSavingMenu = false
		inMenu = false		
		$ProjectSave.clear()
		print("save to wav")
		# returns to the main menu after successfully saving
		toAddToDescription =  "the " + $ProjectSave.text + "file has been saved in the customAssets directory"
		returnToMainMenu()
		
	# after typing in the name of the wav and pressing enter the
	# file is saved (this is for project files) ~ main thing to
	# note is that the file extension can be whatever, but want something
	# that ties into the name of the program (ig since this is opensource
	# someone could just rename it to some extent, but I'd like for there
	# to be some organizing, rn it just saves it to whatever you type in)
	if saveFileType == 0 && inSavingMenu == true && $ProjectSave.text != "" && Input.is_action_just_pressed("EnterAction"):
		$ProjectSave.text = $ProjectSave.text + ".rsrbtz"
		fileSave()
		# returns to the main menu after successfully saving
		toAddToDescription =  "the " + $ProjectSave.text + "file has been saved in the customAssets directory"
		returnToMainMenu()


	
	# *switch tracks *switchtracks *track
	if Input.is_action_just_pressed("SwitchTrackAction") && inMenu == false:
		# this calls the draw event to show which track we are currently on
		# (the draw event is called constantly, but this makes it so it only draws 
		# when this is true). This specific if statement puts u in the track shifting menu
		if shiftingTracks == false:
			shiftingTracks = true
			inMenu = true
			# this sets an extra menu thingy for the sake of not
			# being able to press left/right while typing the instrument
			# ^ u can't switch tracks while entering the name of a new instrument
			searchForStrument = false
			queue_redraw()
	# this closes you out of the shifting tracks menu
	if Input.is_action_just_pressed("ExitAction") && shiftingTracks == true:
		shiftingTracks = false
		inMenu = false	
		searchForStrument = false		
		queue_redraw()
		


	# if you are in the track switching menu, press left n right to switch tracks
	if shiftingTracks == true:
		

		
		# This lets you type in a audio file to set as the instrument
		if Input.is_action_just_pressed("RecordAction"):
			get_node("TrackInstrument").grab_focus()
			searchForStrument = true
		
		# shift tracks to the left
		if searchForStrument == false:
			if Input.is_action_just_pressed("LeftAction"):
				# loop around if necessary
				if currentTrack == 0:
					currentTrack = tracks.size() - 1
				if currentTrack != 0:
					currentTrack -= 1
		
					
				queue_redraw()
						
			# shift tracks to the right	
			if Input.is_action_just_pressed("RightAction"):
				# instead of looping, this just creates a new track
				if currentTrack == tracks.size() - 1:
					# makes an empty track
					tracks.append("")
					TrackVolume.append(-1.0)
					currentTrack += 1
				if currentTrack != tracks.size() - 1:
					currentTrack += 1
				queue_redraw()
			# *volume
			
			# increase the volume of the track
			if Input.is_action_just_pressed("UpAction"):
				TrackVolume[currentTrack] += 1
				
							
				for child in get_parent().get_children():
					if child is NoteClass:
						if child.track == currentTrack:
							child.volume = TrackVolume[currentTrack]

			# decrease the volume of the track
			if Input.is_action_just_pressed("DownAction"):
				TrackVolume[currentTrack] -= 1

				for child in get_parent().get_children():
					if child is NoteClass:
						if child.track == currentTrack:
							child.volume = TrackVolume[currentTrack]


				queue_redraw()
			
		# choosing the music instrument file (mp3)	
		if Input.is_action_just_pressed("EnterAction"):		
			tracks[currentTrack] = $TrackInstrument.text
			shiftingTracks = false	
			searchForStrument = false
			inMenu = false
			
			# this switches the instrument for every note in the track
			for child in get_parent().get_children():
				if child is NoteClass:
					if child.track == currentTrack:
						child.Instrument = $TrackInstrument.text
						child.pitchSetChek = false
				
		# close out of the shifting menu
		if Input.is_action_just_pressed("ExitAction"):	
			shiftingTracks = false	
			searchForStrument = false	
			inMenu = false					


# *select

	# saves the coords of when u first left click
	if shiftingMidis == false && shiftingTracks == false && PlayingInProgress == false:
		# this is for selecting every note on a track
		if Input.is_action_just_pressed("SelectAll"):
			for child in get_parent().get_children():
				if child is NoteClass:
					if child.track == currentTrack:
						selNotes.append(child)
		
		# this is for selecting every not past the playing bar
		# (only for current track)
		# ctrl d
		if Input.is_action_just_pressed("SelectPast"):
			for child in get_parent().get_children():
				if child is NoteClass:
					if child.track == currentTrack && child.global_position.x > global_position.x:
						selNotes.append(child)		
		
		
		# this is for selecting individual notes
		if Input.is_action_just_pressed("LeftClick") && get_global_mouse_position().y < 0:
			# this lets you select new notes
			selNotes.clear()
			StartXSelectCorner = get_global_mouse_position().x
			StartYSelectCorner = get_global_mouse_position().y

			
		# if you are conintuously holding left click
		if Input.is_action_pressed("LeftClick") && get_global_mouse_position().y < 0:
			# x pos (takes where u first click an extends it to current mouse pos)
			var selectLengthX = -(StartXSelectCorner - get_global_mouse_position().x)
			$TheSelector/CollisionShape2D.scale.x = selectLengthX
			$TheSelector.global_position.x = StartXSelectCorner + (selectLengthX / 2)
			replaySelect = $TheSelector.global_position.x - ($TheSelector/CollisionShape2D.scale.x / 2);
			# same as above but for y
			var selectLengthY = (StartYSelectCorner - get_global_mouse_position().y)
			$TheSelector.scale.y = selectLengthY
			$TheSelector.global_position.y = StartYSelectCorner - (selectLengthY / 2)
		
		# when u just let go, all of the colliding notes get selected
		if Input.is_action_just_released("LeftClick"):
			for collidNotes in $TheSelector.get_overlapping_areas():
				# this iterates through the notes colliding with the
				# selection box and appends them to the selected array
				if collidNotes is NoteClass && collidNotes.track == currentTrack:	
					# just put the pitch thing to check if this works, but I would
					# put these notes in an array and just make it so 
					# upon pushing different keys different things happen
					# to them (might need to consider how to keep them
					# selected when holding shift too)	
					selNotes.append(collidNotes)
					#print("test 2")
		
		# if the player is not using the mouse, they can still adjust the selecting
		# box from using the select menu (code for which is below, note that these 
		# actions are just for changing the boxe's dimensions, to actually change the
		# notes you return to the main menu. Ig the better way to phrase this is 
		# the note selector-but-not-adjuster-quite-yet
		
		if Input.is_action_just_pressed("SelectAdjustAction"):
			if !adjustingSelector:
				selNotes.clear()
				$TheSelector/CollisionShape2D.scale.x = 16;		
				$TheSelector.global_position.x = global_position.x;
				$TheSelector.scale.y = 16;		
				$TheSelector.global_position.y = global_position.y;
			
			adjustingSelector = not adjustingSelector
			inMenu = adjustingSelector

		# this increases the x of a note by the value typed into the bottom right
		
		# ~ [feature] this kinda works, but u have to do select, then set the value with MoveTo
		# tho pressing esc removes focus, but not actually and u can't type again unless
		# u press enter again (want to see if we can mess around with getting focus
		# so that u dont have to press those specific buttons). leaving this for 
		# now tho, just know what keys u gotta press (would like some means of remapping
		# tho, I believe u can try to set the ui_escape and ui_enter options
		# in the button remap, or maybe below like make enterAction = ui_enter
		# (would also like to make this a bit more intuitive to navigate if you
		# are not using all of the keyboard keys and just iterating through changing
		# the parameters of the notes you have selected/are trying to select)
		if Input.is_action_just_pressed("MoveToAction") && inMenu == false:
			quickNav = not quickNav;
			inMenu = true
			get_node("MoveTo").clear();
			get_node("MoveTo").grab_focus();
			# calls the narration function (check the NarrationAudioPlayer
			# for what each of these vals represent)
			NarrationAudioPlayer.nextClipIndex = 0
			NarrationAudioPlayer._narrate("moveto",0)

			
		if quickNav == true:
			if Input.is_action_just_pressed("EnterAction") && ($MoveTo.text != ""):
					inMenu = false
					quickNav = false;
				# if you have notes selected, they get moved to the 
				# position you entered
					for i in range(selNotes.size()):
						selNotes[i].summonedX = int($MoveTo.text)
				# even if you don't have anything selected, using this action still
				# moves the playing bar by the amount specified
					position.x = int($MoveTo.text)	
				# focus reset is just an obj that grabs focus so u can reset it
				# if you switch to another text box
					get_node("FocusReset").grab_focus();
			
		# these specfiically are for the finer tuning changes, but you can change
		# the positions quicker (by typing in values) with quick adjust
		if adjustingSelector == true:
			if Input.is_action_pressed("LeftAction"):	
				$TheSelector/CollisionShape2D.scale.x += 2;		
				$TheSelector.global_position.x -= 1;
			if Input.is_action_pressed("RightAction"):			
				$TheSelector/CollisionShape2D.scale.x += 2;	
				$TheSelector.global_position.x += 1;
			if Input.is_action_pressed("UpAction"):			
				$TheSelector.scale.y -= 2;	
				$TheSelector.global_position.y -= 1;
			if Input.is_action_pressed("DownAction"):			
				$TheSelector.scale.y -= 2;	
				$TheSelector.global_position.y += 1;
			
			# this is where u can type each of the coordinate values (if u press record
			# u can enter in a start time and end time and lower and higher pitch
			# for the selecting box to encompass)
			
			if Input.is_action_just_pressed("RecordAction"):
				get_node("EnterSelectDimensions").grab_focus();
				dimensionIterator = 0;
				
			if Input.is_action_just_pressed("EnterAction") && ($EnterSelectDimensions.text != ""):
				var selectDifference = 0;
				
				
				if dimensionIterator == 0:
					# first value typed is the starting time
					#selectDifference = $TheSelector.global_position.x - int($EnterSelectDimensions.text);
					selectDifference = int($EnterSelectDimensions.text);					
					$TheSelector.global_position.x = selectDifference;

				if dimensionIterator == 1:
					# second value typed is the starting time
					selectDifference = int($EnterSelectDimensions.text) - $TheSelector.global_position.x;
					$TheSelector.global_position.x = (selectDifference / 2) + $TheSelector.global_position.x;
					$TheSelector/CollisionShape2D.scale.x = selectDifference;
					
				if dimensionIterator == 2:				
					# third value typed is the lower pitch (unless I messed up this calc lol)			
					selectDifference = int($EnterSelectDimensions.text);					
					$TheSelector.global_position.y = selectDifference;


				if dimensionIterator == 3:
					# fourth value typed is the lower pitch (unless I messed up this calc lol)
					selectDifference = int($EnterSelectDimensions.text) - $TheSelector.global_position.y;
					$TheSelector.global_position.y = selectDifference;
					$TheSelector.scale.y = -2 * selectDifference;	
				
				
				dimensionIterator += 1;
				get_node("FocusReset").grab_focus();
				get_node("EnterSelectDimensions").clear();
				if dimensionIterator < 4:					
					get_node("EnterSelectDimensions").grab_focus();

					
			
			# this adds the notes that are colliding with the now moved selection
			# box to be added to the list of selected notes (same idea as using
			# left click above, but for the keys)
			if Input.is_action_just_released("LeftAction") || Input.is_action_just_released("RightAction") || Input.is_action_just_released("DownAction") || Input.is_action_just_released("UpAction") || dimensionIterator >= 4:
				dimensionIterator = 0;
				for collidNotes in $TheSelector.get_overlapping_areas():
					if !(collidNotes in selNotes) && collidNotes is NoteClass && collidNotes.track == currentTrack:		
						selNotes.append(collidNotes)	
				
				
		
		# this is the code that replays the notes that are currently select
		if replaySelect > $TheSelector.global_position.x + ($TheSelector/CollisionShape2D.scale.x / 2):
			replaySelect = $TheSelector.global_position.x - ($TheSelector/CollisionShape2D.scale.x / 2);
		replaySelect += PlayBackSpeed;
		$TheSelector.get_node("Sprite2D").global_position.x = replaySelect
		
		
	# if your not in a menu then pressing different buttons will change
	# the selected notes n stuff		
			# moves the selected notes to the left
		if inMenu == false:
			if adjustingSelector == false:
				if Input.is_action_pressed("LeftAction"):
						for i in range(selNotes.size()):
							selNotes[i].summonedX -= 1
				# same but for the right
				if Input.is_action_pressed("RightAction"):
						for i in range(selNotes.size()):
							selNotes[i].summonedX += 1
				# this moves selected notes up
				if Input.is_action_just_pressed("UpAction"):
						for i in range(selNotes.size()):
							selNotes[i].pitch -= 1	
							selNotes[i].pitchSetChek = false
				# same for down
				if Input.is_action_just_pressed("DownAction"):
						for i in range(selNotes.size()):
							selNotes[i].pitch += 1	
							selNotes[i].pitchSetChek = false


				# this resizes the notes (position still needs to be readjusted tho fyi)
				if Input.is_action_just_pressed("DecSizeAction"):
					for i in range(selNotes.size()):
						if selNotes[i].track == currentTrack:
							selNotes[i].length -= 1
							
				if Input.is_action_just_pressed("IncSizeAction"):
					for i in range(selNotes.size()):
						if selNotes[i].track == currentTrack:
							selNotes[i].length += 1					
				
				# this creates a copy of the selected notes on top of the current
				# selected ones (the copied notes are not apart of the selected ones)
				if Input.is_action_just_pressed("CopyAction"):
					for i in range(selNotes.size()):
						if selNotes[i] != null:	
							selNotes[i]._clone()

				# This increases the selected note's individual dynamics (volume)
				# U key
				if Input.is_action_just_pressed("ForteAction"):					
					for i in range(selNotes.size()):
						if selNotes[i] != null:	
							selNotes[i].indivol += 0.1
							selNotes[i].pitchSetChek = false
							
				# This decreases the selected note's individual dynamics (volume)
				# Y key
				if Input.is_action_just_pressed("PianoAction"):					
					for i in range(selNotes.size()):
						if selNotes[i] != null:	
							selNotes[i].indivol -= 0.1
							selNotes[i].pitchSetChek = false		
							
				# this moves the selected notes to the track above	
				# O key	
				if Input.is_action_just_pressed("trackUpAction"):
					var movetoTrack = 0
					if currentTrack == tracks.size() - 1:
						movetoTrack = 0
					else:
						movetoTrack = currentTrack + 1
										
					for i in range(selNotes.size()):
						if selNotes[i] != null:	
							selNotes[i].track = movetoTrack
							selNotes[i].volume = TrackVolume[movetoTrack]
							selNotes[i].noteColor = Color(TrackColors[( movetoTrack * 3 ) % TrackColors.size()], TrackColors[( (movetoTrack * 3) + 1 ) % TrackColors.size()], TrackColors[( (movetoTrack * 3) + 2 ) % TrackColors.size()])
							selNotes[i].Instrument = tracks[movetoTrack]
							selNotes[i].pitchSetChek = false
				
				# this moves the selected notes to the track below	
				# I Key (uh)	
				if Input.is_action_just_pressed("trackDownAction"):
					var movetoTrack = 0
					if currentTrack == 0:
						movetoTrack = tracks.size() - 1
					else:
						movetoTrack = currentTrack - 1
										
					for i in range(selNotes.size()):
						if selNotes[i] != null:	
							selNotes[i].track = movetoTrack
							selNotes[i].volume = TrackVolume[movetoTrack]
							selNotes[i].noteColor = Color(TrackColors[( movetoTrack * 3 ) % TrackColors.size()], TrackColors[( (movetoTrack * 3) + 1 ) % TrackColors.size()], TrackColors[( (movetoTrack * 3) + 2 ) % TrackColors.size()])
							selNotes[i].Instrument = tracks[movetoTrack]
							selNotes[i].pitchSetChek = false
																	
				# this deletes all selected notes
				# *delete
				if Input.is_key_pressed(KEY_DELETE):
						for i in range(selNotes.size()):
							if selNotes[i] != null:
								selNotes[i].queue_free();	
						selNotes.clear()		
									
				# not select but this toggles the transpose for the notes
				if Input.is_action_just_pressed("TransposeAction"):
					if transpose == 1:
						transpose = 0
					else:
						transpose = 1

				# toggles the vibrations with the device (andriod only right now
				# requires you set up export tools as well (go to top right, of
				# godot, click on export, scroll until you get to the vibration
				# check box and select that. You also likely need to get an
				# exporting tool, but that should auto download as you do these
				# steps. Also make sure you have vibrations turned on for your device
				if Input.is_action_just_pressed("TactileAction"):
					if tactileSound == true:
						tactileSound = false
					else:
						tactileSound = true
						
				# if ur in no menu, pressing 7 takes u to the start
				if Input.is_action_just_pressed("ReturnAction"):# && PlayingInProgress == false && RecordingInProgress == false && shiftingTracks == false:
					position.x = 0

				
# *Play *PlayMusic * playing * play *playing * playMusic *play music * play music
	
	# this is for playing tracks back, it iterates through the timeline 
	# based on the playback speed/tempo, the main thing for playing is that this code just makes
	# the playing bar move, the actual note objects themselves are what actually play the sound fx
	# (kinda cuz otherwise this would have to iterate through a list of all the notes and keep up with
	# them which is a bit slower run time wise than splitting up the work)
	if Input.is_key_pressed(KEY_ENTER) && inMenu == false:
		PlayingInProgress = true
		$AnimatedSprite2D.play("run")

	# this draws the x position of the playing bar
	if PlayingInProgress == true:
		queue_redraw()

	# this pauses the player
	if Input.is_action_just_pressed("PauseAction"):
		PlayingInProgress = false		
		$AnimatedSprite2D.play("idle")
			
	
	# stops playing
	if Input.is_action_just_pressed("ExitAction") && PlayingInProgress == true:
		PlayingInProgress = false		
		$AnimatedSprite2D.play("idle")
		# uncomment line above and use enter to playback
	

	# this lets you scroll a bit more (for skimming/debug)
	# (but for mouse skimming)
		
		# ~ completely less related but was checking the docs
		# for mouse buttons and based on the multiple controller set up
		# I'm curious if this means you can connect multiple mice with the
		# mouse button index here: https://docs.godotengine.org/en/stable/classes/class_inputeventmousebutton.html
	
	# if the player is holding right click then they move to the mouse position
	if Input.is_action_pressed("TeleportPlayingBar"):
			# worth noting for future projs, that global position is more general
			# where as position is more relative to the camera/screen (or node more
			# specifically ig, but yeah)
			
			# these specific if check caps the speed that the playing
			# bar can move (for flashing lights prevention)
		#if get_global_mouse_position().x > global_position.x + 500:
			#global_position.x += 500
		#elif get_global_mouse_position().x < global_position.x - 500:
			#global_position.x -= 500
		#else:
			global_position.x = get_global_mouse_position().x
			

		
	if PlayingInProgress == true:
		position.x += PlayBackSpeed
		
	# this moves the camera to follow the cursor
	_Camera.position.x = position.x
	
	# if escape is pressed at any point it moves the
	# focus off of the current button
	if Input.is_action_just_pressed("ExitAction"):

		# if the musician would be in the main menu after pressing
		# the escape action, then the main menu script is read
		if inMenu == false:
			returnToMainMenu()
	# moved playing stuff to the Note obj instead

	queue_redraw()

	
	pass
