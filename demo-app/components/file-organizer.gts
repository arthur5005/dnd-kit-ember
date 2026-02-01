import { on } from '@ember/modifier';
import { tracked } from '@glimmer/tracking';
import { htmlSafe, type SafeString } from '@ember/template';

import DragDrop from '../../src/components/drag-drop.gts';
import type { DragDropEvents } from '../../src/index.ts';

interface File {
  id: string;
  name: string;
  type: 'document' | 'image' | 'music' | 'video';
  icon: string;
}

interface Folders {
  inbox: File[];
  documents: File[];
  media: File[];
  archive: File[];
}

const initialFiles: Folders = {
  inbox: [
    { id: 'file-1', name: 'Report.pdf', type: 'document', icon: '📄' },
    { id: 'file-2', name: 'Vacation.jpg', type: 'image', icon: '🖼️' },
    { id: 'file-3', name: 'Song.mp3', type: 'music', icon: '🎵' },
    { id: 'file-4', name: 'Meeting.mp4', type: 'video', icon: '🎬' },
    { id: 'file-5', name: 'Notes.txt', type: 'document', icon: '📝' },
    { id: 'file-6', name: 'Photo.png', type: 'image', icon: '📷' },
  ],
  documents: [],
  media: [],
  archive: [],
};

class State {
  @tracked folders: Folders = {
    inbox: [...initialFiles.inbox],
    documents: [],
    media: [],
    archive: [],
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
  const targetFolder = event.operation.target.id as keyof Folders;

  // Find which folder the file is currently in
  let sourceFolder: keyof Folders | null = null;
  let file: File | null = null;

  for (const [folder, files] of Object.entries(state.folders) as [
    keyof Folders,
    File[],
  ][]) {
    const found = files.find((f: File) => f.id === sourceId);
    if (found) {
      sourceFolder = folder;
      file = found;
      break;
    }
  }

  if (!file || !sourceFolder || sourceFolder === targetFolder) return;

  // Move the file to the new folder
  const newFolders = { ...state.folders };
  newFolders[sourceFolder] = newFolders[sourceFolder].filter(
    (f) => f.id !== sourceId,
  );
  newFolders[targetFolder] = [...newFolders[targetFolder], file];
  state.folders = newFolders;
}

function resetFiles() {
  state.folders = {
    inbox: [...initialFiles.inbox],
    documents: [],
    media: [],
    archive: [],
  };
}

interface FolderConfig {
  label: string;
  icon: string;
  color: string;
  bgActive: string;
  bgNormal: string;
  borderActive: string;
  borderNormal: string;
}

const folderConfig: Record<string, FolderConfig> = {
  inbox: {
    label: 'Inbox',
    icon: '📥',
    color: '#f59e0b',
    bgActive: '#fef3c7',
    bgNormal: '#fffbeb',
    borderActive: '#f59e0b',
    borderNormal: '#fcd34d',
  },
  documents: {
    label: 'Documents',
    icon: '📁',
    color: '#3b82f6',
    bgActive: '#dbeafe',
    bgNormal: '#eff6ff',
    borderActive: '#3b82f6',
    borderNormal: '#93c5fd',
  },
  media: {
    label: 'Media',
    icon: '🎨',
    color: '#8b5cf6',
    bgActive: '#ede9fe',
    bgNormal: '#f5f3ff',
    borderActive: '#8b5cf6',
    borderNormal: '#c4b5fd',
  },
  archive: {
    label: 'Archive',
    icon: '🗄️',
    color: '#6b7280',
    bgActive: '#e5e7eb',
    bgNormal: '#f3f4f6',
    borderActive: '#6b7280',
    borderNormal: '#d1d5db',
  },
};

function folderStyle(isActive: boolean, config: FolderConfig): SafeString {
  return htmlSafe(`
    padding: 16px;
    min-height: 180px;
    background: ${isActive ? config.bgActive : config.bgNormal};
    border: 2px dashed ${isActive ? config.borderActive : config.borderNormal};
    border-radius: 12px;
    transition: all 0.2s;
  `);
}

function folderHeaderStyle(color: string): SafeString {
  return htmlSafe(`
    margin: 0 0 12px 0;
    font-size: 14px;
    color: ${color};
    display: flex;
    align-items: center;
    gap: 8px;
  `);
}

function badgeStyle(color: string): SafeString {
  return htmlSafe(`
    margin-left: auto;
    background: ${color};
    color: white;
    padding: 2px 8px;
    border-radius: 10px;
    font-size: 12px;
  `);
}

function eq(a: unknown, b: unknown): boolean {
  return a === b;
}

function getFolderFiles(folderId: string) {
  return state.folders[folderId as keyof Folders];
}

<template>
  {{! template-lint-disable no-inline-styles }}
  <div style="margin-bottom: 24px;">
    <h2 style="margin-bottom: 8px;">File Organizer</h2>
    <p style="color: #666; margin-bottom: 16px;">
      Drag files between folders to organize them. Any file can go in any
      folder.
    </p>
    <button
      type="button"
      style="padding: 8px 16px; background: #3b82f6; color: white; border: none; border-radius: 4px; cursor: pointer;"
      {{on "click" resetFiles}}
    >
      Reset Files
    </button>
  </div>

  <DragDrop @onDragOver={{handleDragOver}} @onDragEnd={{handleDragEnd}} as |dd|>
    <div
      style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px;"
    >
      {{#each-in folderConfig as |folderId config|}}
        <div
          {{dd.droppable id=folderId}}
          style={{folderStyle (eq state.activeDropZone folderId) config}}
        >
          <h3 style={{folderHeaderStyle config.color}}>
            <span>{{config.icon}}</span>
            {{config.label}}
            <span style={{badgeStyle config.color}}>
              {{#let (getFolderFiles folderId) as |files|}}
                {{files.length}}
              {{/let}}
            </span>
          </h3>
          <div style="display: flex; flex-direction: column; gap: 6px;">
            {{#let (getFolderFiles folderId) as |files|}}
              {{#each files as |file|}}
                <div
                  {{dd.draggable id=file.id}}
                  style="
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    padding: 8px 12px;
                    background: white;
                    border-radius: 6px;
                    cursor: grab;
                    user-select: none;
                    font-size: 13px;
                    box-shadow: 0 1px 2px rgba(0,0,0,0.05);
                  "
                >
                  <span>{{file.icon}}</span>
                  <span
                    style="flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"
                  >{{file.name}}</span>
                </div>
              {{else}}
                <div
                  style="padding: 20px; text-align: center; color: #9ca3af; font-size: 13px;"
                >
                  Empty
                </div>
              {{/each}}
            {{/let}}
          </div>
        </div>
      {{/each-in}}
    </div>
  </DragDrop>
</template>
