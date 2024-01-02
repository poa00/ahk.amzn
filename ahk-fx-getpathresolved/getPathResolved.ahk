/**
 * Rosolves relative/short paths into long absolute.
 * 
 * ### Example
 * ```autohotkey
 * msgbox % getPathResolved( "..\test", A_ScriptDir )
 * msgbox % getPathResolved( "S:\project\functions\sample" )
 * ```
 * @version     1.0.0
 */

/**
 * @see         PathCombine : www.msdn.microsoft.com/en-us/library/bb773571(VS.85).aspx
 * @since       1.0.0
 */
getPathResolved( sPath, sWorkingDir="" ) {

    static _sAorW := A_IsUnicode ? "W" : "A"
    sWorkingDir   := sWorkingDir ? sWorkingDir : A_WorkingDir
    VarSetCapacity( _sAbsolutePath, 260, 0 )
    DllCall( "shlwapi\PathCombine" _sAorW, Str, _sAbsolutePath, Str, sWorkingDir, Str, sPath )
    
    ; Convert short paths into long.
    Loop, Files, % _sAbsolutePath, FD 
    {
        return % A_LoopFileLongPath
    }    
    return _sAbsolutePath
    
}
