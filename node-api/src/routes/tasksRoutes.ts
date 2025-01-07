import { Router, Request, Response } from "express";
import { TasksRepository } from "../repositories/tasksRepository";
import axios from "axios";

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

    // Cria a "tarefa"
    const task = tasksRepository.createTask(text);

    try {
      // Solicitar o resumo ao serviço Python
      const pythonServiceUrl = "http://localhost:5000/summarize";
      const response = await axios.post(pythonServiceUrl, { text, lang });

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
      console.error("Erro no serviço Python:", pythonError.message || pythonError);
      return res.status(500).json({
        error: "Tarefa criada, mas não foi possível gerar o resumo. Tente novamente mais tarde.",
        task,
      });
    }
  } catch (error) {
    console.error("Erro ao criar tarefa:", error.message || error);
    return res.status(500).json({ error: "Ocorreu um erro ao criar a tarefa." });
  }
});

// GET: Lista todas as tarefas
router.get("/", (req: Request, res: Response) => {
  const tasks = tasksRepository.getAllTasks();
  return res.json(tasks);
});

// GET: Busca uma tarefa pelo ID
router.get("/:id", (req: Request, res: Response) => {
  const { id } = req.params;

  const task = tasksRepository.getTaskById(Number(id));

  if (!task) {
    return res.status(404).json({ error: "Tarefa não encontrada" });
  }

  return res.json(task);
});

// DELETE: Remove uma tarefa pelo ID
router.delete("/:id", (req: Request, res: Response) => {
  const { id } = req.params;

  const deleted = tasksRepository.deleteTask(Number(id));

  if (!deleted) {
    return res.status(404).json({ error: "Tarefa não encontrada" });
  }

  return res.status(204).send();
});

export default router;
