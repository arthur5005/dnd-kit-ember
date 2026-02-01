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
  { id: 'item-1', name: 'Red Apple', color: '#ef4444' },
  { id: 'item-2', name: 'Orange Citrus', color: '#f97316' },
  { id: 'item-3', name: 'Yellow Banana', color: '#eab308' },
  { id: 'item-4', name: 'Green Lime', color: '#22c55e' },
  { id: 'item-5', name: 'Blue Berry', color: '#3b82f6' },
  { id: 'item-6', name: 'Purple Grape', color: '#a855f7' },
];

const alternateItems: Item[] = [
  { id: 'item-7', name: 'Cyan Ocean', color: '#06b6d4' },
  { id: 'item-8', name: 'Pink Rose', color: '#ec4899' },
  { id: 'item-9', name: 'Brown Earth', color: '#a0522d' },
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

function swapList() {
  state.items = [...alternateItems];
}

function removeLastItem() {
  if (state.items.length > 0) {
    state.items = state.items.slice(0, -1);
  }
}

function colorStyle(color: string): SafeString {
  return htmlSafe(
    `width: 24px; height: 24px; border-radius: 50%; background: ${color}; flex-shrink: 0;`,
  );
}

<template>
  {{! template-lint-disable no-inline-styles }}
  <div style="margin-bottom: 24px;">
    <h2 style="margin-bottom: 8px;">Sortable List</h2>
    <p style="color: #666; margin-bottom: 16px;">
      Drag and drop items to reorder them. Press Escape to cancel.
    </p>
    <button
      type="button"
      style="padding: 8px 16px; background: #3b82f6; color: white; border: none; border-radius: 4px; cursor: pointer; margin-right: 8px;"
      {{on "click" resetItems}}
    >
      Reset
    </button>
    <button
      type="button"
      style="padding: 8px 16px; background: #8b5cf6; color: white; border: none; border-radius: 4px; cursor: pointer; margin-right: 8px;"
      {{on "click" swapList}}
    >
      Swap List
    </button>
    <button
      type="button"
      style="padding: 8px 16px; background: #ef4444; color: white; border: none; border-radius: 4px; cursor: pointer;"
      {{on "click" removeLastItem}}
    >
      Remove Last
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
            padding: 10px 12px;
            gap: 12px;
            border: 1px solid #e5e7eb;
            background: white;
            border-radius: 8px;
            cursor: grab;
            user-select: none;
            transition: box-shadow 0.2s, transform 0.2s;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);"
        >
          <span style={{colorStyle item.color}}></span>
          <span style="font-weight: 500;">{{item.name}}</span>
          <span style="margin-left: auto; color: #9ca3af; font-size: 12px;">
            {{item.id}}
            - Sort Order: #{{index}}
          </span>
        </div>
      {{/each}}
    </div>
  </DragDrop>

  <div
    style="margin-top: 24px; padding: 12px; background: #f5f5f5; border-radius: 8px; font-size: 13px;"
  >
    <strong>Current Order:</strong>
    {{#each state.items as |item index|}}
      <code
        style="margin-left: 6px; padding: 2px 6px; background: #e0e0e0; border-radius: 2px;"
      >
        {{index}}:
        {{item.id}}
      </code>
    {{/each}}
  </div>
</template>
