[ INDEX ]

	1:1 Intro
	2:1 playername image
	3:1 stage portrait
	4:1 character costume
	4:2 character costume
	5:1 players.xml
	6:1 character menu
	6:2 character menu
	7:1 death portraits
	7:2 death portraits
	8:1 main.lua
	9:1 metadata
	10:1 uploading
	11:1 workshop

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

Keep an original copy of this file, you will need it later!

The image created by the website will be much too big with the text much too small. but at least has the right font
Open your preferred image editor and do these steps.
First move the text to roughly in the center of the image instead of the top left corner
Next crop the image to exactly 192 x 64, this is the image size the game uses for the playername
lastly, do a transform on the text and increase its scale by 200% on both the X and Y.
using a Fill change the color of the text to #c7b299.
if you have the ability to do so in your image editor, true align the text to be centered on both the X and the Y
save the file out to playername_charactername.png (lowercase the name).


[ 3:1 stage portrait ]
for this section we will create the player portrait used when changing floors.
this file can be found in ".\resources\gfx\ui\stage"

the file needs to be 144 x 144
just like before how you do this is up to you, but you can always edit my template.
once your done be the file is named "playerportrait_charactername.png" just like the others lowercase the name


[ 4:1 character costume ]
this is what will determine what your character will look like.
this file can be found in ".\resources\gfx\characters\costumes"
its highly recommened to use my template and just edit it instead of trying to make your own!

the file needs to be a 512x512
be sure to name the file "character_charactername.png" just like all the rest, lowercase the name.

[ 4:2 character costume ]
Included in this template is a simple cat ears costume. along with its PSD reference I used to create it.
this template mod allows you to apply a costume for both the default and tainted character separately

creating a costume takes 4 steps
1. make the costume frames in "\resources\gfx\characters\costumes"
	- you need 8 frames total, 1 for each each facing direction + 1 for each heading direction while firing
2. setup the anm2 in "\resources\gfx\characters"
	- you can use the animation editor in the tools folder of isaac install (this is covered 6:2)
3. tell the game your costume exists by adding it to costumes2.xml in "\content"
4. apply the costume in main.lua

If you do not have / want a costume, you can delete these the costumes2.xml, along with my example costume files:
"character_alpha_cat_ears.anm2"
"character_cat_ears_template.png"

regardless if you do a costume or not be sure to delete the "character_cat_ears_template_reference.psd" file
when your done using it (if you do).

[ 5:1 players.xml ]
ok, with all of the basic images done and out of the way, we need to head over to players.xml to actually tell the game about our new character
players.xml can be found in ".\content\"
there is instructions once you have openned the file. follow those then come back here.


[ 6:1 character menu ]
ok, this is where It can get a little complicated.
let's start with the simple part. Go to "\content\gfx"
and open charactermenu.png with an editor

you can remove the template Name and template picture I put in there.
instead put your characters name and picture in there.
*HINT: remember how I told you to keep a copy of that charactername file? this is why

If you have a tainted character you'll need to do the same thing, but in charactermenualt.png

[ 6:2 character menu ]
*DEPSITE THIS BEING NEXT I SUGGEST DOING 7:1 FIRST*
you'll need to head to the tools folder again this time to open the animation editor
"\tools\IsaacAnimationEditor"

after opening that editor go to do "\content\gfx" and open charactermenu.anm2
inside of there on the right side panel you'll see the template character "Alpha"
click that and push duplicate. Rename it to your character's name (including caps)
IT MUST BE EXACTLY LIKE THAT OR IT WILL NOT SHOW UP.
then you can delete Alpha.

now make sure ur character is selected on the right side.
down below is the different parts of the animation, clicking the yellow square with a dot will let you edit that frame.
doing so will bring up the sprite sheet (charactermenu.png) where you can select what to replace it with
the tools for all of that are on the most right side of the program.
when you are done changing what you want, save it.
It will warn you about overwriting something that already exists, accept and overwrite.

if you have a tainted character do the same in charactermenualt.anm2

now do this same process with characterportrait.anm2 and characterportraitalt.anm2
both together make up what you see on your main menu.

[ 7:1 death portraits ]
this is mostly like 6:1, open "death portraits.png" with your editor
remove what I put in there and replace with your content.

you do not need to do anything for the tainted character unless you're like me and made the character have a different name
on the tainted side OMEGA instead of ALPHA.
if you did just make sure to put your tainted character's name in there too.

[ 7:2 death portraits ]
*I HIGHLY SUGGEST GOING BACK TO 6:2 and Doing this and that one at the same time*
ok, now we just need to do the death screen anm2, so open "death screen.anm2"
now just like with 6:2 duplicate Alpha, renaming it your characters name
then delete Alpha

now this is where it's a little different, the only thing you need to change in this file is the Name sprite.
if you want to change other things go ahead of course, but I won't be covering that.

once your done save it.

If you have a tainted character that has a different name from its default then you need to do the same thing in "death screen alt.anm2"
otherwise, just delete the alt anm2 altogether.

[ 8:1 main.lua ]
Ok, now that we have all the image stuff out of the way. lets actually get your characters base items/stats setup.
go back to the root of your mod and open main.lua

there is instructions in the file of what you need to do, even if you have 0 experience with coding it shouldn't be
difficult to setup the file.

you can remove the comments if you *want* when your done. but leaving them there won't harm anything :)

[ 9:1 metadata ]
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

[ 10:1 Uploading ]
Ok, now is a good time to double check you have everything in order.

then we need to create a thumbnail for the workshop "THIS DOES NOT GO IN THE MOD FOLDER" it is only used by the workshop
and uploading it would just take up space.

the thumbnail (which is what you see when scrolling past) is a 268x268 image, however, you can probably just do like 512x512 and let it down scale/crop it

the big image you get when you click onto the actual mod page is basically just a 16:9 ratio image, I would suggest atleast 1920x1080.

these are mostly up to you, but below is some suggestions/helpful tips if you have never done this before.

for the thumbnail image you should aim to show off the main part of your mod (in which case the character), without making it too busy.
for example, a druid type character against a forest will be very poor, as literally everything is green.
instead for a druid do something like a zoom in of him sitting on a log, with the camera angle towards the sky to give good contrast.

now for the big image you want to show off what your mod is all about, so maybe load up the game with your character and take multiple pictures
from the main menu, to your character in action. you can add multiple of these types of images to your mod, so don't be afraid
you can also add things like videos if you have something on youtube uploaded.

now once you have at least a thumbnail finished go the tools folder in Isaac and open the ModUploader
once again select your mods metadata.xml only this time well be doing the things we didn't bother with last time

so...
for change notes I highly recommend for your 1.0 release you simply put "Initial Commmit" or something like that.
then click the change button and find your thumbnail image (Not the big ones, you do that on the workshop page)
finally if you didn't already set your tags.

if you want you can set the intial visibility to "Private" which means no one will see it.
then push Upload Mod.

once it finishes close the tool (Don't bother with the view mod button, it opens in a browser which is very not useful)
then open Steam, find Isaac and click "Workshop"
go under the "Browse" section and click "Subscribed Items"
at the top of that page you can change it to "By YOUR STEAM NAME" ex "by manaphoenix"
click that and it will reload the page, and you can now see your mod that you uploaded.
click that and lets setup the rest of the things.

[ 11:1 Workshop ]
On the right side when you will see Owner Controls

if you have more images you can add/remove that from "Add/edit images & videos"

what is recommended you do at least tho is go down to "Add/Remove Required DLC" and select the DLC that your mod needs to run
(MODDING only if you have mininum AB+, but be sure to also select Repentance if your mod uses stuff from it)

once done, the only thing you may need to change is the Visibility back to Public, and there you go you did it!
don't forget to post in #promotion in the discord if your part of the isaac modding discord ;)
