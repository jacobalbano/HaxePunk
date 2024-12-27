An opinionated refactor of Haxepunk

Code has been dramatically cut down, changes have been made to achieve compatibility with OpenFL 9x.
Not an official project, just one that is meant to make it easier for me to port some of my old Flashpunk games to Haxe.

Also, the `Scene` class has been renamed back to `World`.

### Setup
```
haxelib install lime
haxelib install openfl
haxelib run lime setup
```

### How to use
---
- Rename the `template/` directory to whatever you want as your project folder
- Edit `project.xml`:
  - Set `<meta>` attributes as appropriate
  - If you don't want to use the preloader, edit the `<app>` tag to remove the `preloader` attribute
- Open the project folder in VSCode, select build target, and run
- Builds will be placed in the `export/` folder
