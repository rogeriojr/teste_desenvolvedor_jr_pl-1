import os
import sys
from dotenv import load_dotenv

# Carregar variáveis de ambiente do arquivo .env
env_path = os.path.join(os.path.dirname(__file__), "../.env")
if not load_dotenv(env_path):
    print(f"⚠️ Aviso: Arquivo .env não encontrado no caminho {env_path}")

# Adicionar o diretório "app" ao sys.path para permitir imports
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.join(current_dir, "../app"))

from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel, ValidationError
from services.llm_service import LLMService

app = FastAPI()
llm_service = LLMService()

SUPPORTED_LANGS = ["pt", "en", "es"]

# Modelo para os dados recebidos na requisição
class TextData(BaseModel):
    text: str
    lang: str

# Rota inicial para verificar o status da API
@app.get("/")
def read_root():
    return {"message": "API is running"}

# Endpoint para resumir texto
@app.post("/summarize")
async def summarize(request: Request):
    try:
        # Tenta extrair o corpo da requisição
        body = await request.json()
        print(body)
        data = TextData(**body)
    except ValidationError as ve:
        # Erro de validação explícita
        raise HTTPException(status_code=422, detail=ve.errors())
    except Exception as e:
        # Erro genérico ao processar o corpo
        raise HTTPException(status_code=400, detail=f"Erro ao processar o corpo da requisição: {str(e)}")

    # Valida se o idioma é suportado
    if data.lang not in SUPPORTED_LANGS:
        raise HTTPException(status_code=400, detail="Language not supported")

    try:
        # Chama o serviço LLM para gerar o resumo
        summary = llm_service.summarize_text(data.text, data.lang)
        return {"summary": summary}
    except Exception as e:
        # Trata exceções e retorna mensagem de erro
        raise HTTPException(status_code=500, detail=f"Erro ao gerar o resumo: {str(e)}")
