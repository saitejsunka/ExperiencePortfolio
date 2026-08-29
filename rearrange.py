with open("frontend/index.html", "r") as f:
    lines = f.readlines()

# Find the start and end of each point
def find_bounds(start_str, end_str=None):
    start_idx = next(i for i, line in enumerate(lines) if start_str in line)
    if end_str:
        end_idx = next(i for i, line in enumerate(lines[start_idx:]) if end_str in line) + start_idx
        return start_idx, end_idx
    return start_idx

# We know the indices roughly based on the previous view_file
p3_start = next(i for i, line in enumerate(lines) if "<!-- Point 3: Data Consistency (Transactional Outbox & CDC) -->" in line)
p4_start = next(i for i, line in enumerate(lines) if "<!-- Point 4: Zero-Downtime Migration (PostgreSQL to NoSQL) -->" in line)
p5_start = next(i for i, line in enumerate(lines) if "<!-- Point 5: Resilience & Fault Tolerance -->" in line)
end_of_p5 = next(i for i, line in enumerate(lines[p5_start:]) if "</article>" in line) + p5_start

block_p3 = lines[p3_start:p4_start]
block_p4 = lines[p4_start:p5_start]
block_p5 = lines[p5_start:end_of_p5+1]

# Now we rewrite them and fix the comments and IDs
def fix_labels(block, old_num, new_num):
    new_block = []
    for line in block:
        if f"<!-- Point {old_num}:" in line:
            line = line.replace(f"<!-- Point {old_num}:", f"<!-- Point {new_num}:")
        if f'id="point-{old_num}"' in line:
            line = line.replace(f'id="point-{old_num}"', f'id="point-{new_num}"')
        new_block.append(line)
    return new_block

block_p5_new = fix_labels(block_p5, 5, 3)
block_p3_new = fix_labels(block_p3, 3, 4)
block_p4_new = fix_labels(block_p4, 4, 5)

# For point 5 (now point 3) we should change margin-bottom: 6rem; to not be there, as it was the last element.
# Actually, point 4 had no margin-bottom. point 5 did.
for i in range(len(block_p5_new)):
    if '<article class="infographic-section"' in block_p5_new[i]:
        block_p5_new[i] = block_p5_new[i].replace('margin-bottom: 6rem;', '')

for i in range(len(block_p4_new)):
    if '<article class="infographic-section"' in block_p4_new[i]:
        # Add margin-bottom: 6rem; if it doesn't have it
        if 'margin-bottom: 6rem;' not in block_p4_new[i]:
            block_p4_new[i] = block_p4_new[i].replace('margin-top: 6rem;">', 'margin-top: 6rem; margin-bottom: 6rem;">')

new_lines = lines[:p3_start] + block_p5_new + block_p3_new + block_p4_new + lines[end_of_p5+1:]

with open("frontend/index.html", "w") as f:
    f.writelines(new_lines)
