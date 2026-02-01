# dnd-kit-ember

An Ember addon providing drag and drop functionality powered by [@dnd-kit/dom](https://next.dndkit.com/overview).

**[Live Demo](https://arthur5005.github.io/dnd-kit-ember/)**

> **Early Development Warning**: This is an experimental addon with no tests. It is intended as an exploration for replacing [ember-sortable](https://github.com/adopted-ember-addons/ember-sortable). The API is subject to change. Use at your own risk.

## Installation

```bash
pnpm add @arthur5005/dnd-kit-ember
```

## Requirements

- **Ember 5.0+**
- **GJS/GTS only** - This addon only supports strict mode templates (`.gjs`/`.gts` files)
- **Embroider** - This is a v2 addon and requires an Embroider-compatible build pipeline

## Usage

### Draggable and Droppable

```gts
import DragDrop from '@arthur5005/dnd-kit-ember/components/drag-drop';
import type { DragDropEvents } from '@arthur5005/dnd-kit-ember';

function handleDragEnd(event: Parameters<DragDropEvents['dragend']>[0]) {
  if (event.canceled) return;

  const sourceId = event.operation.source?.id;
  const targetId = event.operation.target?.id;
  // Handle the drop
}

<template>
  <DragDrop @onDragEnd={{handleDragEnd}} as |dd|>
    <div {{dd.draggable id="item-1"}}>
      Drag me
    </div>

    <div {{dd.droppable id="drop-zone"}}>
      Drop here
    </div>
  </DragDrop>
</template>
```

### Type-Restricted Drop Zones

```gts
<DragDrop @onDragEnd={{handleDragEnd}} as |dd|>
  <div {{dd.draggable id="circle-1" type="circle"}}>Circle</div>
  <div {{dd.draggable id="square-1" type="square"}}>Square</div>

  <div {{dd.droppable id="circles-only" accept="circle"}}>
    Only accepts circles
  </div>
</DragDrop>
```

### Sortable List

The `sortable` modifier combines draggable and droppable behavior for reorderable lists.

> **Note**: dnd-kit's sortable is an **optimistic sorter** - items visually reorder as you drag over them. You must handle `@onDragStart`, `@onDragOver`, and `@onDragEnd` to maintain state and support cancellation (e.g., pressing Escape).

```gts
import { tracked } from '@glimmer/tracking';
import DragDrop from '@arthur5005/dnd-kit-ember/components/drag-drop';
import { move } from '@dnd-kit/helpers';
import type { DragDropEvents } from '@arthur5005/dnd-kit-ember';

class State {
  @tracked items = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];
  @tracked snapshot: string[] = [];
}

const state = new State();

function handleDragStart() {
  // Save snapshot for cancellation
  state.snapshot = [...state.items];
}

function handleDragOver(event: Parameters<DragDropEvents['dragover']>[0]) {
  // Optimistically reorder items as we drag
  state.items = move(state.items, event);
}

function handleDragEnd(event: Parameters<DragDropEvents['dragend']>[0]) {
  if (event.canceled) {
    // Restore snapshot if cancelled (e.g., Escape key)
    state.items = [...state.snapshot];
  }
}

<template>
  <DragDrop
    @onDragStart={{handleDragStart}}
    @onDragOver={{handleDragOver}}
    @onDragEnd={{handleDragEnd}}
    as |dd|
  >
    <ul>
      {{#each state.items as |item index|}}
        <li {{dd.sortable id=item index=index}}>
          {{item}}
        </li>
      {{/each}}
    </ul>
  </DragDrop>
</template>
```

### Sortable with Drag Handles

```gts
<DragDrop
  @onDragStart={{handleDragStart}}
  @onDragOver={{handleDragOver}}
  @onDragEnd={{handleDragEnd}}
  as |dd|
>
  <ul>
    {{#each state.items as |item index|}}
      <li {{dd.sortable id=item index=index}}>
        <span {{dd.handle}}>⠿</span>
        {{item}}
      </li>
    {{/each}}
  </ul>
</DragDrop>
```

## API

### DragDrop Component

The main component that sets up the drag and drop context.

| Argument | Type | Description |
|----------|------|-------------|
| `@sensors` | `Sensor[]` | Custom sensors for drag detection |
| `@plugins` | `Plugin[]` | DnD Kit plugins |
| `@modifiers` | `Modifier[]` | DnD Kit modifiers |
| `@onBeforeDragStart` | `function` | Called before drag starts |
| `@onDragStart` | `function` | Called when drag starts |
| `@onDragMove` | `function` | Called on drag movement |
| `@onDragOver` | `function` | Called when dragging over a droppable |
| `@onDragEnd` | `function` | Called when drag ends |
| `@onCollision` | `function` | Called on collision detection |

**Yielded modifiers:**
- `draggable` - Makes an element draggable (required: `id`)
- `droppable` - Makes an element a drop target (required: `id`)
- `sortable` - Combines draggable/droppable for sortable lists (required: `id`, `index`)
- `handle` - Designates a drag handle within a draggable or sortable

Each modifier accepts additional options from dnd-kit. See the [dnd-kit documentation](https://next.dndkit.com/overview) for the full list of available options.

## Learn More

For detailed documentation on dnd-kit's features, sensors, plugins, and modifiers, see the [dnd-kit documentation](https://next.dndkit.com/overview).

## License

MIT
