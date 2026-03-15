# this is an audio player for narration, it technically could be
# in the playingNode, but figured as it has some files to set up, giving
# this it's own node makes sense (and is much cleaner, as we can just adjust
# it's own volume and stuff separately if needed)

extends AudioStreamPlayer

# this stores the names for all of the audio files for each of the inputs
# when you are using the narration (maybe could use the HUDnGUI mapping
# for this technically, but again, kinda felt better about giving the narration
# it's own node). While numbered this is a dictionary since we don't actually
# use the numbers in much order (as it depends on what the user has them mapped to)
@onready var inputAudioFiles = {
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
	38 : "res://narratedAudio/keys/R.mp3",
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
	67 : "res://narratedAudio/keys/Enter.mp3"
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
}

# this saves the HUDnGUI node so its easier to access later (whenever u
# wanna change the HUDnGUI stuff)
@onready var HUDnGUI = get_parent().get_node("HUDnGUI");

# this keeps track of the index for which audio clip in the sequence 
# is being played next
@onready var nextClipIndex = 0

# this keeps track of the menu to pull the audio clip from
@onready var menuAudio = "main"

# this is the same idea as the menu, but for the specific sequence
# of audio clips to play
@onready var focusSequence = 0


# this intis the var for the array, but we fill it up in the ready func
# below (since that's after the user's preset file has been read)
var audioDescriptions = []



func _ready():
	# ` plan for now is to use the default godot text to speech
	# stuff to write out everything (since the voice clip idea is
	# paused), but i'll leave some of this in here in case its something
	# to come back to (prob will, but might b a bit)
	
	# this dictionary array combo stores all of the audio descriptions for
	# each of the menus for the program. 
	# The 1st index indicates what menu the user is in
	# The 2nd index indicates the sequence of audio files to play for the action
	# And the 3rd index has the actual audio files themselves
	# ^ to clarify the last 2 indexes, some actions have multiple audio files
	# (usually one that explains the action, and another for which input is
	# mapped to the action to tell the user what they should press to do 
	# whatever action they want to). Made this an array since some
	# of the sequences are sequenctial, but debating on making it a dict
	# that stores the sequential parts (since that's faster to index, besta
	# both world type beat)
	audioDescriptions = {
		# main [0]
		"main":	
			# main menu initial [0]
			[
				[
				"res://MainMenuInitial.mp3"
				]
			],
		# move to [1]
		"moveto":
			# move to initial [0]
			[
				[
					"res://narratedAudio/menus/MoveToInitial1.mp3",
					inputAudioFiles.get( HUDnGUI.hashKeys.get( InputMap.action_get_events("EnterAction")[0].as_text_physical_keycode() ) ),
					"res://narratedAudio/menus/MoveToInitial2.mp3"
				]
			],
			
		# select adjust [2]
		"selectAdjust":
			{
				
			},
		# load [3]
		"load":
			{
				
			},
		# save [4]
		"save":
			{
				
			},
		# remap [5]
		"remap":
			{
				
			}
	};

# this checks for if you press buttons to iterate through to the
# next audio sequence (
# ~ note that the godot default tab + shift tab events
# are turned off for this project. go into project settings and
# set the inputs for ui_focus_next and ui_focus_prev if you want them back
# (just disabled them to do our own screen reading, but considering options
# to make use them, namely for using buttons that you can iterate through
# would also need to adjust the range of button remapping to allow u to change
# those actions as well so just doing it like this)
func _input(iterate_input):
	if Input.is_action_just_pressed("FocusAction"):
		if focusSequence < audioDescriptions.get(menuAudio).size():
			focusSequence += 1
		else:
			focusSequence = 0

# this function gets called when you want to have the text be narrated
# you pass in a menu (as in the menu the user is currently in), and 
# a sequence (this is the sequence of audio files to play/narrate)
func _narrate(menu : String,sequence : int):
	# this iterates through the sequence that was chosen and plays
	# the audio (these vars get saved for when we recurse, which is done
	# in the _on_finished signal function call below
	menuAudio = menu
	focusSequence = sequence
	

	# stops the previous audio sequence (if there is one playing)
	stop()
	
	# this part just makes sure that play is ran once for each
	# part of the audio instead of too many times
	#if playing == false:
	set_stream( AudioStreamMP3.load_from_file( audioDescriptions.get(menu)[sequence][nextClipIndex] ) )
	play()
	nextClipIndex += 1
	print("next ", nextClipIndex)
	# if narrarate is called while there is already audio playing
	# then it will switch to the new sequence instead of continuing
	#else:

# We need this to be a singal instead of just one function because it 
# keeps the whole program trapped there (if it keeps recursing or running
# a while loop in the funciton), so this makes it so the player can do other
# actions/inputs while the audio is playing, and the NarrationAudioPlayer
# can still iterate through the audio clips
func _on_finished() -> void:
	print("finished")
	if nextClipIndex < audioDescriptions.get(menuAudio)[focusSequence].size():
		_narrate(menuAudio, focusSequence)
	else:
		nextClipIndex = 0


#audioDescriptions = [
		## main [0]
		#[	
			## main menu initial [0]
			#[
				#"res://MainMenuInitial.mp3"
			#],
		#],
		## move to [1]
		#[
			## move to initial [0]
			#[
				#"res://MoveToInitial1.mp3",
				#inputAudioFiles.get( HUDnGUI.hashKeys.get( InputMap.action_get_events("EnterAction")[0].as_text_physical_keycode() ) ),
				#"res://MoveToInitial2.mp3"
			#],
			#
		#],
		## select adjust [2]
		#[],
		## load [3]
		#[],
		## save [4]
		#[],
		## remap [5]
		#[]
	#];
