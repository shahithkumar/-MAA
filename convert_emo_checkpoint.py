import torch
import torch.nn as nn
from transformers import RobertaModel

# ====== REQUIRED TRAINING CLASSES (so checkpoint can load) ======

class EmoBERTaSingle(nn.Module):
    def __init__(self, num_labels=7):
        super().__init__()
        self.roberta = RobertaModel.from_pretrained('roberta-base')
        self.mha = nn.MultiheadAttention(embed_dim=768, num_heads=8, dropout=0.1, batch_first=True)
        self.fc = nn.Linear(768, num_labels)
        self.dropout = nn.Dropout(0.1)

    def forward(self, input_ids, attention_mask):
        outputs = self.roberta(input_ids, attention_mask=attention_mask)
        H = outputs.last_hidden_state
        attn_out, _ = self.mha(H, H, H, key_padding_mask=~attention_mask.bool())
        pooled = attn_out.mean(dim=1)
        pooled = self.dropout(pooled)
        return self.fc(pooled)

class DES(nn.Module):
    def __init__(self, models, top_k=2):
        super().__init__()
        self.models = nn.ModuleList(models)
        self.top_k = top_k

    def forward(self, *args, **kwargs):
        pass  # not used for conversion

# ====== PATHS ======

OLD_PATH = r"C:\Users\shahi\OneDrive\Documents\Mental_Health_App_Backend\models\emo_berta_final_permanent.pth"
NEW_PATH = r"C:\Users\shahi\OneDrive\Documents\Mental_Health_App_Backend\models\emo_berta_state_dict_clean.pth"

print("🔍 Loading checkpoint...")

# Must use weights_only=False
checkpoint = torch.load(OLD_PATH, map_location="cpu", weights_only=False)

print("✅ Loaded successfully! Extracting weights...")

# Extract weights from loaded model
state_dict = checkpoint.state_dict()

torch.save(state_dict, NEW_PATH)

print("\n🎉 CONVERSION DONE!")
print(f"➡ Saved clean file here:\n{NEW_PATH}")
print("\n✔ This file can now be loaded in Django without errors.")
