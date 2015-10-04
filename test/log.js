'use strict';

describe('ﬁ.log', function(){

	it('has all common logging methods.', function(done){
		let methods = Object.keys(ﬁ.log);
		expect(methods).to.deep.equal(['trace', 'debug', 'info', 'warn', 'error']);
		done();
	});

	xit('follows the defined pattern.', function(){});
	xit('can use custom logging methods', function(){});
	xit('omits levels that are not enabled.', function(){});
	xit('omits functions that don\'t pass the «show» expression', function(){});
	xit('throwz an error if an invalid «type» output is used.', function(){});
	xit('throws an error if an invalid «show» expression is used.', function(){});
	xit('throws an error if an invalid «color» is used for a method.', function(){});

});
