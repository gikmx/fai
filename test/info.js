'use strict';

const Path = require('path');

describe('ﬁ.info', function(){

	it('uses «package.js»', function(done){
		let pack = require(Path.join(FAI_PATH, '..', 'package'));
		expect(ﬁ.info).to.deep.equal(pack);
		done();
	});
});
