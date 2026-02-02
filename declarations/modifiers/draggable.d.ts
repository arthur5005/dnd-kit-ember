import Modifier from 'ember-modifier';
import type Owner from '@ember/owner';
import type { Data, DraggableInput } from '../types.ts';
import { DragDropManager } from '../types.ts';
export interface DraggableModifierSignature<T extends Data = Data> {
    Args: {
        Named: Omit<DraggableInput<T>, 'element'>;
    };
    Element: HTMLElement;
}
export declare class DraggableModifier<T extends Data = Data> extends Modifier<DraggableModifierSignature<T>> {
    private manager;
    private draggable?;
    private currentId?;
    constructor(owner: Owner, manager: DragDropManager);
    get key(): string;
    modify(element: HTMLElement, _positional: [], named: DraggableModifierSignature<T>['Args']['Named']): void;
    private cleanup;
}
export declare function createDraggableModifier(manager: DragDropManager): typeof DraggableModifier<Data>;
//# sourceMappingURL=draggable.d.ts.map