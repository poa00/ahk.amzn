/**
 * Compares two versions such as `0.0.1` vs `0.0.2`.
 * 
 * Supports the following string notations (case-insensitive).
 *  - RC
 *  - Unstable
 *  - Beta 
 *  - b     : same as `Beta`
 *  - Alpha 
 *  - a     : same as `Alpha`
 *  - Dev
 *
 * ### Examples
 
 * ```autohotkey
 *  msgbox % compareVersions( "0.0.1", "0.0.2" ) ; -1
 *  msgbox % compareVersions( 10, 10.1 ) ; -1
 *  msgbox % compareVersions( "0.0.0.1", "0.0.0.0.2" ) ; 1
 *  msgbox % compareVersions( "0.0.1", "0.0.1b" ) ; 1
 *  msgbox % compareVersions( "1", "0.0.1b" ) ; 1
 *  msgbox % compareVersions( "0.0.1a", "0.0.1b" ) ; -1
 *  msgbox % compareVersions( "0.1", "0.1.0" ) ; 0
 * ```
 *
 * @requires    AutoHotkey v1.1.13 as it uses `StrSplit()`.
 * @return      integer      -1 when version A is older than B. 0 when version A is equal to version B. 1 when version A is newer than version B.
 * @version     1.0.0
 */
compareVersions( sVersionA, sVersionB ) {
    
    _aVersionA := StrSplit( sVersionA, "." )
    _aVersionB := StrSplit( sVersionB, "." )
    _iMaxIndex := compareVersions_getMaxNumberOfElements( _aVersionA, _aVersionB )    
    loop % _iMaxIndex {
        _iVersionA := compareVersions_getVersionSanitized( _aVersionA[ A_Index ] )
        _iVersionB := compareVersions_getVersionSanitized( _aVersionB[ A_Index ] )
        if ( _iVersionA > _iVersionB ) {
            return 1
        }
        if ( _iVersionA < _iVersionB ) {
            return -1
        }
    }
    return 0
    
}
    /**
     * Supports dev, RC, beta, b, alpha, a
     * @return      integer
     */
    compareVersions_getVersionSanitized( sVersion ) {
        sVersion := trim( sVersion )
        if ( "" = sVersion ) {
            return 0
        }
        _aLevels := { "RC": -100
            , "UNSTABLE": -200
            , "BETA": -300, "([^A-Za-z]|^)B([^A-Za-z]|$)": -300
            , "ALPHA": -400, "([^A-Za-z]|^)A([^A-Za-z]|$)": -400
            , "DEV": -500 }
        
        _iOverallCoefficient := 1
        for _sLevel, _iCoefficient in _aLevels {
            ; for exatct matches
            if ( RegexMatch( sVersion, "i)^" _sLevel "$" ) ) {
                return _iCoefficient
            }
            ; for partial matches such as `10b`, `3dev`
            if ( RegexMatch( sVersion, "i)" _sLevel ) ) {
                sVersion := RegexReplace( sVersion, "i)" _sLevel )
                if sVersion is integer
                {
                    return sVersion * _iCoefficient
                }
                ; Exceptional cases. Maybe mixed like `a20b`.
                _iOverallCoefficient := _iOverallCoefficient * _iCoefficient
            }
        }
        return sVersion * _iOverallCoefficient
        
    }
    /**
     * @return      integer     The found maximum index between the given two.
     */
    compareVersions_getMaxNumberOfElements( aA, aB ) {
        _aIndex := []
        _iAMax  := aA.MaxIndex() 
        _iBMax  := aB.MaxIndex() 
        _aIndex[ _iAMax ] := _iAMax
        _aIndex[ _iBMax ] := _iBMax
        return _aIndex.MaxIndex()
    }