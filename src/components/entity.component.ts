import {Component} from '@loopback/core';
//import {UpdateCategoryRelationObserver} from '../observers';

export class EntityComponent implements Component {
  lifeCycleObservers = []; //[UpdateCategoryRelationObserver];
}
