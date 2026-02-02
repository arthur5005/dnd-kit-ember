import Modifier from 'ember-modifier';
import type Owner from '@ember/owner';
import type { UniqueIdentifier } from '../types.ts';
import { DragDropManager } from '../types.ts';
export interface HandleModifierSignature {
    Args: {
        Named: {
            id: UniqueIdentifier;
        };
    };
    Element: HTMLElement;
}
export declare class HandleModifier extends Modifier<HandleModifierSignature> {
    private manager;
    private currentId?;
    private element?;
    constructor(owner: Owner, manager: DragDropManager);
    get key(): string;
    modify(element: HTMLElement, _positional: [], named: HandleModifierSignature['Args']['Named']): void;
    private cleanup;
}
export declare function createHandleModifier(manager: DragDropManager): typeof HandleModifier;
//# sourceMappingURL=handle.d.ts.map