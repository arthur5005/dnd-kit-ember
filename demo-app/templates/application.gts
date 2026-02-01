import { pageTitle } from 'ember-page-title';

// Sortable demos
import SortableList from '../components/sortable-list.gts';
import SortableHandles from '../components/sortable-handles.gts';
import SortableGrid from '../components/sortable-grid.gts';
import KanbanBoard from '../components/kanban-board.gts';

// Draggable/Droppable demos
import DragToDelete from '../components/drag-to-delete.gts';
import TypeMatching from '../components/type-matching.gts';
import ComponentPalette from '../components/component-palette.gts';
import FileOrganizer from '../components/file-organizer.gts';

<template>
  {{pageTitle "DnD Kit Ember Demo"}}

  {{! template-lint-disable no-inline-styles }}
  <div
    style="padding: 20px; max-width: 700px; margin: 0 auto; font-family: system-ui, sans-serif;"
  >
    <h1 style="margin-bottom: 8px;">DnD Kit Ember Demo</h1>
    <p style="color: #666; margin-bottom: 32px;">
      Examples showcasing drag and drop functionality with dnd-kit-ember.
    </p>

    <div style="margin-bottom: 48px;">
      <h2
        style="
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: 0.1em;
        color: #9ca3af;
        margin-bottom: 24px;
        padding-bottom: 8px;
        border-bottom: 1px solid #e5e7eb;
      "
      >
        Sortable
      </h2>

      <section style="margin-bottom: 48px;">
        <SortableList />
      </section>

      <section
        style="margin-bottom: 48px; padding-top: 24px; border-top: 1px solid #e5e7eb;"
      >
        <SortableHandles />
      </section>

      <section
        style="margin-bottom: 48px; padding-top: 24px; border-top: 1px solid #e5e7eb;"
      >
        <SortableGrid />
      </section>

      <section style="padding-top: 24px; border-top: 1px solid #e5e7eb;">
        <KanbanBoard />
      </section>
    </div>

    <div>
      <h2
        style="
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: 0.1em;
        color: #9ca3af;
        margin-bottom: 24px;
        padding-bottom: 8px;
        border-bottom: 1px solid #e5e7eb;
      "
      >
        Draggable & Droppable
      </h2>

      <section style="margin-bottom: 48px;">
        <DragToDelete />
      </section>

      <section
        style="margin-bottom: 48px; padding-top: 24px; border-top: 1px solid #e5e7eb;"
      >
        <TypeMatching />
      </section>

      <section
        style="margin-bottom: 48px; padding-top: 24px; border-top: 1px solid #e5e7eb;"
      >
        <ComponentPalette />
      </section>

      <section style="padding-top: 24px; border-top: 1px solid #e5e7eb;">
        <FileOrganizer />
      </section>
    </div>
  </div>
</template>
