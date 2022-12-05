# GDData

Create sheets to manage all your data in your Godot games using expressions !

<img src="screenshots/screenshot_main.png">

## Features:
All columns will be able to define an expression that will automatically calculate all your data using [Godot expression](https://docs.godotengine.org/en/stable/tutorials/scripting/evaluating_expressions.html) system.
An expression ca be:
- A simple mathematical expression such as ```(2 + 4) * 16/4.0```.
- A built-in method call like ```deg_2_rad(90)```.
- A conditional statements result like ```test(1 < 2, "Obvious", "Oh wait ...")```
- A function using any other column value such as ```values.col1 + (values.col2 * 2)```
  <img src="screenshots/screenshot_column.png" height="200">

Some other awesome feature will be able to help you to organize your game data.
- Lock editor to prevent error
- Set a default value for each column
- Define tags and create group based on a specific expression to improve searching
  <img src="screenshots/screenshot_group.png" height="200">

## Handled type:
You can visualize and edit all your data depending on the type.

- **Text**: Any string \
  <img src="screenshots/screenshot_editor_text.png" height="100">
- **Number**: Any number \
  <img src="screenshots/screenshot_editor_number.png" height="100">
- **Bool**: true / false \
  <img src="screenshots/screenshot_editor_bool.png" height="100">
- **Color**: HTML hexadecimal color string in RGBA format (ex: "ff34f822") \
  <img src="screenshots/screenshot_editor_color.png" height="100">
- **Reference**: To another line from another sheet \
  <img src="screenshots/screenshot_editor_reference.png" height="100">
- **Object**: Any array or dictionary \
  <img src="screenshots/screenshot_editor_object.png" height="100">
- **Region**: An image that crops out part of another image \
  <img src="screenshots/screenshot_editor_region.png" height="100">
- **File**: Any file \
  <img src="screenshots/screenshot_editor_file.png" height="100">
- **Image**: .bmp, .dds, .exr, .hdr, .jpg, .jpeg, .png, .tga, .svg, .svgz, .webp \
  <img src="screenshots/screenshot_editor_image.png" height="100">
- **Audio**: .wav, .ogg, .mp3 \
  <img src="screenshots/screenshot_editor_audio.png" height="100">
- **3D**: .gltf, .glb, .dae, .escn, .fbx, .obj \
  <img src="screenshots/screenshot_editor_3d.png" height="100">
- **Scene**: .tscn \
  <img src="screenshots/screenshot_editor_scene.png" height="100">
- **Script**: .gd \
  <img src="screenshots/screenshot_editor_script.png" height="100">
- **Resource**: .tres \
  <img src="screenshots/screenshot_editor_resource.png" height="100">

## Installation

To install a plugin, download it as a ZIP archive.

Extract the ZIP archive and move the addons/ folder it contains into your project folder. If your project already contains an addons/ folder, move the plugin's addons/ folder into your project folder to merge the new folder contents with the existing one. Your file manager may ask you whether to write into the folder; answer Yes. No files will be overwritten in the process.

---

[MIT License](https://github.com/wod-rsarrazin/gd-data/blob/main/LICENSE)
