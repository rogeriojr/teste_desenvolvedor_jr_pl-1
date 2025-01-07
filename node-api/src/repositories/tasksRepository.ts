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

  /**
   * Salva as tarefas no arquivo JSON.
   */
  private saveTasksToFile(): void {
    try {
      fs.writeFileSync(this.FILE_PATH, JSON.stringify(this.tasks, null, 2), "utf-8");
    } catch (error: unknown) {
      console.error("Erro ao salvar tarefas no arquivo:", (error as Error).message);
    }
  }

  /**
   * Carrega as tarefas do arquivo JSON.
   */
  private loadTasksFromFile(): void {
    if (fs.existsSync(this.FILE_PATH)) {
      try {
        const data = fs.readFileSync(this.FILE_PATH, "utf-8");
        const parsedData = JSON.parse(data);

        if (Array.isArray(parsedData)) {
          this.tasks = parsedData;
          this.currentId = this.tasks.length > 0 ? Math.max(...this.tasks.map((t) => t.id)) + 1 : 1;
        } else {
          console.warn("O conteúdo do arquivo não é uma lista válida de tarefas. Inicializando vazio.");
        }
      } catch (error: unknown) {
        console.error("Erro ao carregar tarefas do arquivo. Certifique-se de que o arquivo está no formato JSON válido:", (error as Error).message);
        this.tasks = []; // Reseta para evitar sobrescrita com dados corrompidos.
      }
    }
  }

  /**
   * Cria uma nova tarefa e salva no arquivo.
   * @param text Texto da tarefa.
   * @returns A nova tarefa criada.
   */
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

  /**
   * Atualiza o resumo de uma tarefa pelo ID.
   * @param id ID da tarefa.
   * @param summary Resumo a ser atualizado.
   * @returns A tarefa atualizada ou `null` se não encontrada.
   */
  updateTask(id: number, summary: string): Task | null {
    const taskIndex = this.tasks.findIndex((t) => t.id === id);
    if (taskIndex > -1) {
      this.tasks[taskIndex].summary = summary;
      this.saveTasksToFile();
      return this.tasks[taskIndex];
    }
    return null;
  }

  /**
   * Busca uma tarefa pelo ID.
   * @param id ID da tarefa.
   * @returns A tarefa encontrada ou `null`.
   */
  getTaskById(id: number): Task | null {
    return this.tasks.find((t) => t.id === id) || null;
  }

  /**
   * Retorna todas as tarefas.
   * @returns Lista de todas as tarefas.
   */
  getAllTasks(): Task[] {
    return this.tasks;
  }

  /**
   * Remove uma tarefa pelo ID.
   * @param id ID da tarefa.
   * @returns `true` se a tarefa foi removida, `false` caso contrário.
   */
  deleteTask(id: number): boolean {
    const initialLength = this.tasks.length;
    this.tasks = this.tasks.filter((task) => task.id !== id);
    if (this.tasks.length < initialLength) {
      this.saveTasksToFile();
      return true;
    }
    return false;
  }
}
