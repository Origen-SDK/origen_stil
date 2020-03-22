[![Actions Status](https://github.com/Origen-SDK/origen_stil/workflows/Ruby/badge.svg)](https://github.com/Origen-SDK/origen_stil/actions)
[![Coverage Status](https://coveralls.io/repos/github/Origen-SDK/origen_stil/badge.svg?branch=master)](https://coveralls.io/github/Origen-SDK/origen_stil?branch=master)

# OrigenSTIL

This plugin provides an API to read STIL formatted ATE pattern files, allowing STIL pattern snippets to be embedded within Origen pattern logic:

~~~ruby
# Add pins (and groups) from the given STIL pattern to the DUT
OrigenSTIL.add_pins("#{Origen.root}/vendor/mode_entry.stil")

# Execute the vectors within the given STIL pattern, sending them to the current tester
OrigenSTIL.execute("#{Origen.root}/vendor/mode_entry.stil")
~~~

This API is used by the Origen pattern conversion command when the input format is STIL:

~~~text
origen convert my_pattern.stil -e v93k
~~~

### Known Limitations

Any valid STIL should be parsed, however not all of it will be understood or handled yet.

Additionally, there are some restrictions around formatting within the `Pattern` (vectors) blocks which are mainly to allow Origen to execute them quickly without having for formally language-parse this section.

Here are some of the main known limitations currently:

* MatchLoop statements are not supported
* V/Vector blocks must begin and terminate within a single line
* Block comments (`/* ... */`) are not supported within Pattern blocks, though inline comment style is (`// ...`)
* Macros are not supported
* Shift and other scan test constructs are not supported
* Only cyclized vector statements are supported
* Hexadecimal and decimal pin value assignments within vector blocks are not supported
* Subtraction within pin group definitions is not supported

The plugin is more useable than the above list might suggest, since many tools which render STIL will themselves emit a constrained subset of the full language.
However, support for these additional features is being added on an as-needed basis.

Please open an Issue ticket if you find the need for a missing feature, ideally including a STIL snippet showing an example.






