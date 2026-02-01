# dnd-kit-ember

An Ember addon providing drag and drop functionality powered by [@dnd-kit/dom](https://next.dndkit.com/overview).

> **Early Development Warning**: This is an experimental addon with no tests. It is intended as an exploration for replacing [ember-sortable](https://github.com/adopted-ember-addons/ember-sortable). The API is subject to change. Use at your own risk.

## Installation

```bash
pnpm add dnd-kit-ember
```

## Requirements

- **Ember 5.0+**
- **GJS/GTS only** - This addon only supports strict mode templates (`.gjs`/`.gts` files)
- **Embroider** - This is a v2 addon and requires an Embroider-compatible build pipeline

## Usage

### Basic Sortable List

```gts
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import DragDrop from 'dnd-kit-ember/components/drag-drop';
import { move } from '@dnd-kit/helpers';
import type { DragDropEvents } from 'dnd-kit-ember';

class State {
  @tracked items = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];
}

const state = new State();

function handleDragEnd(event: Parameters<DragDropEvents['dragend']>[0]) {
  if (event.canceled) return;
  state.items = move(state.items, event);
}

<template>
  <DragDrop @onDragEnd={{handleDragEnd}} as |dd|>
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
<DragDrop @onDragEnd={{handleDragEnd}} as |dd|>
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

### Draggable and Droppable

```gts
<DragDrop @onDragEnd={{handleDragEnd}} as |dd|>
  <div {{dd.draggable id="item-1"}}>
    Drag me
  </div>

  <div {{dd.droppable id="drop-zone"}}>
    Drop here
  </div>
</DragDrop>
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

## Event Structure

Events provide access to the drag operation:

```ts
function handleDragEnd(event: Parameters<DragDropEvents['dragend']>[0]) {
  const sourceId = event.operation.source?.id;
  const targetId = event.operation.target?.id;

  if (event.canceled) return;

  // Handle the drop
}
```

## Learn More

For detailed documentation on dnd-kit's features, sensors, plugins, and modifiers, see the [dnd-kit documentation](https://next.dndkit.com/overview).

## License

MIT
