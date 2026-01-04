<div align="middle">

<img src="git_assets/banner.png" align=""></img>

Godot 4.4 / 4.5 plugin to convert any Godot variant to raw JSON & back, with absolutely no data loss.

</div>

**Version:** 1.3.4

[![Release](https://img.shields.io/badge/Need_help%3F-gray?style=flat&logo=discord)](https://dsc.gg/sohp)

# **Introduction:**
This plugin can serialize any data type within Godot to raw readable JSON so long as the appropriate type handlers have been implemented. You can serialize any custom & built-in classes too.

Any-JSON is very simple to use, no need for setup or specification. Most common classes should already be supported, but if you run into an object with an unsupported class you can simply add that class to the `A2J.object_registry` & try again. For finer control over how things get done, see [rulesets](#rulesets).

After converting your item to an AJSON dictionary, you can use `JSON.stringify` to turn it into a raw text string but you will need to convert it back to a dictionary using `JSON.parse_string` if you want to convert it back to the original item.

# **Table of contents:**
- [Why use over alternatives](#why-use-over-alternatives)
- [Features](#features)
  - [Supported types](#all-types-handled)
  - [Recursive](#nesting-all-the-way)
  - [Type-safe](#types-preserved)
  - [Modular](#modular)
  - [Editor-ready](#editor-ready)
  - [Rulesets](#rulesets)
  - [Error logs](#error-logs)
- [Preserving data integrity](#preserving-data-integrity)
- [Examples](#example-usage)
  - [Adding to object registry](#adding-to-object-registry)
  - [Serializing to AJSON](#serializing-to-ajson)
  - [Serializing back from AJSON](#serializing-back-from-ajson)
  - [Safe deserialization](#safe-deserialization)
  - [More...](./examples/)

# Why use over alternatives
## JSON.stringify
This is good for storing simple data structures like primitives in arrays & dictionaries, but cannot support objects or more complex Variant types.

## JSON.from_native
This is by far the best solution at your disposal in Godot, if you are willing to sacrifice flexibility, security, & size.

`JSON.from_native` does not give you any control over serialization besides the `full_objects` parameter that determines whether or not it will serialize objects. It also leaves you vulnerable to external code execution as it also stores all scripts with no option to exclude them in objects.

Another reason you might consider using Any-JSON instead, is that `JSON.from_native` produces about 25% more text in my testing, taking up more space than outputs in Any-JSON. This is because the way the JSON is structured is just less efficient, but mostly because it also stores values that can be outright discarded as they are default values that can be restored during deserialization.

The final downside to this is that you cannot serialize local classes (classes without a global name), it will just throw an error. This is probably not a concern for anyone.

In conclusion, use Any-JSON for fine control & security via [rulesets](#rulesets). If that does not matter to you, use `JSON.from_native`.

## var_to_str / var_to_bytes
This has all the issues that `JSON.from_native` has, except it does produce smaller outputs since it does not have to conform to the JSON standard.

# Features
## All types handled
All types listed below can be converted to JSON & back while preserving every detail.
- Bool
- Int
- Float
- String
- Object (both built-in & custom classes supported)
- Array (any value type supported)
- Dictionary (any key or value type supported)
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
- Transform2D, Transform3D
- Projection

As of Godot 4.5 this is almost every `Variant.Type` available in GDScript that isn't run-time exclusive (like `RID`). If new types are added to GDScript you can add your own handler by extending `A2JTypeHandler` & adding an instance of the handler to `A2J.type_handlers`.

**Note:**
Packed array types are converted to a long hexadecimal string, so they will not be human readable.
The only exceptions are `PackedColorArray` (array of color hex codes), & `PackedStringArray` (array of strings).

Here are the types that will never be supported & their reasons:
- Signal: signals are too complex due to all the moving parts & references. On top of that, there is no use case that comes to mind where saving this to disk would be useful.
- RID: this type is exclusively used for run time resource identifiers & would not be useful to save, as stated in the GDScript documentation.

## Nesting all the way
All children of the item you are converting are recursively serialized. This means you can convert entire scene trees & every single resource it uses if you wanted to.

This is a big advantage over some other plugins.

Any-JSON also handles circular references, this means a property can link back to the original object but it will simply be converted to a reference instead of triggering infinite recursion.
This works by storing an index value (packed within ".type") for every *unique* object.

## Types preserved
Any-JSON automatically re-types values to the type of the property it is assigning to in an `Object`, meaning you can serialize objects with strict property types & still guarantee everything will be the correct type upon deserialization.

Without automatic typing, Godot will for example, fail to apply a standard `Array` value to a property of type `Array[int]` or to any other typed property. The same applies to typed dictionaries.

The way Any-JSON ensures type safety is very efficient & doesn't require saving type data. During deserialization, property type details are pulled from the class & that is used to determine the type the data should be.

## Modular
Everything is coded in GDScript across distinct classes & files, allowing for easy modification & extension.

## Editor-ready
Unlike the most common alternatives, Any-JSON can work in the editor so it can be used within other editor tools.
A downside to `ResourceSaver` is that the resource path, UID, & other meta data are saved when used in the editor. This was one of the main drives for me to make Any-JSON, as this would not be viable for some of my purposes.

## Rulesets
A "ruleset" can be supplied when converting to or from AJSON allowing fine control over serialization. Something you don't get with `var_to_str` & not as much with `ResourceSaver`.

**Basic rules:**
- `type_exclusions (Array[String])`: Types of variables that will be discarded.
- `type_inclusions (Array[String])`: Types of variables that are allowed, all others will be discarded. If left empty, all types are permitted.
- `class_exclusions (Array[String])`: Object classes that will be discarded.
- `class_inclusions (Array[String])`: Object classes that are allowed, all others will be discarded. If left empty, all types are permitted.
- `property_exclusions (Dictionary[String,Array[String]])`: Names of properties that will be discarded for each object. Can be used to exclude for example `Resource` specific properties like `resource_path`.
- `property_inclusions (Dictionary[String,Array[String]])`: Names of properties that are permitted for each object. Used for only saving specific properties. Will not be used if left empty.
- `exclude_private_properties (bool)`: Exclude properties that start with an underscore "\_". Also affects metadata properties.
- `exclude_properties_set_to_default (bool)`: Exclude properties whoms values are the same as the default of that property. This is used to reduce the amount of data we have to store, but isn't recommended if the defaults of class properties are expected to change.
- `fppe_mitigation (bool)`: Limits the number of decimals any floating point number can have to just 8, removing floating point precision errors.

**Advanced Rules:**
- `property_references (Dictionary[String,Array[String]])`: Names of object properties that will be converted to a named reference when converting to JSON. Named values can be supplied during conversion back to the original item with `references`.
- `references (Dictionary[String,Dictionary[String,Variant]])`: Variants to replace property references with.
- `instantiator_function (Callable(registered_object:Object, object_class:String, args:Array=[]) -> Object)`: Used for implementing custom logic for object instantiation. Useful for changing values after instantiation. The returned object will be used to compare default values when converting to AJSON, & will be used as a base when converting from AJSON.
- `instantiator_arguments (Dictionary[String,Array])`: Arguments that will be passed to the object's `new` method.
- `midpoint (Callable(item:Variant, ruleset:Dictionary) -> bool)`: Called right before conversion for every variable & property including nested ones. Returning `true` will permit conversion, returning `false` will discard the conversion for that item.

## Error logs
Custom errors are printed to the console when serialization goes wrong. You can access a history of these errors through the `error_stack` property on type handlers.

If you don't want to proactively check these logs, you may use the `A2J.error_server` to connect functions to the error signals provided.

# Preserving data integrity
Here are a few rules you should follow so that you don't risk losing any data during or after serialization.
- **Don't modify object indices:** Any-JSON uses index numbers to identify unique objects in resulting AJSON. These are necessary for resolving references & tampering with the indices will lead to incorrect deserialization of those references.
- **Don't modify property defaults:** (Only applies if you use `exclude_properties_set_to_default` rule) Don't modify the default values of properties in classes that are used in serialization.
- **Be aware of script dependencies:** Properties dependent on the original object's script in AJSON will be lost unless the script property is present in the AJSON (as a reference or an actual script object).
- **Version mismatching:** Never use AJSON data produced from outdated versions of Any-JSON. Always use the same version to deserialize as you used to originally serialize that data. However, minor versions should still be cross compatible (X.X.*).

# Example usage
## Adding to object registry
Simply add the name of the class & the class itself to the `A2J.object_registry` dictionary. Do not add an instance of the object to the registry.
```gdscript
class custom_class_1:
  var some_value:bool = true


class custom_class_2:
  var some_value:int = 1


A2J.object_registry.merge({
  'custom_class_1': custom_class_1,
  'custom_class_2': custom_class_2,
})


# With constructor.
# -----------------

class custom_class_3:
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
  var_1:int = 1
  var_2:float = 0.5

var ruleset := {
  # Excludes the "var_1" property for "custom_class".
  'property_exclusions': {
	'custom_class': [
	  'var_1',
    ],
  },
}

A2J.object_registry.set('custom_class', custom_class)
result = A2J.to_json(custom_class.new(), ruleset)
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

## Safe deserialization
This is how you can deserialize AJSON data without the risk of running external code. (1.3.0+, "class_exclusions" rule not introduced before then).
```gdscript
var ruleset := {
  'class_exclusions': [
    'GDScript',
  ],
}

var result = A2J.from_json(your_serialized_object, ruleset)
```
In this example we utilize the "class\_exclusions" rule to exclude any object with the class name "GDScript". Any instances of a GDScript object in the AJSON will be discarded during conversion back to an object.

If you have any other classes in the `A2J.object_registry` that can execute arbitrary code, you may want to add them to the list of exclusions.
