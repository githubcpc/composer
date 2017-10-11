/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';

const Admin = require('composer-admin');

const ResetCMD = require('../../lib/cmds/network/resetCommand.js');
const CmdUtil = require('../../lib/cmds/utils/cmdutils.js');
const Reset = require('../../lib/cmds/network/lib/reset.js');
const ora = require('ora');

require('chai').should();

const chai = require('chai');
const sinon = require('sinon');
chai.should();
chai.use(require('chai-things'));
chai.use(require('chai-as-promised'));


let mockAdminConnection;

describe('composer reset network CLI unit tests', function () {

    let sandbox;

    beforeEach(() => {
        sandbox = sinon.sandbox.create();

        mockAdminConnection = sinon.createStubInstance(Admin.AdminConnection);
        mockAdminConnection.createProfile.resolves();
        mockAdminConnection.connect.resolves();
        mockAdminConnection.undeploy.resolves();
        sandbox.stub(CmdUtil, 'createAdminConnection').returns(mockAdminConnection);
        sandbox.stub(process, 'exit');


    });

    afterEach(() => {
        sandbox.restore();
    });


    describe('update command method tests', () => {

        it('should contain update in the command and describe', () => {
            ResetCMD.command.should.include('reset');
            ResetCMD.describe.should.match(/Resets/);
        });

        it('should invoke the Update handler correctly', () => {
            sandbox.stub(Reset, 'handler');
            let argv = {};
            ResetCMD.handler(argv);
            sinon.assert.calledOnce(Reset.handler);
            sinon.assert.calledWith(Reset.handler, argv);
            argv.should.have.property('thePromise');
        });


    });

    describe('test main reset logic', () =>{
        it('main line code path', ()=>{
            let argv = {'businessNetworkName':'networkname','connectionProfileName':'hlfv1','enrollId':'admin','enrollSecret':'adminpw'};
            mockAdminConnection.reset.resolves();
            return Reset.handler(argv).then(()=>{
                sinon.assert.calledWith(mockAdminConnection.reset,'networkname');
            });

        });

        it('no secret given', ()=>{
            let argv = {'businessNetworkName':'networkname','connectionProfileName':'hlfv1','enrollId':'admin'};
            sandbox.stub(CmdUtil, 'prompt').resolves({'enrollmentSecret':'adminpw'});

            return Reset.handler(argv);

        });
        it('error path - prompt method fails', ()=>{
            let argv = {'businessNetworkName':'networkname','connectionProfileName':'hlfv1','enrollId':'admin'};
            sandbox.stub(CmdUtil, 'prompt').rejects(new Error('computer says no'));

            return Reset.handler(argv).should.eventually.be.rejectedWith(/computer says no/);

        });
        it('error path #2 prompt method fails, along with the spinner class', ()=>{
            let argv = {'businessNetworkName':'networkname','connectionProfileName':'hlfv1','enrollId':'admin','enrollSecret':'adminpw'};
            mockAdminConnection.reset.rejects(new Error('computer says no'));
            sandbox.stub(ora,'start').returns({});
            sandbox.stub(ora,'fail').returns();

            return Reset.handler(argv).should.eventually.be.rejectedWith(/computer says no/);

        });
    });

});
