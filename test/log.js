'use strict';

describe('ﬁ.log', function(){

	it('has all common logging methods.', function(done){
		let methods = Object.keys(ﬁ.log);
		expect(methods).to.deep.equal(['trace', 'debug', 'info', 'warn', 'error']);
		done();
	});
});
