import {Chance} from 'chance';
import {UniqueEntityId} from 'utils/unique-entity-id';
import {Category} from '../../../models';

type PropOrFactory<T> = T | ((_index: number) => T);

export class CategoryFakeBuilder<TBuild = any> {
  private chance: any;

  // auto-generated in entity
  private _unique_entity_id = undefined;
  private _name: PropOrFactory<string> = _index => this.chance.word();
  private _description: PropOrFactory<string> = _index => this.chance.word();
  private _active: PropOrFactory<boolean> = _index => true;
  // auto-generated in entity
  private _created = undefined;
  private _updated = undefined;

  private countObjs;

  // Only aCategory() & theCategories() are accessible

  static aCategory() {
    return new CategoryFakeBuilder<Category>();
  }

  static theCategories(countObjs: number) {
    return new CategoryFakeBuilder<Category[]>(countObjs);
  }

  private constructor(countObjs = 1) {
    this.countObjs = countObjs;
    this.chance = new Chance() as Chance.Chance;
  }

  withUniqueEntityId(valueOrFactory: PropOrFactory<UniqueEntityId>) {
    this._unique_entity_id = valueOrFactory;
    return this;
  }

  withName(valueOrFactory: PropOrFactory<string>) {
    this._name = valueOrFactory;
    return this;
  }

  withInvalidNameNotString(value?: any) {
    this._name = value ?? 5;
    return this;
  }

  withInvalidNameTooLong(value?: string) {
    this._name = value ?? this.chance.word({length: 256});
    return this;
  }

  withDescription(valueOrFactory: PropOrFactory<string>) {
    this._description = valueOrFactory;
    return this;
  }

  withInvalidNameEmpty(value: '' | null | undefined) {
    this._name = value;
    return this;
  }

  withInvalidDescriptionNotString(value?: any) {
    this._description = value ?? 5;
    return this;
  }

  withInvalidDescriptionTooLong(value?: string) {
    this._description = value ?? this.chance.word({length: 256});
    return this;
  }

  withActiveTrue() {
    this._active = true;
    return this;
  }

  withActiveFalse() {
    this._active = false;
    return this;
  }

  withInvalidActiveEmpty(value: '' | null | undefined) {
    this._active = value as any;
    return this;
  }

  withInvalidActiveNotBoolean(value?: any) {
    this._active = value ?? 'fake boolean';
    return this;
  }

  withCreated(valueOrFactory: PropOrFactory<Date>) {
    this._created = valueOrFactory;
    return this;
  }

  withUpdated(valueOrFactory: PropOrFactory<Date>) {
    this._updated = valueOrFactory;
    return this;
  }

  build(): TBuild {
    const categories = new Array(this.countObjs).fill(undefined).map(
      (_, index) =>
        new Category({
          id: !this._unique_entity_id
            ? undefined
            : this.callFactory(this._unique_entity_id.id, index),
          name: this.callFactory(this._name, index),
          description: this.callFactory(this._description, index),
          active: this.callFactory(this._active, index),
          ...(this._created && {
            created: this.callFactory(this._created, index),
          }),
          ...(this._updated && {
            updated: this.callFactory(this._updated, index),
          }),
        }),
    );
    return this.countObjs === 1 ? (categories[0] as any) : categories;
  }

  get unique_entity_id() {
    return this.getValue('unique_entity_id');
  }
  get name() {
    return this.getValue('name');
  }
  get description() {
    return this.getValue('description');
  }
  get active() {
    return this.getValue('active');
  }
  get created() {
    return this.getValue('created');
  }
  get updated() {
    return this.getValue('updated');
  }

  private getValue(prop) {
    const optional = ['unique_entity_id', 'created', 'updated'];
    const privateProp = `_${prop}`;
    if (!this[privateProp] && optional.includes(prop)) {
      throw new Error(
        `Property ${prop} does not have a factory, use a 'with' method`,
      );
    }
    return this.callFactory(this[privateProp], 0);
  }

  private callFactory(factoryOrValue: PropOrFactory<any>, index: number) {
    return typeof factoryOrValue === 'function'
      ? factoryOrValue(index)
      : factoryOrValue;
  }
}
