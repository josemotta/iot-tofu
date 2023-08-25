import {inject} from '@loopback/core';
import {DefaultCrudRepository} from '@loopback/repository';
import {RegionDataSource} from '../datasources';
import {Category, CategoryRelations} from '../models';

export class CategoryRepository extends DefaultCrudRepository<
  Category,
  typeof Category.prototype.id,
  CategoryRelations
> {
  constructor(
    @inject('datasources.region') dataSource: RegionDataSource,
  ) {
    super(Category, dataSource);
  }
}
