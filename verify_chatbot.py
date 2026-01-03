
import os
import sys
import django
from django.conf import settings

# Setup Django environment (minimal)
sys.path.append(r"c:\Users\shahi\OneDrive\Documents\Mental_Health_App_Backend")
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'mental_health_backend.settings')

try:
    django.setup()
    print("Django setup successful.")
except Exception as e:
    print(f"Django setup failed: {e}")
    # We might not be able to full setup without env vars, but we can try importing specific modules
    pass

try:
    from chatbot.core.decision_layer import DecisionLayer, Policy
    print("Imported DecisionLayer.")
    
    # Test Policy Enum
    print(f"Policy.GENERAL: {Policy.GENERAL}")
    
    # Test select_policy for normal mode
    policy = DecisionLayer.select_policy({}, "LOW", "CHECK_IN", mode="normal")
    print(f"Policy for normal mode: {policy}")
    assert policy == "GENERAL"
    
except ImportError as e:
    print(f"ImportError: {e}")
except Exception as e:
    print(f"Error: {e}")

try:
    from chatbot.core.generation_layer import GenerationLayer
    print("Imported GenerationLayer.")
    # We can't easily instantiate GenerationLayer without api key, but the import proves syntax is okay.
except ImportError as e:
    print(f"ImportError GenerationLayer: {e}")

try:
    from chatbot.orchestrator import Orchestrator
    print("Imported Orchestrator.")
except ImportError as e:
    print(f"ImportError Orchestrator: {e}")

print("Verification complete.")
