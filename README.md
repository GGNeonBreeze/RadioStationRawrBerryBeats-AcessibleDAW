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

# Why Godot
I mentioned above that I'd love to see other's takes on something like this and I'm curious as to what they would use to build it, but I picked Godot for a couple of reasons
- I'm familiar with using game engines
- That said, I hadn't used Godot Prior and wanted to learn how
- game engines in general have a lot of built ins that can/have already helped (Godot in particular already had support for midi keyboard devices which is awesome, this can also help with loading up the project on different operating systems including mobile)
- As of 2025 Godot has screen reader support (https://godotengine.org/article/dev-snapshot-godot-4-5-dev-3/)
- Godot is also open source so if we need to edit it specifically for this project we can
- Since it's open source it is free and light weight (it works on my nearly 10 year old laptop) so more folks should be able to run it

