import { Router, Request, Response } from "express";
import { TasksRepository } from "../repositories/tasksRepository";

const router = Router();
const tasksRepository = new TasksRepository();
const SUPPORTED_LANGS = ["pt", "en", "es"];

// Rota para criar tarefa via URL ou corpo
router.post("/create-task", (req: Request, res: Response) => {
  try {
    const { text, lang } = req.query; // Aceita dados via query

    // Valida os parâmetros
    if (!text || typeof text !== "string") {
      return res
        .status(400)
        .json({ error: 'O parâmetro "text" é obrigatório e deve ser uma string.' });
    }

    if (!lang || typeof lang !== "string" || !SUPPORTED_LANGS.includes(lang)) {
      return res.status(400).json({
        error: `O parâmetro "lang" é obrigatório e deve ser um dos seguintes valores: ${SUPPORTED_LANGS.join(", ")}.`,
      });
    }

    // Cria tarefa
    const task = tasksRepository.createTask(text);

    return res.status(201).json({
      message: "Tarefa criada com sucesso!",
      task: {
        ...task,
        lang,
      },
    });
  } catch (error: unknown) {
    console.error("Erro ao criar tarefa:", (error as Error).message);
    return res.status(500).json({ error: "Erro interno ao criar a tarefa." });
  }
});

export default router;
