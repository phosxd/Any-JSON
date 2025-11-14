Convert any Godot Variant or Object to raw JSON, with support for converting back into the original item with absolutely no data loss.

This plugin is under development & not fully ready for use.

# Features:
# Error logging:
There is a dedicated error logging system so you dont have to deal with obscure error messages when the plugin isn't used properly.
## Modular & extendable:
Everything is coded in GDScript across distinct classes & files, allowing for easy modification & extension.
## Editor-ready:
Unlike the most common alternatives, Any-JSON can work in the editor so it can be used within other editor tools.
A downside to `ResourceSaver` is that the resource path, UUID, & other meta data are saved when used in the editor. This was one of the main drives for me to make Any-JSON as this would not work for some of my purposes.
## Rulesets:
A "ruleset" can be supplied when converting to or from JSON allowing fine control over serialization. Something you dont get with `var_to_str` or not as much with `ResourceSaver`.

All rules:
- **allowed_types** (Array\[String\]): Types that will be recognized.
- **property_exclusions** (Dictionary\[String,Array\[String\]\]): Names of properties that will not be recognized for each object. Can be used to exlcude for example `Resource` specific properties like `resource_path`.

More rules will be available in the full release.

# To-Do:
- Add support for non string keys in dictionaries.
- Add ability to store named object references in Any-JSON objects.
- Add built-in handlers for Vector & other common types.
- Add more built-in objects in the object registry.
