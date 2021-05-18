[ INDEX ]

	1:1 Intro
	2:1 playername image
	4:1 stage portrait
	5:1 character costume
	6:1 players.xml
	7:1 character menu
	8:1 death portraits
	9:1 main.lua
	10:1 metadata


[ 1:1 Intro ]
Welcome to the "Template Mod Character"
This readme file will guide you through each step of what you need to do.
some files may also have extra comments and instructions to further help or clarify things.

Before you begin reading any further be sure to have a character name in mind. that name will be used
throughout this entire guide.

This file uses an index system,
at the top each section will be this format " [ SECTION:SUBSECTION SECTION NAME ] "
using this you can quickly search through this file and find what your looking for.
SECTION is just a section number
SUBSECTION is what step within the section, for stuff that has multiple steps
SECTION NAME is just a generalized name for what you'll be doing in that section.
Mostly there just so you can use the search function to quickly get back to it (CTRL+F) 

Note: these sections are not necessarily in the order they could be done.

Extra Resources and Notes:
All Image files in Isaac need to be a 32 bit depth PNG file.
Image instructions will be a generalized instruction, as each image editor is slightly different.
you may need to figure out how to do certain things within your image editor of choice.


[ 2:1 playername Image ]
In this section we will be creating the player name image that shows up when you enter a boss arena
to create the base for this image you can use (https://wofsauge.github.io/IsaacTools/text_generator.html)

this file can be found in ".\resources\gfx\ui\boss"

The image created by the website will be much too big with the text much too small. but at least has the right font
Open your preferred image editor and do these steps.
First move the text to roughly in the center of the image instead of the top left corner
Next crop the image to exactly 192 x 64, this is the image size the game uses for the playername
lastly, do a transform on the text and increase its scale by 200% on both the X and Y.
using a Fill change the color of the text to #c7b299.
if you have the ability to do so in your image editor, true align the text to be centered on both the X and the Y
save the file out to playername_charactername.png (lowercase the name).


[ 4:1 stage portrait ]
for this section we will create the player portrait used when changing floors.
this file can be found in ".\resources\gfx\ui\stage"

the file needs to be 144 x 144
just like before how you do this is up to you, but you can always edit my template.
once your done be the file is named "playerportrait_charactername.png" just like the others lowercase the name


[ 5:1 character costume ]
this is what will determine what your character will look like.
this file can be found in ".\resources\gfx\characters\costumes"
its highly recommened to use my template and just edit it instead of trying to make your own!

the file needs to be a 512x512
be sure to name the file "character_charactername.png" just like all the rest, lowercase the name.


[ 6:1 players.xml ]
ok, with all of the basic images done and out of the way, we need to head over to players.xml to actually tell the game about our new character
players.xml can be found in ".\content\"
there is instructions once you have openned the file. follow those then come back here.


[ 7:1 character menu ]
TODO

[ 8:1 death portraits ]
TODO

[ 9:1 main.lua ]
Ok, now that we have all the image stuff out of the way. lets actually get your characters base items/stats setup.
go back to the root of your mod and open main.lua

there is instructions in the file of what you need to do, even if you have 0 experience with coding it shouldn't be
difficult to setup the file.

you can remove the comments if you *want* when your done. but leaving them there won't harm anything :)

[ 10:1 metadata ]
your almost there!

the first thing you want to do is rename the folder to whatever you want for your mod.
NO SPACES, only lowercase characters, use underscores _ for spaces
then open the metadata.xml and rename the <directory> line with whatever you named the folder
DO NOT CHANGE ANYTHING ELSE

once done save and close the metadata.xml file.
now to actually update and do the rest, go to your isaac install directory...

you can get to this in steam by right clicking the game in your library
going down to Manage
and click "Browse Local Files"

go to the tools folder
then ModUploader folder
and open the ModUploader.exe

once open click the "Choose Mod..."
browse to your mod folder and choose the metadata.xml

now you can change everything to your hearts galore.
don't hit upload or worry about the thumbnail image, or "change notes" section yet.
once your done close the uploader, it will save what you did.