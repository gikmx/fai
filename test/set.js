'use strict';

describe('ﬁ.set', function(){

	it('sets a property on the main instance', function(){
		ﬁ.set('__test', true,  {writable:true, configurable:true});
		expect(ﬁ.__test).not.to.equal(undefined);
		delete ﬁ.__test;
	});

	it('allows to redefine a property, as long as it\'s writable.', function(){
		let test1 = function(){
			ﬁ.set('test_writable', true,  {writable: true});
			ﬁ.set('test_writable', 'yes', {writable: true});
		};
		expect(test1).not.to.throw();
		expect(ﬁ.test_writable).to.equal('yes');
	});

	it('allows to delete a property, as long as it\'s configurable.', function(){
		let test1 = function(){
			ﬁ.set('test_configurable', true,  {configurable: true});
			delete ﬁ.test_configurable;
		};
		expect(test1).not.to.throw();
		expect(ﬁ.test_configurable).to.equal(undefined);
	});

	xit('allows a property to be shown, as long as it\'s enumerable.', function(){});

	it('throws an error if a read only property tries to be modified.', function(){
		ﬁ.set('test_read_only_property', {writable:false, configurable:false});
		let test1 = ()=> delete ﬁ.test_read_only_property;
		let test2 = ()=> ﬁ.test_read_only_property = true;
		expect(test1).to.throw(TypeError, 'Cannot delete property');
		expect(test2).to.throw(TypeError, 'Cannot assign to read only property');
	});
});