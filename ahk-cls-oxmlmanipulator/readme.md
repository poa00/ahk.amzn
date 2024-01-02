# oXMLManipulator
An AutoHotkey class that helps manipulate XML files.

## Properties

### oXMLCOM
Stores the COM object. oftern reffered as a DOM object.

## Methods
### setNodePathPrefix( aPath* )
Sets the node prefix for the `getValue()` method. Use this when you want to omit preceding part of the node path.

For example if you want to retrieve value of `Items` -> `Item` -> `Path`, then setting `Items` as a path prefix ebales you to get the value by omitting the set prefix `Item` and you need to spefiy just only `Item`, `Path`.
#### Parameters
##### aPath*
(object)
#### Return Value
Void

### getSingleNode( aPath* ) 
#### Parameters
##### aPath*
(object)
#### Return Value
Void

### getValue( aPath* )
#### Parameters
##### aPath*
(object) The node path to get the value out of.
#### Return Value
(String) The value set to the specified node.

### save( sFilePath="" )
#### Parameters
##### sFilePath
(string) The target file path. If omitted, the loaded XML file path will be used.

### Change Log
#### 1.2.1 - 2017/07/27
 - Added the `getDOM()` method.
#### 1.2.0
 - Added the save() method.
#### 1.0.1
 - Added the getSingleNode() method.
#### 1.0.0
 - Released initially.