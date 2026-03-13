import json
import os
import sys

TEAM_DIR = ".antigravity/team"

def init_team():
    """Inicializa la infraestructura del equipo."""
    os.makedirs(f"{TEAM_DIR}/mailbox", exist_ok=True)
    os.makedirs(f"{TEAM_DIR}/locks", exist_ok=True)
    tasks_path = f"{TEAM_DIR}/tasks.json"
    if not os.path.exists(tasks_path):
        with open(tasks_path, 'w') as f:
            json.dump({"tasks": [], "members": []}, f, indent=2)
    if not os.path.exists(f"{TEAM_DIR}/broadcast.msg"):
        with open(f"{TEAM_DIR}/broadcast.msg", 'w') as f: f.write("")
    print("[OK] Infraestructura 'Equipo Alejabot' lista.")

def assign_task(title, assigned_to, deps=[]):
    """Asigna una nueva tarea con soporte para dependencias."""
    path = f"{TEAM_DIR}/tasks.json"
    if not os.path.exists(path):
        init_team()
    with open(path, 'r+') as f:
        data = json.load(f)
        task = {
            "id": len(data["tasks"]) + 1,
            "title": title,
            "status": "PENDING",
            "plan_approved": False,
            "assigned_to": assigned_to,
            "dependencies": deps
        }
        data["tasks"].append(task)
        f.seek(0)
        json.dump(data, f, indent=2)
        f.truncate()
    print(f"[OK] Tarea {task['id']} ({title}) asignada a {assigned_to}.")

def update_task_status(task_id, status, plan_approved=None):
    path = f"{TEAM_DIR}/tasks.json"
    with open(path, 'r+') as f:
        data = json.load(f)
        for task in data["tasks"]:
            if task["id"] == task_id:
                task["status"] = status
                if plan_approved is not None:
                    task["plan_approved"] = plan_approved
                break
        f.seek(0)
        json.dump(data, f, indent=2)
        f.truncate()

def broadcast(sender, text):
    """Envía un mensaje a todos los miembros del equipo."""
    msg = {"de": sender, "tipo": "BROADCAST", "mensaje": text}
    with open(f"{TEAM_DIR}/broadcast.msg", 'a') as f:
        f.write(json.dumps(msg) + "\n")
    print(f"[OK] Mensaje global enviado por {sender}.")

def send_message(sender, receiver, text):
    """Envía un mensaje al buzón de un agente específico."""
    msg = {"de": sender, "mensaje": text}
    with open(f"{TEAM_DIR}/mailbox/{receiver}.msg", 'a') as f:
        f.write(json.dumps(msg) + "\n")
    print(f"[OK] Mensaje enviado a {receiver}.")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "init": init_team()
        elif cmd == "assign":
            title = sys.argv[2]
            assigned_to = sys.argv[3]
            deps = json.loads(sys.argv[4]) if len(sys.argv) > 4 else []
            assign_task(title, assigned_to, deps)
        elif cmd == "status":
            task_id = int(sys.argv[2])
            status = sys.argv[3]
            plan_approved = sys.argv[4].lower() == 'true' if len(sys.argv) > 4 else None
            update_task_status(task_id, status, plan_approved)
