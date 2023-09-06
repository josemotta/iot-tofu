// Adapted from https://github.com/loopbackio/loopback-datasource-juggler/blob/master/test/datasource.test.js

import {RegionDataSource as DataSource} from '../region.datasource';

describe('DataSource', () => {
  describe('constructor', () => {
    it('clones settings to prevent surprising changes in passed args', () => {
      const config = {connector: 'memory'};

      const ds = new DataSource(config);
      ds.settings.extra = true;

      expect(config).toStrictEqual({connector: 'memory'});
    });

    it('reports helpful error when connector init throws', () => {
      const throwingConnector = {
        name: 'loopback-connector-throwing',
        initialize: function (ds, cb) {
          throw new Error('expected test error');
        },
      };

      expect(() => {
        // this is what LoopBack does
        return new DataSource({
          name: 'dsname',
          connector: throwingConnector,
        });
      }).toThrow(/loopback-connector-throwing/);
    });

    it('should retain the name assigned to it', () => {
      const dataSource = new DataSource({
        name: 'myDataSource',
        connector: 'memory',
      });

      expect(dataSource.name).toStrictEqual('myDataSource');
    });

    it('should retain the name from the settings if no name is assigned', () => {
      const dataSource = new DataSource({
        name: 'defaultDataSource',
        connector: 'memory',
      });

      expect(dataSource.name).toStrictEqual('defaultDataSource');
    });

    it('should use the connector name if no name is provided', () => {
      const dataSource = new DataSource({
        connector: 'memory',
      });

      expect(dataSource.name).toStrictEqual('memory');
    });

    it('should accept resolved connector', () => {
      const mockConnector = {
        name: 'loopback-connector-mock',
        initialize: (ds, cb) => {
          ds.connector = mockConnector;
          return cb(null);
        },
      };
      const dataSource = new DataSource(mockConnector);

      expect(dataSource.name).toStrictEqual('loopback-connector-mock');
      expect(dataSource.connector).toStrictEqual(mockConnector);
    });

    it('should set states correctly with eager connect', done => {
      const mockConnector = {
        name: 'loopback-connector-mock',
        initialize: function (ds, cb) {
          ds.connector = mockConnector;
          this.connect(cb);
        },

        connect: function (cb) {
          process.nextTick(function () {
            cb(null);
          });
        },
      };
      const dataSource = new DataSource(mockConnector);
      // DataSource is instantiated
      // connected: false, connecting: false, initialized: false
      expect(dataSource.connected).toBeFalsy();
      expect(dataSource.connecting).toBeFalsy();
      expect(dataSource.initialized).toBeFalsy();

      dataSource.on('initialized', () => {
        // DataSource is initialized with lazyConnect
        // connected: false, connecting: false, initialized: true
        expect(dataSource.connected).toBeFalsy();
        expect(dataSource.connecting).toBeFalsy();
        expect(dataSource.initialized).toBeTruthy();
      });

      dataSource.on('connected', () => {
        // DataSource is now connected
        // connected: true, connecting: false
        expect(dataSource.connected).toBeTruthy();
        expect(dataSource.connecting).toBeFalsy();
      });

      // Call connect() in next tick so that we'll receive initialized event
      // first
      process.nextTick(function () {
        // At this point, the datasource is already connected by
        // connector's (mockConnector) initialize function
        dataSource.connect(function () {
          // DataSource is now connected
          // connected: true, connecting: false
          expect(dataSource.connected).toBeTruthy();
          expect(dataSource.connecting).toBeFalsy();
          done();
        });
        // As the datasource is already connected, no connecting will happen
        // connected: true, connecting: false
        expect(dataSource.connected).toBeTruthy();
        expect(dataSource.connecting).toBeFalsy();
      });
    });

    it('should set states correctly with deferred connect', done => {
      const mockConnector = {
        name: 'loopback-connector-mock',
        initialize: (ds, cb) => {
          ds.connector = mockConnector;
          // Explicitly call back with false to denote connection is not ready
          process.nextTick(function () {
            cb(null, false);
          });
        },

        connect: function (cb) {
          process.nextTick(function () {
            cb(null);
          });
        },
      };
      const dataSource = new DataSource(mockConnector);
      // DataSource is instantiated
      // connected: false, connecting: false, initialized: false
      expect(dataSource.connected).toBeFalsy();
      expect(dataSource.connecting).toBeFalsy();
      expect(dataSource.initialized).toBeFalsy();

      dataSource.on('initialized', function () {
        // DataSource is initialized with lazyConnect
        // connected: false, connecting: false, initialized: true
        expect(dataSource.connected).toBeFalsy();
        expect(dataSource.connecting).toBeFalsy();
        expect(dataSource.initialized).toBeTruthy();
      });

      dataSource.on('connected', function () {
        // DataSource is now connected
        // connected: true, connecting: false
        expect(dataSource.connected).toBeTruthy();
        expect(dataSource.connecting).toBeFalsy();
      });

      // Call connect() in next tick so that we'll receive initialized event
      // first
      process.nextTick(() => {
        dataSource.connect(() => {
          // DataSource is now connected
          // connected: true, connecting: false
          expect(dataSource.connected).toBeTruthy();
          expect(dataSource.connecting).toBeFalsy();
          done();
        });
        // As the datasource is not connected, connecting will happen
        // connected: false, connecting: true
        expect(dataSource.connected).toBeFalsy();
        expect(dataSource.connecting).toBeTruthy();
      });
    });
  });

  // it('provides stop() API calling disconnect', done => {
  //   const mockConnector = {
  //     name: 'loopback-connector-mock',
  //     initialize: (ds, cb) => {
  //       ds.connector = mockConnector;
  //       process.nextTick(() => {
  //         cb(null);
  //       });
  //     },
  //   };

  //   const dataSource = new DataSource(mockConnector);
  //   dataSource.on('connected', () => {
  //     // DataSource is now connected
  //     // connected: true, connecting: false
  //     expect(dataSource.connected).toBeTruthy();
  //     expect(dataSource.connecting).toBeFalsy();

  //     dataSource.stop(() => {
  //       expect(dataSource.connected).toBeFalsy();
  //       done();
  //     });
  //   });
  // });
});

// describe('deleteModelByName()', () => {
//   it('removes the model from ModelBuilder registry', () => {
//     const ds = new DataSource('ds', {connector: 'memory'});

//     ds.createModel('TestModel');
//     Object.keys(ds.modelBuilder.models).should.containEql('TestModel');
//     Object.keys(ds.modelBuilder.definitions).should.containEql('TestModel');

//     ds.deleteModelByName('TestModel');

//     Object.keys(ds.modelBuilder.models).should.not.containEql('TestModel');
//     Object.keys(ds.modelBuilder.definitions).should.not.containEql('TestModel');
//   });

//   it('removes the model from connector registry', () => {
//     const ds = new DataSource('ds', {connector: 'memory'});

//     ds.createModel('TestModel');
//     Object.keys(ds.connector._models).should.containEql('TestModel');

//     ds.deleteModelByName('TestModel');

//     Object.keys(ds.connector._models).should.not.containEql('TestModel');
//   });
// });

//   describe('execute', () => {
//     let ds;
//     beforeEach(() => ds = new DataSource('ds', {connector: 'memory'}));

//     it('calls connnector to execute the command', async () => {
//       let called = 'not called';
//       ds.connector.execute = function(command, args, options, callback) {
//         called = {command, args, options};
//         callback(null, 'a-result');
//       };

//       const result = await ds.execute(
//         'command',
//         ['arg1', 'arg2'],
//         {'a-flag': 'a-value'},
//       );

//       result.should.be.equal('a-result');
//       called.should.be.eql({
//         command: 'command',
//         args: ['arg1', 'arg2'],
//         options: {'a-flag': 'a-value'},
//       });
//     });

//     it('supports shorthand version (cmd)', async () => {
//       let called = 'not called';
//       ds.connector.execute = function(command, args, options, callback) {
//         // copied from loopback-connector/lib/sql.js
//         if (typeof args === 'function' && options === undefined && callback === undefined) {
//           // execute(sql, callback)
//           options = {};
//           callback = args;
//           args = [];
//         }

//         called = {command, args, options};
//         callback(null, 'a-result');
//       };

//       const result = await ds.execute('command');
//       result.should.be.equal('a-result');
//       called.should.be.eql({
//         command: 'command',
//         args: [],
//         options: {},
//       });
//     });

//     it('supports shorthand version (cmd, args)', async () => {
//       let called = 'not called';
//       ds.connector.execute = function(command, args, options, callback) {
//         // copied from loopback-connector/lib/sql.js
//         if (typeof options === 'function' && callback === undefined) {
//           // execute(sql, params, callback)
//           callback = options;
//           options = {};
//         }

//         called = {command, args, options};
//         callback(null, 'a-result');
//       };

//       await ds.execute('command', ['arg1', 'arg2']);
//       called.should.be.eql({
//         command: 'command',
//         args: ['arg1', 'arg2'],
//         options: {},
//       });
//     });

//     it('converts multiple callbacks arguments into a promise resolved with an array', async () => {
//       ds.connector.execute = function() {
//         const callback = arguments[arguments.length - 1];
//         callback(null, 'result1', 'result2');
//       };
//       const result = await ds.execute('command');
//       result.should.eql(['result1', 'result2']);
//     });

//     it('allows args as object', async () => {
//       let called = 'not called';
//       ds.connector.execute = function(command, args, options, callback) {
//         called = {command, args, options};
//         callback();
//       };

//       // See https://www.npmjs.com/package/loopback-connector-neo4j-graph
//       const command = 'MATCH (u:User {email: {email}}) RETURN u';
//       await ds.execute(command, {email: 'alice@example.com'}, {options: true});
//       called.should.be.eql({
//         command,
//         args: {email: 'alice@example.com'},
//         options: {options: true},
//       });
//     });

//     it('supports MongoDB version (collection, cmd, args, options)', async () => {
//       let called = 'not called';
//       ds.connector.execute = function(...params) {
//         const callback = params.pop();
//         called = params;
//         callback(null, 'a-result');
//       };

//       const result = await ds.execute(
//         'collection',
//         'command',
//         ['arg1', 'arg2'],
//         {options: true},
//       );

//       result.should.equal('a-result');
//       called.should.be.eql([
//         'collection',
//         'command',
//         ['arg1', 'arg2'],
//         {options: true},
//       ]);
//     });

//     it('supports free-form version (...params)', async () => {
//       let called = 'not called';
//       ds.connector.execute = function(...params) {
//         const callback = params.pop();
//         called = params;
//         callback(null, 'a-result');
//       };

//       const result = await ds.execute(
//         'arg1',
//         'arg2',
//         'arg3',
//         'arg4',
//         {options: true},
//       );

//       result.should.equal('a-result');
//       called.should.be.eql([
//         'arg1',
//         'arg2',
//         'arg3',
//         'arg4',
//         {options: true},
//       ]);
//     });

//     it('throws NOT_IMPLEMENTED when no connector is provided', () => {
//       ds.connector = undefined;
//       return ds.execute('command').should.be.rejectedWith({
//         code: 'NOT_IMPLEMENTED',
//       });
//     });

//     it('throws NOT_IMPLEMENTED for connectors not implementing execute', () => {
//       ds.connector.execute = undefined;
//       return ds.execute('command').should.be.rejectedWith({
//         code: 'NOT_IMPLEMENTED',
//       });
//     });
//   });

//   describe('automigrate', () => {
//     it('reports connection errors (immediate connect)', async () => {
//       const dataSource = new DataSource({
//         connector: givenConnectorFailingOnConnect(),
//       });
//       dataSource.define('MyModel');
//       await dataSource.automigrate().should.be.rejectedWith(/test failure/);
//     });

//     it('reports connection errors (lazy connect)', () => {
//       const dataSource = new DataSource({
//         connector: givenConnectorFailingOnConnect(),
//         lazyConnect: true,
//       });
//       dataSource.define('MyModel');
//       return dataSource.automigrate().should.be.rejectedWith(/test failure/);
//     });

//     function givenConnectorFailingOnConnect() {
//       return givenMockConnector({
//         connect: function(cb) {
//           process.nextTick(() => cb(new Error('test failure')));
//         },
//         automigrate: function(models, cb) {
//           cb(new Error('automigrate should not have been called'));
//         },
//       });
//     }
//   });

//   describe('autoupdate', () => {
//     it('reports connection errors (immediate connect)', async () => {
//       const dataSource = new DataSource({
//         connector: givenConnectorFailingOnConnect(),
//       });
//       dataSource.define('MyModel');
//       await dataSource.autoupdate().should.be.rejectedWith(/test failure/);
//     });

//     it('reports connection errors (lazy connect)', () => {
//       const dataSource = new DataSource({
//         connector: givenConnectorFailingOnConnect(),
//         lazyConnect: true,
//       });
//       dataSource.define('MyModel');
//       return dataSource.autoupdate().should.be.rejectedWith(/test failure/);
//     });

//     function givenConnectorFailingOnConnect() {
//       return givenMockConnector({
//         connect: function(cb) {
//           process.nextTick(() => cb(new Error('test failure')));
//         },
//         autoupdate: function(models, cb) {
//           cb(new Error('autoupdate should not have been called'));
//         },
//       });
//     }
//   });

//   describe('deleteAllModels', () => {
//     it('removes all model definitions', () => {
//       const ds = new DataSource({connector: 'memory'});
//       ds.define('Category');
//       ds.define('Product');

//       Object.keys(ds.modelBuilder.definitions)
//         .should.deepEqual(['Category', 'Product']);
//       Object.keys(ds.modelBuilder.models)
//         .should.deepEqual(['Category', 'Product']);
//       Object.keys(ds.connector._models)
//         .should.deepEqual(['Category', 'Product']);

//       ds.deleteAllModels();

//       Object.keys(ds.modelBuilder.definitions).should.be.empty();
//       Object.keys(ds.modelBuilder.models).should.be.empty();
//       Object.keys(ds.connector._models).should.be.empty();
//     });

//     it('preserves the connector instance', () => {
//       const ds = new DataSource({connector: 'memory'});
//       const connector = ds.connector;
//       ds.deleteAllModels();
//       ds.connector.should.equal(connector);
//     });
//   });

//   describe('getMaxOfflineRequests', () => {
//     let ds;
//     beforeEach(() => ds = new DataSource('ds', {connector: 'memory'}));

//     it('sets the default maximum number of event listeners to 16', () => {
//       ds.getMaxOfflineRequests().should.be.eql(16);
//     });

//     it('uses provided number of listeners', () => {
//       ds.settings.maxOfflineRequests = 17;
//       ds.getMaxOfflineRequests().should.be.eql(17);
//     });

//     it('throws an error if a non-number is provided for the max number of listeners', () => {
//       ds.settings.maxOfflineRequests = '17';

//       (function() {
//         return ds.getMaxOfflineRequests();
//       }).should.throw('maxOfflineRequests must be a number');
//     });
//   });
// });

// function givenMockConnector(props) {
//   const connector = {
//     name: 'loopback-connector-mock',
//     initialize: function(ds, cb) {
//       ds.connector = connector;
//       if (ds.settings.lazyConnect) {
//         cb(null, false);
//       } else {
//         connector.connect(cb);
//       }
//     },
//     ...props,
//   };
//   return connector;
// }
