# oAmazonProductDetails
Downloads Amazon product details by ASIN.

### Example
```autohotkey
oAPD := new oAmazonProductDetails( "B01ETRGGYI", "amazon.co.jp" )
aDetails := oAPD.get()
```


### Change Log
#### 1.1.0 - 2017/08/11
 - Fixed an issue that thumbnails were no longer retrieved.
 - Fixed an issue that sponsored images were included in content images.
#### 1.0.0 - 2017/07/28
 - Released.