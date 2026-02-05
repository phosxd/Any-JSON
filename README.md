<div align="middle">

<img src="git_assets/banner.png" align=""></img>

Godot 4.5 / 4.6 plugin to convert any Godot variant to raw JSON & back.

[![Release](https://img.shields.io/badge/-gray?style=flat&logo=discord)](https://dsc.gg/sohp) **Version:** 2.0.0-beta

</div>

# **Introduction**
This plugin can serialize pretty much any\* data type within Godot to a JSON-compatible dictionary. You can serialize entire objects or trees of objects while preserving all data.

<!--
Any-JSON can be split into 2 main parts, either can be used without ever needing to know how to use the other.

1. **Any-JSON interface:** this pertains to the global `A2J` static class which you can use to serialize variables directly by calling it's methods.

  This is what most of the documentation is for & what most examples will be using.
2. **SceneStateCapture:** this is a custom node that can be added to your scene that makes it stupidly easy to save (AND load) entire nodes or just specific node properties in your scene. You can learn more at [SceneStateCapture](#scenestatecapture).
-->

Any-JSON is very simple to use, no need for setup or specification. All built-in classes should already be supported, but if you run into an object with an unsupported class you can simply add that class to the `A2J.object_registry` & try again. For finer control over how things get done, see [rulesets](#rulesets).

After converting your item to an AJSON dictionary, you can use `JSON.stringify` to turn it into a raw text string but you will need to convert it back to a dictionary using `JSON.parse_string` if you want to convert it back to the original item.

# **Table of contents**
- [Features](#features)
  - [Supported types](#all-types-handled)
  - [Recursive](#nesting-all-the-way)
  - [Type-safe](#types-preserved)
  - [Modular](#modular)
  - [Editor-ready](#editor-ready)
  - [Error server](#error-logs)
- [Rulesets](#rulesets)
- [Preserving data integrity](#preserving-data-integrity)
- [Editing object registry](#editing-the-object-registry)
- [Examples](#example-usage)
  - [Adding to object registry](#adding-to-object-registry)
  - [Serializing to AJSON](#serializing-to-ajson)
  - [Serializing back from AJSON](#serializing-back-from-ajson)
  - [Safe deserialization](#safe-deserialization)
  - [More...](./examples/)

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

As of Godot 4.6 this is almost every `Variant.Type` available in GDScript that isn't run-time exclusive (like `RID`). If new types are added to GDScript you can add your own handler by extending `A2JTypeHandler` & adding an instance of the handler to `A2J.type_handlers`.

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

**There is one exception!** This system will fail to apply values to object properties that are typed with LOCAL custom classes. Example:
- Invalid:
  ```gdscript
  var property:CustomLocalClass

  class CustomLocalClass:
    # ...
  ```
- Valid:
  ```gdscript
  # example.gd
  var property:CustomGlobalClass
  # ...

  # global_class.gd
  class_name CustomGlobalClass
  # ...
  ```

Without automatic typing, Godot will fail to apply a standard `Array` value to a property of type `Array[int]`. The same applies to typed dictionaries & other typed values.

The way Any-JSON ensures type safety is very efficient & doesn't require saving type data. During deserialization property type data is pulled from the class & that is used to tell the value what type it should be.

## Modular
Everything is coded in GDScript across distinct classes & files, allowing for easy modification & extension.

## Editor-ready
Unlike the most common alternatives, Any-JSON can work in the editor so it can be used within other editor tools.
A downside to `ResourceSaver` is that the resource path, UID, & other meta data are saved when used in the editor. This was one of the main drives for me to make Any-JSON, as this would not be viable for some of my purposes.

## Error logs
Custom errors are printed to the console when serialization goes wrong. A generic unknown class error would look something like this `ERROR: A2JObjectTypeHandler.gd found error at ROOT > SomeProperty > @index:0: Class "MyCustomClass" is not defined in registry.`.

You can connect to the `A2J.error_server` to run code when an error occurs.
There are 2 signals emitted from `A2J.error_server`.
- `handler_error`: Emitted when any of the type handlers catch an error.
- `core_error`: Emitted when the core A2J process catches an error.


# Rulesets
A "ruleset" can be supplied when converting to or from AJSON allowing fine control over serialization. Something you don't get with `var_to_str` & not as much with `ResourceSaver`.

The layout of a ruleset is simple. Rules are set per-class. You can also use special keys that start with "@" to specify groups of rules that apply to things based on the key. For example the "\@global" group specifies rules that apply to every class.

Example:
```
{
  # This is where you can put rules that apply to EVERYTHING you serialize or deserialize.
  '@global': {
    # ...
  },
  # This is where you can put rules that only apply to nodes.
  'Node': {
    # ...
  },
  'MyCustomClass': {
    # ...
  },
}
```

## Special groups
### `@global`
Rules that apply everywhere.

### `@depth:<int>[+,-]`
Rules that only apply a certain tree depth. Use the `+` sign to have this group also affect all depths above the specified depth. Use the `-` sign to also affect depths below.

## Rule modifiers
You can add modifiers to the end of rule keys to affect it's behavior. Here is an example: `type_exclusions@des`.

### `@des`
The rule will only apply during deserialization (converting *from* an AJSON object).

### `@ser`
The rule will only apply during serialization (converting *to* an AJSON object).

## Basic rules
### `type_exclusions (Array[String])`
Variant types that will be discarded.

### `type_inclusions (Array[String])`
Variant types that are allowed, all other types will be discarded unless the list is left empty.

### `class_exclusions (Array[String])`
Object classes that will be discarded.

### `class_inclusions (Array[String])`
Object classes that are allowed, all other classes will be discarded unless the list is left empty.

### `property_exclusions (Array[String])`
Property names that will be discarded.

### `property_inclusions (Array[String])`
Property names that are allowed, all other properties will be discarded unless the list is left empty.

### `exclude_private_properties (bool=false)`
Exclude object properties that start with an underscore. Also affects object metadata properties.

### `exclude_default_values (bool=false)`:
Exclude object properties with values the same as the default of that property. This can be enabled to prevent saving unnecessary data.

## Advanced rules

### `automatic_resource_references (bool=false)`
Automatically convert external resource objects to references when serializing to AJSON. This will only affect resources available as it's own file.

### `property_references (Dictionary[String,String])`
Names of object properties that will be converted to a named reference (that doesn't store any actual data) when serializing to AJSON. The value of this property must be supplied during deserialization using the `property_reference_values` rule.

### `property_reference_values (Dictionary[String,Variant])`
Variants to replace named references with during deserialization.

### `instantiator_arguments (Array[Array])`
Arguments that will be passed to the class' `new` method. Can only be used under class rule groups.

### `instantiator_function (Callable(registered_object:Object, object_class:String, args:Array=[]) -> Object)`
 Used for implementing custom logic for object instantiation. Useful for changing values after instantiation. The returned object will be used to compare default values when converting to AJSON, & will be used as a base when converting from AJSON.

 Does not make a difference which rule group this rule is used under.

### `midpoint (Callable(item:Variant, ruleset:Dictionary) -> bool)`
Called right before serializing a variant. Returning `true` will permit the variant to be passed on, returning `false` will discard the variant (passing `null` instead).


# Preserving data integrity
Here are a few rules you should follow so that you don't risk losing any data during or after serialization.
- **Don't modify object indices:** Any-JSON uses index numbers to identify unique objects in resulting AJSON. These are necessary for resolving references & tampering with the indices will lead to incorrect deserialization of those references.
- **Don't modify property defaults:** (Only applies if you use `exclude_properties_set_to_default` rule) Don't modify the default values of properties in classes that are used in serialization.
- **Be aware of script dependencies:** Properties dependent on the original object's script in AJSON will be lost unless the script property is present in the AJSON (as a reference or an actual script object).
- **Version mismatching:** Never use AJSON data produced from outdated versions of Any-JSON. Always use the same version to deserialize as you used to originally serialize that data. However, minor versions should still be cross compatible (X.X.*).

# Editing the object registry
In Any-JSON the object registry is a collection of classes & their names. This is required for the plugin to find & access the class methods. You may need to edit the object registry if you have custom classes or if there are built-in classes that you have removed from the engine.

The simpliest way to do this is via code in your project.
```gdscript
A2J.object_registry.set('my_custom_class', my_custom_class)
```
However with this method it is only effective for *adding* to the registry. If you need to remove classes that are no longer available or that you have explicitly removed from your engine, then you have 2 options.
1. Manually find & remove the class(es) from `object_registry` in `A2J.gd` in the plugin's folder.
2. Use the registry generator tool included in the repo to replace the value of `object_registry`.

I recommend including only the classes that you *know* you will be passing through Any-JSON. The default object registry includes nearly every built-in instantiable class in Godot, but that is only for the convenience of new or one-time users. In reality you will never need all of those classes.

## Using the registry generator
To use this tool, make sure you have the entire repo downloaded & open inside Godot. Now open the registry generator scene & select the top node, you should see a "Generate" button in the inspector dock.

Clicking "Generate" will output the new registry in the `output_path` defined in the inspector. There are 2 main settings you need to know about:
- `engine_compilation_configuration`: GDBuild file to use for deciding which classes to include in the generated registry. This can also use "disabled_build_options" to decide classes to exclude.
- `more_disabled_classes`: Classes to exclude in the generated registry.

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
  '@global': {
    'instantiator_arguments': {
  	'custom_class_3': [100], # With this, "custom_class_3" will be instantiated with the first argument in it's constructor as "100".
    },
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
  'custom_class': {
    'property_exclusions': [
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
This is how you can deserialize AJSON data without the risk of running external code.
```gdscript
var ruleset := {
  '@global': {
    'class_exclusions@des': [
  	'GDScript',
    ],
  },
}

var result = A2J.from_json(your_serialized_object, ruleset)
```
In this example we utilize the "class\_exclusions" rule (with [@des](#des) modifier) to exclude any object with the class name "GDScript during deserialization. Any instances of a GDScript object in the AJSON will be discarded during conversion back to an object.

However if your object is like a node with a script attached, you cannot exclude the script otherwise script dependent variables will be lost. You should **reference** the script instead excluding it see [rulesets -> advanced rules](#rulesets).

If you have any other classes in the `A2J.object_registry` that can execute arbitrary code, you may want to add them to the list of exclusions.
