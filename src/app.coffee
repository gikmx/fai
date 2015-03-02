locals =
	pretty  : not ﬁ.conf.live
	basedir : ﬁ.path.app.root

app             = {}
app.conf        = ﬁ.require.fs ﬁ.path.app.conf
app.locals      = app.conf.locals or {}
app.locals      = ﬁ.util.object.extend locals, app.locals

module.exports = app