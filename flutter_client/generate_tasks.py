import uuid

categories = [
    { "id": "kitchen", "name": "Cocina", "icon": "🍽️", "color": "#E57373" },
    { "id": "laundry", "name": "Ropa", "icon": "👕", "color": "#64B5F6" },
    { "id": "waste", "name": "Residuos", "icon": "🗑️", "color": "#81C784" },
    { "id": "living_room", "name": "Sala / Espacios comunes", "icon": "🧹", "color": "#FFD54F" },
    { "id": "bathroom", "name": "Baño", "icon": "🚿", "color": "#4DD0E1" },
    { "id": "bedroom", "name": "Dormitorio", "icon": "🛏️", "color": "#BA68C8" },
    { "id": "study", "name": "Estudio / Educación", "icon": "📚", "color": "#A1887F" },
    { "id": "shopping", "name": "Compras", "icon": "🛒", "color": "#90A4AE" },
    { "id": "maintenance", "name": "Mantenimiento / Bricolaje", "icon": "🔧", "color": "#7986CB" },
    { "id": "garden", "name": "Jardín", "icon": "🌱", "color": "#AED581" },
    { "id": "kids", "name": "Niños", "icon": "👶", "color": "#FFB74D" },
    { "id": "pets", "name": "Mascotas", "icon": "🐶", "color": "#DCE775" },
    { "id": "vehicle", "name": "Vehículo", "icon": "🚗", "color": "#F06292" }
]

tasks = [
  ("Lavar los platos", 15, "kitchen"),
  ("Guardar / vaciar el lavavajillas", 15, "kitchen"),
  ("Poner la mesa", 10, "kitchen"),
  ("Quitar / levantar la mesa", 10, "kitchen"),
  ("Limpiar la mesa", 15, "kitchen"),
  ("Limpiar la cocina (superficies y mesada)", 25, "kitchen"),
  ("Limpiar el horno", 30, "kitchen"),
  ("Limpiar el microondas", 20, "kitchen"),
  ("Limpiar la heladera", 30, "kitchen"),
  ("Limpiar muebles de cocina", 25, "kitchen"),
  ("Preparar comida sencilla", 15, "kitchen"),
  ("Preparar comida normal", 25, "kitchen"),
  ("Preparar comida compleja", 35, "kitchen"),
  ("Organizar la despensa", 20, "kitchen"),
  ("Descongelar y limpiar el freezer", 30, "kitchen"),
  
  ("Lavar la ropa", 20, "laundry"),
  ("Tender la ropa", 15, "laundry"),
  ("Usar secadora", 10, "laundry"),
  ("Doblar y guardar la ropa", 20, "laundry"),
  ("Planchar la ropa", 25, "laundry"),
  ("Cambiar toallas", 10, "laundry"),
  ("Organizar el placard", 20, "laundry"),
  
  ("Sacar la basura", 15, "waste"),
  ("Separar reciclables", 10, "waste"),
  
  ("Barrer", 15, "living_room"),
  ("Pasar la mopa", 15, "living_room"),
  ("Pasar la aspiradora", 20, "living_room"),
  ("Limpiar el polvo", 20, "living_room"),
  ("Limpiar ventanas", 40, "living_room"),
  ("Orden general del living", 20, "living_room"),
  ("Limpiar sillones", 25, "living_room"),
  
  ("Limpiar el baño completo", 35, "bathroom"),
  ("Limpiar la ducha", 30, "bathroom"),
  ("Limpiar la bañera", 20, "bathroom"),
  ("Reponer papel higiénico y jabón", 5, "bathroom"),
  ("Limpiar espejo", 10, "bathroom"),
  
  ("Barrer el cuarto", 15, "bedroom"),
  ("Tender la cama", 10, "bedroom"),
  ("Cambiar sábanas", 25, "bedroom"),
  ("Ordenar placard", 20, "bedroom"),
  ("Orden general del cuarto", 15, "bedroom"),
  
  ("Hacer la tarea", 25, "study"),
  ("Leer", 45, "study"),
  ("Ordenar el escritorio", 15, "study"),
  
  ("Hacer las compras", 45, "shopping"),
  ("Planificar menú semanal", 20, "shopping"),
  
  ("Pequeño arreglo", 20, "maintenance"),
  ("Arreglo mediano", 30, "maintenance"),
  ("Arreglo grande", 40, "maintenance"),
  
  ("Regar las plantas", 10, "garden"),
  ("Cortar el pasto", 45, "garden"),
  ("Limpiar hojas del patio", 20, "garden"),
  
  ("Bañar a los niños", 25, "kids"),
  ("Dar de comer a un niño", 25, "kids"),
  ("Ayudar con la tarea", 25, "kids"),
  ("Recoger juguetes", 25, "kids"),
  
  ("Limpiar arenero", 15, "pets"),
  ("Pasear al perro", 20, "pets"),
  
  ("Lavar el auto", 35, "vehicle")
]

print("DELETE FROM public.task_templates;\n")
print("DELETE FROM public.categories;\n")

print("INSERT INTO public.categories (id, name, icon, color, sort_order) VALUES")
cat_values = []
for i, c in enumerate(categories):
    cat_values.append(f"('{c['id']}', '{c['name']}', '{c['icon']}', '{c['color']}', {i})")
print(",\n".join(cat_values) + ";\n")

print("INSERT INTO public.task_templates (id, title, category_id, difficulty, xp_reward, coin_reward, icon, is_popular, sort_order) VALUES")
task_values = []
for i, t in enumerate(tasks):
    id_val = str(uuid.uuid4())
    title = t[0].replace("'", "''")
    xp = t[1]
    coin = t[1]
    cat_id = t[2]
    
    # Simple difficulty logic
    if xp < 20:
        difficulty = "Fácil"
    elif xp <= 25:
        difficulty = "Media"
    else:
        difficulty = "Difícil"
        
    icon = None
    for c in categories:
        if c['id'] == cat_id:
            icon = c['icon']
            break
            
    is_popular = 'false'
    
    task_values.append(f"('{id_val}', '{title}', '{cat_id}', '{difficulty}', {xp}, {coin}, '{icon}', {is_popular}, {i})")

print(",\n".join(task_values) + ";")
