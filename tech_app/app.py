from flask import Flask, request
import sqlite3
import os
import subprocess

app = Flask(__name__)

# Hardcoded secret (intencional para testes de detecção de secret scanning)
API_KEY = "AKIA_TEST_HARDCODED_PLACEHOLDER"

DB = "test.db"

def init_db():
    conn = sqlite3.connect(DB)
    cursor = conn.cursor()
    cursor.execute("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT, email TEXT)")
    cursor.execute("INSERT INTO users (name, email) VALUES ('alice', 'alice@example.com')")
    conn.commit()
    conn.close()

@app.route("/search")
def search():
    # SQL injection vulnerability: concatenating user input into query
    q = request.args.get("q", "")
    conn = sqlite3.connect(DB)
    cur = conn.cursor()
    query = "SELECT * FROM users WHERE name LIKE '%" + q + "%';"
    cur.execute(query)
    rows = cur.fetchall()
    conn.close()
    return {"results": rows}

@app.route("/run")
def run_cmd():
    # Command injection: passing user input directly to shell
    cmd = request.args.get("cmd", "echo hello")
    # WARNING: this is intentionally insecure
    output = subprocess.check_output(cmd, shell=True)
    return {"output": output.decode()}

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000)
