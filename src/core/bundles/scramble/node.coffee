module.exports = class

	constructor: (node, parent)->
		@getNode   =    -> return node
		@getParent =    -> return parent
		@getName   =    -> return node.name
		@getType   =    -> return node.type
		@getValue  =    -> return node.value
		@getProp   = (p)-> return node[String p]

	isIdentifier: ->
		@getType() is 'Identifier'

	isString: ->
		@isLiteralString() and not @isPropertyKey() and not @isUseStrict()

	isExpression: ->
		@getType() is 'ExpressionStatement'

	isAssignment: ->
		@getType() is 'AssignmentExpression'

	isMember: ->
		@getType() is 'MemberExpression'

	isUncomputedMember: ->
		@isMember() and not @getProp('computed')

	isUseStrict:  ->
		@isLiteralString() and @getValue() is 'use strict'

	isLiteralString: ->
		value = @getValue()
		@getType() is 'Literal' and value and value.constructor is String

	isPropertyKey: ->
		parent = @getParent()
		parent.type is 'Property' and ﬁ.util.object.isEqual parent.key, @getNode()
