# AutoHotkey Compiler Helper

Helps compiling AutoHotkey scripts using the builtin compiler Ahk2Exe.

Place this script in your AutoHotkey project in a directory such as `_tools\compiler` and run it to compile the script with a few clicks.

## Requirements

### Versioning
Add a version annotation, `@version`, followed by a version number of your decision, in a comment section using `/* */`, known as doc-block, in the main script.

The script tries to read the versino number and create a directory with the name of it in the `_releases` directory located in the target script directory. If the version is not found, the directory name will be `0.0.1`.

####Example
```
/**
 * Program Title
 *
 * This is a program description.
 * @version         1.1.0
 */
```


### Settings
Create a setting file named `settings.ini` in the same directory with the subject script. 

The INI file contents should have the `[Paths]` and `[General]` sections with the following key-values. A relative path is accepted for all path values.

#### [Paths]
- `Main` - _(required)_ The subject script path.
- `AHK2Exe` - _(required)_ The `Ahk2Exe.exe` file path.
- `AHKSource32` - _(required)_ The C++ source file named `Unicode 32-bit.bin`.
- `AHKSource64` - _(required)_ The C++ source file named `Unicode 64-bit.bin`.
- `Icon` - _(optional)_ An icon path used for the exedcutable icon. Omit this value to have no cusom icon.

#### [General]
- `Mpress` - _(optional)_ Set `1` for `true`, to enable the Mpress compression; `0` for `false`, to disable it. Default: `1`.

### Example
```ini
[Paths]
Main=..\amazon-product-information-downloader.ahk
Icon=..\_assets\images\icon.ico
AHK2Exe=..\..\..\Apps\AutoHotkey\Compiler\Ahk2Exe.exe
AHKSource32=..\..\..\Apps\AutoHotkey\Compiler\Unicode 32-bit.bin
AHKSource64=..\..\..\Apps\AutoHotkey\Compiler\Unicode 64-bit.bin
```

### Remarks
All the files must be encoded with `UTF-8 BOM`.

### Support
Feel free to post issue on the issue tracker.

### Change Log
- 1.0.0 - 2017/07/27
    - Initial release.