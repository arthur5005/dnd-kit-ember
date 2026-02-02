import Modifier from 'ember-modifier';
import type Owner from '@ember/owner';
import type { Data, DroppableInput } from '../types.ts';
import { DragDropManager } from '../types.ts';
export interface DroppableModifierSignature<T extends Data = Data> {
    Args: {
        Named: Omit<DroppableInput<T>, 'element'>;
    };
    Element: HTMLElement;
}
export declare class DroppableModifier<T extends Data = Data> extends Modifier<DroppableModifierSignature<T>> {
    private manager;
    private droppable?;
    constructor(owner: Owner, manager: DragDropManager);
    modify(element: HTMLElement, _positional: [], named: DroppableModifierSignature<T>['Args']['Named']): void;
    private cleanup;
}
export declare function createDroppableModifier(manager: DragDropManager): typeof DroppableModifier<Data>;
//# sourceMappingURL=droppable.d.ts.map