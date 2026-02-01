import { on } from '@ember/modifier';
import { tracked } from '@glimmer/tracking';
import { move } from '@dnd-kit/helpers';

import DragDrop from '../../src/components/drag-drop.gts';
import type { DragDropEvents } from '../../src/index.ts';
import { htmlSafe, type SafeString } from '@ember/template';

interface Item {
  id: string;
  name: string;
  color: string;
}

const initialItems: Item[] = [
  { id: 'handle-1', name: 'Draggable Item 1', color: '#6366f1' },
  { id: 'handle-2', name: 'Draggable Item 2', color: '#8b5cf6' },
  { id: 'handle-3', name: 'Draggable Item 3', color: '#a855f7' },
  { id: 'handle-4', name: 'Draggable Item 4', color: '#d946ef' },
];

class State {
  @tracked items: Item[] = [...initialItems];
  @tracked snapshot: Item[] = [];
}

const state = new State();

function handleDragStart() {
  state.snapshot = [...state.items];
}

function handleDragOver(event: Parameters<DragDropEvents['dragover']>[0]) {
  event.preventDefault();
  state.items = move(state.items, event);
}

function handleDragEnd(event: Parameters<DragDropEvents['dragend']>[0]) {
  if (event.canceled) {
    state.items = [...state.snapshot];
  }
}

function resetItems() {
  state.items = [...initialItems];
}

function colorStyle(color: string): SafeString {
  return htmlSafe(
    `width: 24px; height: 24px; border-radius: 50%; background: ${color}; flex-shrink: 0;`,
  );
}

<template>
  {{! template-lint-disable no-inline-styles }}
  <div style="margin-bottom: 24px;">
    <h2 style="margin-bottom: 8px;">Sortable with Handles</h2>
    <p style="color: #666; margin-bottom: 16px;">
      Only the grip icon can be used to drag items. Try clicking elsewhere on
      the item - it won't drag.
    </p>
    <button
      type="button"
      style="padding: 8px 16px; background: #3b82f6; color: white; border: none; border-radius: 4px; cursor: pointer;"
      {{on "click" resetItems}}
    >
      Reset
    </button>
  </div>

  <DragDrop
    @onDragStart={{handleDragStart}}
    @onDragEnd={{handleDragEnd}}
    @onDragOver={{handleDragOver}}
    as |dd|
  >
    <div
      style="padding: 0; margin: 0; display: flex; flex-direction: column; gap: 8px;"
    >
      {{#each state.items as |item index|}}
        <div
          {{dd.sortable id=item.id index=index}}
          style="
            display: flex;
            align-items: center;
            padding: 12px 16px;
            gap: 12px;
            border: 1px solid #e5e7eb;
            background: white;
            border-radius: 8px;
            user-select: none;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);"
        >
          <span
            {{dd.handle id=item.id}}
            style="
              cursor: grab;
              padding: 4px;
              color: #9ca3af;
              display: flex;
              align-items: center;
            "
          >
            <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor">
              <circle cx="4" cy="3" r="1.5" />
              <circle cx="4" cy="8" r="1.5" />
              <circle cx="4" cy="13" r="1.5" />
              <circle cx="10" cy="3" r="1.5" />
              <circle cx="10" cy="8" r="1.5" />
              <circle cx="10" cy="13" r="1.5" />
            </svg>
          </span>
          <span style={{colorStyle item.color}}></span>
          <span style="font-weight: 500;">{{item.name}}</span>
          <span style="margin-left: auto; color: #9ca3af; font-size: 12px;">
            #{{index}}
          </span>
        </div>
      {{/each}}
    </div>
  </DragDrop>
</template>
