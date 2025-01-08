import { Router, Request, Response } from "express";
import { TasksRepository } from "../repositories/tasksRepository";

const router = Router();
const tasksRepository = new TasksRepository();

const SUPPORTED_LANGS = ["pt", "en", "es"];

// Rota para criar uma tarefa usando query parameters
router.get("/create-task", (req: Request, res: Response) => {
  try {
    const { text, lang } = req.query;

    // Valida se os parâmetros "text" e "lang" foram fornecidos
    if (!text || typeof text !== "string") {
      return res
        .status(400)
        .json({ error: 'O parâmetro "text" é obrigatório e deve ser uma string.' });
    }

    if (!lang || typeof lang !== "string" || !SUPPORTED_LANGS.includes(lang)) {
      return res.status(400).json({
        error: `O parâmetro "lang" é obrigatório, deve ser uma string e um dos seguintes valores: ${SUPPORTED_LANGS.join(", ")}.`,
      });
    }

    // Cria a tarefa
    const task = tasksRepository.createTask(text);

    // Retorna a tarefa criada
    return res.status(201).json({
      message: "Tarefa criada com sucesso!",
      task: {
        ...task,
        lang, // Inclui a linguagem na resposta
      },
    });
  } catch (error) {
    if (error instanceof Error) {
      console.error("Erro ao criar tarefa:", error.message);
    } else {
      console.error("Erro desconhecido ao criar tarefa.");
    }
    return res.status(500).json({ error: "Erro ao criar a tarefa." });
  }
});

export default router;
