import os
import re

def process_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Fixing task.fromMap -> TaskModel.fromMap
    content = re.sub(r'\btask\.fromMap', r'TaskModel.fromMap', content)
    
    # Fixing task( -> TaskModel(
    # Only if preceded by return, =, or start of line, or commas
    content = re.sub(r'([=,\[\(]\s*|\breturn\s+)task\(', r'\1TaskModel(', content)

    # Fixing "TaskModel[" -> "task[" inside widgets where we use maps
    content = re.sub(r'\bTaskModel\s*\[', r'task[', content)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

for root, _, files in os.walk('test'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

print("Fixed task( -> TaskModel(")
