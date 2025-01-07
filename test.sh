NODE_API_URL="http://localhost:3005"
PYTHON_API_URL="http://localhost:5000"
LOG_FILE="test_logs.txt"

# Testa a rota inicial do Node.js
test_node_root() {
    echo "Testando rota inicial do Node.js..." | tee -a "$LOG_FILE"
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$NODE_API_URL/")
    echo "Resposta do Node.js: HTTP $RESPONSE" | tee -a "$LOG_FILE"
    [ "$RESPONSE" -eq 200 ] && \
    echo "✅ Node.js Root - Passou" | tee -a "$LOG_FILE" || \
    echo "❌ Node.js Root - Falhou" | tee -a "$LOG_FILE"
}

# Testa a rota inicial do Python
test_python_root() {
    echo "Testando rota inicial do Python..." | tee -a "$LOG_FILE"
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$PYTHON_API_URL/")
    echo "Resposta do Python: HTTP $RESPONSE" | tee -a "$LOG_FILE"
    [ "$RESPONSE" -eq 200 ] && \
    echo "✅ Python Root - Passou" | tee -a "$LOG_FILE" || \
    echo "❌ Python Root - Falhou" | tee -a "$LOG_FILE"
}

# Testa criação de uma nova tarefa
test_create_task() {
    echo "Testando criação de uma tarefa válida..." | tee -a "$LOG_FILE"
    RESPONSE=$(curl -s -w "\nHTTP %{http_code}" -X POST "$NODE_API_URL/tasks" \
        -H "Content-Type: application/json" \
        -d '{"text": "Diagnósticos médicos e decisões jurídicas: o papel da IA", "lang": "pt"}')
    echo "Resposta do Node.js (Criar Tarefa): $RESPONSE" | tee -a "$LOG_FILE"
    echo "$RESPONSE" | grep -q '"message": "Tarefa criada com sucesso!"' && \
    echo "✅ Criar Tarefa - Passou" | tee -a "$LOG_FILE" || \
    echo "❌ Criar Tarefa - Falhou" | tee -a "$LOG_FILE"
    TASK_ID=$(echo "$RESPONSE" | sed -n 's/.*"id":\([0-9]*\).*/\1/p')
}

# Testa criação de uma tarefa com erro
test_create_task_invalid() {
    echo "Testando criação de uma tarefa inválida..." | tee -a "$LOG_FILE"
    RESPONSE=$(curl -s -w "\nHTTP %{http_code}" -X POST "$NODE_API_URL/tasks" \
        -H "Content-Type: application/json" \
        -d '{"lang": "pt"}')
    echo "Resposta do Node.js (Criar Tarefa Inválida): $RESPONSE" | tee -a "$LOG_FILE"
    echo "$RESPONSE" | grep -q '"error"' && \
    echo "✅ Criar Tarefa Inválida - Passou" | tee -a "$LOG_FILE" || \
    echo "❌ Criar Tarefa Inválida - Falhou" | tee -a "$LOG_FILE"
}

# Testa obtenção de uma tarefa específica
test_get_task() {
    echo "Testando obtenção de uma tarefa (ID: $TASK_ID)..." | tee -a "$LOG_FILE"
    RESPONSE=$(curl -s -w "\nHTTP %{http_code}" "$NODE_API_URL/tasks/$TASK_ID")
    echo "Resposta do Node.js (Obter Tarefa): $RESPONSE" | tee -a "$LOG_FILE"
    echo "$RESPONSE" | grep -q '"id":' && \
    echo "✅ Obter Tarefa - Passou" | tee -a "$LOG_FILE" || \
    echo "❌ Obter Tarefa - Falhou" | tee -a "$LOG_FILE"
}

# Testa listagem de tarefas
test_list_tasks() {
    echo "Testando listagem de tarefas..." | tee -a "$LOG_FILE"
    RESPONSE=$(curl -s -w "\nHTTP %{http_code}" "$NODE_API_URL/tasks")
    echo "Resposta do Node.js (Listar Tarefas): $RESPONSE" | tee -a "$LOG_FILE"
    echo "$RESPONSE" | grep -q '"id":' && \
    echo "✅ Listar Tarefas - Passou" | tee -a "$LOG_FILE" || \
    echo "❌ Listar Tarefas - Falhou" | tee -a "$LOG_FILE"
}

# Testa remoção de uma tarefa
test_delete_task() {
    echo "Testando remoção de uma tarefa (ID: $TASK_ID)..." | tee -a "$LOG_FILE"
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$NODE_API_URL/tasks/$TASK_ID")
    echo "Resposta do Node.js (Remover Tarefa): HTTP $RESPONSE" | tee -a "$LOG_FILE"
    [ "$RESPONSE" -eq 204 ] && \
    echo "✅ Remover Tarefa - Passou" | tee -a "$LOG_FILE" || \
    echo "❌ Remover Tarefa - Falhou" | tee -a "$LOG_FILE"
}

# Testa o serviço Python para gerar um resumo
test_summarize_python() {
    echo "Testando geração de resumo no Python..." | tee -a "$LOG_FILE"
    RESPONSE=$(curl -s -w "\nHTTP %{http_code}" -X POST "$PYTHON_API_URL/summarize" \
        -H "Content-Type: application/json" \
        -d '{"text": "Diagnósticos médicos e decisões jurídicas: o papel da IA", "lang": "pt"}')
    echo "Resposta do Python (Resumo): $RESPONSE" | tee -a "$LOG_FILE"
    echo "$RESPONSE" | grep -q '"summary":' && \
    echo "✅ Geração de Resumo (Python) - Passou" | tee -a "$LOG_FILE" || \
    echo "❌ Geração de Resumo (Python) - Falhou" | tee -a "$LOG_FILE"
}

# Testa geração de resumo com erro
test_summarize_python_invalid() {
    echo "Testando geração de resumo com erro no Python..." | tee -a "$LOG_FILE"
    RESPONSE=$(curl -s -w "\nHTTP %{http_code}" -X POST "$PYTHON_API_URL/summarize" \
        -H "Content-Type: application/json" \
        -d '{"lang": "pt"}')
    echo "Resposta do Python (Resumo Inválido): $RESPONSE" | tee -a "$LOG_FILE"
    echo "$RESPONSE" | grep -q '"detail":' && \
    echo "✅ Geração de Resumo Inválido - Passou" | tee -a "$LOG_FILE" || \
    echo "❌ Geração de Resumo Inválido - Falhou" | tee -a "$LOG_FILE"
}

# Executa todos os testes
run_tests() {
    echo "Executando testes automatizados..." | tee -a "$LOG_FILE"
    test_node_root
    test_python_root
    test_create_task
    test_create_task_invalid
    test_get_task
    test_list_tasks
    test_delete_task
    test_summarize_python
    test_summarize_python_invalid

    echo "Testes finalizados. Logs salvos em $LOG_FILE"
}

# Verifica dependências
check_dependencies() {
    echo "Verificando dependências..." | tee -a "$LOG_FILE"
    if ! command -v curl > /dev/null; then
        echo "Erro: curl não está instalado. Por favor, instale e tente novamente." | tee -a "$LOG_FILE"
        exit 1
    fi
}

# Início do script
check_dependencies
run_tests
