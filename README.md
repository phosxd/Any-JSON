<div align="middle">

<img src="git_assets/banner.png" align=""></img>

Godot 4.5 plugin to convert any Godot variant to raw JSON & back, with absolutely no data loss.

</div>

**Version:** 1.1.0

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
- `type_exclusions (Array[String])`: Types of variables/properties that will be discarded.
- `property_exclusions (Dictionary[String,Array[String]])`: Names of properties that will not be recognized for each object. Can be used to exclude for example `Resource` specific properties like `resource_path`.
- `exclude_private_properties (bool)`: Exclude properties that start with an underscore "_".
- `exclude_properties_set_to_default (bool)`: Exclude properties whoms values are the same as the default of that property. This is used to reduce the amount of data we have to store, but isn't recommended if the defaults of class properties are expected to change.

**Advanced Rules:**
- `property_references (Dictionary[String,Array[String]])`: Names of object properties that will be converted to a named reference when converting to JSON. Named values can be supplied during conversion back to the original item with `references`.
- `references (Dictionary[String,Dictionary[String,Variant]])`: Variants to replace property references with.
- `instantiator (Callable(object_class:String) -> Object)`: Used for implementing custom logic for object instantiation. Useful for instantiating with objects with arguments or changing values after instantiation. The returned object will be used to compare default values when converting to AJSON, & will be used as a base when converting from AJSON.
- `midpoint (Callable(item:Variant, ruleset:Dictionary) -> bool)`: Called right before conversion for every variable & property including nested ones. Returning `true` will permit conversion, returning `false` will discard the conversion for that item.

# **Limitations:**
## Circular references:
Serializing an object that has a property that can lead back to the original object is a circular reference & can cause infinite recursion if you are not aware & carful. To get around this, you can utilize the `property_references` rule.

# **Example usage:**
## Adding to object registry:
Simply add the name of the class & the class itself to the `A2J.object_registry` dictionary. Do not add an instance of the object to the registry.
```gdscript
class custom_class_1:
  var some_value:bool = true


class custom_class_2:
  var some_value:int = 1


A2J.object_registry.merge({
  'custom_1': custom_class_1,
  'custom_2': custom_class_2,
})
```
In this case, we are using the `merge` method to add multiple objects while preserving all the default ones.

## Serializing to AJSON:
Just pass the item you want to serialize to the `A2J.to_json` method. You can provide a custom ruleset, otherwise it will use the default ruleset defined at `A2J.default_ruleset_to`.
```gdscript
var literally_any_thing := Vector3(1,2,3)
var result = A2J.to_json(literally_any_thing)
if result == null:
  print('something went wrong')
else:
  print(result)


# With custom ruleset.
class custom_class:
  var_1:int = 1
  var_2:float = 0.5

var custom_ruleset := {
  # Excludes the "var_1" property for "custom_class".
  'property_exclusions': {
	'custom_class': [
	  'var_1',
    ],
  },
}

result = A2J.to_json(custom_class.new(), custom_ruleset)
if result == null:
  print('something went wrong')
else:
  print(result)
```

## Serializing back from AJSON:
Just pass the item you want to serialize to the `A2J.from_json` method. You can provide a custom ruleset, otherwise it will use the default ruleset defined at `A2J.default_ruleset_from`.
```gdscript
var ajson = A2J.to_json(Vector3(1,2,3))
var result = A2J.from_json(ajson)
print(result) # Prints "(1, 2, 3)".
print(type_string(typeof(result))) # Prints "Vector3".
```
