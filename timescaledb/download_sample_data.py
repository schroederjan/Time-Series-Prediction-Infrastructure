#this script will download sample data that can be used for the project for testing (SIZE = 1.7G)

import tarfile
import requests    

url = "https://timescaledata.blob.core.windows.net/datasets/nyc_data.tar.gz"
target_path = 'sample_data.tar.gz'

print("Downloading...")
print(url)    
print("as", target_path)

response = requests.get(url, stream=True)
if response.status_code == 200:
    with open(target_path, 'wb') as f:
        f.write(response.raw.read())
        tar = tarfile.open(target_path, "r:gz")
        tar.extract(member="nyc_data_rides.csv")
        tar.close()              

