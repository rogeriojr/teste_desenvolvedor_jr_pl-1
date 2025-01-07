NODE_API_URL="http://localhost:3005"
PYTHON_API_URL="http://localhost:5000"
LOG_FILE="test_logs.txt"

# Função para limpar logs anteriores
initialize_log() {
    > "$LOG_FILE"
}

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

# Testa criação de uma nova tarefa válida
test_create_task() {
    echo "Testando criação de uma tarefa válida..." | tee -a "$LOG_FILE"
    RESPONSE=$(curl -s -w "\nHTTP %{http_code}" -X POST "$NODE_API_URL/tasks" \
        -H "Content-Type: application/json" \
        -d '{"text": "Diagnósticos médicos e decisões jurídicas: o papel da IA", "lang": "pt"}')
    echo "Resposta do Node.js (Criar Tarefa): $RESPONSE" | tee -a "$LOG_FILE"

    if echo "$RESPONSE" | grep -q '"id":'; then
        echo "✅ Criar Tarefa - Passou" | tee -a "$LOG_FILE"
        TASK_ID=$(echo "$RESPONSE" | sed -n 's/.*"id":\([0-9]*\).*/\1/p')
    else
        echo "❌ Criar Tarefa - Falhou" | tee -a "$LOG_FILE"
    fi
}

# Testa criação de uma tarefa com erro (ausência de texto)
test_create_task_invalid() {
    echo "Testando criação de uma tarefa inválida..." | tee -a "$LOG_FILE"
    RESPONSE=$(curl -s -w "\nHTTP %{http_code}" -X POST "$NODE_API_URL/tasks" \
        -H "Content-Type: application/json" \
        -d '{"lang": "pt"}')
    echo "Resposta do Node.js (Criar Tarefa Inválida): $RESPONSE" | tee -a "$LOG_FILE"
    if echo "$RESPONSE" | grep -q '"error"'; then
        echo "✅ Criar Tarefa Inválida - Passou" | tee -a "$LOG_FILE"
    else
        echo "❌ Criar Tarefa Inválida - Falhou" | tee -a "$LOG_FILE"
    fi
}

# Testa obtenção de uma tarefa específica
test_get_task() {
    echo "Testando obtenção de uma tarefa (ID: $TASK_ID)..." | tee -a "$LOG_FILE"
    RESPONSE=$(curl -s -w "\nHTTP %{http_code}" "$NODE_API_URL/tasks/$TASK_ID")
    echo "Resposta do Node.js (Obter Tarefa): $RESPONSE" | tee -a "$LOG_FILE"
    if echo "$RESPONSE" | grep -q '"id":'; then
        echo "✅ Obter Tarefa - Passou" | tee -a "$LOG_FILE"
    else
        echo "❌ Obter Tarefa - Falhou" | tee -a "$LOG_FILE"
    fi
}

# Testa listagem de tarefas
test_list_tasks() {
    echo "Testando listagem de tarefas..." | tee -a "$LOG_FILE"
    RESPONSE=$(curl -s -w "\nHTTP %{http_code}" "$NODE_API_URL/tasks")
    echo "Resposta do Node.js (Listar Tarefas): $RESPONSE" | tee -a "$LOG_FILE"
    if echo "$RESPONSE" | grep -q '"id":'; then
        echo "✅ Listar Tarefas - Passou" | tee -a "$LOG_FILE"
    else
        echo "❌ Listar Tarefas - Falhou" | tee -a "$LOG_FILE"
    fi
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

# Testa o serviço Python para gerar um resumo válido
test_summarize_python_valid() {
    echo "Testando geração de resumo válida no Python..." | tee -a "$LOG_FILE"
    RESPONSE=$(curl -s -w "\nHTTP %{http_code}" -X POST "$PYTHON_API_URL/summarize" \
        -H "Content-Type: application/json" \
        -H "User-Agent: insomnia/2023.5.8" \
        -d '{"lang": "pt", "text": "texto"}')
    echo "Resposta do Python (Resumo Válido): $RESPONSE" | tee -a "$LOG_FILE"

    if echo "$RESPONSE" | grep -q '"summary"'; then
        echo "✅ Geração de Resumo Válido - Passou" | tee -a "$LOG_FILE"
    else
        echo "❌ Geração de Resumo Válido - Falhou" | tee -a "$LOG_FILE"
    fi
}

# Testa geração de resumo com dados inválidos
test_summarize_python_invalid() {
    echo "Testando geração de resumo com erro no Python..." | tee -a "$LOG_FILE"
    RESPONSE=$(curl -s -w "\nHTTP %{http_code}" -X POST "$PYTHON_API_URL/summarize" \
        -H "Content-Type: application/json" \
        -H "User-Agent: insomnia/2023.5.8" \
        -d '{"lang": "pt"}')
    echo "Resposta do Python (Resumo Inválido): $RESPONSE" | tee -a "$LOG_FILE"

    if echo "$RESPONSE" | grep -q '"detail"'; then
        echo "✅ Geração de Resumo Inválido - Passou" | tee -a "$LOG_FILE"
    else
        echo "❌ Geração de Resumo Inválido - Falhou" | tee -a "$LOG_FILE"
    fi
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
initialize_log
check_dependencies
run_tests
