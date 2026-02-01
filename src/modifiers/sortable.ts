import { registerDestructor } from '@ember/destroyable';
import Modifier from 'ember-modifier';

import type Owner from '@ember/owner';
import type { Data, SortableInput, UniqueIdentifier } from '../types.ts';
import {
  DragDropManager,
  Sortable,
  SortableKeyboardPlugin,
  defaultSortableTransition,
} from '../types.ts';
import { guidFor } from '@ember/object/internals';
import { draggableRegistry, handleRegistry } from './registries.ts';

export interface SortableModifierSignature<T extends Data = Data> {
  Args: {
    Named: Omit<SortableInput<T>, 'element'>;
  };
  Element: HTMLElement;
}

export class SortableModifier<T extends Data = Data> extends Modifier<
  SortableModifierSignature<T>
> {
  private manager: DragDropManager;
  private sortable?: Sortable<T>;
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
    named: SortableModifierSignature<T>['Args']['Named'],
  ) {
    this.currentId = named.id;

    if (this.sortable) {
      this.sortable.id = named.id;
      this.sortable.element = element;
      this.sortable.index = named.index;
      this.sortable.group = named.group;
      this.sortable.handle = named.handle ?? handleRegistry.get(this.key);
      this.sortable.type = named.type;
      this.sortable.accept = named.accept;
      this.sortable.disabled = named.disabled ?? false;
      this.sortable.feedback = named.feedback ?? 'default';
      this.sortable.alignment = named.alignment;
      this.sortable.modifiers = named.modifiers;
      this.sortable.sensors = named.sensors;
      this.sortable.collisionPriority = named.collisionPriority;
      this.sortable.transition = named.transition ?? defaultSortableTransition;

      if (named.collisionDetector) {
        this.sortable.collisionDetector = named.collisionDetector;
      }

      if (named.data) {
        this.sortable.data = named.data;
      }
    } else {
      this.sortable = new Sortable(
        {
          element,
          // important, eliminates the default OptimisticSortingPlugin, which is not suitable for Ember's rendering model, causing issues with re-rendering
          // including the SortableKeyboardPlugin by default for keyboard accessibility, seems like a sensible default
          plugins: [SortableKeyboardPlugin],
          handle: handleRegistry.get(this.key),
          ...named,
        },
        this.manager,
      );

      draggableRegistry.set(this.key, this.sortable);
    }
  }

  private cleanup() {
    if (this.sortable) {
      draggableRegistry.delete(this.key);

      this.sortable.destroy();
      this.sortable = undefined;
    }
  }
}

export function createSortableModifier(
  manager: DragDropManager,
): typeof SortableModifier<Data> {
  return class BoundSortableModifier extends SortableModifier {
    constructor(owner: Owner) {
      super(owner, manager);
    }
  };
}
