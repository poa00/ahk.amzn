#NoEnv
#SingleInstance, Force

#Include %A_ScriptDir%\oAmazonProductDetails.ahk

_oAPD := new oAmazonProductDetails( "B01DOWUC08", "amazon.co.jp", {} )
_aDetails := _oAPD.get()
_aDetails.delete( "Content" )
msgbox % getKeyValues( _aDetails )
ExitApp

getKeyValues( oObj ) {
    for k, v in oObj {
        if ( isObject( v ) ) {
            _s .= "[" k "]`n" getKeyValues( v ) "`n"
            continue
        }
        _s .= "[" k "]`n" v "`n"
    }
    return trim( _s )
}