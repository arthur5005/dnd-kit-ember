import { registerDestructor } from '@ember/destroyable';
import Modifier from 'ember-modifier';

import type Owner from '@ember/owner';
import type { Data, DraggableInput, UniqueIdentifier } from '../types.ts';
import { DragDropManager, Draggable } from '../types.ts';
import { guidFor } from '@ember/object/internals';
import { draggableRegistry, handleRegistry } from './registries.ts';

export interface DraggableModifierSignature<T extends Data = Data> {
  Args: {
    Named: Omit<DraggableInput<T>, 'element'>;
  };
  Element: HTMLElement;
}

export class DraggableModifier<T extends Data = Data> extends Modifier<
  DraggableModifierSignature<T>
> {
  private manager: DragDropManager;
  private draggable?: Draggable<T>;
  private currentId?: UniqueIdentifier;

  constructor(owner: Owner, manager: DragDropManager) {
    super(owner, {} as never);
    this.manager = manager;
    registerDestructor(this, this.cleanup.bind(this));
  }

  get key() {
    if (!this.currentId) {
      return '';
    }

    const managerId = guidFor(this.manager);
    return `${managerId}_${this.currentId}`;
  }

  modify(
    element: HTMLElement,
    _positional: [],
    named: DraggableModifierSignature<T>['Args']['Named'],
  ) {
    this.currentId = named.id;

    if (this.draggable) {
      this.draggable.id = named.id;
      this.draggable.element = element;
      this.draggable.handle = named.handle ?? handleRegistry.get(this.key);
      this.draggable.type = named.type;
      this.draggable.feedback = named.feedback ?? 'default';
      this.draggable.disabled = !!named.disabled;
      this.draggable.sensors = named.sensors;

      if (named.data) {
        this.draggable.data = named.data;
      }
    } else {
      this.draggable = new Draggable(
        { element, handle: handleRegistry.get(this.key), ...named },
        this.manager,
      );
      draggableRegistry.set(this.key, this.draggable);
    }
  }

  private cleanup() {
    if (this.draggable) {
      draggableRegistry.delete(this.key);

      this.draggable.destroy();
      this.draggable = undefined;
    }
  }
}

export function createDraggableModifier(
  manager: DragDropManager,
): typeof DraggableModifier<Data> {
  return class BoundDraggableModifier extends DraggableModifier {
    constructor(owner: Owner) {
      super(owner, manager);
    }
  };
}
