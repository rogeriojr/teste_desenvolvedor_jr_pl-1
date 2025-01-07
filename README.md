
# LLM Summarizer API

Este projeto é uma API Node.js desenvolvida com TypeScript e Express, que permite aos usuários submeter textos e receber resumos gerados por um serviço Python utilizando LangChain. O resumo gerado é salvo com o texto original e a versão resumida e traduzido conforme o idioma solicitado pelo usuário.

---

## Estrutura do Projeto

- **node-api/**: Contém a implementação da API Node.js.
  - **src/**: Contém o código-fonte da API.
    - **app.ts**: Ponto de entrada da aplicação.
    - **index.ts**: Inicia o servidor.
    - **routes/**: Define as rotas da API.
      - **tasksRoutes.ts**: Gerencia as rotas relacionadas a tarefas.
      - **queryRoutes.ts**: Rotas que utilizam query parameters.
    - **repositories/**: Gerencia as tarefas em memória.
      - **tasksRepository.ts**: Implementa a lógica de armazenamento de tarefas.
- **python-llm/**: Contém a implementação do serviço Python.
  - **app/**: Contém o código-fonte do serviço Python.
    - **main.py**: Ponto de entrada da aplicação FastAPI.
    - **services/**: Implementa a lógica de resumo de texto.
      - **llm_service.py**: Interage com LangChain para gerar resumos.

---

## Environment

**HF_TOKEN**: Token de acesso ao Hugging Face ([criar aqui](https://huggingface.co/settings/tokens)). Caso não tenha, crie uma conta e gere um token (gratuito).

---

## Como Executar

1. Clone o repositório.
2. Navegue até o diretório do projeto.
3. Instale as dependências dos projetos Node.js e Python:
   ```bash
   ./setup.sh install-node
   ./setup.sh install-python
   ```
4. Inicie a API Node.js e o serviço Python:
   ```bash
   ./setup.sh start-all
   ```
5. Acesse a API Node.js em `http://localhost:3005` e a API Python em `http://localhost:5000`.

---

## Endpoints Disponíveis

### Node.js

- **GET /**: Retorna `{"message": "API is running"}` para indicar que a API está rodando.
- **POST /tasks**: Cria uma nova tarefa com o texto e idioma especificados.
  - **Body:**  
    ```json
    {
      "text": "Texto para resumir",
      "lang": "pt"
    }
    ```
  - **Idiomas suportados:**  
    - `pt`: Português
    - `en`: Inglês
    - `es`: Espanhol
- **GET /tasks**: Lista todas as tarefas criadas.
- **GET /tasks/:id**: Retorna os detalhes de uma tarefa específica.
- **DELETE /tasks/:id**: Remove uma tarefa pelo ID.
- **GET /query/create-task**: Cria uma tarefa usando parâmetros de consulta.
  - **Exemplo de uso:**
    ```
    curl -X GET "http://localhost:3005/query/create-task?text=Texto%20de%20exemplo&lang=pt"
    ```

### Python

- **GET /**: Retorna `{"message": "API is running"}` para indicar que a API está rodando.
- **POST /summarize**: Gera um resumo para o texto enviado no idioma solicitado.
  - **Body:**  
    ```json
    {
      "text": "Texto para resumir",
      "lang": "pt"
    }
    ```

---

## Projeto Teste Realizado por Rogério

Os testes foram realizados para validar os requisitos do projeto. Seguem os passos e resultados:

### **1. Testes Automatizados**

Utilizando o script `test.sh`, os endpoints foram testados automaticamente. Para rodar os testes:

1. Certifique-se de que os servidores estão rodando:
   ```bash
   ./setup.sh start-all
   ```
2. Execute o script de testes:
   ```bash
   chmod +x test.sh
   ./test.sh
   ```
3. O script realiza os seguintes testes:
   - Verifica se as APIs Node.js e Python estão rodando.
   - Cria uma tarefa e valida a resposta.
   - Lista as tarefas e verifica a presença da tarefa criada.
   - Obtém detalhes de uma tarefa específica.
   - Remove a tarefa e valida a exclusão.
   - Testa diretamente o endpoint de resumo do Python.

**Exemplo de Saída:**
```
✅ Node.js Root - Passou
✅ Python Root - Passou
✅ Criar Tarefa - Passou
✅ Obter Tarefa - Passou
✅ Listar Tarefas - Passou
✅ Remover Tarefa - Passou
✅ Geração de Resumo (Python) - Passou
```

---

### **2. Configuração do Swagger**

Para facilitar o teste manual dos endpoints, o Swagger foi configurado.

#### Node.js (API Node)
1. Instale o `swagger-ui-express` no projeto Node.js:
   ```bash
   npm install swagger-ui-express
   ```
2. Adicione o seguinte ao arquivo `app.ts`:
   ```typescript
   import swaggerUi from 'swagger-ui-express';
   import swaggerDocument from './swagger.json';

   app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));
   ```
3. Crie o arquivo `swagger.json` na raiz do projeto com a documentação dos endpoints:
   ```json
   {
     "openapi": "3.0.0",
     "info": {
       "title": "LLM Summarizer API",
       "version": "1.0.0",
       "description": "API para resumo de textos utilizando Node.js e Python"
     },
     "paths": {
       "/tasks": {
         "post": {
           "summary": "Cria uma nova tarefa",
           "requestBody": {
             "content": {
               "application/json": {
                 "schema": {
                   "type": "object",
                   "properties": {
                     "text": { "type": "string" },
                     "lang": { "type": "string" }
                   },
                   "required": ["text", "lang"]
                 }
               }
             }
           },
           "responses": {
             "201": {
               "description": "Tarefa criada com sucesso"
             }
           }
         }
       }
     }
   }
   ```

#### Python (API Python)
1. O FastAPI já possui Swagger embutido. Basta acessar:
   - [Swagger Docs do Python](http://localhost:5000/docs)
   - [ReDoc Docs do Python](http://localhost:5000/redoc)

---

## Forçar refresh das portas e terminais se necessário
4. Inicie a API Node.js e o serviço Python:
   ```bash
   ./refresh_shells.sh
   ```

---

## Conclusão

Todos os requisitos foram implementados, testados e validados com sucesso. O projeto está pronto para ser submetido ao repositório pessoal. 🚀

Se precisar de mais ajuda, estou à disposição!
