#!/bin/bash

# Função para verificar e matar processos que estão usando uma porta específica
kill_port() {
    PORT=$1
    echo "Verificando processos na porta $PORT..."
    PIDS=$(netstat -ano | grep ":$PORT" | awk '{print $5}' | sort -u)

    if [ -z "$PIDS" ]; then
        echo "Nenhum processo encontrado na porta $PORT."
    else
        echo "Encerrando processos na porta $PORT..."
        for PID in $PIDS; do
            taskkill //PID $PID //F > /dev/null 2>&1 && echo "Processo $PID encerrado."
        done
    fi
}

# Mata os processos que estão usando as portas 3005 e 5000
kill_port 3005
kill_port 5000

echo "Todos os processos usando as portas 3005 e 5000 foram finalizados."
