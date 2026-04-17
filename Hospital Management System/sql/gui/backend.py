from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import cx_Oracle

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Replace with your actual DB credentials and TNS
conn = cx_Oracle.connect("system", "omthegreat", "localhost/FREE")
cursor = conn.cursor()

@app.get("/patients")
def search_patients(search: str = ""):
    query = """
            SELECT Patient_ID, Name, Phone, Gender FROM Patient
            WHERE LOWER(Name) LIKE :search OR Phone LIKE :search OR TO_CHAR(Patient_ID) = :id
        """
    search_term = f"%{search.lower()}%"
    cursor.execute(query, {'search': search_term, 'id': search})
    rows = cursor.fetchall()
    return [{"id": r[0], "name": r[1], "phone": r[2], "gender": r[3]} for r in rows]
