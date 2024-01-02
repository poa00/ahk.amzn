# compareVersions( sVersionA, sVersionB )
Compares two versions such as `0.0.1` vs `0.0.2`. 

Supports the following string notations (case-insensitive).

 - RC
 - Unstable
 - Beta 
 - b     : same as `Beta`
 - Alpha 
 - a     : same as `Alpha`
 - Dev

### Parameters
#### sVersionA
The subject version to be compared with.
#### Type 
String
#### sVersionB
Another version to be compared to.
#### Type 
String

#### sVersionB
 
### Return Value
#### Type 
Integer
####
- `-1` when version A is older than B. 
- `0` when version A is equal to version B. 
- `1` when version A is newer than version B.

 
 
### Examples

```autohotkey
 msgbox % compareVersions( "0.0.1", "0.0.2" ) ; -1
 msgbox % compareVersions( 10, 10.1 ) ; -1
 msgbox % compareVersions( "0.0.0.1", "0.0.0.0.2" ) ; 1
 msgbox % compareVersions( "0.0.1", "0.0.1b" ) ; 1
 msgbox % compareVersions( "1", "0.0.1b" ) ; 1
 msgbox % compareVersions( "0.0.1a", "0.0.1b" ) ; -1
 msgbox % compareVersions( "0.1", "0.1.0" ) ; 0
```

### Requirements
 - AutoHotkey v1.1.13 as it uses `StrSplit()`.

## Change Log
### 1.0.0
 - Initial Release