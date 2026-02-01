import { registerDestructor } from '@ember/destroyable';
import Modifier from 'ember-modifier';

import type Owner from '@ember/owner';
import type { UniqueIdentifier } from '../types.ts';
import { DragDropManager } from '../types.ts';
import { guidFor } from '@ember/object/internals';
import { draggableRegistry, handleRegistry } from './registries.ts';

export interface HandleModifierSignature {
  Args: {
    Named: {
      id: UniqueIdentifier;
    };
  };
  Element: HTMLElement;
}

export class HandleModifier extends Modifier<HandleModifierSignature> {
  private manager: DragDropManager;
  private currentId?: UniqueIdentifier;
  private element?: HTMLElement;

  constructor(owner: Owner, manager: DragDropManager) {
    super(owner, {} as never);
    this.manager = manager;
    registerDestructor(this, this.cleanup.bind(this));
  }

  get key() {
    if (!this.currentId || !this.manager) {
      return '';
    }

    const managerId = guidFor(this.manager);
    return `${managerId}_${this.currentId}`;
  }

  modify(
    element: HTMLElement,
    _positional: [],
    named: HandleModifierSignature['Args']['Named'],
  ) {
    this.element = element;
    this.currentId = named.id;

    handleRegistry.set(this.key, element);
    const draggable = draggableRegistry.get(this.key);
    if (draggable) {
      draggable.handle = this.element;
    }
  }

  private cleanup() {
    // Clear the handle when the modifier is destroyed
    if (this.currentId) {
      handleRegistry.delete(this.key);
      const draggable = draggableRegistry.get(this.key);
      if (draggable && draggable.handle === this.element) {
        draggable.handle = undefined;
      }
    }
  }
}

export function createHandleModifier(
  manager: DragDropManager,
): typeof HandleModifier {
  return class BoundHandleModifier extends HandleModifier {
    constructor(owner: Owner) {
      super(owner, manager);
    }
  };
}
