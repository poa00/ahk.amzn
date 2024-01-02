/**
 * Retrieves a verion number in a comment block with the `@version` annotation from a given file.
 * 
 * @version     1.1.0       Added the `bInComment` parameter.
 */

/**
 * Retrieves a verion number in a comment block with the `@version` annotation from a given file.
 * 
 * @return     string       The found version number.
 */ 
getScriptVersion( sScriptCode, bInComment=true, sDefaultVersion="0.0.1" ) {
    if ( bInComment ) {
        RegexMatch( sScriptCode, "O)/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+/", oMatches )
        sScriptCode := oMatches[ 0 ]
    }
    RegexMatch( sScriptCode, "Omi)@version\s+\K.+?(?=(\s+)|$)", oMatches )
    if ( "" != oMatches[ 0 ] ) {
        return oMatches[ 0 ]
    }
    return sDefaultVersion  ; default    
}
/**
 * Retrives a version number in a comment block with the `@version` annotation from a file of the given path.
 *
 * @return      string      The found version number.
 */
getScriptVersion_FromFile( sScriptPath, bInComment=true, sDefaultVersion="0.0.1" ) {
    FileRead, _sScriptCode, % sScriptPath
    return getScriptVersion( _sScriptCode, bInComment, sDefaultVersion )
}