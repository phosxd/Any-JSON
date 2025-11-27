<div align="middle">

<img src="git_assets/banner.png" align=""></img>

Godot 4.5 plugin to convert any Godot variant to raw JSON & back, with absolutely no data loss.

</div>

**Version:** 1.2.0

[![Release](https://img.shields.io/badge/Need_help%3F-gray?style=flat&logo=discord)](https://dsc.gg/sohp)

# **Introduction:**
This plugin can serialize any data type within Godot to raw readable JSON so long as the appropriate type handlers have been implemented. You can serialize any custom & built-in classes too.

Any-JSON is very simple to use, no need for setup or specification. Most common classes should already be supported, but if you run into an object with an unsupported class you can simply add that class to the `A2J.object_registry` & try again. For finer control over how things get done, see [rulesets](#rulesets).

After converting your item to an AJSON dictionary, you can use `JSON.stringify` to turn it into a raw text string but you will need to convert it back to a dictionary using `JSON.parse_string` if you want to convert it back to the original item.

# **Table of contents:**
- [Features](#features)
  - [Supported types](#all-types-handled)
  - [Recursive](#nesting-all-the-way)
  - [Modular](#modular)
  - [Editor-ready](#editor-ready)
  - [Rulesets](#rulesets)
  - [Error logs](#error-logs)
- [Limitations](#limitations)
  - [Local classes](#handling-local-classes)
- [Examples](#example-usage)
  - [Adding to object registry](#adding-to-object-registry)
  - [Serializing to AJSON](#serializing-to-ajson)
  - [Serializing back from AJSON](#serializing-back-from-ajson)
  - [More...](./examples/)

# Features
## All types handled
All types listed below can be converted to JSON & back while preserving every detail.
- Bool
- Int
- Float
- String
- Object (both built-in & custom classes supported)
- Array
- Dictionary (any key type supported)
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

As of Godot 4.5 this is almost every `Variant.Type` available in GDScript that isn't run-time exclusive (like `RID`). If new types are added to GDScript you can add your own handler by extending `A2JTypeHandler` & adding an instance of the handler to `A2J.type_handlers`.

**Note:** Most packed array types are converted to hexadecimal strings, so they will not be human readable. This might change in the future.

Here are the types that will never be supported & their reasons:
- Signal: signals are too complex due to all the moving parts & references. On top of that, there is no use case that comes to mind where saving this to disk would be useful.
- RID: this type is exclusively used for run time resource identifiers & would not be useful to save, as stated in the GDScript documentation.

## Nesting all the way
All children of the item you are converting are recursively serialized. This means you can convert entire scene trees & every single resource it uses if you wanted to.

This is a big advantage over some other plugins.

Any-JSON also handles circular references, this means a property can link back to the original object but it will simply be converted to a reference instead of triggering infinite recursion.
This works by storing an index value for every *unique* object & a reference to that index when it encounters a copy. However this does mean if the index values are tampered with in the JSON it could produce unexpected behavior.

## Modular
Everything is coded in GDScript across distinct classes & files, allowing for easy modification & extension.

## Editor-ready
Unlike the most common alternatives, Any-JSON can work in the editor so it can be used within other editor tools.
A downside to `ResourceSaver` is that the resource path, UID, & other meta data are saved when used in the editor. This was one of the main drives for me to make Any-JSON, as this would not be viable for some of my purposes.

## Rulesets
A "ruleset" can be supplied when converting to or from AJSON allowing fine control over serialization. Something you don't get with `var_to_str` & not as much with `ResourceSaver`.

**Basic rules:**
- `type_exclusions (Array[String])`: Types of variables/properties that will be discarded.
- `property_exclusions (Dictionary[String,Array[String]])`: Names of properties that will not be recognized for each object. Can be used to exclude for example `Resource` specific properties like `resource_path`.
- `exclude_private_properties (bool)`: Exclude properties that start with an underscore "_".
- `exclude_properties_set_to_default (bool)`: Exclude properties whoms values are the same as the default of that property. This is used to reduce the amount of data we have to store, but isn't recommended if the defaults of class properties are expected to change.

**Advanced Rules:**
- `property_references (Dictionary[String,Array[String]])`: Names of object properties that will be converted to a named reference when converting to JSON. Named values can be supplied during conversion back to the original item with `references`.
- `references (Dictionary[String,Dictionary[String,Variant]])`: Variants to replace property references with.
- `instantiator_function (Callable(registered_object:Object, object_class:String, args:Array=[]) -> Object)`: Used for implementing custom logic for object instantiation. Useful for changing values after instantiation. The returned object will be used to compare default values when converting to AJSON, & will be used as a base when converting from AJSON.
- `instantiator_arguments (Dictionary[String,Array])`: Arguments that will be passed to the object's `new` method.
- `midpoint (Callable(item:Variant, ruleset:Dictionary) -> bool)`: Called right before conversion for every variable & property including nested ones. Returning `true` will permit conversion, returning `false` will discard the conversion for that item.

## Error logs
Custom errors are printed to the console when serialization goes wrong. You can access a history of these errors through the `error_stack` property on type handlers that have `print_error` set to true.

# Limitations
## Handling local classes:
All objects extending a custom class that is NOT globally available (defined as a child of a parent script) cannot be automatically identified as it has no global name.

You will need to give your local classes the `_global_name` string constant which should be the same as the name you give it in the `A2J.object_registry`. The global name constant will allow Any-JSON to identify it when serializing.

**What if I don't define `_global_name` on a local class?**

Then the object will assume the class name of whatever the local class extends (RefCounted by default). No property data is discarded, it just cannot be applied to the correct class if you wish to convert it back from AJSON.

# Example usage
## Adding to object registry
Simply add the name of the class & the class itself to the `A2J.object_registry` dictionary. Do not add an instance of the object to the registry.
```gdscript
class custom_class_1:
  const _global_name := 'custom_class_1'
  var some_value:bool = true


class custom_class_2:
  const _global_name := 'custom_class_2'
  var some_value:int = 1


A2J.object_registry.merge({
  'custom_1': custom_class_1,
  'custom_2': custom_class_2,
})


# With constructor.
# -----------------

class custom_class_3:
  const _global_name := 'custom_class_3'
  var some_value: int

  func _init(some_value:int) -> void:
  		self.some_value = some_value


# Add as normal.
A2J.object_registry.merge({
  'custom_class_3': custom_class_3,
})


# Add instantiator arguments for "custom_class_3".
var ruleset := {
  'instantiator_arguments': {
    'custom_class_3': [100], # With this, "custom_class_3" will be instantiated with the first argument in it's constructor as "100".
  },
}
```
In this case, we are using the `merge` method on the object registry to add multiple objects while preserving all the default ones.

## Serializing to AJSON
Just pass the item you want to serialize to the `A2J.to_json` method. You can provide a custom ruleset, otherwise it will use the default ruleset defined at `A2J.default_ruleset_to`.
```gdscript
var literally_any_thing := Vector3(1,2,3)
var result = A2J.to_json(literally_any_thing)
if result == null:
  print('something went wrong')
else:
  print(result)


# With custom ruleset.
# --------------------

class custom_class:
  const _global_name := 'custom_class'
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

## Serializing back from AJSON
Just pass the item you want to serialize to the `A2J.from_json` method. You can provide a custom ruleset, otherwise it will use the default ruleset defined at `A2J.default_ruleset_from`.
```gdscript
var ajson = A2J.to_json(Vector3(1,2,3))
var result = A2J.from_json(ajson)
print(result) # Prints "(1, 2, 3)".
print(type_string(typeof(result))) # Prints "Vector3".
```
