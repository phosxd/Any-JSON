<div align="middle">

[![Release](https://img.shields.io/badge/Need_help%3F-gray?style=flat&logo=discord)](https://dsc.gg/sohp)

<img src="git_assets/banner.png" align=""></img>

Convert any Godot Variant or Object to raw JSON, with support for converting back into the original item with absolutely no data loss.

This plugin is under development & not fully ready for use. Suggestions & contributions are still welcome!

</div>

# Features:
# Error logging:
There is a dedicated error logging system so you don't have to deal with obscure error messages when the plugin isn't used properly.
## Modular & extendable:
Everything is coded in GDScript across distinct classes & files, allowing for easy modification & extension.
## Editor-ready:
Unlike the most common alternatives, Any-JSON can work in the editor so it can be used within other editor tools.
A downside to `ResourceSaver` is that the resource path, UID, & other meta data are saved when used in the editor. This was one of the main drives for me to make Any-JSON as this would not be viable for some of my purposes.
## Rulesets:
A "ruleset" can be supplied when converting to or from AJSON allowing fine control over serialization. Something you don't get with `var_to_str` or not as much with `ResourceSaver`.

All rules:
- **allowed_types** (Array\[String\]): Types that will be recognized.
- **property_exclusions** (Dictionary\[String,Array\[String\]\]): Names of properties that will not be recognized for each object. Can be used to exclude for example `Resource` specific properties like `resource_path`.
- **convert_properties_to_references** (Dictionary[String,Array[String]]): Names of object properties that will be converted to a named reference when converting to JSON. Named values can be supplied during conversion back to the original item with `named_references`.
- **named_references** (Dictionary[String,Dictionary[String,Variant]]): Variants to replace named references with. See `convert_properties_to_references`.

More rules will be available in the full release.

# To-Do:
- Add support for non string keys in dictionaries.
- Add built-in handlers for Vector & other common types.
- Add more built-in objects in the object registry.
