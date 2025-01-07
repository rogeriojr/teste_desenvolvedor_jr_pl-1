import { Router, Request, Response } from "express";
import { TasksRepository } from "../repositories/tasksRepository";
import axios, { AxiosError } from "axios";

const router = Router();
const tasksRepository = new TasksRepository();

const SUPPORTED_LANGS = ["pt", "en", "es"];

// POST: Cria uma tarefa e solicita resumo ao serviço Python
router.post("/", async (req: Request, res: Response) => {
  try {
    const { text, lang } = req.body;

    // Validação de parâmetros obrigatórios
    if (!text || !lang) {
      return res.status(400).json({ error: 'Os campos "text" e "lang" são obrigatórios.' });
    }

    // Validação de idioma suportado
    if (!SUPPORTED_LANGS.includes(lang)) {
      return res.status(400).json({ error: "Idioma não suportado" });
    }

    // Cria a tarefa
    const task = tasksRepository.createTask(text);

    try {
      // Solicita o resumo ao serviço Python
      const pythonServiceUrl = "http://localhost:5000/summarize";
      const response = await axios.post(
        pythonServiceUrl,
        { text, lang },
        { timeout: 5000 } // Define um timeout para evitar travamentos
      );

      if (!response.data || !response.data.summary) {
        throw new Error("Erro ao obter o resumo do serviço Python.");
      }

      const summary = response.data.summary;

      // Atualiza a tarefa com o resumo
      tasksRepository.updateTask(task.id, summary);

      return res.status(201).json({
        message: "Tarefa criada com sucesso!",
        task: tasksRepository.getTaskById(task.id),
      });
    } catch (pythonError) {
      if (axios.isAxiosError(pythonError)) {
        console.error("Erro no serviço Python (Axios):", pythonError.message);
        return res.status(500).json({
          error: `Erro ao comunicar-se com o serviço Python: ${pythonError.response?.data || pythonError.message}`,
          task,
        });
      } else {
        console.error("Erro desconhecido no serviço Python:", (pythonError as Error).message);
        return res.status(500).json({
          error: "Erro desconhecido ao comunicar-se com o serviço Python.",
          task,
        });
      }
    }
  } catch (error) {
    console.error("Erro ao criar tarefa:", (error as Error).message);
    return res.status(500).json({ error: "Ocorreu um erro ao criar a tarefa." });
  }
});

// GET: Lista todas as tarefas
router.get("/", (req: Request, res: Response) => {
  try {
    const tasks = tasksRepository.getAllTasks();
    return res.status(200).json(tasks);
  } catch (error) {
    console.error("Erro ao listar tarefas:", (error as Error).message);
    return res.status(500).json({ error: "Erro ao listar tarefas." });
  }
});

// GET: Busca uma tarefa pelo ID
router.get("/:id", (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const task = tasksRepository.getTaskById(Number(id));

    if (!task) {
      return res.status(404).json({ error: "Tarefa não encontrada" });
    }

    return res.status(200).json(task);
  } catch (error) {
    console.error("Erro ao buscar tarefa:", (error as Error).message);
    return res.status(500).json({ error: "Erro ao buscar tarefa." });
  }
});

// DELETE: Remove uma tarefa pelo ID
router.delete("/:id", (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const deleted = tasksRepository.deleteTask(Number(id));

    if (!deleted) {
      return res.status(404).json({ error: "Tarefa não encontrada" });
    }

    return res.status(204).send();
  } catch (error) {
    console.error("Erro ao remover tarefa:", (error as Error).message);
    return res.status(500).json({ error: "Erro ao remover tarefa." });
  }
});

export default router;
