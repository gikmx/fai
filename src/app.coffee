locals =
	pretty  : not ﬁ.conf.live
	basedir : ﬁ.path.app.root

app        = ﬁ.require.fs ﬁ.path.app.conf
app.locals = {} if not app.locals
app.locals = ﬁ.util.object.extend locals, app.locals

module.exports = app