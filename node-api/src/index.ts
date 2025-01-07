import dotenv from "dotenv";
dotenv.config(); // Carrega as variáveis de ambiente do arquivo .env

import app from "./app"; // Importa o app configurado no arquivo app.ts

// Porta padrão do servidor definida no .env ou 3005 como fallback
const PORT = process.env.PORT || 3005;

// Inicia o servidor
app.listen(PORT, () => {
  console.log(`Node API rodando na porta ${PORT}`);
  console.log(`Documentação do Swagger disponível em http://localhost:${PORT}/api-docs`);
});

// Tratamento global de erros não tratados
process.on("unhandledRejection", (reason) => {
  console.error("Unhandled Rejection:", reason);
});

process.on("uncaughtException", (error) => {
  console.error("Uncaught Exception:", error);
  process.exit(1); // Finaliza o processo em caso de erro crítico
});
