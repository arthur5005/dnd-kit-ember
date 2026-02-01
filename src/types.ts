// Re-export types from @dnd-kit/abstract
export type {
  Data,
  DragDropEvents as AbstractDragDropEvents,
  DragDropManagerInput as AbstractDragDropManagerInput,
  DragOperation,
  DraggableInput as AbstractDraggableInput,
  DroppableInput as AbstractDroppableInput,
  Type,
  UniqueIdentifier,
  CollisionDetector,
  Modifiers,
  Sensors as AbstractSensors,
  PluginConstructor,
} from '@dnd-kit/abstract';

// Re-export types from @dnd-kit/dom
export type {
  DragDropManagerInput,
  DraggableInput,
  DroppableInput,
  FeedbackType,
  Sensors,
  Transition,
} from '@dnd-kit/dom';

export type { SortableInput, SortableTransition } from '@dnd-kit/dom/sortable';

// Re-export classes and functions
export {
  DragDropManager,
  Draggable,
  Droppable,
  PointerSensor,
  KeyboardSensor,
  defaultPreset,
} from '@dnd-kit/dom';

export {
  Sortable,
  SortableKeyboardPlugin,
  defaultSortableTransition,
} from '@dnd-kit/dom/sortable';

export { move } from '@dnd-kit/helpers';

// Create a convenient Events type following the SolidJS/React pattern
import type {
  Data,
  DragDropEvents as AbstractDragDropEvents,
} from '@dnd-kit/abstract';
import type { DragDropManager, Draggable, Droppable } from '@dnd-kit/dom';

/**
 * Convenience type for drag and drop event handlers.
 * Maps event names to their handler signatures.
 *
 * @template T - The data type attached to draggable/droppable items
 *
 * @example
 * ```ts
 * const onDragStart: DragDropEvents<MyData>['dragstart'] = (event, manager) => {
 *   console.log(event.operation.source);
 * };
 * ```
 */
export type DragDropEvents<T extends Data = Data> = AbstractDragDropEvents<
  Draggable<T>,
  Droppable<T>,
  DragDropManager<T, Draggable<T>, Droppable<T>>
>;
