# obtain locals from settings

throw new ﬁ.error 'Application locals setting missing.' if not ﬁ.settings.locals

locals = ﬁ.util.extend {}, ﬁ.settings.locals

# Shows indented HTML when not in production mode
locals.pretty = not ﬁ.conf.live

# Make ﬁ available for views
#locals.ﬁ = ﬁ

module.exports = locals

