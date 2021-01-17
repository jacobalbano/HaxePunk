An opinionated refactor of Haxepunk

Code has been dramatically cut down, changes have been made to achieve compatibility with OpenFL 9x.
Not an official project, just one that is meant to make it easier for me to port some of my old Flashpunk games to Haxe.

Also, the `Scene` class has been renamed back to `World`.

### How to use
---
- Make a copy of the entire `template/` directory and rename it to whatever you want
- Edit `project.xml`:
  - Set `<meta>` attributes as appropriate
  - If you don't want to use the preloader, edit the `<app>` tag to remove the `preloader` attribute
  - Modify the `<source path="{{Haxepunk}}"/>` tag to point to the folder which *contains* the `haxepunk/` source folder
- Open the folder in VSCode, select build target, and run
- Builds will be placed in the `export/` folder
