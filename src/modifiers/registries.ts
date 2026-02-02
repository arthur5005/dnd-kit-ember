import type { Draggable, Sortable } from '../types.ts';

export const draggableRegistry = new Map<string, Draggable | Sortable>();
export const handleRegistry = new Map<string, HTMLElement>();
