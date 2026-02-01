import { on } from '@ember/modifier';
import { tracked } from '@glimmer/tracking';
import { htmlSafe, type SafeString } from '@ember/template';
import { move } from '@dnd-kit/helpers';

import DragDrop from '../../src/components/drag-drop.gts';
import type { DragDropEvents } from '../../src/index.ts';

interface Item {
  id: string;
  name: string;
  color: string;
}

const initialItems: Item[] = [
  { id: 'grid-1', name: 'Red', color: '#ef4444' },
  { id: 'grid-2', name: 'Orange', color: '#f97316' },
  { id: 'grid-3', name: 'Yellow', color: '#eab308' },
  { id: 'grid-4', name: 'Green', color: '#22c55e' },
  { id: 'grid-5', name: 'Blue', color: '#3b82f6' },
  { id: 'grid-6', name: 'Purple', color: '#a855f7' },
  { id: 'grid-7', name: 'Cyan', color: '#06b6d4' },
  { id: 'grid-8', name: 'Pink', color: '#ec4899' },
  { id: 'grid-9', name: 'Gray', color: '#64748b' },
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

function gridItemStyle(color: string): SafeString {
  return htmlSafe(`
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    aspect-ratio: 1;
    background: ${color};
    border-radius: 12px;
    cursor: grab;
    user-select: none;
    color: white;
    text-shadow: 0 1px 2px rgba(0,0,0,0.3);
  `);
}

<template>
  {{! template-lint-disable no-inline-styles }}
  <div style="margin-bottom: 24px;">
    <h2 style="margin-bottom: 8px;">Sortable Grid</h2>
    <p style="color: #666; margin-bottom: 16px;">
      Same drag and drop behavior, but with a CSS grid layout.
    </p>
    <button
      type="button"
      style="padding: 8px 16px; background: #3b82f6; color: white; border: none; border-radius: 4px; cursor: pointer;"
      {{on "click" resetItems}}
    >
      Reset Grid
    </button>
  </div>

  <DragDrop
    @onDragStart={{handleDragStart}}
    @onDragEnd={{handleDragEnd}}
    @onDragOver={{handleDragOver}}
    as |dd|
  >
    <div
      style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px;"
    >
      {{#each state.items as |item index|}}
        <div
          {{dd.sortable id=item.id index=index group="grid"}}
          style={{gridItemStyle item.color}}
        >
          <span style="font-size: 20px; font-weight: bold;">{{item.name}}</span>
          <span style="font-size: 12px; opacity: 0.8;">#{{index}}</span>
        </div>
      {{/each}}
    </div>
  </DragDrop>

  <div
    style="margin-top: 16px; padding: 12px; background: #f5f5f5; border-radius: 8px; font-size: 13px;"
  >
    <strong>Grid Order:</strong>
    {{#each state.items as |item index|}}
      <code
        style="margin-left: 6px; padding: 2px 6px; background: #e0e0e0; border-radius: 2px;"
      >
        {{index}}:
        {{item.name}}
      </code>
    {{/each}}
  </div>
</template>
