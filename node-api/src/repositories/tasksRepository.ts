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
      fs.writeFileSync(this.FILE_PATH, JSON.stringify(this.tasks, null, 2), 'utf8');
    } catch (error) {
      if (error instanceof Error) {
        console.error("Erro ao salvar tarefas no arquivo:", error.message);
      } else {
        console.error("Erro desconhecido ao salvar tarefas no arquivo.");
      }
    }
  }

  /**
   * Carrega as tarefas do arquivo JSON.
   */
  private loadTasksFromFile(): void {
    if (fs.existsSync(this.FILE_PATH)) {
      try {
        const data = fs.readFileSync(this.FILE_PATH, 'utf8'); // Certifique-se de ler o arquivo como UTF-8
        const parsedData = JSON.parse(data);

        if (Array.isArray(parsedData)) {
          this.tasks = parsedData.map(task => ({
            ...task,
            text: task.text.normalize('NFC'), // Normaliza o texto para evitar problemas de encoding
          }));
          this.currentId = this.tasks.length > 0 ? Math.max(...this.tasks.map((t) => t.id)) + 1 : 1;
        } else {
          console.warn("O conteúdo do arquivo não é uma lista válida de tarefas. Inicializando vazio.");
          this.tasks = [];
        }
      } catch (error) {
        if (error instanceof SyntaxError) {
          console.error("Erro de sintaxe ao carregar o JSON das tarefas:", error.message);
        } else if (error instanceof Error) {
          console.error("Erro ao carregar tarefas do arquivo:", error.message);
        } else {
          console.error("Erro desconhecido ao carregar tarefas do arquivo.");
        }
        this.tasks = [];
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
      text: text.normalize('NFC'), // Normaliza o texto ao criar a tarefa
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
