### 0.2.2
* `NEW` Project now compiles to JS to when publishing to NPM.
* `FIX` Utils' require now determines the path, before asking for an extension name.
        This is specially important now, since the compiled code, can differ from the
        user's app code.

### 0.2.1
* `FIX` Jeet module was not being loaded correctly on styles.
* `DEL` Removed express-device module.
* `FIX` Application locals are now rendered correctly.
* `FIX` hmac utility now looks for app.secret correctly.