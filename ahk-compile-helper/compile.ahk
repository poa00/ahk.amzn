/**
 * Automates compiling project scripts with Ahk2Exe.
 * 
 * Edit the `settings.ini` file in the same directory and do necessary configurations.
 * 
 * @version     1.0.0
 */

#NoEnv
#SingleInstance, Force

_sSettiongPath := A_ScriptDir "\settings.ini"
exitIfFIleNotExist( _sSettiongPath )

IniRead, _sAhk2ExePath, % _sSettiongPath, Paths, AHK2Exe
_sAhk2ExePath := getPathResolved( _sAhk2ExePath )
exitIfFileNotExist( _sAhk2ExePath, "AHK2Exe" )

; Check if AutoHotkey.exe exists. This is important for auto-include Lib files.
; @todo maybe copy executed `AutoHotkey.exe` for the user if it does not exist by asking Yes or No.
if ( ! AutoHotkeyExeExists() ) {
    terminate( "The AutoHotkey.exe could not be found. It is required for auto-include scripts under Lib directory. The script exists.", 48 )
}

IniRead, _sMainScriptPath, % _sSettiongPath, Paths, Main
_sMainScriptPath := getPathResolved( _sMainScriptPath )
exitIfFileNotExist( _sMainScriptPath, "Main Script" )

SplitPath, % _sMainScriptPath, name, _sMainDirPath, ext, _sNameWOExt, drive

_sVersion    := getScriptVersion( _sMainScriptPath )
_sOutDirPath := _sMainDirPath "\_releases\" _sVersion 
_sOutPath32  := _sOutDirPath "\" _sNameWOExt ".x86.exe"
_sOutPath64  := _sOutDirPath "\" _sNameWOExt ".x64.exe"

FileRemoveDir, % _sOutDirPath, 1
FileCreateDir, % _sOutDirPath

IniRead, _sIconPath, % _sSettiongPath, Paths, Icon
_sIconPath := getPathResolved( _sIconPath )

IniRead, _sSource32, % _sSettiongPath, Paths, AHKSource32
_sSource32Path := getPathResolved( _sSource32 )
exitIfFIleNotExist( _sSource32Path, "Source File (32bit)" )
IniRead, _sSource64, % _sSettiongPath, Paths, AHKSource64
_sSource64Path := getPathResolved( _sSource64 )
exitIfFIleNotExist( _sSource64Path, "Source File (64bit)" )

; Compress
IniRead, _bMpress, % _sSettiongPath, General, Mpress

; Start compiling.
compileWithAhk2Exe( _sAhk2ExePath, _sMainScriptPath, _sOutPath32, _sIconPath, _sSource32Path, _bMpress )
compileWithAhk2Exe( _sAhk2ExePath, _sMainScriptPath, _sOutPath64, _sIconPath, _sSource64Path, _bMpress )
Msgbox, % "Compilation script has been completed."
ExitApp

AutoHotkeyExeExists() {
    SplitPath, % A_AhkPath,, _sAhkExeDirPath,,,
    return % FileExist( _sAhkExeDirPath "\AutoHotkey.exe" ) 
        ? true 
        : false
}

compileWithAhk2Exe( sAhk2ExePath, sMainScriptPath, sOutPath, sIconPath, sSourceFilePath, bMpress=1 ) {

    _sCommand := """" sAhk2ExePath """"
        . " /in """ sMainScriptPath """"
        . " /out """ sOutPath """"
        . ( FileExist( sIconPath ) ? " /icon """ sIconPath """ " : "" )
        . ( FileExist( sSourceFilePath ) ? " /bin """  sSourceFilePath """" : "" )
        . ( bMpress ? " /mpress 1" : " /mpress 0" )
    RunWait, % _sCommand,,  UseErrorLevel, nPIDx86
    if ErrorLevel = ERROR 
    {
        Msgbox, % "Error occurred while running the compiler with the command below:`n"
            . _sCommand
        ExitApp
    }
    
}

getScriptVersion( sScriptPath ) {
    
    FileRead, _sScriptCode, % sScriptPath
    RegexMatch( _sScriptCode, "O)/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+/", oMatches )
    RegexMatch( oMatches[ 0 ], "Omi)@version\s+\K.+?(?=(\s+)?$)", oMatches )
    if ( "" != oMatches[ 0 ] ) {
        return oMatches[ 0 ]
    }
    return "0.0.1"  ; default
    
}
getPathResolved( sRelativePath ) {
    sRelativePath := trim( sRelativePath )
    if ( SubStr( sRelativePath, 1, 1 ) = "." ) {
        sRelativePath := A_ScriptDir "\" sRelativePath
    }   
    Loop, Files, % sRelativePath, F 
    {
        return % A_LoopFileLongPath
    }
}
ProcessExist( nPID ){
    if ( "" = nPID ) {
        return false
    }
	Process, Exist, % nPID
	return Errorlevel
}

terminate( sMessage, iMsgBoxOption=0 ) {
    Msgbox, % iMsgBoxOption,, % sMessage
    ExitApp
}

exitIfFileNotExist( sFilePath, sName="" ) {
    if ( FileExist( sFilePath ) ) {
        return
    }
    _sMessage := sName 
        ? "The file " sName " could not be located."
        : "The file could not be located."
    terminate( _sMessage "`n" sFilePath , 48 )
    ExitApp
}