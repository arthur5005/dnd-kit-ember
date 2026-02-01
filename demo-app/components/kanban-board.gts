import { on } from '@ember/modifier';
import { move } from '@dnd-kit/helpers';
import { TrackedObject } from 'tracked-built-ins';
import { CollisionPriority } from '@dnd-kit/abstract';

import DragDrop from '../../src/components/drag-drop.gts';
import type { DragDropEvents, UniqueIdentifier } from '../../src/index.ts';

interface Task {
  id: string;
  title: string;
}

interface KanbanItems {
  todo: Task[];
  inProgress: Task[];
  done: Task[];
}

const initialKanban: KanbanItems = {
  todo: [
    { id: 'task-1', title: 'Design mockups' },
    { id: 'task-2', title: 'Write tests' },
    { id: 'task-3', title: 'Update docs' },
  ],
  inProgress: [
    { id: 'task-4', title: 'Build API' },
    { id: 'task-5', title: 'Code review' },
  ],
  done: [{ id: 'task-6', title: 'Setup repo' }],
};

const state = new TrackedObject({
  todo: [...initialKanban.todo],
  inProgress: [...initialKanban.inProgress],
  done: [...initialKanban.done],
});

let snapshot: KanbanItems = {
  todo: [],
  inProgress: [],
  done: [],
};

function handleDragStart() {
  snapshot = {
    todo: [...state.todo],
    inProgress: [...state.inProgress],
    done: [...state.done],
  };
}

function handleDragOver(event: Parameters<DragDropEvents['dragover']>[0]) {
  const result = move(
    state as unknown as Record<UniqueIdentifier, Task[]>,
    event,
  );

  state.todo = result.todo!;
  state.inProgress = result.inProgress!;
  state.done = result.done!;
}

function handleDragEnd(event: Parameters<DragDropEvents['dragend']>[0]) {
  if (event.canceled) {
    state.todo = [...snapshot.todo];
    state.inProgress = [...snapshot.inProgress];
    state.done = [...snapshot.done];
  }
}

function resetBoard() {
  state.todo = [...initialKanban.todo];
  state.inProgress = [...initialKanban.inProgress];
  state.done = [...initialKanban.done];
}

<template>
  {{! template-lint-disable no-inline-styles }}
  <div style="margin-bottom: 24px;">
    <h2 style="margin-bottom: 8px;">Kanban Board</h2>
    <p style="color: #666; margin-bottom: 16px;">
      Drag tasks between columns. Press Escape to cancel.
    </p>
    <button
      type="button"
      style="padding: 8px 16px; background: #3b82f6; color: white; border: none; border-radius: 4px; cursor: pointer;"
      {{on "click" resetBoard}}
    >
      Reset Board
    </button>
  </div>

  <DragDrop
    @onDragStart={{handleDragStart}}
    @onDragEnd={{handleDragEnd}}
    @onDragOver={{handleDragOver}}
    as |dd|
  >
    <div
      style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px;"
    >
      {{! To Do Column }}
      <div style="background: #fef3c7; border-radius: 8px; padding: 12px;">
        <h3
          style="margin: 0 0 12px 0; font-size: 14px; font-weight: 600; color: #92400e;"
        >
          To Do ({{state.todo.length}})
        </h3>
        <div
          style="display: flex; flex-direction: column; gap: 8px; min-height: 200px;"
          {{dd.droppable
            id="todo"
            collisionPriority=CollisionPriority.Low
            accept="item"
          }}
        >
          {{#each state.todo as |task index|}}
            <div
              {{dd.sortable id=task.id index=index group="todo" type="item"}}
              style="
                display: flex;
                padding: 10px 12px;
                background: white;
                border-radius: 6px;
                box-shadow: 0 1px 2px rgba(0,0,0,0.1);
                cursor: grab;
                user-select: none;
                font-size: 14px;
              "
            >
              {{task.title}}
            </div>
          {{/each}}
        </div>
      </div>

      {{! In Progress Column }}
      <div style="background: #dbeafe; border-radius: 8px; padding: 12px;">
        <h3
          style="margin: 0 0 12px 0; font-size: 14px; font-weight: 600; color: #1e40af;"
        >
          In Progress ({{state.inProgress.length}})
        </h3>
        <div
          style="display: flex; flex-direction: column; gap: 8px; min-height: 200px;"
          {{dd.droppable
            id="inProgress"
            collisionPriority=CollisionPriority.Low
            accept="item"
          }}
        >
          {{#each state.inProgress as |task index|}}
            <div
              {{dd.sortable
                id=task.id
                index=index
                group="inProgress"
                type="item"
              }}
              style="
                display: flex;
                padding: 10px 12px;
                background: white;
                border-radius: 6px;
                box-shadow: 0 1px 2px rgba(0,0,0,0.1);
                cursor: grab;
                user-select: none;
                font-size: 14px;
              "
            >
              {{task.title}}
            </div>
          {{/each}}
        </div>
      </div>

      {{! Done Column }}
      <div style="background: #dcfce7; border-radius: 8px; padding: 12px;">
        <h3
          style="margin: 0 0 12px 0; font-size: 14px; font-weight: 600; color: #166534;"
        >
          Done ({{state.done.length}})
        </h3>
        <div
          style="display: flex; flex-direction: column; gap: 8px; min-height: 200px;"
          {{dd.droppable
            id="done"
            collisionPriority=CollisionPriority.Low
            accept="item"
          }}
        >
          {{#each state.done as |task index|}}
            <div
              {{dd.sortable id=task.id index=index group="done" type="item"}}
              style="
                display: flex;
                padding: 10px 12px;
                background: white;
                border-radius: 6px;
                box-shadow: 0 1px 2px rgba(0,0,0,0.1);
                cursor: grab;
                user-select: none;
                font-size: 14px;
              "
            >
              {{task.title}}
            </div>
          {{/each}}
        </div>
      </div>
    </div>
  </DragDrop>
</template>
