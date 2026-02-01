import { on } from '@ember/modifier';
import { tracked } from '@glimmer/tracking';
import { htmlSafe, type SafeString } from '@ember/template';

import DragDrop from '../../src/components/drag-drop.gts';
import type { DragDropEvents } from '../../src/index.ts';

interface Item {
  id: string;
  name: string;
  icon: string;
}

const initialItems: Item[] = [
  { id: 'file-1', name: 'Document.pdf', icon: '📄' },
  { id: 'file-2', name: 'Photo.jpg', icon: '🖼️' },
  { id: 'file-3', name: 'Music.mp3', icon: '🎵' },
  { id: 'file-4', name: 'Video.mp4', icon: '🎬' },
  { id: 'file-5', name: 'Archive.zip', icon: '📦' },
];

class State {
  @tracked items: Item[] = [...initialItems];
  @tracked isOverTrash = false;
}

const state = new State();

function handleDragOver(event: Parameters<DragDropEvents['dragover']>[0]) {
  state.isOverTrash = event.operation.target?.id === 'trash';
}

function handleDragEnd(event: Parameters<DragDropEvents['dragend']>[0]) {
  state.isOverTrash = false;

  if (event.canceled) return;

  // If dropped on trash, remove the item
  if (event.operation.target?.id === 'trash') {
    state.items = state.items.filter(
      (item) => item.id !== event.operation.source?.id,
    );
  }
}

function resetItems() {
  state.items = [...initialItems];
}

function trashZoneStyle(isOver: boolean): SafeString {
  return htmlSafe(`
    width: 150px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 24px;
    background: ${isOver ? '#fef2f2' : '#f9fafb'};
    border: 2px dashed ${isOver ? '#ef4444' : '#d1d5db'};
    border-radius: 12px;
    transition: all 0.2s;
  `);
}

function trashTextStyle(isOver: boolean): SafeString {
  return htmlSafe(`
    font-size: 14px;
    color: ${isOver ? '#ef4444' : '#6b7280'};
    font-weight: 500;
  `);
}

<template>
  {{! template-lint-disable no-inline-styles }}
  <div style="margin-bottom: 24px;">
    <h2 style="margin-bottom: 8px;">Drag to Delete</h2>
    <p style="color: #666; margin-bottom: 16px;">
      Drag files to the trash to delete them. Basic draggable and droppable
      interaction.
    </p>
    <button
      type="button"
      style="padding: 8px 16px; background: #3b82f6; color: white; border: none; border-radius: 4px; cursor: pointer;"
      {{on "click" resetItems}}
    >
      Reset Files
    </button>
  </div>

  <DragDrop @onDragOver={{handleDragOver}} @onDragEnd={{handleDragEnd}} as |dd|>
    <div style="display: flex; gap: 24px;">
      {{! Files list }}
      <div style="flex: 1;">
        <h3 style="margin: 0 0 12px 0; font-size: 14px; color: #666;">Files</h3>
        <div
          style="display: flex; flex-direction: column; gap: 8px; min-height: 200px;"
        >
          {{#each state.items as |item|}}
            <div
              {{dd.draggable id=item.id}}
              style="
                display: flex;
                align-items: center;
                gap: 12px;
                padding: 12px 16px;
                background: white;
                border: 1px solid #e5e7eb;
                border-radius: 8px;
                cursor: grab;
                user-select: none;
                box-shadow: 0 1px 3px rgba(0,0,0,0.1);
              "
            >
              <span style="font-size: 24px;">{{item.icon}}</span>
              <span style="font-weight: 500;">{{item.name}}</span>
            </div>
          {{else}}
            <div
              style="padding: 40px; text-align: center; color: #9ca3af; border: 2px dashed #e5e7eb; border-radius: 8px;"
            >
              No files remaining
            </div>
          {{/each}}
        </div>
      </div>

      {{! Trash zone }}
      <div
        {{dd.droppable id="trash"}}
        style={{trashZoneStyle state.isOverTrash}}
      >
        <span style="font-size: 48px;">🗑️</span>
        <span style={{trashTextStyle state.isOverTrash}}>
          {{if state.isOverTrash "Release to delete" "Drop here"}}
        </span>
      </div>
    </div>
  </DragDrop>
</template>
