import { fn } from '@ember/helper';
import { on } from '@ember/modifier';
import { tracked } from '@glimmer/tracking';
import { htmlSafe, type SafeString } from '@ember/template';

import DragDrop from '../../src/components/drag-drop.gts';
import type { DragDropEvents } from '../../src/index.ts';

interface Component {
  id: string;
  type: string;
  label: string;
  icon: string;
}

const paletteComponents: Component[] = [
  { id: 'palette-button', type: 'button', label: 'Button', icon: '🔘' },
  { id: 'palette-input', type: 'input', label: 'Input', icon: '📝' },
  { id: 'palette-image', type: 'image', label: 'Image', icon: '🖼️' },
  { id: 'palette-text', type: 'text', label: 'Text', icon: '📄' },
  { id: 'palette-video', type: 'video', label: 'Video', icon: '🎬' },
  { id: 'palette-divider', type: 'divider', label: 'Divider', icon: '➖' },
];

interface CanvasItem extends Component {
  canvasId: string;
}

class State {
  @tracked canvasItems: CanvasItem[] = [];
  @tracked isOverCanvas = false;
  @tracked draggedType: string | null = null;
  nextId = 1;
}

const state = new State();

function handleDragStart(event: Parameters<DragDropEvents['dragstart']>[0]) {
  const id = event.operation.source?.id as string;
  const paletteItem = paletteComponents.find((c) => c.id === id);
  if (paletteItem) {
    state.draggedType = paletteItem.type;
  }
}

function handleDragOver(event: Parameters<DragDropEvents['dragover']>[0]) {
  state.isOverCanvas = event.operation.target?.id === 'canvas';
}

function handleDragEnd(event: Parameters<DragDropEvents['dragend']>[0]) {
  state.isOverCanvas = false;
  state.draggedType = null;

  if (event.canceled || !event.operation.target) return;

  const sourceId = event.operation.source?.id as string;

  // Check if dragging from palette (clone) or from canvas (reorder)
  const paletteItem = paletteComponents.find((c) => c.id === sourceId);

  if (paletteItem && event.operation.target.id === 'canvas') {
    // Clone from palette to canvas
    const newItem: CanvasItem = {
      ...paletteItem,
      id: `canvas-${paletteItem.type}-${state.nextId}`,
      canvasId: `canvas-${state.nextId}`,
    };
    state.nextId++;
    state.canvasItems = [...state.canvasItems, newItem];
  }
}

function removeFromCanvas(canvasId: string) {
  state.canvasItems = state.canvasItems.filter(
    (item) => item.canvasId !== canvasId,
  );
}

function clearCanvas() {
  state.canvasItems = [];
  state.nextId = 1;
}

function canvasStyle(isOver: boolean): SafeString {
  return htmlSafe(`
    flex: 1;
    min-height: 400px;
    padding: 16px;
    background: ${isOver ? '#f0fdf4' : '#fafafa'};
    border: 2px dashed ${isOver ? '#22c55e' : '#d1d5db'};
    border-radius: 12px;
    transition: all 0.2s;
  `);
}

<template>
  {{! template-lint-disable no-inline-styles }}
  <div style="margin-bottom: 24px;">
    <h2 style="margin-bottom: 8px;">Component Palette</h2>
    <p style="color: #666; margin-bottom: 16px;">
      Drag components from the palette to the canvas. Palette items are cloned,
      not moved.
    </p>
    <button
      type="button"
      style="padding: 8px 16px; background: #ef4444; color: white; border: none; border-radius: 4px; cursor: pointer;"
      {{on "click" clearCanvas}}
    >
      Clear Canvas
    </button>
  </div>

  <DragDrop
    @onDragStart={{handleDragStart}}
    @onDragOver={{handleDragOver}}
    @onDragEnd={{handleDragEnd}}
    as |dd|
  >
    <div style="display: flex; gap: 24px;">
      {{! Palette }}
      <div style="width: 140px; flex-shrink: 0;">
        <h3
          style="margin: 0 0 12px 0; font-size: 14px; color: #666;"
        >Components</h3>
        <div style="display: flex; flex-direction: column; gap: 8px;">
          {{#each paletteComponents as |comp|}}
            <div
              {{dd.draggable id=comp.id type=comp.type}}
              style="
                display: flex;
                align-items: center;
                gap: 8px;
                padding: 10px 12px;
                background: white;
                border: 1px solid #e5e7eb;
                border-radius: 6px;
                cursor: grab;
                user-select: none;
                font-size: 13px;
                box-shadow: 0 1px 2px rgba(0,0,0,0.05);
              "
            >
              <span>{{comp.icon}}</span>
              <span>{{comp.label}}</span>
            </div>
          {{/each}}
        </div>
      </div>

      {{! Canvas }}
      <div
        {{dd.droppable id="canvas"}}
        style={{canvasStyle state.isOverCanvas}}
      >
        <h3 style="margin: 0 0 16px 0; font-size: 14px; color: #666;">
          Canvas ({{state.canvasItems.length}}
          items)
        </h3>

        {{#if state.canvasItems.length}}
          <div style="display: flex; flex-direction: column; gap: 12px;">
            {{#each state.canvasItems as |item|}}
              <div
                style="
                  display: flex;
                  align-items: center;
                  justify-content: space-between;
                  padding: 12px 16px;
                  background: white;
                  border: 1px solid #e5e7eb;
                  border-radius: 8px;
                  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
                "
              >
                <div style="display: flex; align-items: center; gap: 12px;">
                  <span style="font-size: 20px;">{{item.icon}}</span>
                  <div>
                    <div style="font-weight: 500;">{{item.label}}</div>
                    <div
                      style="font-size: 12px; color: #9ca3af;"
                    >{{item.id}}</div>
                  </div>
                </div>
                <button
                  type="button"
                  style="
                    padding: 4px 8px;
                    background: #fee2e2;
                    color: #dc2626;
                    border: none;
                    border-radius: 4px;
                    cursor: pointer;
                    font-size: 12px;
                  "
                  {{on "click" (fn removeFromCanvas item.canvasId)}}
                >
                  Remove
                </button>
              </div>
            {{/each}}
          </div>
        {{else}}
          <div
            style="
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 300px;
            color: #9ca3af;
          "
          >
            <span style="font-size: 48px; margin-bottom: 12px;">📦</span>
            <span>Drag components here</span>
          </div>
        {{/if}}
      </div>
    </div>
  </DragDrop>
</template>
