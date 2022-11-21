# GDData

Create sheets to manage all your data in your Godot games using expressions !

## Expression:
Use [Godot expression](https://docs.godotengine.org/en/stable/tutorials/scripting/evaluating_expressions.html) system to compute your data.

An expression can be:
- A simple mathematical expression such as ```(2 + 4) * 16/4.0```.
- A built-in method call like ```deg_2_rad(90)```.
- A conditional statements result like ```test(1 < 2, "Obvious", "Oh wait ...")```
- A function using any other column value such as ```values.col1 + (values.col2 * 2)```

## Handled type:
- Text
- Number
- Boolean
- Color
- File
- Reference (Line key from another sheet)
- Object (Array or Dictionary)

## Handled file extensions:
- Image (.bmp, .dds, .exr, .hdr, .jpg, .jpeg, .png, .tga, .svg, .svgz, .webp)
- Audio (.wav, .ogg, .mp3)
- 3D (.gltf, .glb, .dae, .escn, .fbx, .obj)
- GD Scene (.tscn)
- GD Script (.gd)
- GD Resource (.tres)
- Any

## Installation

To install a plugin, download it as a ZIP archive.

Extract the ZIP archive and move the addons/ folder it contains into your project folder. If your project already contains an addons/ folder, move the plugin's addons/ folder into your project folder to merge the new folder contents with the existing one. Your file manager may ask you whether to write into the folder; answer Yes. No files will be overwritten in the process.

---

[MIT License](https://github.com/wod-rsarrazin/gd-data/blob/main/LICENSE)
