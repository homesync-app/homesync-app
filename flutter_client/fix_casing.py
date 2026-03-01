import os
import re

def process_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # We want to replace "TaskModel" back to "task" when it's clearly a variable name.
    # A type name usually appears as:
    # TaskModel <var_name>
    # <TaskModel>
    # List<TaskModel>
    # Future<TaskModel>
    # class TaskModel
    # new TaskModel(
    # TaskModel(
    # on TaskModel
    # is TaskModel
    # as TaskModel
    # TaskModel.fromMap
    # etc.

    # When it was a variable `task`, it would now be:
    # TaskModel.id -> task.id
    # TaskModel.title -> task.title
    # (TaskModel) -> (task)
    # {TaskModel: -> {task:
    # TaskModel, -> task,
    # TaskModel; -> task;
    # final TaskModel = -> final task =
    # TaskModel = -> task =
    # TaskModel == -> task ==
    # TaskModel != -> task !=

    def replace_var(match):
        return match.group(0).replace("TaskModel", "task")

    # Replace variable usages
    # 1. TaskModel.something
    content = re.sub(r'\bTaskModel\.', r'task.', content)
    
    # 2. task comma/paren/bracket
    content = re.sub(r'\bTaskModel\b([,)\];}])', r'task\1', content)

    # 3. assignment / operators
    content = re.sub(r'\bTaskModel\b\s*([!=+\-*/:])', r'task \1', content)

    # 4. lambda parameters or parameters: (TaskModel)
    content = re.sub(r'\(\s*\bTaskModel\b\s*\)', r'(task)', content)
    
    # 5. string interpolation $TaskModel
    content = re.sub(r'\$TaskModel\b', r'$task', content)
    
    # 6. final TaskModel =
    content = re.sub(r'\bfinal\s+TaskModel\s*=', r'final task =', content)
    
    # 7. for (final TaskModel in ...)
    content = re.sub(r'\bfinal\s+TaskModel\s+in\b', r'final task in', content)
    
    # 8. Function(TaskModel) type signatures might have been Function(Task), we want them to remain TaskModel
    # But what if it was `(task) {` ? We caught that with (TaskModel) -> (task) ? No, `(TaskModel) {` doesn't match `\(\s*\bTaskModel\b\s*\)`. Wait it does!
    
    # 9. In map loops: `TaskModel in ...`
    content = re.sub(r'\bTaskModel\s+in\b', r'task in', content)

    # 10. `if (TaskModel ...)`
    content = re.sub(r'if\s*\(\s*TaskModel\b', r'if (task', content)
    
    # 11. `... = TaskModel` -> `... = task`
    content = re.sub(r'=\s*TaskModel\b(?![\(\.])', r'= task', content)

    # Let's write it back
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

print("Fixed TaskModel casings.")
