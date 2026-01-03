from chatbot.doc_engine import query_documents

class RAGLayer:
    @staticmethod
    def retrieve(policy: str, query: str) -> str:
        """
        Layer 6: RAG Knowledge Injection.
        Fetches context ONLY if Policy requires it.
        """
        # Rules:
        # - Supportive/Validation/Crisis: NO RAG (rely on empathy/safety protocols).
        # - CBT/Grounding/Psychoeducation: YES RAG (fetch technique).
        
        if policy in ["CRISIS"]:
            return "" # No context needed for immediate crisis protocols
            
        # For CBT/Grounding/Psychoed, we fetch relevant info
        # We append the policy to the query to guide the retrieval (heuristic)
        # e.g. "CBT technique for self-blame"
        enhanced_query = f"{policy} advice for: {query}"
        
        try:
            context = query_documents(enhanced_query)
            # Filter error messages or "Empty Response"
            if "Error" in context or "Empty Response" in context:
                return ""
            return context
        except:
            return ""
