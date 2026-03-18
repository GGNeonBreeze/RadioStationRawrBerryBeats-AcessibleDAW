# -WIP-Name-Pre-Alpha-Open-Source-RadioStationRawrBerryBeats-AcessibleDAW-
Very Early Acessible DAW made in the Godot Game Engine

# About
This was originally a side project that I was working on for another a game that I figured would work best as an opensource project. There are a lot of other DAWs out there, but I wanted to learn about how they operate and the ins and outs of music files so that's why I started working on this. I also couldn't find that many examples of accessible DAWs and or ones that were opensource (if you know of any feel free to share them here I would love for there to be more of these especially if people prefer different languages/interfaces), so that's became another goal of this project

I'm making a version of it now because while I have been working on it over the last year, recently I had to take a bit of a break (general life stuff, you know the drill), but I had enough to get the proof of concept done (as in the ability to read and write to music files with some navigation optoins, albiet in a very debuggy and unfinished way) which is enough to consider this a start (or pre alpha or whatever phrase we want to call this)

The name is just something funny that I came up with based on grind fiction and it sounds awesome.

# Guide to use the program since that's not implemented yet
I did say this was a very very debuggy and early version so there isn't an in program guide (it's one of the next major things to be done since again the basic proof of concept is in place)
- Press Space to start recording
- Play notes using the keyboard keys, the on screen buttons (press the ones with icons that resemble notes), and or a midi keyboard device if you have one plugged in
- Press Escape to stop recording
- Press ctrl + s  to enter the saving menu (no on screen indicator for this right now, again proof of concept)
    - By pressing Enter in here you can type in a file name to save the project itself
    - By pressing Space in here the program will play and record it's own audio, after pressing escape, you can type in a file to save the recorded audio as a WAV
- Press ctrl + l to enter the loading menu, type in the name of a file (make sure the directory is correct) to load it (works with Radio Station Rawr Berry Beats projects, and midis * some midi functionality isn't fully coded, and some might not fully work, but the idea for getting the note positions should in this version)
- Press period you can go back to the start of the project
- Hold Q and move the cursor left or right relative to the playing bar to move it much quicker ( * Flashing Warning if you are loading in large files *)
- Press ctrl + a to select all notes on a track
- Press ctrl + d to select all notes on a track to the right of the playing bar
- Press alt to open up the selecting box ( * WIP)
   - pressing up, down, left, and right can adjust which notes are selected by the box (the notes selected will play repeatedly, the debuggy pink box that loops is the WIP indicator for that)
   - press enter to stop adjusting and select the notes, these notes can then be edited with some functions below:
        - Press R, type in a number, and press enter to move the cursor (and any selected notes) to that x value
        - Press Z to increase the length of the notes
        - Press X to decrease the length of the notes
        - Press V to incease the volume of the selected notes
        - Press B to decrease the volume of the selected notes
        - Press I to move the selected notes to the track above
        - Press O to move the selected notes to the track below
        - Press up, down, left, and right to reposition the selected notes in those respective directions (with up increasing the pitch and down decreasing the pitch, again after the notes are selected)
- Press shift to open the shift tracks menu (* WIP)
   - pressing left will iterate backwards through the tracks
   - pressing right will iterate forwards through the tracks, if there is no track greater than the current one, then it will make a new track (this part is where it is a WIP)
   - press up to increase the volume of all the notes on the track
   - press down to decrease the volume of all the notes on the track
   - press esc to exit the shifting tracks menu (you will be moved to the track that was selected and notes will be on that track denoted by their color)
- Press Backspace to open up the remapping menu * potentially buggy not fully finished
  - iterate through the actions to remap using left and right
  - select the action you wish to remap with enter
  - press the button you wish to map to the action


# Why Godot
I mentioned above that I'd love to see other's takes on something like this and I'm curious as to what they would use to build it, but I picked Godot for a couple of reasons
- I'm familiar with using game engines
- That said, I hadn't used Godot Prior and wanted to learn how
- game engines in general have a lot of built ins that can/have already helped (Godot in particular already had support for midi keyboard devices which is awesome, this can also help with loading up the project on different operating systems including mobile)
- As of 2025 Godot has screen reader support (https://godotengine.org/article/dev-snapshot-godot-4-5-dev-3/)
- Godot is also open source so if we need to edit it specifically for this project we can
- Since it's open source it is free and light weight (it works on my nearly 10 year old laptop) so more folks should be able to run it (you can download it here: https://godotengine.org/)

# License
We are using MIT which the long story short of for this project means you are allowed to copy the code, make your own additions, and even sell it. This also means that if there is any sort of damage caused by the program or any programs that branch from this main project, creators are not liable for the damages. But that's just a tldr, you can read over the whole license in LICENSE.txt and throughout the internet.

# General Code Policy (comments, expectations, ai, etc.)
I am new to opensource projects and git hub as a whole so feel free to make some suggestions as to how the project should operate, but right now if you want to add on to the code feel free to make a new branch with whatever additions you want. 
- If people like the branch then we will merge it to the main one (with the author's permission ofc, I know the license technically means we can do that legally speaking, but I would still like to ask). This way allows for freedom with additions, means people can search for specifics if they want to, and keeps the main one clean.
- Speaking of keeping it clean, you don't need to comment everything or have every piece of code be 100% perfect, but I would appreciate it if there is an effort to explain the code such that people know places where you left off, or are stuck (just to make helping out easier).
- If you refrence something (website, book, video, etc.) please also credit those (no need to be super formal, but some link or means of letting someone find the original piece helps with the above).
- Because of the policy above, while you technically can do whatever you want with your own code we are not planning on having AI generated code in the main branch. This is because tbh I don't know the full legal and computational specifics on it, and like giving people agency with what they make/code (that's kinda the whole point of this project in the first place).

#Contact
Still setting this up fully for a couple of reasons, and am down for suggestions on what works best for open source project, but for now just use github (create issues to suggest features). Will have a more organized way to allow for contact later.

#Credits
(feel free to add your name here if you pull/make your own copy, if you get added to the main branch you will also be added here)
Programmers, Artists, contributors of any kind for this project directly
- NeonBreeze
Refrences for code
- Godot documentation (for audio capture, and a general idea for how the engine works):
https://docs.godotengine.org/en/latest/
- delta time calc comes from here (Craig Stuart Sapp):
			https://www.ccarh.org/courses/253/handout/vlv/
- understanding the midi formatting comes from here (The Sonic Spot Founded by Mitch Bechtel, also shoutouts to the internet archive/wayback machine for this link):
			https://web.archive.org/web/20141227205754/http://www.sonicspot.com:80/guide/midifiles.html
- pitch calculation (Miller Puckette from UCSD and Shubha Tewari in The Physics of Music on UMass Amherst):
            https://msp.ucsd.edu/techniques/v0.08/book-html/node8.html
            https://openbooks.library.umass.edu/physicsofmusic/chapter/lab-activity-7/
