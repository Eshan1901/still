import type { ProjectInput, TaskInput } from '@still/contracts';
import type { Project, Task, ProjectStatus, TaskStatus, Priority } from './generated/prisma/client';
export const projectStatusDb = {
  'Not Started': 'NOT_STARTED',
  'In Progress': 'IN_PROGRESS',
  'On Hold': 'ON_HOLD',
  Completed: 'COMPLETED',
  Cancelled: 'CANCELLED',
} as const;
export const taskStatusDb = {
  Pending: 'PENDING',
  'In Progress': 'IN_PROGRESS',
  'In Review': 'IN_REVIEW',
  Completed: 'COMPLETED',
  Cancelled: 'CANCELLED',
} as const;
export const priorityDb = { Low: 'LOW', Medium: 'MEDIUM', High: 'HIGH', Critical: 'CRITICAL' } as const;
const projectStatus = {
  NOT_STARTED: 'Not Started',
  IN_PROGRESS: 'In Progress',
  ON_HOLD: 'On Hold',
  COMPLETED: 'Completed',
  CANCELLED: 'Cancelled',
} as const;
const taskStatus = {
  PENDING: 'Pending',
  IN_PROGRESS: 'In Progress',
  IN_REVIEW: 'In Review',
  COMPLETED: 'Completed',
  CANCELLED: 'Cancelled',
} as const;
const priority = { LOW: 'Low', MEDIUM: 'Medium', HIGH: 'High', CRITICAL: 'Critical' } as const;
export const date = (v: string) => new Date(v + 'T00:00:00.000Z');
export function projectData(v: ProjectInput) {
  return {
    ...v,
    status: projectStatusDb[v.status] as ProjectStatus,
    startDate: date(v.startDate),
    endDate: date(v.endDate),
  };
}
export function taskData(v: TaskInput) {
  return {
    ...v,
    status: taskStatusDb[v.status] as TaskStatus,
    priority: priorityDb[v.priority] as Priority,
    dueDate: date(v.dueDate),
  };
}
export function projectDto(p: Project & { _count: { tasks: number }; tasks: { id: string }[] }) {
  return {
    id: p.id,
    name: p.name,
    description: p.description,
    status: projectStatus[p.status],
    startDate: p.startDate.toISOString().slice(0, 10),
    endDate: p.endDate.toISOString().slice(0, 10),
    createdAt: p.createdAt.toISOString(),
    updatedAt: p.updatedAt.toISOString(),
    taskCount: p._count.tasks,
    completedTaskCount: p.tasks.length,
  };
}
export function taskDto(t: Task & { project: { name: string } }) {
  return {
    id: t.id,
    projectId: t.projectId,
    projectName: t.project.name,
    name: t.name,
    description: t.description,
    priority: priority[t.priority],
    status: taskStatus[t.status],
    dueDate: t.dueDate.toISOString().slice(0, 10),
    createdAt: t.createdAt.toISOString(),
    updatedAt: t.updatedAt.toISOString(),
  };
}
