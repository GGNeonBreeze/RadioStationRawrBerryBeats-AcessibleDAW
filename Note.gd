extends Area2D
class_name NoteClass

# *key
	# *playing
	# *load


# this gets the info for the sprite and collision box
@onready var _sprite = $Sprite2D
# gets the info for the audio player
@onready var _AudioStreamPlayer = $AudioStreamPlayer
## this gets the collision for the notes
#@onready var _Area2D = $Area2D
# this is a bool to check when the note should be playing its sound
@onready var NoteplayingToggle: bool = false;
# this is the bool that gets toggles to make it play
@onready var Noteplaying: bool = false;
# this is a var to check if the notes are fully loaded
@onready var canPlay: bool = false;
# this is a bool to check if the notes pitch has been set correctly (based on its y value)
@onready var pitchSetChek: bool = false;
# this is the id for the notes
@onready var MyNoteID: int = 0
# this stores the track that the notes are on (mostly just for saving the project)
@onready var track: int = 0
# this stores the pitch of the note, which is not exactly the y val
# there is a bit of spacing cald below
@onready var pitch: float = 0
# this calculates the actual pitch scale change needed to play the pitch
@onready var pitchCalc: float = 0.0

# this stores the delta times for when this note starts and ends (delta
# times are times relative to the previous event's start time, not the 
# global time of them, this is more for file saving since the files that get
# read/saved use these)
@onready var deltaStart: String = ""
@onready var deltaEnd: String = ""

# this is the instrument (mp3 file/audio stream) for the note
@onready var Instrument: String = "res://GenA3.mp3"

@onready var playback: AudioStreamPlayback = null # Actual playback stream, assigned in _ready().

# this is the color for the note (determined by what track its on)
@onready var noteColor : Color = Color(0.25, 0.01, 1, 1)

# to make it so notes can have their own dynamics (and dynamic changes thru
# out the track), notes have their own individual volume changing value
# on top of the base volume used for the track
@onready var indivol: float = 0

# this stores the volume of each note (track volume)
@onready var volume: float = 0

# this is the vol val that gets stored in the file for each note
@onready var volumeHex: String = "00"

# this determines if the note should play its audio from the
# start when it is initially played, or if it should play the audio 
# starting from a specific position (more for backing tracks)
@onready var realTimePos: bool = false

# this keeps track of the playingbar
@onready var playingBar = get_parent().get_node("PlayingNode");

# this determines when to vibrate the device
@onready var tactileTimeHigh = false
# this determines how long to vibrate the device for (as a time high)
@onready var timeHigh : float


# Called when the node enters the scene tree for the first time.
func _ready():
	# layer notes are checking for collisions
	set_collision_mask_value(1, true) 
	# layer the notes are not on (they only check for one collision with the playing bar)
	set_collision_layer_value(1, false) 
	# the notes get put on this layer (for checking if they loaded correctly)
	set_collision_layer_value(2, true) 
	#_AudioStreamPlayer.volume_linear = 0.0

	#
	# for modulate: https://docs.godotengine.org/en/stable/classes/class_canvasitem.html#class-canvasitem-property-modulate
	# for sound generator: https://docs.godotengine.org/en/stable/classes/class_audiostreamgenerator.html

	
	pass # Replace with function body.


# this checks if the note is growing (currently being played, it increases its length until it is
# not being played anymore)
@onready var growing: bool = false;

# note length is also denoted by the hitbox length too
@onready var length: float = 0;

# this determines the x coord (time) to start playing the note (the x coord of the left side of
# the collision box)
@onready var summonedX: float = 0;

# this checks if the notes are colliding
@onready var isBonking: bool = false

# this stores the string versions of every note for drawing what each note is
# (the first one is for G instruments (alto flute, piano), the 2nd is for e flat (alto sax)
@onready var NoteStrings = [["E","F","Fsh","G","Gsh","A","Ash","B","C","Csh","D","Dsh"],["Csh","D","Dsh","E","F","Fsh","G","Gsh","A","Ash","B","C"]]

# this is used for copying and pasting notes
func _clone():
		var a_note = preload("res://Note.tscn").instantiate();
		get_parent().add_child(a_note);
		a_note.summonedX = summonedX
		a_note.pitch = pitch
		a_note.volume = volume
		a_note.Instrument = Instrument
		a_note.track = track
		a_note.noteColor = noteColor
		a_note.length = length
		a_note.canPlay = true


# this function is for a couple of events that draw text (namely track shifting
# and file loading)
func _draw():
		var default_font = ThemeDB.fallback_font
		var default_font_size = ThemeDB.fallback_font_size
		#if the note is playing, it displays what note it is
		if NoteplayingToggle == true:
			# okay now do this again, but with a setting for transposing to sazx
			# for calling the node correctly, ".." calls the parent (InputMidiObjNode's
			# top node, which is the Node2D), and "/PlayingNode" calls that node's child 
			# (which is named that on the left hand side), cuz that's where the actual playing
			# bar and music maker controler code is
			
			# (might need to move the playing bar off of the notes and back on again
			# to update the drawing, but yeah this workds)
			draw_string(default_font, Vector2(0, -60 + (2 * pitch)), NoteStrings[get_node("../PlayingNode").transpose][(-int(pitch) - 40) % 12],0, 60, 24)

			# debug for volume
			#draw_string(default_font, Vector2(0, -70), str(volume),0, 60, 24)
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# *load
	
	# this caps the volume

	if volume >= 19:
		volume = 18
	_AudioStreamPlayer.volume_db = volume
	
	# ~ this is kinda cool, but fornow, just gonna save the volume as a
	# rounded hex val so yeah
		# 20 - (22 - (19 / 256) * volume_val_from_file(which is hex)) = volume_db
		# ^ where 19 is just me picking a val for the max volume_db, and
		# the volume_val_... is how much quieter the note is from that val
		# the 20 - 22 part is just to make the volu go from -2 to 19
	

	
	
	# this checks if the note needs to grow (is currently being played)
	if growing == true:
		length += 1

	# would just update the Node(area2d's scale), but that messes with
	# drawing the note pitch above so doing this instead
	$CollisionShape2D.scale.x = length
	$Sprite2D.scale.x = length
	
	# ** this adjusts the note based on its width (the 128 comes from the size of the sprite so 
	# if that gets changed (the sprite deffo needs to be changed for its height, but I think the width
	# can technically stay the same) so just a heads up when editing
	if growing == false:
		position.x = summonedX + (1 * length / 2)
		# prob better way to write this, this just makes it so the notes dont
		# go on and off (and stop colliding with the bar) as they are being made
	if growing == true:
		position.x = summonedX + (1 * length / 2) + 1

	# this loads the pitch (and Instrument and Track) correctly
	if pitchSetChek == false:
		position.y = 125 + (pitch * 3)
		# for tuning this, just gonna play notes and check wit a 
		# tuner to see how much higher the pitch needs to go (if its still 1/12)
		# then def try the GenC.mp3 (most in tune example) and the exact numeric method
		# below instead of rounding (suspecting that the pitch scale in godot
		# doesn't let me make it as precise so might need some work there, but we wil c

		# 1 = c
		# 1.059 = c sharp
		# 1.12 = d
		# 1.18 = d shar
		# 1.24 = e
		# 1.335 = f
		# 1.41 = f shar
		# 1.5 = G 
		# 1.59 (1.587 ish) = a flat
		# 1.68 = a
		# 1.
		
		# 2 = higher c
		
		# pitch calc idea:
			# refrenced: https://msp.ucsd.edu/techniques/v0.08/book-html/node8.html
			# https://openbooks.library.umass.edu/physicsofmusic/chapter/lab-activity-7/
				# ^ the pitch scale is what the pitch is being multiplied by, which is 
				# exponential (not linear) (a2 = 110 hz, a3 = 220 hz, a4 = 440 hz) where
				# each octave basically multiplies it by 2 so if we want a to be the base 
				# pitch = 69 + 12 * log_base2_(frequency / 440) wher 69 is the midi pitch for
				# a4, 12 represents the notes in an octave, and the log base 2 is how many times
				# 2 goes into the quotient of freq / 440 (how many times greater this pitch's 
				# frequency is over a4's frequency), also a4 should literally be the 4th a 
				# on the keyboard im using rn
				# or freq = 440 * 2 ^((pitch - 69) / 12)
				# for the sake of what I wanna do tho,
				# freq / 440 = 2 ^((pitch - 69) / 12) = pitch scale
		pitchCalc = 2 ** ((-pitch - 69) / 12)

		_AudioStreamPlayer.pitch_scale = pitchCalc


		# this sets the color of the note
		set_modulate(noteColor)


		# (makes sure audio types match the file too)

		# ogg
		if Instrument.substr(Instrument.length() - 3, -1) == "ogg":
			_AudioStreamPlayer.set_stream(AudioStreamOggVorbis.load_from_file(Instrument))
		# mp3
		if Instrument.substr(Instrument.length() - 3, -1) == "mp3":
			_AudioStreamPlayer.set_stream(AudioStreamMP3.load_from_file(Instrument))
		# wav
		if Instrument.substr(Instrument.length() - 3, -1) == "wav":
			_AudioStreamPlayer.set_stream(AudioStreamWAV.load_from_file(Instrument))

		# this adds individual dunamic changes to the base volume
		volume = volume + indivol

		# this gets set to true when the pitch (and other note aspects)
		# have been altered (so they don't constantly get called
		# ~ note to self tho, make this a function instead of a bool
		# that gets checked every frame for lag)
		pitchSetChek = true	


	# *playing
	
	
	# if the note collides with the play bar it plays its pitch
	# (updated this to not use collisions and instead just check x vals since we don't care
	# about the y ones, and it makes the notes have to load less (more optimizing yay)
	# it also helps with repeating selected notes too
	if canPlay == true :
		
		
		# if the note is not growing, wait for the playing bar (or replaying bar) to reach it before playing
		if growing == false:
			
			
			if (  (playingBar.position.x >= summonedX) && (playingBar.position.x <= summonedX + length)  ) ||   (   (playingBar.replaySelect >= summonedX) && (playingBar.replaySelect <= summonedX + length)  && (position.y < -((playingBar.get_node("TheSelector").scale.y / 2) - (playingBar.get_node("TheSelector").global_position.y))) && (position.y > ((playingBar.get_node("TheSelector").scale.y / 2) + (playingBar.get_node("TheSelector").global_position.y)) )  ):# && (pitch < playingBar.get_node("the_selector").global_position.y + playingBar.get_node("the_selector").scale.y) && (pitch > playingBar.get_node("the_selector").global_position.y)):
				isBonking = true;
			else: 
				isBonking = false;
		# if the note is growing just play the note
		else:
			isBonking = true;


		# ~ I really wanted to use this to play the notes instead of the growing logic above
		# but it wasn't working, tho leaving this for future me to maybe investigate
		if isBonking == true || growing == true:
			# this activates a toggle to make play() be ran once,can't just call
			# play() or else a buncha static gets produced as the game constantly replays
			# the sound from the start
			
			# this is for drawing the text (see _draw at the top for more)

			if NoteplayingToggle == false:
				# ~ (like this idea, but marking since I want this to be
				# a setting that can be turned on for any track (also to allow for
				# multiple of these))
				# messed with the playing of specific tracks (namely the backing
				# idea track) so that you can play that from any starting
				# point in the track itself, would prob need a better way to 
				# load this in (there's a bug if u load the "overcastproj.txt" twice
				# in the same run time cuz it doesn't make enough space in the
				# tracks array ig in the main file so thats something to also
				# change), but this works for now as long as the base is the first
				# track loaded in, (the code is working, its just that the file
				# isn't saving it correctly rn cuz I don't think its saving the
				# tracks from reading files correctly, but u can prob just edit
				# the file manually until it works tbh if push comes to shove)
				if track != 1:
					# ` this might b the cause of a bit of the lag wen
					# playing btw since the background noise is technically starting
					# a bit later than the notes, but would also check for lag too
					# would also investigate giving each track their own bus in the main
					# parent node, and having each note play thru their respective parent's
					# bus since instruments and other effects are kinda universal (but that
					# depends on if we are allowed to have one bus play multiple sfx at a time)
					_AudioStreamPlayer.play(10)
					# like the instance where pitch calc is calculated, there is
					# a magic number here that assumes that the pitch is 440, but
					# you can technically use an audio file where the pitch isn't
					timeHigh = pitchCalc / (440) / 2
					#print(timeHigh)
					$Timer.start(timeHigh)
					NoteplayingToggle = true
					queue_redraw()
				else:
					# this is for tracks that have fully audio (playing the note
					# starting from a 3rd in will play the track from a 3rd of the
					# way in)
					if playingBar.PlayingInProgress == true:
							_AudioStreamPlayer.play((playingBar.position.x - summonedX) * 0.01669)
												
						
							NoteplayingToggle = true
							
			# this pauses full audio notes when you pause the track				
			if track == 1 && playingBar.PlayingInProgress == false:
				_AudioStreamPlayer.stop()
				NoteplayingToggle = false
			
		# this stops the playing when not colliding with the bar
		if isBonking == false:
			if NoteplayingToggle == true:
				_AudioStreamPlayer.stop()
				NoteplayingToggle = false
				queue_redraw()
				
	# ~ final queue redraw for debug stuff mostly (comment out for a bit
	# more optimization)			
	queue_redraw()


	pass


func _on_timer_timeout() -> void:
	if playingBar.tactileSound == true && NoteplayingToggle == true:
		if tactileTimeHigh == false:
			tactileTimeHigh = true
			playingBar.vibrationAdd(timeHigh,0.3)
			#print(timeHigh)
		else:
			tactileTimeHigh = false
			playingBar.vibrationSub(0.3)
	else:
		$Timer.stop()
