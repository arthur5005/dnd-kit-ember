import { registerDestructor } from '@ember/destroyable';
import { hash } from '@ember/helper';
import { scheduleOnce } from '@ember/runloop';
import Component from '@glimmer/component';
import { cached } from '@glimmer/tracking';

import type Owner from '@ember/owner';
import type { Data, DragDropEvents, DragDropManagerInput } from '../types.ts';
import { DragDropManager } from '../types.ts';

import {
  DraggableModifier,
  createDraggableModifier,
  DroppableModifier,
  createDroppableModifier,
  SortableModifier,
  createSortableModifier,
  HandleModifier,
  createHandleModifier,
} from '../modifiers/index.ts';

export interface DragDropSignature {
  Args: {
    sensors?: DragDropManagerInput['sensors'];
    plugins?: DragDropManagerInput['plugins'];
    modifiers?: DragDropManagerInput['modifiers'];
    onBeforeDragStart?: DragDropEvents['beforedragstart'];
    onDragStart?: DragDropEvents['dragstart'];
    onDragMove?: DragDropEvents['dragmove'];
    onDragOver?: DragDropEvents['dragover'];
    onDragEnd?: DragDropEvents['dragend'];
    onCollision?: DragDropEvents['collision'];
  };
  Blocks: {
    default: [
      {
        draggable: typeof DraggableModifier<Data>;
        droppable: typeof DroppableModifier<Data>;
        sortable: typeof SortableModifier<Data>;
        handle: typeof HandleModifier;
        manager: DragDropManager;
      },
    ];
  };
}

export default class DragDrop extends Component<DragDropSignature> {
  private manager: DragDropManager;
  private cleanupFns: (() => void)[] = [];

  constructor(owner: Owner, args: DragDropSignature['Args']) {
    super(owner, args);

    const options: DragDropManagerInput = {};
    if (this.args.sensors) options.sensors = this.args.sensors;
    if (this.args.plugins) options.plugins = this.args.plugins;
    if (this.args.modifiers) options.modifiers = this.args.modifiers;

    this.manager = new DragDropManager(options);

    // Integrate with Ember's runloop for proper rendering coordination
    this.manager.renderer = {
      get rendering() {
        return new Promise<void>((resolve) => {
          // eslint-disable-next-line ember/no-runloop
          scheduleOnce('render', null, resolve);
        });
      },
    };

    // Set up event listeners
    if (this.args.onBeforeDragStart) {
      const cleanup = this.manager.monitor.addEventListener(
        'beforedragstart',
        this.args.onBeforeDragStart as () => void,
      );
      this.cleanupFns.push(cleanup);
    }

    if (this.args.onDragStart) {
      const cleanup = this.manager.monitor.addEventListener(
        'dragstart',
        this.args.onDragStart as () => void,
      );
      this.cleanupFns.push(cleanup);
    }

    if (this.args.onDragMove) {
      const cleanup = this.manager.monitor.addEventListener(
        'dragmove',
        this.args.onDragMove as () => void,
      );
      this.cleanupFns.push(cleanup);
    }

    if (this.args.onDragOver) {
      const cleanup = this.manager.monitor.addEventListener(
        'dragover',
        this.args.onDragOver as () => void,
      );
      this.cleanupFns.push(cleanup);
    }

    if (this.args.onDragEnd) {
      const cleanup = this.manager.monitor.addEventListener(
        'dragend',
        this.args.onDragEnd as () => void,
      );
      this.cleanupFns.push(cleanup);
    }

    if (this.args.onCollision) {
      const cleanup = this.manager.monitor.addEventListener(
        'collision',
        this.args.onCollision as () => void,
      );
      this.cleanupFns.push(cleanup);
    }

    registerDestructor(this, this.cleanup.bind(this));
  }

  private cleanup() {
    for (const fn of this.cleanupFns) {
      fn();
    }
    this.cleanupFns = [];
    this.manager.destroy();
  }

  @cached
  get draggableModifier(): typeof DraggableModifier<Data> {
    return createDraggableModifier(this.manager);
  }

  @cached
  get droppableModifier(): typeof DroppableModifier<Data> {
    return createDroppableModifier(this.manager);
  }

  @cached
  get sortableModifier(): typeof SortableModifier<Data> {
    return createSortableModifier(this.manager);
  }

  @cached
  get handleModifier(): typeof HandleModifier {
    return createHandleModifier(this.manager);
  }

  <template>
    {{yield
      (hash
        draggable=this.draggableModifier
        droppable=this.droppableModifier
        sortable=this.sortableModifier
        handle=this.handleModifier
        manager=this.manager
      )
    }}
  </template>
}
