extends Area2D

# *Key:

# ctrl f "`" for the most recently worked on thing

# *fileRead *file *read Read
# *fileWrite *write Write
# *delete *undo
# *switch tracks *switchtracks *track
# *Play *PlayMusic

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
	# this initializes the array of notes, expand it (make the range greater) if needed
	# (idk how many for my keyboard haven't counted yet oops)
	for i in range(105):
		currentNotes.append(null);
	# moves the midi file text a bit lower to not overlap
	$MidiFile.position.y = 50

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


# tracks

# This checks if ur in the trak shifting menu
@onready var shiftingTracks : bool = false
# this stores the tracks that you can shift thru
# (each value is each track, but the string stored is the instrument for each)
@onready var tracks = ["res://2 Mello - Love Sickubus 2-Pak - 01 Love Lightside.ogg"];
# this keeps track of the current track
@onready var currentTrack = 0
# each track has a list that stores all the notes in it (used for quickly muting
# a track)
@onready var notesInTrack = [null]

# this function is for a couple of events that draw text (namely track shifting
# and file loading)
func _draw():
	var default_font = ThemeDB.fallback_font
	if shiftingTracks == true:
		draw_string(default_font, Vector2(position.x, position.y - 40), str(currentTrack),0, 90, 22)
	#draw_string(default_font, Vector2(position.x, position.y + 40), str(position.x),0, 90, 22)
	if shiftingMidis == true:
		draw_string(default_font, Vector2(position.x, position.y - 80), str(substringSkip),0, 90, 22)
	

# this event gets called each time there is an input ....
func _input(input_event):
	# .. and specifically this if statement when
	# the input is from a midi device 
	# (main syntax for this is from:
	# https://docs.godotengine.org/en/stable/classes/class_inputeventmidi.html
	# )
	if input_event is InputEventMIDI:
		_print_midi_info(input_event)

		
		# when the velocity = 0, that means that the note was released
		# so I start by saving an event when the note is first pressed (for
		# my keyboard, this is velocity = 90 * note to change this when making
		# a general release version of it), and saving the universal time (frame)
		# when the note was pressed
		
		
		# as I understand this funciton is only being ran when new inputs are detected
		# (not every frame), so I'm making a new array to store note's pitch
		# and frame it was played
		var NoteBundle = [input_event.pitch, PreSigUniversalTimer];
		# based on if a note was pressed or released, the note bundle gets stored
		# into a different array (one for release and one for press, not in that order 
		# tho lol)
		if RecordingInProgress == true:

			if input_event.velocity != 0:
				var a_note = loadedNote.instantiate();
				get_parent().add_child(a_note);
				a_note.growing = true;
				NoteID += 1
				a_note.MyNoteID = NoteID
				a_note.summonedX = position.x
				a_note.position.y = -input_event.pitch
				# trying to pass in notes into tracks n stuff
				# also trying to figure this out (tired rn ctrlf ->, @onready var notesInTrack = [null])
				a_note.Instrument = tracks[currentTrack]	
				a_note.canPlay = true
				# maybe wanna toy around with the pitch stuff more to make it sound better obv
				# but otherwise started working on saving files (maybe wanna implement that other pitch
				# stuff too like in the demo as well)
				currentNotes[input_event.pitch] = a_note
				saveNotes.append(a_note)
			# when the key is not being held
			if input_event.velocity == 0:		
				currentNotes[input_event.pitch].growing = false;
				pitchRecStopList.append(NoteBundle)

	



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
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#refrence old test proj, wanted to get this set up and
	#just start with seeing if the midi keyboard works first
	#(if not might consider other options if this is something I want
	# to expand upon). Haven't ran this code, just copied it from here:
	#   https://docs.godotengine.org/en/stable/classes/class_inputeventmidi.html
	# ^ would also check if gms2 has some OS thing similar to this tbh VVV
	# https://docs.godotengine.org/en/stable/classes/class_os.html#class-os-method-get-connected-midi-inputs
	# ^ and also check if theres a way to see os devices for like python
	# for blind gaming stuff
	
	
	#InputEventMIDI
	
	# *fileRead *file *read Read
	
	#String From Instrument.midi

	# *~*~*~*~*~ uncomment for ref for midi reading
	
	# change this for debug
	#midiLoadCheck = true
	
	# toggle midi selecting menu
	if Input.is_key_pressed(KEY_L):
		shiftingMidis = true
	# this lets you adjust the starting substring a bit cuz I'm unsure when some tracks
	# start exactly
	if shiftingMidis == true:
		if Input.is_action_just_pressed("ShiftStartLeft"):
			substringSkip -= 1
		if Input.is_action_just_pressed("ShiftStartRight"):
			substringSkip += 1	
	# when you have typed in the midi file it gets loaded
	if Input.is_key_pressed(KEY_ENTER) && shiftingMidis == true: 
		midiLoadCheck = false
		shiftingMidis = false

		
	if midiLoadCheck == false:
		position.x = 0
		# this opens the file
		#var file = FileAccess.open("res://TwoQuarterNotesOnBeats1,3.mid", FileAccess.READ)
		# the reads the file (reading as a string directly doesn't work for some
		# reason so I'm just doing this instead, which is reading each char as ascii)
		#var content = FileAccess.get_file_as_bytes("res://TwoQuarterNotesOnBeats1,3.mid")
		#var content = FileAccess.get_file_as_bytes("res://[Tricks] DEBATING on 148 or 153 tempo Mashup Trix Definitive (Check 9 mins for reaaaal good) - Instrument.mid")
		#var content = FileAccess.get_file_as_bytes("res://HalfHigherPitch.mid")
		#var content = FileAccess.get_file_as_bytes("res://[Tricks] sillystinkkska - Instrument - dec 1 2024.mid")
		#var content = FileAccess.get_file_as_bytes("res://Instrument (1).mid")		
		#var content = FileAccess.get_file_as_bytes("res://MoarInstuments.mid")
		var content = FileAccess.get_file_as_bytes($MidiFile.text)

		# * if it crashes at some other points (beyond negative notes, still working on
		# ) might be a problem of different note events potentially (some do have pitch bend)

		# this converts each of the ascii chars into hex (useful for parsing the midi)
		var hexStringVer = content.hex_encode()
		#print(hexStringVer)
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
		
		# problem is that the delta time vals in some files are greater than the largest
		# int val possible for godot (I suspect that it might mean I'm reading the ticks
		# incorrectly a bit, but based on the max possible time division vals it still looks
		# massive tbh) and what's happening is that they are looping around b/c their size
		# for now tempted to make each note have some default gap and size (ignoring the exact
		# times and going for more of a pitch n position thing (essentialy only checking for
		# times that are 0 for chords otherwise every new note is separated)) otherwise the
		# gameplan would be to break the files into chunks (deltarune mod by the max int size, to
		# store notes into chunk array) and when the playing bar is close to the next chunk it starts
		# loading notes for that chunk (might be nice for optimizing too), def gonna entertain
		# the later, but gonna do the former if it doesn't work out o7 (also did another search
		# and saved a new link in phone (also have screen shots) for a different method for calcing
		# the delta times correctly so actually try that first)
		
		var weebitShorterString = hexStringVer.substr(hexStringVer.rfind("00c0"))
		# this is a lot better now (and technically reading the file correctly, timing
		# and precision is off as well as the mp3 file), the only real weird wack thing
		# is some files require the substring start below to be different values 
		# (4 I think for the 1, and 3 file) so maybe look into the exact method for
		# getting that, but otherwise looks good (also might need to add the other midi
		# events back into the parsing idk if I forgor to do that, kinda wanna make the
		# loud thing at the start go away as the next thing to fix) (AUDIO WORKS RN
		# JUST MUTED NOTES CUZ I WANTED TO FIX THIS LOL)
		
		# ` was more doing other stuff to make loading files n the general prog better
		# but fwiw there is a string length 
		
		weebitShorterString = weebitShorterString.substr(substringSkip,-1)
		
		#var weebitShorterString = hexStringVer.substr(hexStringVer.rfind("4d54726b"))
		#weebitShorterString = weebitShorterString.substr(44,-1)
		print(weebitShorterString)
		# this stores info for all of the notes so they can be made (keeps track of the delta
		# start times for each note as they get played and subtracts it from the
		# delta end times when those get called)
		var MidiNotes = [];
		for i in range(300):
			MidiNotes.append(null);
		
		# this is for counting the delta time inbetween events
		var deltaTimeCountList = []
		# for delta time refrence, 240 is a quarter note in 120 time (4/4)
		var deltarune = 0 
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
		var masterBus = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_mute(masterBus,true)
		
		TopTenChars = weebitShorterString.substr(0,10)
		#print(TopTenChars[9])
		
		# ~ entering the main file reading loop
		#while iterMidi < 10:
		#while !(endString[0] == "f" && endString[1] == "2" && endString[2] == "f" && endString[3] == "f") :
		#while !(TopTenChars[9] == "f" && endString[8] == "2" && TopTenChars[7] == "f" && TopTenChars[6] == "f") :

		# if we have not reached the end of the file
		while iterMidi < weebitShorterString.length():			#
			TopTenChars = weebitShorterString.substr(iterMidi,10)

			# if we have not reached the end of the file (cont, mayb slightly better way
			# to do but whatever)
			if TopTenChars.length() >= 10:
				var endOfDeltaChec
				endOfDeltaChec = (TopTenChars[0].hex_to_int() * 16) + TopTenChars[1].hex_to_int()
				if (EventEnd == 0) && (endOfDeltaChec < 128):
					print("event Start ")
					print(TopTenChars)
					print(" ")
					var whichPitch = -TopTenChars[4].hex_to_int() * 16
					whichPitch -= TopTenChars[5].hex_to_int()
					print("whichpic ", whichPitch)

					# this calculates the deltarune for when the event needs to be played
					for i in range(deltaTimeCountList.size()):
						# the math for this is that for each character it gets multipied by
						# 16 to the power of whatever and added to the sum
						deltarune += (deltaTimeCountList[deltaTimeCountList.size() - 1 - i] * (16 ** (i))) * 2
						#print(deltaTimeCountList[i])

				
					# note on event
					if TopTenChars[2] == "9":
						print("note on ", deltarune)

						# the notes aren't actually created here (they get made in the note off
						# event), but the time at which they are played gets saved as a refrence
						# for then (we can't make them as quickly now without the note end)
						

						
						# this stotes the time for when a note is being played
						MidiNotes[whichPitch] = deltarune
						#print(deltarune)
						
						# this counts the amount of chars included in this event
						# (important for finding the next event's delta time)
						EventEnd = 7
						# if this was the first event then we can start counting the delta
						# times (done below)
						deltaStart = false
						
						deltaTimeCountList.clear()
						# if this is NOT the start of the track events, the counter for where the 
						# previous track chunk ended also gets set  here
						#if StartOfTrackEvents == false:
						LastTrackEventEndedHere = iterMidi

					# note off event
					elif TopTenChars[2] == "8":
						print("note off", deltarune)
						
						# * Fixed this prob but have sommore
						# to fix negative index problem figure out what the note is 
						# and how much to add to the index (after checking if negative)
						# to at least match the note. Maybe still poking at tracks a bit
						# but did get two different note instances to have two different 
						# instruments and bug fixes so tbh kinda important day =:D
						#if whichPitch < 0:
							#whichPitch = whichPitch * -1
						if MidiNotes[whichPitch] != null:
							var a_note = loadedNote.instantiate();
							get_parent().add_child(a_note);
							# sets the pitch based on the two values
							a_note.position.y = whichPitch
							
							a_note.length = (deltarune - MidiNotes[whichPitch])
							# this sets the time of the note based on the accumulated
							# delta times
							a_note.summonedX = MidiNotes[whichPitch] 
							
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
						#print("misc event", deltarune)
						## ig it needs this here anyways, but ig thats fine too
						deltaStart = false
						
						# ~~ once all the events are done (copying an pasting
						# into statements cuz there can be instances of 002 (for an example)
						# which is not a midi event: 
						# this resets the count of the delta time number values
						deltaTimeCountList.clear()

						# if this is NOT the start of the track events, the counter for where the 
						# previous track chunk ended also gets set  here
						#if StartOfTrackEvents == false:
						LastTrackEventEndedHere = iterMidi
						

					elif TopTenChars[2] == "d" || TopTenChars[2] == "c":
						EventEnd = 5
						#print("misc event", deltarune)
						## ig it needs this here anyways, but ig thats fine too
						deltaStart = false
						
						# ~~ once all the events are done (copying an pasting
						# into statements cuz there can be instances of 002 (for an example)
						# which is not a midi event: 
						# this resets the count of the delta time number values
						deltaTimeCountList.clear()

						# if this is NOT the start of the track events, the counter for where the 
						# previous track chunk ended also gets set  here
						#if StartOfTrackEvents == false:
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
			# (UPDATE this is done just they are spread out like crazy)
			# Rn still trying to get the delta times (just doing note start for now)
			# need something to keep track of the last event's end position
			# to know when to start counting the delta times. Kinda have this implemented
			# (double check that it works) judging by the value of deltarune tho, prob
			# need some sort of start checker (cuz I think its adding a lotta the
			# previous values)
					
			
			iterMidi += 1
			

			# (UPDATE this is done just they are spread out like crazy)
			# Rn still trying to get the delta times (just doing note start for now)
			# need something to keep track of the last event's end position
			# to know when to start counting the delta times. Kinda have this implemented
			# (double check that it works) judging by the value of deltarune tho, prob
			# need some sort of start checker (cuz I think its adding a lotta the
			# previous values)
			
			# lets the notes know they can play now
			for child in saveNotes:
				child.canPlay = true
			
		#for i in range(4):
			#print(endString[i])
		midiLoadCheck = true
		#print(deltarune)
		#print(weebitShorterString)

		# fixed, but u just have to start a recording and then click escape to
		# return to the start of the song, but no loud noise yay
		# need to revise this a bit (leaving two 's cuz I didn't check the last one)
		# trying to get muting by unmuting if there are 0 collisions detected 
		# (kinda right idea, maybe need this to be a while loop or somthing)
		#var fullyLoaded = saveNotes[saveNotes.size() - 1].position.x
		
		# this unmutes the program to not make a crazy loud noise after
		# the notes all get placed
		while position.x < deltarune:
			position.x += 5000
		
		AudioServer.set_bus_mute(masterBus,false)
		
		print("finished loading file")
		print(position.x)

		
	#for i in range(saveNotes.size()):
		#if saveNotes[i].position.x > 0:
			#print(saveNotes[i].position.x)
			#print(saveNotes[i].position.y)
	
	
	#var stringTest = "MThd     < MTrk    ÿQ ¡  ÿXƒà ÿ/ MTrk    ÿ
#Instrument À  0dƒà €0  ÿ/ "
	#print(int("ÿ"))
	#print(int("M"))
	#print("MThd     < MTrk    ÿQ ¡  ÿXƒà ÿ/ MTrk    ÿ
#Instrument À  0dƒà €0  ÿ/ ")
	#var stringTest = "MThd     < MTrk    ÿQ ¡  ÿXƒà ÿ/ MTrk     ÿ
#Instrument À -0dƒÞS€0  ÿ/"
	#var stringTest = "Instrument À"
	#var stringTest = "MThd     < MTrk    ÿQ ¡  ÿXƒà ÿ/ MTrk   ) ÿ
#Instrument À  0dø €0 ø 0dø €0 ø ÿ/ "
#
	#print(stringTest)
	#var hexTest = stringTest.to_utf8_buffer().hex_encode();
	#print(hexTest);
	
	# this format matches the hex values according to the site, and tbh I
	# think the next step is just following each of these 1 by 1 to match
	# the midi file (somethings idk like the exact timing of the note, oopsies,
	# but the main thing to note is that it is a 3C, maybe get another note with
	# a known volume or smth lol) I'd start by looking at where each section
	# begins and ends since according to the site the first 4 characters, and hex bits 
	# are always the same ("MThd" in the file, and "0x4d546864" in the print), and there
	# is another section for the track chunk which is "MTrk", or "4d54726b", which
	# is also below, so I want to start before writing the code to guestimate/identify
	# each part just for one note and track, and then comparing it to another track
	
	# https://web.archive.org/web/20141227205754/http://www.sonicspot.com:80/guide/midifiles.html
	
	 # *delete *undo
	
	# quickly undo the last set of saveNotes (includes undoing a midi file)
	#if Input.is_key_pressed(KEY_DELETE):
	if Input.is_key_pressed(KEY_CTRL) && Input.is_key_pressed(KEY_Z):	
		for i in range(saveNotes.size()):
			if saveNotes[i] != null:
				saveNotes[i].queue_free();	
		saveNotes.clear()
	
	
	
	
	# *fileWrite *write Write
	# basic recording thingy
	
	# press space to start recording, and esc to stop 
	if Input.is_key_pressed(KEY_SPACE) && RecordingInProgress == false:
		RecordingInProgress = true
	if Input.is_key_pressed(KEY_ESCAPE) && RecordingInProgress == true:
		RecordingInProgress = false
		position.x = 0
		print(position.x)
		#for i in range(pitchRecStartList.size()):
			#print("start pitch ", pitchRecStartList[i][0])
			#print("start time ", pitchRecStartList[i][1])
			#print(" ")
			
			# FIXED  messed up something with the stop time oopsies
			
			#print("stop pitch ",pitchRecStopList[i][0])
			#print("stop time ",pitchRecStopList[i][1])	
			
			# the way how I wanna do this is instead of for looping twice (once
			# for the start and another for the end time cuz a note can begin
			# part way through playing another), is to use another list to basically
			# act as an inbetween linking the start time with the end time (FWIW
			# currently planning another track to be needed if you want another note
			# to be playing at the same time of the same pitch)
			#var a_note = loadedNote.instantiate();
			#add_child(a_note);
			#a_note.y = pitchRecStartList[i][0]
			
	# checks if u are recording
	if RecordingInProgress == true:
		PreSigUniversalTimer += 1
		PlayingInProgress = true
		#print(PreSigUniversalTimer)
	
	
	# *switch tracks *switchtracks *track
	if Input.is_key_pressed(KEY_SHIFT) == true:
		# this calls the draw event to show which track we are currently on
		# (the draw event is called constantly, but this makes it so it only draws 
		# when this is true). This specific if statement puts u in the track shifting menu
		if shiftingTracks == false:
			shiftingTracks = true
			queue_redraw()
	if Input.is_key_pressed(KEY_ESCAPE) && shiftingTracks == true:
		shiftingTracks = false				
		queue_redraw()

	# if you are in the track switching menu, press left n right to switch tracks
	if shiftingTracks == true:
		
		# shift tracks to the left
		if Input.is_key_pressed(KEY_LEFT):
			if currentTrack != 0:
				currentTrack -= 1
			# loop around if necessary
			if currentTrack == 0:
				currentTrack = tracks.size() - 1	
				
			queue_redraw()
					
		# shift tracks to the right	
		if Input.is_key_pressed(KEY_RIGHT):
			# instead of looping, this just creates a new track
			if currentTrack == tracks.size() - 1:
				# makes an empty track
				tracks.append("")
				currentTrack += 1
			if currentTrack != tracks.size() - 1:
				currentTrack += 1

			queue_redraw()
			
		#print(currentTrack)	
		# choosing the music instrument file (mp3)	
		if Input.is_key_pressed(KEY_ENTER):		
			tracks[currentTrack] = $TrackInstrument.text		
						
				
	# *Play *PlayMusic
	
	# this is for playing tracks back, it iterates through the timeline 
	# based on the playback speed/tempo, the main thing for playing is that this code just makes
	# the playing bar move, the actual note objects themselves are what actually play the sound fx
	# (kinda cuz otherwise this would have to iterate through a list of all the notes and keep up with
	# them which is a bit slower run time wise than splitting up the work)
	if Input.is_key_pressed(KEY_ENTER) && PlayingInProgress == false && shiftingTracks == false:
		PlayingInProgress = true
		$AnimatedSprite2D.play("run")

	# this pauses the player
	if Input.is_key_label_pressed(KEY_P):
		PlayingInProgress = false		
		$AnimatedSprite2D.play("idle")
			
	
		
	if Input.is_key_pressed(KEY_ESCAPE) && PlayingInProgress == true:
		PlayingInProgress = false		
		position.x = 0
		$AnimatedSprite2D.play("idle")
		# uncomment line above and use enter to playback
		
		
	# this lets you scroll a bit more (for skimming/debug)
	# (but for mouse skimming)
		
		# * completely less related but was checking the docs
		# for mouse buttons and based on the multiple controller set up
		# I'm curious if this means you can connect multiple mice with the
		# mouse button index here: https://docs.godotengine.org/en/stable/classes/class_inputeventmousebutton.html
	
	# if the player is holding right click then they move to the mouse position
	if Input.is_action_pressed("TeleportPlayingBar"):
			# worth noting for future projs, that global position is more general
			# where as position is more relative to the camera/screen (or node more
			# specifically ig, but yeah)
		global_position.x = get_global_mouse_position().x
			
			
			
		# need to find a way to iterate through all of the notes that 
		# are in a track (doing this b4 tackling direct midis), questioning
		# how to organize the file based on if you write something in the middle
		# of a track (like should the lists be reordered, or can I insert or something
		# else, ig it depends on godot functions so look into those ig), 
		
		# still keeping this above but kinda got a way to spawn notes in and am
		# just gonna check collisions to play notes (need some adjustment to the notes
		# a bit obv but I likey)
		
	## this lets you scroll a bit more (for skimming/debug)
#
	#
	#if Input.is_action_pressed("TeleportPlayingBar"):
		#position.x = Cameraget_viewport().get_mouse_position()
		
	if PlayingInProgress == true:
		position.x += PlayBackSpeed
		
	# this moves the camera to follow the cursor
	_Camera.position.x = position.x
	
	# moved playing stuff to the Note obj instead
	
	pass
