import torch
from torch.serialization import add_safe_globals

# Register missing class name so torch.load works
class DES:
    pass

add_safe_globals([DES])

OLD_PATH = r"C:\Users\shahi\OneDrive\Documents\Mental_Health_App_Backend\models\emo_berta_final_permanent.pth"

print("\nLoading checkpoint...")
checkpoint = torch.load(OLD_PATH, map_location="cpu", weights_only=False)

print("\nTYPE:", type(checkpoint))
print("\nATTRIBUTES:\n")

for attr in dir(checkpoint):
    if not attr.startswith("_"):
        value = getattr(checkpoint, attr)
        print(f"{attr}  -->  {type(value)}")
