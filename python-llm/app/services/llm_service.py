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
        Gera um resumo para o texto fornecido no idioma especificado.

        Args:
            text (str): Texto a ser resumido.
            lang (str): Idioma do resumo desejado (pt, en, es, etc.).

        Returns:
            str: Resumo gerado.

        Raises:
            ValueError: Se ocorrer algum erro ao invocar o modelo ou processar a resposta.
        """
        try:
            # Valida e processa a entrada do texto
            if not isinstance(text, str) or not text.strip():
                raise ValueError("O texto fornecido é inválido ou vazio.")

            if not isinstance(lang, str) or not lang.strip():
                raise ValueError("O idioma fornecido é inválido ou vazio.")

            # Garante que o texto esteja em formato UTF-8 válido
            text = text.encode('utf-8').decode('utf-8', 'ignore').strip()

            # Cria o prompt para o modelo
            prompt = f"Resuma o seguinte texto no idioma {lang}:\n\n{text}"
            response = self.llm.invoke(prompt)

            if not response or not response.strip():
                raise ValueError("Erro ao obter resposta do modelo.")

            return response.strip()
        except UnicodeDecodeError as e:
            raise ValueError(f"Erro de encoding no texto fornecido: {e}")
        except Exception as e:
            raise ValueError(f"Erro ao invocar o modelo: {str(e)}")
