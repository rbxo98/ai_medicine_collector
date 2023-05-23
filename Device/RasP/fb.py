import pandas as pd
import requests
import firebase_admin
import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
firebase_db = firestore.client()
data=firebase_db.collection('MachineData').get()
print(data)
