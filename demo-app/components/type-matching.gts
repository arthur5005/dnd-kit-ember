import { on } from '@ember/modifier';
import { tracked } from '@glimmer/tracking';
import { htmlSafe, type SafeString } from '@ember/template';

import DragDrop from '../../src/components/drag-drop.gts';
import type { DragDropEvents } from '../../src/index.ts';

function eq(a: unknown, b: unknown): boolean {
  return a === b;
}

interface Shape {
  id: string;
  type: 'circle' | 'square' | 'triangle';
  color: string;
}

const initialShapes: Shape[] = [
  { id: 'shape-1', type: 'circle', color: '#ef4444' },
  { id: 'shape-2', type: 'square', color: '#3b82f6' },
  { id: 'shape-3', type: 'triangle', color: '#22c55e' },
  { id: 'shape-4', type: 'circle', color: '#f97316' },
  { id: 'shape-5', type: 'square', color: '#8b5cf6' },
  { id: 'shape-6', type: 'triangle', color: '#06b6d4' },
];

interface Zones {
  available: Shape[];
  circles: Shape[];
  squares: Shape[];
  triangles: Shape[];
}

class State {
  @tracked zones: Zones = {
    available: [...initialShapes],
    circles: [],
    squares: [],
    triangles: [],
  };
  @tracked activeDropZone: string | null = null;
}

const state = new State();

function handleDragOver(event: Parameters<DragDropEvents['dragover']>[0]) {
  state.activeDropZone = event.operation.target?.id as string | null;
}

function handleDragEnd(event: Parameters<DragDropEvents['dragend']>[0]) {
  state.activeDropZone = null;

  if (event.canceled || !event.operation.target) return;

  const sourceId = event.operation.source?.id as string;
  const targetZone = event.operation.target.id as keyof Zones;

  // Find which zone the shape is currently in
  let sourceZone: keyof Zones | null = null;
  let shape: Shape | null = null;

  for (const [zone, shapes] of Object.entries(state.zones) as [
    keyof Zones,
    Shape[],
  ][]) {
    const found = shapes.find((s: Shape) => s.id === sourceId);
    if (found) {
      sourceZone = zone;
      shape = found;
      break;
    }
  }

  if (!shape || !sourceZone || sourceZone === targetZone) return;

  // Move the shape to the new zone
  const newZones = { ...state.zones };
  newZones[sourceZone] = newZones[sourceZone].filter((s) => s.id !== sourceId);
  newZones[targetZone] = [...newZones[targetZone], shape];
  state.zones = newZones;
}

function resetShapes() {
  state.zones = {
    available: [...initialShapes],
    circles: [],
    squares: [],
    triangles: [],
  };
}

function shapeStyle(shape: Shape): SafeString {
  if (shape.type === 'circle') {
    return htmlSafe(`
      cursor: grab;
      width: 40px;
      height: 40px;
      border-radius: 50%;
      background: ${shape.color};
    `);
  } else if (shape.type === 'square') {
    return htmlSafe(`
      cursor: grab;
      width: 40px;
      height: 40px;
      border-radius: 4px;
      background: ${shape.color};
    `);
  } else {
    return htmlSafe(`
      cursor: grab;
      width: 0;
      height: 0;
      border-left: 20px solid transparent;
      border-right: 20px solid transparent;
      border-bottom: 40px solid ${shape.color};
    `);
  }
}

interface ZoneColors {
  bgActive: string;
  bgNormal: string;
  borderActive: string;
  borderNormal: string;
}

function zoneStyle(isActive: boolean, colors: ZoneColors): SafeString {
  return htmlSafe(`
    padding: 16px;
    min-height: 150px;
    background: ${isActive ? colors.bgActive : colors.bgNormal};
    border: 2px dashed ${isActive ? colors.borderActive : colors.borderNormal};
    border-radius: 8px;
    transition: all 0.2s;
  `);
}

const circlesColors: ZoneColors = {
  bgActive: '#fef2f2',
  bgNormal: '#fff5f5',
  borderActive: '#ef4444',
  borderNormal: '#fca5a5',
};
const squaresColors: ZoneColors = {
  bgActive: '#eff6ff',
  bgNormal: '#f0f9ff',
  borderActive: '#3b82f6',
  borderNormal: '#93c5fd',
};
const trianglesColors: ZoneColors = {
  bgActive: '#f0fdf4',
  bgNormal: '#f0fdf9',
  borderActive: '#22c55e',
  borderNormal: '#86efac',
};

<template>
  {{! template-lint-disable no-inline-styles }}
  <div style="margin-bottom: 24px;">
    <h2 style="margin-bottom: 8px;">Type Matching</h2>
    <p style="color: #666; margin-bottom: 16px;">
      Each drop zone only accepts its matching shape type. Uses the
      <code>accept</code>
      property.
    </p>
    <button
      type="button"
      style="padding: 8px 16px; background: #3b82f6; color: white; border: none; border-radius: 4px; cursor: pointer;"
      {{on "click" resetShapes}}
    >
      Reset Shapes
    </button>
  </div>

  <DragDrop @onDragOver={{handleDragOver}} @onDragEnd={{handleDragEnd}} as |dd|>
    {{! Available shapes }}
    <div
      style="
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        padding: 16px;
        min-height: 80px;
        background: #f9fafb;
        border: 2px dashed #e5e7eb;
        border-radius: 8px;
        margin-bottom: 24px;
      "
      {{dd.droppable id="available"}}
    >
      {{#each state.zones.available as |shape|}}
        <div
          {{dd.draggable id=shape.id type=shape.type}}
          style={{shapeStyle shape}}
        ></div>
      {{else}}
        <span style="color: #9ca3af; font-size: 14px;">All shapes sorted!</span>
      {{/each}}
    </div>

    {{! Drop zones }}
    <div
      style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px;"
    >
      {{! Circles zone }}
      <div
        {{dd.droppable id="circles" accept="circle"}}
        style={{zoneStyle (eq state.activeDropZone "circles") circlesColors}}
      >
        <h3
          style="margin: 0 0 12px 0; font-size: 14px; color: #dc2626; display: flex; align-items: center; gap: 8px;"
        >
          <span
            style="width: 16px; height: 16px; border-radius: 50%; background: #ef4444;"
          ></span>
          Circles ({{state.zones.circles.length}})
        </h3>
        <div style="display: flex; flex-wrap: wrap; gap: 8px;">
          {{#each state.zones.circles as |shape|}}
            <div
              {{dd.draggable id=shape.id type=shape.type}}
              style={{shapeStyle shape}}
            ></div>
          {{/each}}
        </div>
      </div>

      {{! Squares zone }}
      <div
        {{dd.droppable id="squares" accept="square"}}
        style={{zoneStyle (eq state.activeDropZone "squares") squaresColors}}
      >
        <h3
          style="margin: 0 0 12px 0; font-size: 14px; color: #2563eb; display: flex; align-items: center; gap: 8px;"
        >
          <span
            style="width: 16px; height: 16px; border-radius: 2px; background: #3b82f6;"
          ></span>
          Squares ({{state.zones.squares.length}})
        </h3>
        <div style="display: flex; flex-wrap: wrap; gap: 8px;">
          {{#each state.zones.squares as |shape|}}
            <div
              {{dd.draggable id=shape.id type=shape.type}}
              style={{shapeStyle shape}}
            ></div>
          {{/each}}
        </div>
      </div>

      {{! Triangles zone }}
      <div
        {{dd.droppable id="triangles" accept="triangle"}}
        style={{zoneStyle
          (eq state.activeDropZone "triangles")
          trianglesColors
        }}
      >
        <h3
          style="margin: 0 0 12px 0; font-size: 14px; color: #16a34a; display: flex; align-items: center; gap: 8px;"
        >
          <span
            style="width: 0; height: 0; border-left: 8px solid transparent; border-right: 8px solid transparent; border-bottom: 14px solid #22c55e;"
          ></span>
          Triangles ({{state.zones.triangles.length}})
        </h3>
        <div style="display: flex; flex-wrap: wrap; gap: 8px;">
          {{#each state.zones.triangles as |shape|}}
            <div
              {{dd.draggable id=shape.id type=shape.type}}
              style={{shapeStyle shape}}
            ></div>
          {{/each}}
        </div>
      </div>
    </div>
  </DragDrop>
</template>
