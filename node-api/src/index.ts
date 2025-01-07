import dotenv from 'dotenv';
dotenv.config(); // Carregar variáveis de ambiente do arquivo .env

import app from './app'; // Importa o app configurado no arquivo app.ts

// Porta padrão do servidor definida no .env ou 3005 como fallback
const PORT = process.env.PORT || 3005;

// Inicia o servidor
app.listen(PORT, () => {
  console.log(`Node API rodando na porta ${PORT}`);
  console.log(`Documentação do Swagger disponível em http://localhost:${PORT}/api-docs`);
});
