import fs from "fs";
import path from "path";

interface Task {
  id: number;
  text: string;
  summary: string | null;
}

export class TasksRepository {
  private tasks: Task[] = [];
  private currentId: number = 1;
  private readonly FILE_PATH = path.resolve(__dirname, "../../tasks.json");

  constructor() {
    this.loadTasksFromFile();
  }

  private saveTasksToFile(): void {
    try {
      fs.writeFileSync(this.FILE_PATH, JSON.stringify(this.tasks, null, 2), "utf-8");
    } catch (error) {
      console.error("Erro ao salvar tarefas no arquivo:", error.message || error);
    }
  }

  private loadTasksFromFile(): void {
    if (fs.existsSync(this.FILE_PATH)) {
      try {
        const data = fs.readFileSync(this.FILE_PATH, "utf-8");
        this.tasks = JSON.parse(data);
        this.currentId = this.tasks.length > 0 ? Math.max(...this.tasks.map(t => t.id)) + 1 : 1;
      } catch (error) {
        console.error("Erro ao carregar tarefas do arquivo:", error.message || error);
      }
    }
  }

  createTask(text: string): Task {
    const task: Task = {
      id: this.currentId++,
      text,
      summary: null,
    };
    this.tasks.push(task);
    this.saveTasksToFile();
    return task;
  }

  updateTask(id: number, summary: string): Task | null {
    const taskIndex = this.tasks.findIndex(t => t.id === id);
    if (taskIndex > -1) {
      this.tasks[taskIndex].summary = summary;
      this.saveTasksToFile();
      return this.tasks[taskIndex];
    }
    return null;
  }

  getTaskById(id: number): Task | null {
    return this.tasks.find(t => t.id === id) || null;
  }

  getAllTasks(): Task[] {
    return this.tasks;
  }

  deleteTask(id: number): boolean {
    const initialLength = this.tasks.length;
    this.tasks = this.tasks.filter(task => task.id !== id);
    if (this.tasks.length < initialLength) {
      this.saveTasksToFile();
      return true;
    }
    return false;
  }
}
