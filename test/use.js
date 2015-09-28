'use strict';

describe('ﬁ.use', function(){

	it('accepts a string for «core» modules.', function(){
		let test = function(){
			ﬁ.use('test/module-valid', null, {configurable:true});
			delete ﬁ.__test_valid;
		};
		expect(test).not.to.throw();
	});

	it('accepts a named function for «external» modules.', function(){
		function Test(){ return {}; }
		let test = ()=> ﬁ.use(Test, null, {configurable:true});
		expect(test).not.to.throw();
		expect(ﬁ.test).not.to.equal(undefined);
		delete ﬁ.test;
	});

	it('sets the returned object into the main instance.', function(){
		ﬁ.use('test/module-valid', null, {configurable: true});
		expect(ﬁ.__test_valid).not.to.equal(undefined);
		delete ﬁ.__test_valid;
	});

	it('throws an error a when «core» module cannot be required.', function(){
		let test1 = ()=> ﬁ.use('__non-existent__'); // does not exist
		let test2 = ()=> ﬁ.use('test/module-throws'); // syntax error
		expect(test1).to.throw();
		expect(test2).to.throw();
	});

	it('throws an error when module is not a function.', function(){
		let test1 = ()=> ﬁ.use('test/module-invalid');
		let test2 = ()=> ﬁ.use(null);
		expect(test1).to.throw(TypeError, 'Expected a function');
		expect(test2).to.throw(TypeError, 'Expected a function');
	});

	it('throws an error when module is not a named function.', function(){
		let test1 = ()=> ﬁ.use('test/module-unnamed');
		let test2 = ()=> ﬁ.use(function(){});
		expect(test1).to.throw(ReferenceError, 'Expected a named function');
		expect(test2).to.throw(ReferenceError, 'Expected a named function');
	});

	it('throws an error when module does not return an object.', function(){
		let test1 = ()=> ﬁ.use('test/module-noreturn');
		let test2 = ()=> ﬁ.use(function Test2(){ return true; });
		expect(test1).to.throw(TypeError, 'Expected module to return an object');
		expect(test2).to.throw(TypeError, 'Expected module to return an object');
	});

	it('throws an error when module\'s property tries to be modified.', function(){
		function test_read_only_module(){ return {}; }
		ﬁ.use(test_read_only_module, null, {writable:false, configurable:false});
		let test1 = ()=> delete ﬁ.test_read_only_module;
		let test2 = ()=> ﬁ.test_read_only_module = true;
		expect(test1).to.throw(TypeError, 'Cannot delete property');
		expect(test2).to.throw(TypeError, 'Cannot assign to read only property');
	});

});
