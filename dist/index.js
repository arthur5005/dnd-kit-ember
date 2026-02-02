import { registerDestructor } from '@ember/destroyable';
import { hash } from '@ember/helper';
import { scheduleOnce } from '@ember/runloop';
import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';
import { Draggable, Droppable, DragDropManager } from '@dnd-kit/dom';
export { DragDropManager, Draggable, Droppable, KeyboardSensor, PointerSensor, defaultPreset } from '@dnd-kit/dom';
import { defaultSortableTransition, Sortable, SortableKeyboardPlugin } from '@dnd-kit/dom/sortable';
export { Sortable, SortableKeyboardPlugin, defaultSortableTransition } from '@dnd-kit/dom/sortable';
export { move } from '@dnd-kit/helpers';
import Modifier from 'ember-modifier';
import { guidFor } from '@ember/object/internals';
import { precompileTemplate } from '@ember/template-compilation';
import { setComponentTemplate } from '@ember/component';
import { n } from 'decorator-transforms/runtime-esm';

const draggableRegistry = new Map();
const handleRegistry = new Map();

class DraggableModifier extends Modifier {
  manager;
  draggable;
  currentId;
  constructor(owner, manager) {
    super(owner, {});
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
  modify(element, _positional, named) {
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
      this.draggable = new Draggable({
        element,
        handle: handleRegistry.get(this.key),
        ...named
      }, this.manager);
      draggableRegistry.set(this.key, this.draggable);
    }
  }
  cleanup() {
    if (this.draggable) {
      draggableRegistry.delete(this.key);
      this.draggable.destroy();
      this.draggable = undefined;
    }
  }
}
function createDraggableModifier(manager) {
  return class BoundDraggableModifier extends DraggableModifier {
    constructor(owner) {
      super(owner, manager);
    }
  };
}

class DroppableModifier extends Modifier {
  manager;
  droppable;
  constructor(owner, manager) {
    super(owner, {});
    this.manager = manager;
    registerDestructor(this, this.cleanup.bind(this));
  }
  modify(element, _positional, named) {
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
      this.droppable = new Droppable({
        element,
        ...named
      }, this.manager);
    }
  }
  cleanup() {
    if (this.droppable) {
      this.droppable.destroy();
      this.droppable = undefined;
    }
  }
}
function createDroppableModifier(manager) {
  return class BoundDroppableModifier extends DroppableModifier {
    constructor(owner) {
      super(owner, manager);
    }
  };
}

class SortableModifier extends Modifier {
  manager;
  sortable;
  currentId;
  constructor(owner, manager) {
    super(owner, {});
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
  modify(element, _positional, named) {
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
      this.sortable = new Sortable({
        element,
        // important, eliminates the default OptimisticSortingPlugin, which is not suitable for Ember's rendering model, causing issues with re-rendering
        // including the SortableKeyboardPlugin by default for keyboard accessibility, seems like a sensible default
        plugins: [SortableKeyboardPlugin],
        handle: handleRegistry.get(this.key),
        ...named
      }, this.manager);
      draggableRegistry.set(this.key, this.sortable);
    }
  }
  cleanup() {
    if (this.sortable) {
      draggableRegistry.delete(this.key);
      this.sortable.destroy();
      this.sortable = undefined;
    }
  }
}
function createSortableModifier(manager) {
  return class BoundSortableModifier extends SortableModifier {
    constructor(owner) {
      super(owner, manager);
    }
  };
}

class HandleModifier extends Modifier {
  manager;
  currentId;
  element;
  constructor(owner, manager) {
    super(owner, {});
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
  modify(element, _positional, named) {
    this.element = element;
    this.currentId = named.id;
    handleRegistry.set(this.key, element);
    const draggable = draggableRegistry.get(this.key);
    if (draggable) {
      draggable.handle = this.element;
    }
  }
  cleanup() {
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
function createHandleModifier(manager) {
  return class BoundHandleModifier extends HandleModifier {
    constructor(owner) {
      super(owner, manager);
    }
  };
}

class DragDrop extends Component {
  manager;
  cleanupFns = [];
  constructor(owner, args) {
    super(owner, args);
    const options = {};
    if (this.args.sensors) options.sensors = this.args.sensors;
    if (this.args.plugins) options.plugins = this.args.plugins;
    if (this.args.modifiers) options.modifiers = this.args.modifiers;
    this.manager = new DragDropManager(options);
    // Integrate with Ember's runloop for proper rendering coordination
    this.manager.renderer = {
      get rendering() {
        return new Promise(resolve => {
          // eslint-disable-next-line ember/no-runloop
          scheduleOnce('render', null, resolve);
        });
      }
    };
    // Set up event listeners
    if (this.args.onBeforeDragStart) {
      const cleanup = this.manager.monitor.addEventListener('beforedragstart', this.args.onBeforeDragStart);
      this.cleanupFns.push(cleanup);
    }
    if (this.args.onDragStart) {
      const cleanup = this.manager.monitor.addEventListener('dragstart', this.args.onDragStart);
      this.cleanupFns.push(cleanup);
    }
    if (this.args.onDragMove) {
      const cleanup = this.manager.monitor.addEventListener('dragmove', this.args.onDragMove);
      this.cleanupFns.push(cleanup);
    }
    if (this.args.onDragOver) {
      const cleanup = this.manager.monitor.addEventListener('dragover', this.args.onDragOver);
      this.cleanupFns.push(cleanup);
    }
    if (this.args.onDragEnd) {
      const cleanup = this.manager.monitor.addEventListener('dragend', this.args.onDragEnd);
      this.cleanupFns.push(cleanup);
    }
    if (this.args.onCollision) {
      const cleanup = this.manager.monitor.addEventListener('collision', this.args.onCollision);
      this.cleanupFns.push(cleanup);
    }
    registerDestructor(this, this.cleanup.bind(this));
  }
  cleanup() {
    for (const fn of this.cleanupFns) {
      fn();
    }
    this.cleanupFns = [];
    this.manager.destroy();
  }
  get draggableModifier() {
    return createDraggableModifier(this.manager);
  }
  static {
    n(this.prototype, "draggableModifier", [cached]);
  }
  get droppableModifier() {
    return createDroppableModifier(this.manager);
  }
  static {
    n(this.prototype, "droppableModifier", [cached]);
  }
  get sortableModifier() {
    return createSortableModifier(this.manager);
  }
  static {
    n(this.prototype, "sortableModifier", [cached]);
  }
  get handleModifier() {
    return createHandleModifier(this.manager);
  }
  static {
    n(this.prototype, "handleModifier", [cached]);
  }
  static {
    setComponentTemplate(precompileTemplate("{{yield (hash draggable=this.draggableModifier droppable=this.droppableModifier sortable=this.sortableModifier handle=this.handleModifier manager=this.manager)}}", {
      strictMode: true,
      scope: () => ({
        hash
      })
    }), this);
  }
}

export { DragDrop, DraggableModifier, DroppableModifier, HandleModifier, SortableModifier, createDraggableModifier, createDroppableModifier, createHandleModifier, createSortableModifier };
//# sourceMappingURL=index.js.map
