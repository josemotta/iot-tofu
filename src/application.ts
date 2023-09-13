import {BootMixin} from '@loopback/boot';
import {Application, ApplicationConfig} from '@loopback/core';
import {RestExplorerBindings} from '@loopback/rest-explorer';
import {RepositoryMixin} from '@loopback/repository';
import {RestBindings, RestComponent, RestServer} from '@loopback/rest';
import {ServiceMixin} from '@loopback/service-proxy';
import path from 'path';
import {MySequence} from './sequence';
import {
  EntityComponent,
  ValidatorsComponent,
  RestExplorerComponent,
} from './components';
import {ApiResourceProvider} from './providers/api-resources.provider';
// import {Category} from './models';
// import {ValidatorService} from 'services/validator.services';

export {ApplicationConfig};

export class BackApplication extends BootMixin(
  ServiceMixin(RepositoryMixin(Application)),
) {
  constructor(options: ApplicationConfig = {}) {
    super(options);

    // Set up the custom sequence
    options.rest.sequence = MySequence;

    this.component(RestComponent);
    const restServer = this.getSync<RestServer>('servers.RestServer');

    // Set up default home page
    restServer.static('/', path.join(__dirname, '../public'));

    // Customize @loopback/rest-explorer configuration here
    this.bind(RestExplorerBindings.CONFIG).to({
      path: '/explorer',
    });

    this.bind(RestBindings.SequenceActions.SEND).toProvider(
      ApiResourceProvider,
    );

    this.component(RestExplorerComponent);
    this.component(ValidatorsComponent);
    this.component(EntityComponent);

    this.projectRoot = __dirname;

    this.bootOptions = {
      controllers: {
        // Customize ControllerBooter Conventions here
        dirs: ['controllers'],
        extensions: ['.controller.js', '.controller.ts'],
        nested: true,
      },
      repositories: {
        // Customize RepositoryBooter Conventions here
        dirs: ['repositories'],
        extensions: ['.repository.js', '.repository.ts'],
        nested: true,
      },
    };
  }

  async boot() {
    await super.boot();

    // validator development tests

    // const validator = this.getSync<ValidatorService>(
    //   'services.ValidatorService',
    // );
    // try {
    //   await validator.validate({
    //     data: {},
    //     entityClass: Category,
    //   });
    // } catch (e) {
    //   console.dir(e, {depth: 8});
    // }

    // const categoryRepo = this.getSync('repositories.CategoryRepository');
    // // @ts-ignore
    // const category = await categoryRepo.find({where: {id: '1-cat'}});
    // console.log(category);
    // // @ts-ignore
    // categoryRepo.updateById(category[0].id, {
    //   ...category[0],
    //   name: 'Funcionando no Loopback',
    // });
    // const validator = this.getSync<ValidatorService>('services.ValidatorService');
    // try {
    //   await validator.validate({
    //     data: {
    //       id: ['1-cat', '2-cat']
    //     },
    //     entityClass: Category
    //   })
    // } catch (e) {
    //   console.dir(e, { depth: 8 })
    // }

    // try {
    //   await validator.validate({
    //     data: {},
    //     entityClass: Genre
    //   })
    // }catch (e) {
    //   console.dir(e, {depth: 8})
    // }
  }
}
