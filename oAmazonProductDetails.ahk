/**
 * Amazon Product Details
 *
 * An AutoHotkey class that retrieves Amazon product details.
 *  
 * @version 1.1.0
 */
 
/**
 * Retrieves Amazon product details.
 * 
 */ 
class oAmazonProductDetails {
    
    sASIN := ""
    sDomain := ""
    aCallbacks := { "FormattedDescription": "" }
    
    ; Internal properties
    _bShowGUI := false
    
    __New( sASIN, sDomain="amazon.co.jp", aCallbacks="" ) {
        this.sASIN      := sASIN
        this.sDomain    := sDomain
        aCallbacks := aCallbacks ? aCallbacks : {}
        this._mergeObjects( this.aCallbacks, aCallbacks, false )
    }
        /**
         * @see     https://sites.google.com/site/ahkref/custom-functions/objmerge
         */
        _mergeObjects(OrigObj, MergingObj, MergeBase=True) {
            If !IsObject(OrigObj) || !IsObject(MergingObj)
                Return False
            For k, v in MergingObj
                ObjInsert(OrigObj, k, v)
            if MergeBase && IsObject(MergingObj.base) {
                If !IsObject(OrigObj.base)
                    OrigObj.base := []
                For k, v in MergingObj.base
                    ObjInsert(OrigObj.base, k, v)       
            }   
            Return True
        }    
    /**
     * @return      object      An array object holding product details.
     */
    get() {
        return this.getDetailsByASIN( this.sASIN )
    }
    
    getDetailsByASIN( sASIN ) {
    
        _oWebBrowser := new this.oWebBrowser
        _oWebBrowser.bShowGUI := this._bShowGUI
; _oWebBrowser.bShowGUI := true
        _oWebBrowser.navigate( "https://" this.sDomain "/dp/" . sASIN )
        
        ; _sTitle   := _getTitle( _oWebBrowser.oWB.document )
        ; _saveTitle( _sTitle )
        ; _savePrice( _oWebBrowser.oWB.document )
        ; _saveNumberOfReviews( _oWebBrowser.oWB.document )
        ; _saveRating( _oWebBrowser.oWB.document )
        ; _sFeatures := _getFeatures( _oWebBrowser.oWB.document )
        ; _saveFeatures( _sFeatures )
        ; _sContent  := _getContent( _oWebBrowser.oWB.document )
        ; _saveContent( _sContent )
        ; _saveFormattedContent( _sTitle, _sFeatures, _sContent )
        ; _saveMerchant( _oWebBrowser.oWB.document )
        ; _saveProductImages( _oWebBrowser )
        _oExtractor := new this.oExtractor( _oWebBrowser )
        
        _aDetails := {  "_reserved": ""
            , "Title": _oExtractor.getTitle()
            , "Price": _oExtractor.getPrice()
            , "NumberOfReviews": _oExtractor.getNumberOfReviews()
            , "Rating": _oExtractor.getRating()
            , "Features": _oExtractor.getFeatures()
            , "Content": _oExtractor.getContent()
            , "Merchant": _oExtractor.getMerchant()
            , "ContentImages": _oExtractor.getContentImages()
            , "Thumbnails": _oExtractor.getThumbnails()
            
            ; Internal information
            , "DownloadedTime": A_Now
            , "_reserved": "" }  
        _aDetails.Delete( "_reserved" )              
        
        _oWebBrowser := ""  ; trigger the destructor 
        
        return _aDetails
    }
    
    class oExtractor {
    
        __New( oWebBrowser ) {
            this.oWebBrowser := oWebBrowser
            this.oWB := oWebBrowser.oWB
        }
        
        getInnerTextByID( oDoc, sID ) {
            _node   := oDoc.getElementById( sID )
            return trim( _node.innerText )
        }
        
        getTitle() {
            return this.getInnerTextByID( this.oWB.document, "productTitle" )
        }
        getPrice() {
            try {
                _sInnerText := this.getInnerTextByID( this.oWB.document, "priceblock_ourprice" )
                
                ; If the price tag is found, go to the catch clause
                if ( "" != _sInnerText ) {
                    throw _sInnerText
                }      
                
                ; Second attempt
                _sInnerText := this.getInnerTextByID( this.oWB.document, "priceblock_saleprice" )
                
            } catch _sError {
                ; No error handling
            } 
            return RegExReplace( _sInnerText, "\D" )
                                   
        }
        getNumberOfReviews() {        
            _sInnerText := this.getInnerTextByID( this.oWB.document, "acrCustomerReviewText" )
            return RegExReplace( _sInnerText, "\D" )            
        }
        getRating() {
            ; _sInnerText := this.getInnerTextByID( this.oWB.document, "avgRating" )    ; somehow not working in some cases
            _sInnerText := this.getInnerTextByID( this.oWB.document, "acrPopover" )
            RegexMatch( _sInnerText, "O)\d\.\d", oMatches )
            return oMatches[ 0 ]
        }
        getFeatures() {
            
            _nodeFeatures  := this.oWB.document.getElementById( "feature-bullets" )
            _nodeLis       := _nodeFeatures.getElementsByTagName( "li" )
            _sFeatures     := ""
            loop % _nodeLis.length {
                _nodeThis  := _nodeLis[ A_Index - 1 ]
                if ( _nodeThis.getAttribute( "id" ) = "replacementPartsFitmentBullet" ) {
                    continue
                }
                _sFeatures .= trim( _nodeThis.innerText ) "`n"
            }
; @todo apply the callback
            return _sFeatures
        }
        getMerchant() {
            return this.getInnerTextByID( this.oWB.document, "merchant-info" )
        }
        getContent() {
            return this.getInnerTextByID( this.oWB.document, "productDescription" )
        }        
        getContentImages() {
            _aImageContainer := []
            for k, _sElementID in [ "productDescription", "aplus", "descriptionAndDetails" ] {
                for _i, _sURL in this._getImageURLsOfElementByID( _sElementID ) {
                    _aImageContainer.push( _sURL )
                }
            }
            return _aImageContainer
        }
            _getImageURLsOfElementByID( sElementID ) {
                _node := this.oWB.document.getElementById( sElementID )
                _nodeImgs := _node.getElementsByTagName( "img" )
                _aImages := []
                loop % _nodeImgs.length {
                    _nodeThis := _nodeImgs[ A_Index - 1 ] 
                    _aImages.push( _nodeThis.getAttribute( "src" ) )
                }            
                return _aImages            
            }
        getThumbnails() {
            _nodeThumb := this.oWebBrowser.oWB.document.getElementById( "imgTagWrapperId" )
            _nodeThumb.click()
            this.oWebBrowser.wait()    
            _aTumbnailNodes := this._getThumbnailNodes( this.oWebBrowser.oWB.document ) 
            _aImages := [ this._getLargeImageFromContainer( this.oWebBrowser.oWB.document ) ]
            for k, node in _aTumbnailNodes {
                
                node.click()
                this.oWebBrowser.wait()

                ; If it is a spinner image, wait for the actual image gets loaded.
                while ( _sSRC := this._getLargeImageFromContainer( this.oWebBrowser.oWB.document ) ) {
                    SplitPath, _sSRC, name, dir, _sExt, name_no_ext, drive
                    if ( _sExt != "gif" ) {
                        break
                    }
                    sleep 200
                    if ( A_Index > 200 ) {  
                        break
                    }
                } 
                
                _aImages.push( _sSRC )
                
            }
            return _aImages        
        }
            _getThumbnailNodes( oDoc ) {
                _aResult := []
                _nodeThumb := true
                while ( _nodeThumb ) {
                    _nodeThumb := oDoc.getElementById( "ivImage_" A_Index )
                    if ( ! _nodeThumb.nodeType ) {
                        break
                    }
                    _aResult.push( _nodeThumb )
                }
                return _aResult
            }        
            _getLargeImageFromContainer( oDoc ) {
                _nodeImageBox := oDoc.getElementById( "ivLargeImage" )
                _nodeImgs     := _nodeImageBox.getElementsByTagName( "img" )
                return this._getFirstSRCImage( _nodeImgs )            
            }
                _getFirstSRCImage( nodeImgs ) {
                    loop % nodeImgs.length {
                        _nodeThis := nodeImgs[ A_Index - 1 ] 
                        return _nodeThis.getAttribute( "src" )
                    }
                }        
    }
        
    /**
     *
     * @since       1.0.1       Renamed an internal global variable name to avoid conflicts.
     */
    class oWebBrowser {
        
        oWB           := ""
        hWnd          := ""
        aHistory      := []
        
        iTimeout      := 20000
        iWindowWidth  := 600
        iWindowHeight := 480
        iMargin       := 10
        
        /**
         * Stores the user agent. Note that this only works in a single navigation with the Navigate() method.
         */ 
        sUserAgent    := ""
        
        bComError := false
        bShowGUI  := false
        
        /**
         * Constructor
         */
        __New() {
            
            this.oWB  := this._getBrowserInstance()
            
        }         
            _getBrowserInstance() {
                
                ; The control variable needs to be static or global
                static __oWB
                static oThis
                oThis := this		;make the class accessible from GUI threads
                
                this.bComError := ComObjError( false )  
                Gui, New, % "hwnd" "hWndWebBrowser" " +Resize" " labelAPDWebBrowser"
                this.hWnd := hWndWebBrowser
                
                _iWindowWidth  := this.iWindowWidth
                _iWindowHeight := this.iWindowHeight
                Gui, Add, ActiveX, % "v__oWB hwndhWndBrowserControl" " w" this.iWindowWidth " h" this.iWindowHeight, Shell.Explorer
                this.hWndBrowserControl := hWndBrowserControl
                this.disableClickSound()        
                
                ; merge with the Webbrowser Control event methods
                ComObjConnect(__oWB, this )

                ; Disable security warnings and putting a url entry into global IE history
                __oWB.Silent := true			
                ComObjError( this.bComError )  
                
                ; Release the object and return the copy
                _oTemp      := __oWB
                __oWB := ""  
                return _oTemp
                
                /**
                 * Called when the GUI window is sized.
                 */
                APDWebBrowserSize:

                    ; The window has been minimized.  No action needed.
                    If (A_EventInfo = 1)  {
                        Return	
                    }

                    ; If this event is triggered with SendMessage, the constants are 0. 
                    ; Note that they are not empty "" but 0            
                    _bArtificialCall := ( A_GuiWidth = 0 ) && ( A_GuiHeight = 0 )
                                
                    ; if this label is artificially invoked, A_GuiHeight and A_GuiWidth won't have a value
                    ; so check their values and if not present, use WinGetPos. A_GUI has a value on the other hand.
                    DHW := A_DetectHiddenWindows
                    DetectHiddenWindows, ON
                    if _bArtificialCall {	

                        ; since A_GuiWidth and A_GuiHeight apply to the window's client area.
                        oThis.GetClientRect(A_GUI, nGuiW, nGuiH)	

                    } else {                                        
                        nGuiW := A_GuiWidth, nGuiH := A_GuiHeight
                    }

                    GuiControl, %A_GUI%:Move, % oThis.hWndBrowserControl
                              , % "W" (nGuiW - oThis.iMargin * 2)
                              . " H" (nGuiH - oThis.iMargin * 2) ; - nHeightAdjustment

                    DetectHiddenWindows, % DHW
                Return
                
            }
                /**
                 * Disables the clicking sound	
                 */
                disableClickSound() {
                    DllCall( "urlmon\CoInternetSetFeatureEnabled"
                         , "Int",  FEATURE_DISABLE_NAVIGATION_SOUNDS := 21
                         , "UInt", SET_FEATURE_ON_PROCESS := 0x00000002
                         , "Int", 1 )
                }  
                /**
                 * Deletes the cache of the url before navigating the page
                 */
                deleteBrowserCache( sURL ) {
                    DllCall( "Wininet\DeleteUrlCacheEntry"
                        , str, sURL )
                }  
                /**
                 * 
                 * @remark      not working
                 */
                deleteCookie( sSiteURL ) {
                    SplitPath, sSiteURL, name, dir, ext, name_no_ext, sDomain               
                    ; InternetSetCookie("http://teste.com", NULL, "name = value; expires = Sat,01-Jan-2000 00:00:00 GMT");
                    DllCall( "Wininet\InternetSetCookie"
                        , str, sDomain
                        , ptr, 0    
                        , str, "name = value; expires = Sat,01-Jan-2000 00:00:00 GMT" )

                }
        /**
         * Destructor
         */
        __Delete() {
            
            this.oWB.Document.Close()
            this.oWB := ""
            _hWndWebBrowser := this.hWnd
            Gui, %_hWndWebBrowser%:Destroy 
            ; ComObjError( this.bComError )  
            this.clearMemory()  
            this.clearWebHistory( "Cookies" )
            for sKey, sURL in this.aHistory {
                this.deleteBrowserCache( sURL )
            }
            
        }    
        
        /**
         * 
         * @return      string
         */
        navigate( sURL ) {

            if ! this.isOnline() {
                return false
            }
            if ( this.bShowGUI ) {
                this.showGUI()
            }
            
            ; JavaScript workardound
            global WB
            WB := this.oWB
            ; SetWBClientSite() 
            
            
            ; Navigate the page
            this.oWB.Navigate( sURL
                , 0x4000|0x1000	; navVirtualTab = 0x4000, navOpenInBackgroundTab = 0x1000,
                , null
                , null
                , this.sUserAgent ? "User-Agent:" this.sUserAgent : "")	; sets a user-agent
            
            ; Wait for the page load
            if ( ! this.wait() ) {
                return false
            }
            
            ; _oNodeID  := this.oWB.document.getElementById( sID )
            ; _sVersion := _oNodeID.innerText
            
    ;        this.clearMemory() 
    ;       this._addToHistory( this.oWB.LocationURL )
            return true
            
        }
            _addToHistory( sURL ) {
                this.aHistory.insert( sURL )
            }
            /**
             * Wait for the page load
             * @return      boolean
             */
            wait( iTimeout=0 ) {
                
                iTimeout      := iTimeout ? iTimeout : this.iTimeout
                _iStartedTime := A_TickCount	; for checking timeout
                Loop {	
                    sleep 1000
                    if ( A_TickCount > _iStartedTime + iTimeout ) {
                        ; ComObjError( ComError ) 
                        ; Gui, %hWndWebBrowser%:Destroy 	
                        ; Timed out
                        return false	
                    }
                } Until ! ( this.oWB.ReadyState != 4 || this.oWB.Document.ReadyState != "Complete" || this.oWB.Busy )
                return true
                
            }
            showGUI() {
                _hWnd := this.hWnd
                Gui, %_hWnd%:Show, % " w" this.iWindowWidth + 20 " h" this.iWindowHeight + 20
            }
            /**
             * Checks whether the PC is online or not.
             */
            isOnline() {
                if DllCall( "Wininet.dll\InternetGetConnectedState", "Str", "0x40", "Int", 0 )
                    return true	
                else 
                    return false
            }
            clearMemory( nPID="" ){
                Process, Exist
                nPID := ( nPID="" ) ? ErrorLevel : nPID
                h := DllCall( "OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", nPID, ptr )
                DllCall( "SetProcessWorkingSetSize", ptr, h, "Int", -1, "Int", -1 )
                DllCall( "CloseHandle", "Int", h )
            }	  

        clearWebHistory( sCmd ) {
            ; by ahklerner
            sValidCmdList 	= Files,Cookies,History,Forms,Passwords,All,All2

            Files 			= 8 	; Clear Temporary Internet Files
            Cookies 		= 2 	; Clear Cookies
            History 		= 1 	; Clear History
            Forms 			= 16 	; Clear Form Data
            Passwords 		= 32 	; Clear Passwords
            All 			= 255 	; Clear all
            All2 			= 4351 	; Clear All and Also delete files and settings stored by add-ons

            If sCmd in %sValidCmdList%
            {
                iCmd = % %sCmd% ; Get the integer value
                ; thanks sean :)
                ; http://www.autohotkey.com/forum/viewtopic.php?p=211775#211775
                VarSetCapacity( wCmd,15,0 )
                DllCall( "MultiByteToWideChar"
                    , "Uint", 0
                    , "Uint", 0
                    , "str", iCmd
                    , "int", -1
                    , "str", wCmd
                    , "int", 8 )
                DllCall( "inetcpl.cpl\ClearMyTracksByProcessW"
                    , "Uint", 0
                    , "Uint", 0
                    , "str", wCmd
                    , "int", 0 )
            }
            ; Else
                ; MsgBox Invalid Command -%sCmd%-`nValid commands are`n%ValidCmdList%
            _iErrorLevel := ErrorLevel
            DllCall( "wininet\InternetSetOption"
                , "int", 0
                , "int", INTERNET_OPTION_END_BROWSER_SESSION := 42
                , "int", 0
                , "int", 0 )
                
            return _iErrorLevel
        }        
             
        
        /**
         * COM metohds.
         */

        /**
         * @see     http://msdn.microsoft.com/en-us/library/aa768337%28v=vs.85%29.aspx
         * 
         * [Parameters]
         * 1: 16393
         * 2: Cancel 16395, a combination of VT_BYREF and VT_BOOL
         * 3: 262150
         * 4: the current url : e.g. http://www.ldoceonline.com/dictionary/?q=
         * 5: the opening url : e.g. http://www.ldoceonline.com/popup/popupmode.html?search_str=something
         * 6: _oWB object
         */
        NewWindow3(oParams*) {
    ; msgbox new window		
            ; strURL := oParams[2], doc := oParams[8].document
            _bCancel    := oParams[2]	; 16395, a combination of VT_BYREF and VT_BOOL
            _sThisURL   := oParams[4]
            _sNewURL    := oParams[5]
            _oWB        := oParams[6]		
            
            ; most likely it is a pronunciation window, opening as an IE window. So cancel it and open it as this program window.
            ; NumPut(-1, ComObjValue(_bCancel), "short")		; this sets _bCancel to True, meaning the new window won't open
            
            ; case for the widget pop up window
            if Instr(_sNewURL, "popup/popupmode") {
    ; msgbox POP up            
                if (strHTMLElements := this.oSearch.GetDefinitions(strTerm := this.GetSelectedText())) {
                    this.DeselectText()			
                    this.RewriteBody(strHTMLElements, strTerm ": " this.oINI.constants.WindowTitle)
                } 
                tooltip
                this.ClearMemory()
                return
            }
            
            ; case for the pronunciation pop up window. e.g.http://www.ldoceonline.com/pronunciation/sound_player.html
            ; also images, menus pops up
            ; @todo this is a nested class and not sure if this instantiation using the class name applies globally.
            new oWebBrowser(_sNewURL, "", True, "center w420 h420", False, "", "", 0, 0, False)

            return
        
        
        }		     

        
             
        /**
         * Utility methods
         */
        
        
        GetClientRect(hwnd, ByRef cw, ByRef ch) {
           VarSetCapacity(RECT, 16, 0)
           Ptr := A_PtrSize ? "Ptr" : "UInt"
           DllCall("User32.dll\GetClientRect", Ptr, hwnd, Ptr, &RECT)
           cw := NumGet(RECT, 8, "Int") , ch := Numget(RECT, 12, "Int")
        }	         
    }    
    
}
