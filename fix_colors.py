import os
import re

def replace_in_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace withValues(alpha: 0.5) with withOpacity(0.5)
    # Also handles withValues(alpha: variable)
    new_content = re.sub(r'\.withValues\(alpha:\s*([^)]+)\)', r'.withOpacity(\1)', content)
    
    if new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Fixed: {file_path}")

def main():
    root_dir = r'c:\Users\cagat\.gemini\antigravity\scratch\flux\lib'
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.dart'):
                replace_in_file(os.path.join(root, file))

if __name__ == '__main__':
    main()
