import { registerDestructor } from '@ember/destroyable';
import Modifier from 'ember-modifier';

import type Owner from '@ember/owner';
import type { Data, DroppableInput } from '../types.ts';
import { DragDropManager, Droppable } from '../types.ts';

export interface DroppableModifierSignature<T extends Data = Data> {
  Args: {
    Named: Omit<DroppableInput<T>, 'element'>;
  };
  Element: HTMLElement;
}

export class DroppableModifier<T extends Data = Data> extends Modifier<
  DroppableModifierSignature<T>
> {
  private manager: DragDropManager;
  private droppable?: Droppable<T>;

  constructor(owner: Owner, manager: DragDropManager) {
    super(owner, {} as never);
    this.manager = manager;
    registerDestructor(this, this.cleanup.bind(this));
  }

  modify(
    element: HTMLElement,
    _positional: [],
    named: DroppableModifierSignature<T>['Args']['Named'],
  ) {
    if (this.droppable) {
      this.droppable.id = named.id;
      this.droppable.element = element;
      this.droppable.accept = named.accept;
      this.droppable.collisionPriority = named.collisionPriority;
      this.droppable.disabled = !!named.disabled;
      this.droppable.type = named.type;

      if (named.collisionDetector) {
        this.droppable.collisionDetector = named.collisionDetector;
      }

      if (named.data) {
        this.droppable.data = named.data;
      }
    } else {
      this.droppable = new Droppable({ element, ...named }, this.manager);
    }
  }

  private cleanup() {
    if (this.droppable) {
      this.droppable.destroy();
      this.droppable = undefined;
    }
  }
}

export function createDroppableModifier(
  manager: DragDropManager,
): typeof DroppableModifier<Data> {
  return class BoundDroppableModifier extends DroppableModifier {
    constructor(owner: Owner) {
      super(owner, manager);
    }
  };
}
