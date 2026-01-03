import os
from llama_index.core import VectorStoreIndex, SimpleDirectoryReader, Settings, PromptTemplate
from llama_index.llms.groq import Groq
from llama_index.embeddings.huggingface import HuggingFaceEmbedding
from dotenv import load_dotenv

load_dotenv()

# --- CUSTOM PROMPTS FOR "BEST MENTAL HEALTH BOT" ---

# 1. Text QA Prompt (The Core Answer Generator)
# Injects the "MAA" persona into the RAG response.
QA_PROMPT_TMPL = (
    "You are MAA, an empathetic and professional mental health guide. "
    "Your goal is to provide comforting, evidence-based support using the context below.\n\n"
    "context_str:\n"
    "---------------------\n"
    "{context_str}\n"
    "---------------------\n"
    "INSTRUCTIONS:\n"
    "1. Use the context above to answer the user's question.\n"
    "2. Be warm, non-judgmental, and concise (2-3 sentences max usually).\n"
    "3. If the context doesn't have the answer, kindly say you don't know but offer general support.\n"
    "4. Do NOT say 'According to the document' or 'The context says'. Just give the advice naturally.\n"
    "5. Use active listening: 'It sounds like...'\n\n"
    "Query: {query_str}\n"
    "MAA's Response:"
)
QA_PROMPT = PromptTemplate(QA_PROMPT_TMPL)

# 2. Refine Prompt (For when answer needs to be improved iteratively)
REFINE_PROMPT_TMPL = (
    "The original query is: {query_str}\n"
    "We have provided an existing answer: {existing_answer}\n"
    "We have the opportunity to refine the existing answer "
    "(only if needed) with some more context below.\n"
    "------------\n"
    "{context_msg}\n"
    "------------\n"
    "Given the new context, refine the original answer to be more helpful and empathetic. "
    "If the context isn't useful, return the original answer.\n"
    "MAA's Refined Response:"
)
REFINE_PROMPT = PromptTemplate(REFINE_PROMPT_TMPL)

try:
    # 1. Setup LLM (Groq - Llama 3)
    # Using Llama 3.1 8b Instant for speed and quality
    groq_api_key = os.getenv("GROQ_API_KEY")
    if not groq_api_key:
        raise ValueError("GROQ_API_KEY not found in .env")
        
    llm = Groq(model="llama-3.1-8b-instant", api_key=groq_api_key)
    
    # 2. Setup Embeddings (Local HuggingFace - Free/Fast)
    embed_model = HuggingFaceEmbedding(model_name="sentence-transformers/all-MiniLM-L6-v2")
    
    # 3. Configure Global Settings
    Settings.llm = llm
    Settings.embed_model = embed_model
    
    # 4. Load Data & Create Index
    if os.path.exists("data"):
        print("📂 Found 'data' folder. Loading documents... (This may take a moment)")
        documents = SimpleDirectoryReader("data").load_data()
        print(f"✅ Loaded {len(documents)} documents. Creating AI Index... (This involves heavy processing)")
        index = VectorStoreIndex.from_documents(documents)
        print("✅ AI Index created successfully!")
        
        # 5. Create Query Engine with Custom Persona Prompts
        query_engine = index.as_query_engine(
            text_qa_template=QA_PROMPT,
            refine_template=REFINE_PROMPT,
            streaming=False
        )
    else:
        print("Data directory not found.")
        query_engine = None
        
except Exception as e:
    print(f"Error setting up Doc Engine: {e}")
    query_engine = None

def query_documents(user_query: str) -> str:
    if not query_engine:
        return "Error: Document engine not ready. Check logs/data folder."
    
    try:
        response = query_engine.query(user_query)
        return str(response)
    except Exception as e:
        return f"I'm having trouble reading my guides right now. ({str(e)})"
