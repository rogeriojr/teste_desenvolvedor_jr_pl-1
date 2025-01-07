#!/bin/bash

# Caminhos para as pastas Node.js e Python
NODE_API_DIR="node-api"
PYTHON_LLM_DIR="python-llm"
LOG_DIR="./logs"

# Cria o diretório de logs, se não existir
mkdir -p "$LOG_DIR"

# Função para instalar dependências do Node.js e iniciar o servidor
start_node() {
    echo "Configurando o servidor Node.js..."

    if [ -d "$NODE_API_DIR" ]; then
        cd "$NODE_API_DIR" || exit

        echo "Instalando dependências do Node.js..."
        npm install || { echo "Erro ao instalar dependências do Node.js."; exit 1; }

        echo "Compilando TypeScript para JavaScript..."
        npm run build || { echo "Erro ao compilar o projeto Node.js."; exit 1; }

        echo "Iniciando servidor Node.js..."
        npm run start > "../$LOG_DIR/node.log" 2>&1 &

        echo "Servidor Node.js está rodando. Logs disponíveis em $LOG_DIR/node.log"
        cd - || exit
    else
        echo "Erro: A pasta '$NODE_API_DIR' não foi encontrada."
        exit 1
    fi
}

# Função para instalar dependências do Python e iniciar o servidor
start_python() {
    echo "Configurando o servidor Python..."

    if [ -d "$PYTHON_LLM_DIR" ]; then
        cd "$PYTHON_LLM_DIR" || exit

        echo "Removendo ambiente virtual anterior, se existir..."
        if [ -d ".venv" ]; then
            if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
                rmdir /s /q .venv 2> /dev/null
            else
                rm -rf .venv
            fi
        fi

        echo "Criando um novo ambiente virtual..."
        python -m venv .venv || { echo "Erro ao criar ambiente virtual."; exit 1; }

        echo "Ativando o ambiente virtual..."
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
            .venv/Scripts/python -m pip install --upgrade pip || { echo "Erro ao atualizar pip."; exit 1; }
            .venv/Scripts/python -m pip install -r requirements.txt || { echo "Erro ao instalar dependências do Python."; exit 1; }
        else
            source .venv/bin/activate || { echo "Erro ao ativar ambiente virtual no Linux/Mac."; exit 1; }
            pip install --upgrade pip || { echo "Erro ao atualizar pip."; exit 1; }
            pip install -r requirements.txt || { echo "Erro ao instalar dependências do Python."; exit 1; }
        fi

        echo "Verificando se o módulo app.main:app existe..."
        .venv/Scripts/python -c "import app.main" || { echo "Erro: Não foi possível importar app.main. Verifique se o módulo está correto."; exit 1; }

        echo "Iniciando servidor Python com Uvicorn..."
        .venv/Scripts/python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 5000 > "../$LOG_DIR/python.log" 2>&1 &

        # Verificar se o servidor está rodando
        sleep 5
        if netstat -ano | grep ":5000" > /dev/null 2>&1; then
            echo "Servidor Python iniciado com sucesso. Logs disponíveis em $LOG_DIR/python.log"
        else
            echo "Erro: O servidor Python não está rodando. Verifique os logs em $LOG_DIR/python.log"
            if [ ! -f "../$LOG_DIR/python.log" ]; then
                echo "⚠️  Log do Python não foi criado. Verifique permissões ou configurações."
            fi
            exit 1
        fi

        cd - || exit
    else
        echo "Erro: A pasta '$PYTHON_LLM_DIR' não foi encontrada."
        exit 1
    fi
}

# Função para iniciar ambos os servidores
start_all() {
    echo "Iniciando configuração e servidores..."
    start_node
    start_python

    echo "Ambos os servidores estão rodando."
    echo "Você pode monitorar os logs em $LOG_DIR/node.log e $LOG_DIR/python.log"
    wait
}

# Limpa logs e ambientes virtuais
clean() {
    echo "Limpando logs e ambientes virtuais..."
    rm -rf "$LOG_DIR" node-api/.env python-llm/.venv
    echo "Limpeza concluída."
}

# Verifica o comando passado como argumento
case $1 in
    start-node)
        start_node
        ;;
    start-python)
        start_python
        ;;
    start-all)
        start_all
        ;;
    clean)
        clean
        ;;
    *)
        echo "Comando inválido. Use um dos seguintes:"
        echo "  start-node   - Instala dependências, compila e inicia o servidor Node.js"
        echo "  start-python - Instala dependências e inicia o servidor Python"
        echo "  start-all    - Configura e inicia ambos os servidores"
        echo "  clean        - Limpa logs e ambientes virtuais"
        ;;
esac
