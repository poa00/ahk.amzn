/**
 * @version       1.2.1       Updated some doc-block descriptions.
 */
class oXMLManipulator {
    
    oXMLCOM     := ""
    sError      := ""
    aNodePathPrefix := []
    sFilePath   := ""
    
    __New( sFilePathOrXMLData ) {
        
        _soXMLCOM := FileExist( sFilePathOrXMLData ) 
            ? this._getXMLCOMByFile( sFilePathOrXMLData )
            : this._getXMLCOMByData( sFilePathOrXMLData ) 
        if ( ! isObject( _soXMLCOM ) ) {
            this.sError := _soXMLCOM
        }
        this.oXMLCOM := _soXMLCOM
        
    }
        _getXMLCOMByData( sXMLData ) {
            _oXML := this._getXMLCOM()
            _oXML.loadXML( sXMLData )
            _bsError := this._isXMLParseError( _oXML )
            if ( _bsError ) {
                return _bsError
            }
            return _oXML
        }            
        _getXMLCOMByFile( sXMLFilePath ) {                        
            this.sFilePath := sXMLFilePath
            _oXML := this._getXMLCOM()
            _oXML.load( sXMLFilePath )             
            _bsError := this._isXMLParseError( _oXML )
            if ( _bsError ) {
                return _bsError
            }
            return _oXML
        }
            _getXMLCOM() {
                static _sMSXML := "MSXML2.DOMDocument" (A_OSVersion ~= "WIN_(7|8)" ? ".6.0" : "")    
                _oXML := ComObjCreate( _sMSXML )
                _oXML.async := false
                _oXML.validateOnParse := false
                ; _oXML.resolveExternals := false       
                return _oXML
            }        
            /**
             * @return      boolean|string      false if no error; otherwise, the error message
             */
            _isXMLParseError( oXMLCOM ) {
                if ( oXMLCOM.parseError.errorCode != 0 ) {  
                   return oXMLCOM.parseError
                }           
                return false
            }    
    
    /**
     * @since       1.2.1
     */
    getDOM() {
        return this.oXMLCOM
    }    
    
    /**
     * Sets the preceding path elements so that there will be no need to enter those each time calling `getValue()`     
     *
     * Sets the node prefix for the `getValue()` method. Use this when you want to omit preceding part of the node path.
     *
     * For example if you want to retrieve value of `Items` -> `Item` -> `Path`, then setting `Items` as a path prefix ebales you to get the value by omitting the set prefix `Item` and you need to spefiy just only `Item`, `Path`.
     */
    setNodePathPrefix( aPath* ) {
        this.aNodePathPrefix := aPath
    }
    
    getSingleNode( aPath* ) {
    
        _aPath := []
        
        ; if the / is explicitly set in the first element, do not use the prefix.
        if ( "/" != aPath[ 1 ] ) {                        
            for k, v in this.aNodePathPrefix {
                _aPath.push( v )
            }
            for k, v in aPath {
                _aPath.push( v )
            }
            aPath := _aPath
        }
        _sPath := this._getNodePath( aPath )    
        return this.oXMLCOM.selectSingleNode( _sPath )
        
    }
    
    /**
     * @return      string
     */
    getValue( aPath* ) {        
        return this.getSingleNode( aPath* ).text
        
    }
        /**
         * @return      string
         */
        _getNodePath( aPath ) {
            _sPath := ""
            for k, v in aPath {
                _sPath .= "/"
                ; this way, the user can set // by setting "/" to the first item
                if ( "/" = v ) {    
                    continue
                }
                _sPath .= v
            }
            return _sPath
        }
    
    /**
        Saves the XML document by preserving the indents.
        @see    https://stackoverflow.com/questions/11144192/how-can-i-save-an-msxml2-domdocument-with-indenting-i-think-it-uses-mxxmlwrite
    ## Example
    var root, node, newnode, 
        dom = new ActiveXObject("MSXML2.DOMDocument.6.0");
    dom.async = false;
    dom.resolveExternals = false;
    dom.load(fullpath);
    root = dom.documentElement;
    node = root.selectSingleNode("/root/node1");
    if (node !== null) {
        newnode = dom.createElement('node2');
        newnode.text = "hello";
        root.appendChild(newnode);
        saveDomWithIndent(dom, fullpath);
    }
     * @since       1.2.0
     */
    save( sFilePath="" ) {
        _sFilePath := sFilePath ? sFilePath : this.sFilePath
        if ( ! _sFilePath ) {
            return
        }
        _oWriter        := ComObjCreate( "MSXML2.MXXMLWriter" ),
        _oReader        := ComObjCreate( "MSXML2.SAXXMLReader" )
        _oFSO           := ComObjCreate( "Scripting.FileSystemObject" )
        _oTextStream    := _oFSO.CreateTextFile( sFilePath, true )
        _oWriter.indent := true
        _oWriter.omitXMLDeclaration := true
        _oReader.contentHandler := _oWriter
        _oReader.parse( this.oXMLCOM )
        _oTextStream.Write( _oWriter.output )
        _oTextStream.Close()
    }
    
}