<div align="middle">

<img src="git_assets/banner.png" align=""></img>

Godot 4.5 plugin to convert any Godot variant to raw JSON & back, with absolutely no data loss.

</div>

**Version:** 1.0.0

[![Release](https://img.shields.io/badge/Need_help%3F-gray?style=flat&logo=discord)](https://dsc.gg/sohp)

# Simple run-down:
This plugin can serialize absolutely any data type within Godot to raw readable JSON so long as the appropriate type handlers have been implemented. You can serialize any custom & built-in classes too, as long as they are listed in `A2J.object_registry`, most common objects are already registered by default, but custom classes & more obscure built-in classes need to be manually registered.

The original goal of this plugin was to have a way to serialize resources to independent JSON files (from within the editor) that can be stored on the disk with extreme flexibility when it comes to what & how things get converted.

# **Features:**
## All built-in types handled:
All types listed below can be converted to JSON & back while preserving every detail.
- Bool
- Int
- Float
- String
- Object (both built-in & custom classes supported)
- Array
- Dictionary
- Vector2, Vector2i
- Vector3, Vector3i
- Vector4, Vector4i
- PackedByteArray
- PackedInt32Array, PackedInt64Array
- PackedFloat32Array, PackedFloat64Array
- PackedVector2Array, PackedVector3Array, PackedVector4Array
- PackedColorArray
- PackedStringArray
- StringName
- NodePath
- Color
- Plane
- Quaternion
- Rect2, Rect2i
- AABB
- Basis
- Transform2D
- Transform3D
- Projection

As of Godot 4.5 this is almost every `Variant.Type` available in GDScript that aren't run-time exclusive (like `RID`). If new types are added to GDScript you can add your own handler by extending `A2JTypeHandler` & adding an instance of the handler to `A2J.type_handler`.

Here are the types that are not yet supported but are planned to be:
- Callable

Here are the types that will never be supported & their reasons:
- Signal: signals are too complex due to all the moving parts & references. On top of that, there is no use case that comes to mind where saving this to disk would be useful.
- RID: this type is exclusively used for run time resource identifiers & would not be useful to save, as stated in the GDScript documentation.

## Error logging:
There is a dedicated error logging system so you don't have to deal with obscure error messages or unexpected behavior when the plugin isn't used properly.
## Modular & extendable:
Everything is coded in GDScript across distinct classes & files, allowing for easy modification & extension.
## Editor-ready:
Unlike the most common alternatives, Any-JSON can work in the editor so it can be used within other editor tools.
A downside to `ResourceSaver` is that the resource path, UID, & other meta data are saved when used in the editor. This was one of the main drives for me to make Any-JSON, as this would not be viable for some of my purposes.
## Rulesets:
A "ruleset" can be supplied when converting to or from AJSON allowing fine control over serialization. Something you don't get with `var_to_str` & not as much with `ResourceSaver`.

**Basic rules:**
- `type_exclusions` (Array\[String\]): Types of variables/properties that will be discarded.
- `property_exclusions` (Dictionary\[String,Array\[String\]\]): Names of properties that will not be recognized for each object. Can be used to exclude for example `Resource` specific properties like `resource_path`.
- `convert_properties_to_references` (Dictionary[String,Array[String]]): Names of object properties that will be converted to a named reference when converting to JSON. Named values can be supplied during conversion back to the original item with `named_references`.
- `named_references` (Dictionary[String,Dictionary[String,Variant]]): Variants to replace named references with. See `convert_properties_to_references`.

**Advanced rules:**
- `midpoint (in-dev)` (Callable(item:Variant, ruleset:Dictionary) -> bool): Called right before conversion for every variable & property including nested ones. Returning `true` will permit conversion, returning `false` will discard the conversion for that item.

# **Limitations:**
## Circular references:
Serializing an object that has a property that can lead back to the original object is a circular reference & can cause infinite recursion if you are not aware & carful. To get around this, you can utilize the `convert_properties_to_references` rule.
## Non-string dictionary keys:
Currently, Any-JSON will throw an error if it encounters a dictionary with non-string keys. This is something I will fix in a later version.
