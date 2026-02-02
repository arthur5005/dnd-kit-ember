import Modifier from 'ember-modifier';
import type Owner from '@ember/owner';
import type { Data, SortableInput } from '../types.ts';
import { DragDropManager } from '../types.ts';
export interface SortableModifierSignature<T extends Data = Data> {
    Args: {
        Named: Omit<SortableInput<T>, 'element'>;
    };
    Element: HTMLElement;
}
export declare class SortableModifier<T extends Data = Data> extends Modifier<SortableModifierSignature<T>> {
    private manager;
    private sortable?;
    private currentId?;
    constructor(owner: Owner, manager: DragDropManager);
    get key(): string;
    modify(element: HTMLElement, _positional: [], named: SortableModifierSignature<T>['Args']['Named']): void;
    private cleanup;
}
export declare function createSortableModifier(manager: DragDropManager): typeof SortableModifier<Data>;
//# sourceMappingURL=sortable.d.ts.map