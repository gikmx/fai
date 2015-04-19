### 0.2.7
* `FIX` ﬁ.listen should't require a callback.

### 0.2.6
* `FIX` pseudo require on client-side javascript now emulates a module.exports.
		(minimal implementation, don't expect compatibility with CommonJS)

### 0.2.5
* `NEW` ﬁ.listen now accepts a callback.
* `FIX` Re-enabled ﬁ.extend
* `FIX` Moved ﬁ.util.isDictionary to ﬁ.util.object.isDictionary

### 0.2.4
* `NEW` Added Stylus setting to enable raw CSS files.

### 0.2.3
* `FIX` Improved gulp workflow.
* `FIX` Corrected typo on README.

### 0.2.2
* `NEW` Renamed fi-core to fai.
* `NEW` Project now compiles to JS to when publishing to NPM.
* `FIX` Utils' require now determines the path, before asking for an extension name.
        This is specially important now, since the compiled code, can differ from the
        user's app code.

### 0.2.1
* `FIX` Jeet module was not being loaded correctly on styles.
* `DEL` Removed express-device module.
* `FIX` Application locals are now rendered correctly.
* `FIX` hmac utility now looks for app.secret correctly.
