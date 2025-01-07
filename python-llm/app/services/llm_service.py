import os
from dotenv import load_dotenv
from langchain_openai import OpenAI

# Carrega as variáveis de ambiente do arquivo .env
load_dotenv()

class LLMService:
    def __init__(self):
        """
        Configura o modelo LLM usando a chave de API do Hugging Face.
        """
        api_key = os.getenv("HF_TOKEN")
        if not api_key:
            raise ValueError("A variável de ambiente 'HF_TOKEN' não está definida. Verifique o arquivo .env.")
        
        try:
            self.llm = OpenAI(
                temperature=0.5,
                top_p=0.7,
                api_key=api_key,
                base_url="https://api-inference.huggingface.co/models/Qwen/Qwen2.5-72B-Instruct/v1",
            )
        except Exception as e:
            raise ValueError(f"Erro ao configurar o modelo LLM: {str(e)}")

    def summarize_text(self, text: str, lang: str) -> str:
        """
        Recebe um texto e um idioma, e retorna o resumo gerado pelo modelo.
        """
        prompt = f"Resuma o seguinte texto no idioma {lang}:\n\n{text}".encode("utf-8").decode("utf-8")

        try:
            response = self.llm.invoke(prompt)
            if not response:
                raise ValueError("Erro ao obter resposta do modelo")
            return response.strip()
        except Exception as e:
            raise ValueError(f"Erro ao invocar o modelo: {str(e)}")
