import os
import datetime

def read_file_content(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        return f"Error reading {filepath}: {e}"

def get_directory_structure(rootdir, max_depth=2):
    structure = ""
    rootdir = rootdir.rstrip(os.sep)
    start = rootdir.rfind(os.sep) + 1
    for root, dirs, files in os.walk(rootdir):
        level = root.count(os.sep) - rootdir.count(os.sep)
        if level > max_depth:
            continue
        indent = '  ' * level
        structure += f"{indent}{os.path.basename(root)}/\n"
        subindent = '  ' * (level + 1)
        # Limit files shown to avoid huge output
        file_count = 0
        for f in files:
            if f.startswith('.'): continue
            if file_count < 10:
                structure += f"{subindent}{f}\n"
            file_count += 1
        if file_count >= 10:
            structure += f"{subindent}... ({file_count - 10} more files)\n"
            
    return structure

def generate_context():
    output_path = "docs/aistudio/STARLIST_GEM_KNOWLEDGE.md"
    base_dir = os.getcwd()
    
    # Define source files
    sources = [
        {
            "title": "1. Project Overview",
            "path": "docs/overview/STARLIST_OVERVIEW.md",
            "description": "Vision, Mission, and Core Features"
        },
        {
            "title": "2. Development Rules & Guidelines",
            "path": "docs/development/starlist-rules.md",
            "description": "Coding standards, commit rules, and best practices"
        },
        {
            "title": "3. Current Tasks & Status",
            "path": "docs/planning/Task.md",
            "description": "Active tasks and roadmap"
        },
        {
            "title": "4. Technical Architecture & Context",
            "path": "docs/aistudio/starlist_context.md",
            "description": "Technical details, models, and API signatures"
        }
    ]

    content = []
    content.append(f"# STARLIST Project Knowledge Base for Gemini Gems")
    content.append(f"Generated on: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    
    content.append("> This document is a consolidated knowledge base for the Starlist project. Use this as the primary source of truth for the Starlist Custom Gem.\n")

    # Append File Contents
    for source in sources:
        full_path = os.path.join(base_dir, source['path'])
        content.append(f"## {source['title']}")
        content.append(f"**Source:** `{source['path']}`")
        content.append(f"**Description:** {source['description']}\n")
        content.append("```markdown")
        content.append(read_file_content(full_path))
        content.append("```\n")
        content.append("---\n")

    # Append Directory Structure
    content.append("## 5. Project Directory Structure")
    content.append("```")
    # Simple custom walker or just listing key dirs
    # listing root, lib, server, supabase, docs
    structure_dirs = ['.', 'lib', 'server', 'supabase', 'docs']
    
    # Using a simplified listing to ensure it works across environments
    # Actually, let's just use a hardcoded logic for key directories to be safe and clean
    for d in structure_dirs:
        target = os.path.join(base_dir, d)
        if os.path.exists(target):
             content.append(f"\n--- Directory: {d} ---")
             # content.append(get_directory_structure(target, max_depth=2)) 
             # Let's use list_dir style for better reliability if possible, but simple walk is fine
             for root, dirs, files in os.walk(target):
                level = root.replace(target, '').count(os.sep)
                if level > 1: continue
                indent = '  ' * level
                dirname = os.path.basename(root)
                if dirname.startswith('.') or dirname == '__pycache__' or dirname == 'node_modules': continue
                content.append(f"{indent}{dirname}/")
                for f in files:
                    if not f.startswith('.'):
                        content.append(f"{indent}  {f}")
    
    content.append("```\n")

    # Write output
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(content))
    
    print(f"Successfully generated knowledge base at: {output_path}")

if __name__ == "__main__":
    generate_context()

