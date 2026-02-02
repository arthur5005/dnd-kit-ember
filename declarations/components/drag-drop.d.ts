import Component from '@glimmer/component';
import type Owner from '@ember/owner';
import type { Data, DragDropEvents, DragDropManagerInput } from '../types.ts';
import { DragDropManager } from '../types.ts';
import { DraggableModifier, DroppableModifier, SortableModifier, HandleModifier } from '../modifiers/index.ts';
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
            }
        ];
    };
}
export default class DragDrop extends Component<DragDropSignature> {
    private manager;
    private cleanupFns;
    constructor(owner: Owner, args: DragDropSignature['Args']);
    private cleanup;
    get draggableModifier(): typeof DraggableModifier<Data>;
    get droppableModifier(): typeof DroppableModifier<Data>;
    get sortableModifier(): typeof SortableModifier<Data>;
    get handleModifier(): typeof HandleModifier;
}
//# sourceMappingURL=drag-drop.d.ts.map