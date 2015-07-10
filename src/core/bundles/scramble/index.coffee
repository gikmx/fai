EsPrima    = require 'esprima'
EsTraverse = require 'estraverse'
ESCodeGen  = require 'escodegen'
ASTtypes   = require 'ast-types'

AST =
	build : ASTtypes.builders
	type  : ASTtypes.namedTypes

Node    = require './node'
Encoder = require './encoder'
Decoder = require './decoder'

module.exports = (code)->
	code = String code
	return code if not code.length

	ast = EsPrima.parse code

	return code if not ast or not ast.body or not ast.body.length

	encoder = new Encoder()
	decoder = new Decoder(encoder)

	ﬁ.log.custom (method: 'debug', caller: 'scramble:base'), encoder.base
	ﬁ.log.custom (method: 'debug', caller: 'scramble:code'), encoder.code

	# The function that will be called on each string
	fnName  = AST.build.identifier "_#{encoder.generate(2)}"

	# Traverse each node inside the code, replacing member expressions and strings
	# Don't forget that the function must return a node, otherwise, it will fail silently.
	EsTraverse.replace ast, enter:(_node, _parent)->

		node = new Node(_node, _parent)

		# Uncomputed member expressions (a.b) will converted to computed (a[b])
		if node.isUncomputedMember()
			name = AST.build.literal encoder.encode node.getProp('property').name
			name._isEncoded  = true
			call = AST.build.callExpression fnName, [name]
			expr = AST.build.memberExpression node.getProp('object'), call, true
			return expr

		# If it's a string, store it in array and  don't do any replacements to node.
		if node.isString()
			if node.getProp('_isEncoded')
				delete _node._isEncoded
				return _node

			# This replacement will generate new nodes that would generate recursion
			# so we issue a skip command to avoid it.
			@skip()

			value = encoder.encode node.getValue()
			value._isEncoded = true
			return AST.build.callExpression(fnName, [AST.build.literal value])

		# Everything else, will be unchanged
		return _node

	# We now need to construct an IIFE (Immediately-invoked Function Expression) that
	# will send the decoding function(s) that will be mapped to an decoding argument.
	body = AST.build.blockStatement(ast.body)
	func = AST.build.functionExpression(null, [fnName], body)
	thiz = AST.build.identifier('this')
	call = AST.build.identifier('call')
	iife = AST.build.expressionStatement(
		AST.build.callExpression(
			AST.build.memberExpression(func, call, false),[thiz, decoder.getAST()]
		)
	)

	# Replace body with IIFE
	ast.body = [iife]

	return ESCodeGen.generate ast
