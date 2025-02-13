# Contributing
We welcome any contributions to minigames, bossgames, special rounds, themes, or to the map itself!

## Style
Please follow the codebase's style when making contributions:
* No semicolons in VScript. Semicolons are optional in Squirrel and TF2Ware Ultimate does *not* use them.
* Do not define constants or global variables within a minigame/bossgame/specialround scope.
* Please use CRLF for line breaks.
* Indents should be 4 spaces

If in doubt, there are plenty of examples for each type of contribution - try to match how they are laid out.

## Getting started
To get started, you will need to load the unpacked map of TF2Ware Ultimate, so you can modify assets and scripts easily.

First, download this repository into your TF2's `custom` folder. 

The repo comes with a built BSP without packed content. Type `map tf2ware_ultimate` in console to load this.

## Minigames / Bossgames
The logic for minigames and bossgames in TF2Ware Ultimate is the same, they just are just stored in different locations. Go into [`scripts/vscripts/tf2ware_ultimate`](scripts/vscripts/tf2ware_ultimate/) and pick either `minigames` or `bossgames`.
Create a new .nut file there.

Next, create a `Ware_MinigameData` definition. Look at the other scripts in the same folder for plenty of examples.

Most of the documentation is in the .nut files themselves. All the settings and functions allowed for usage are documented in the [`api`](scripts/vscripts/tf2ware_ultimate/api/) folder. Note that many common minigame features such as thirdperson (`thirdperson`), starting all players passed (`start_pass`), min/max players (`min_players`/`max_players`), etc. are available as parameters in `Ware_MinigameData`. Common callbacks are also documented in this class, see [the minigame API](scripts/vscripts/tf2ware_ultimate/api/minigame.nut) for full documentation.

### Overlays
The text overlays for minigames and bossgames are static images. To generate one, run the `generate_text` Python script in the `tools` folder. If you are on Linux you must have `wine` installed as this script runs a `.exe` file.

This script will automatically place all the materials and textures in the correct folder. The overlay file name must be the same as the minigame/bossgame file name (without the `.nut`). This can be overrided with the `custom_overlay` parameter, but this is only intended for minigames with separate missions, modes, or commonly used overlays (such as `get_end`).

For the overlay text, try be as concise as possible - remember most minigames are only a few seconds long, even before speedup. For example **GET TO THE END!** is better than **GET TO THE END OF THE COURSE!**. The convention is white text with an exclamation mark at the end, though exceptions can be made for emphasis. Any "failure" overlays, such as the one used in [Double Jump](scripts/vscripts/tf2ware_ultimate/minigames/double_jump.nut) are typically red and in brackets.

For longer overlays or those using multiple colours, manual editing is required - longer overlays in particular will need to have a line break to prevent going of the screen, which is *not* handled by the script. To achieve this, comment out the lines `os.remove(name1)` and `os.remove(name2)` in the python script. This will preserve the created `.png` files, which can be processed in any graphics editor such as [GIMP](https://www.gimp.org/). Make sure to uncomment these lines again before submitting a PR.

The processed files can then be converted using VTFEdit and manually imported into the repo. One of the generated `.png`s is a reversed text version which must be added to the VTF as a separate frame by importing both into VTFEdit simultaneously.

A list of commonly used overlays can be seen below. The intention for these is to avoid any duplicate overlays with identical text. These can be used by simply setting the minigame parameter `custom_overlay = "<overlay_name>"`.

| Overlay Name | Overlay Text |
| --- | --- |
| `fight` | **FIGHT AND STAY ALIVE!** |
| `get_end` | **GET TO THE END!** |
| `kill_player` | **KILL A PLAYER!** |
| `push_enemy` | **PUSH AWAY THE ENEMIES!** |
| `survive` | **SURVIVE!** |

### Music
All minigames and bossgames require minigame music. This music must be at least the same duration as the minigame, though it can be longer - if so it will be stopped manually. It's not uncommon for minigame duration to be based on the music's duration, though gameplay should still be the main consideration.

For minigames, you are welcome to use existing minigame music, but for bossgames new music is typically required. See [here](#contributing-audio) for guidelines on contributing audio.

## Special Rounds
The process is similar for Special Rounds, though with some small differences. To get started, create a .nut file in [`scripts/vscripts/tf2ware_ultimate/specialrounds`](scripts/vscripts/tf2ware_ultimate/specialrounds/)

Special Rounds use a distinct `Ware_SpecialRoundData` class, make a definition for this. Look in other Special Rounds for plenty of examples. Note that some parameters that share a name with minigame data parameters are used slightly differently - please read [the special round API](scripts/vscripts/tf2ware_ultimate/api/specialround.nut) carefully to ensure you use them correctly.

Special Rounds have some unique parameters and callbacks that minigames don't have (such as `OnMinigameStart()` and `OnMinigameEnd()`) which may be useful too.

## Testing

Once you are done, add the file's name to the `minigames.cfg`/`bossgames.cfg`/`specialrounds.cfg` in the `tf/scriptdata/tf2ware_ultimate` folder. 

Note that minigames, bossgames and special rounds are hot loaded, therefore changes will be effective immediately. Use the `!ware_force` series of chat commands to force a specific one (type `!ware_help` in chat).

## Themes

### Contributing Audio

## Mapping

Mapping changes are welcome, however vmf changes are more involved to merge (especially if the map has been changed in the meantime). To help with this, please be descriptive about changes made, and test your compile before submitting a PR.

Note when compiling, add the following parameters to VRAD: `-noskyboxrecurse -staticproppolys -textureshadows`. If using the Hammer/Hammer++ compiler, this is in Expert under $light.exe. If using CompilePal, you can add these parameters inidividually under VRAD.