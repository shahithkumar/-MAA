import requests
import os

assets_dir = r"c:\Users\shahi\OneDrive\Documents\Mental_Health_App_Backend\mental_health_app_frontend\assets\images"
images = [
    ("mandala_1.png", "https://cdn.pixabay.com/photo/2016/06/28/05/26/mandala-1483863_1280.png"),
    ("mandala_floral.png", "https://cdn.pixabay.com/photo/2018/02/16/01/59/mandala-3156889_1280.png"),
    ("mandala_geometric.png", "https://cdn.pixabay.com/photo/2016/09/26/16/50/mandala-1696409_1280.png"),
    ("mandala_abstract.png", "https://cdn.pixabay.com/photo/2016/09/26/16/50/mandala-1696403_1280.png"),
    ("mandala_zen.png", "https://cdn.pixabay.com/photo/2013/07/13/11/49/mandala-158744_1280.png"),
]

headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

for name, url in images:
    path = os.path.join(assets_dir, name)
    print(f"Downloading {name}...")
    try:
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            with open(path, "wb") as f:
                f.write(response.content)
            print(f"Saved to {path}")
        else:
            print(f"Failed to download {url}: Status {response.status_code}")
    except Exception as e:
        print(f"Error downloading {url}: {e}")
