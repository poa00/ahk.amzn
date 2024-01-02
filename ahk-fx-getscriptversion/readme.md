## getScriptVersion( sScriptCode, bInComment=true, sDefaultVersion="0.0.1" )
Retrieves a verion number in a comment block with the `@version` annotation from a given file.

### Parameters
#### sScriptCode
(string)
#### bInComment
(boolean)
#### sDefaultVersion
(string)

## getScriptVersion_FromFile( sScriptPath, bInComment=true, sDefaultVersion="0.0.1" )
Retrives a version number in a comment block with the `@version` annotation from a file of the given path.

### Parameters
#### sScriptCode
(string)
#### bInComment
(boolean)
#### sDefaultVersion
(string)



### Change Log
#### 1.1.0 - 2017/07/21
 - Added the `bInComment` parameter.
 - Fixed a bug that a string after the taret verion got included.
#### 1.0.0 - 2017/07/21
 - Released initally.