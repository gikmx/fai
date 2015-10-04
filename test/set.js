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

	it('allows a property to be shown, as long as it\'s enumerable.', function(){
		let test = function(){
			let found = false;
			for (let key in ﬁ) if (key === 'test_enumarable') found = true;
			return found;
		};
		let test1 = function(){
			ﬁ.set('test_enumarable', true, {enumerable:true, configurable:true});
			let result = test();
			delete ﬁ.test_enumarable;
			return result;
		};
		let test2 = function(){
			ﬁ.set('test_enumarable', true, {enumerable:false, configurable:true});
			let result = test();
			delete ﬁ.test_enumarable;
			return result;
		};
		expect(test1).not.to.throw();
		expect(test2).not.to.throw();
		expect(test1()).to.equal(true);
		expect(test2()).to.not.equal(true);
	});

	it('throws an error if a read only property tries to be modified.', function(){
		ﬁ.set('test_read_only_property', {writable:false, configurable:false});
		let test1 = ()=> delete ﬁ.test_read_only_property;
		let test2 = ()=> ﬁ.test_read_only_property = true;
		expect(test1).to.throw(TypeError, 'Cannot delete property');
		expect(test2).to.throw(TypeError, 'Cannot assign to read only property');
	});
});