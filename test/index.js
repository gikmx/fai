'use strict';

describe('fai', function(){

	it('is a function.', function(){
		expect(fai.constructor).to.equal(Function);
	});

	it('returns an object.', function(){
		expect(ﬁ).to.be.an('object');
		expect(ﬁ.constructor).to.equal(Object);
	});

	it('registers a global when told.', function(done){
		GLOBAL.ﬁ = undefined;
		process.env.FAI_GLOBAL = true;
		require(FAI_PATH)();
		expect(GLOBAL.ﬁ).to.not.equal(undefined);
		done();
	});
});