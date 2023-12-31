import sys
import re
import csv
import os

# Read the project name, commit, and granularity from the command line
project = sys.argv[1]
commit = sys.argv[2]
granularity = sys.argv[3]
root_path = sys.argv[4]

# Define the file paths
log_path = f"{root_path}/results/{project}/{commit}/{granularity}.txt"
output_path = f"{root_path}/output_tables/result_table_{granularity}.csv"

# Define the patterns to match
info_pattern = "INFO: (.+: \d+)"
affected_specs_pattern = r"\[INFO\] AffectedSpecs: (\d+)"
time_pattern = r"\[INFO\] Total time:\s+([\d.:]+\s\w+)"
emop_time_pattern = r"\[INFO\] \[eMOP Timer\] (.+) takes (\d+) ms"

# Define headers for different granularities
headers = {
    "hrps": ["Project", "Commit", "Type", "ImpactedMethods", "ChangedMethods", "NewMethods", "ChangedClassesWithChangedHeaders", "ChangedClassesWithoutChangedHeaders", "NewClasses", "DeletedClasses", "AffectedTestClasses", "OldClasses", "ImpactedClasses", "AffectedSpecs", "Total time"],
    "mrps": ["Project", "Commit", "Type", "ImpactedMethods", "ChangedMethods", "NewMethods", "ChangedClasses", "NewClasses", "AffectedTestClasses", "OldClasses", "AffectedSpecs", "Total time"],
    "rps": ["Project", "Commit", "Type", "ChangedClasses", "ImpactedClasses", "AffectedSpecs", "Total time"],
    "test": ["Project", "Commit", "Type", "Total time"],
}

# Check if granularity is valid
if granularity not in headers:
    print(f"Invalid granularity: {granularity}")
    sys.exit(1)

# Get the appropriate header for the current granularity
csv_header = headers[granularity]

# Process the log file
with open(log_path, 'r') as file:
    data = file.read()
    
    # Search for INFO lines
    info_matches = re.findall(info_pattern, data)
    info_dict = {match.split(": ")[0]: match.split(": ")[1] for match in info_matches}
    # info_dict["Total"]
    # Prepare row data in the order defined by the header
    row_data = [project, commit, granularity]
    for header in csv_header[3:-2]:  # Exclude Project, Commit, Type, AffectedSpecs & Total time
        row_data.append(info_dict.get(header, ""))
    
    # Search for AffectedSpecs line
    affected_specs_match = re.search(affected_specs_pattern, data)
    if affected_specs_match:
        row_data.append(affected_specs_match.group(1))
    else:
        row_data.append("0")
    
    # Search for TOTAL TIME line
    time_match = re.search(time_pattern, data)
    if time_match:
        row_data.append(time_match.group(1))

    # Search for time taken line
    emop_time_matches = re.findall(emop_time_pattern, data)
    if emop_time_matches:
        # print(emop_time_matches)
        analysis_time = 0
        for emop_time_match in emop_time_matches:
            head = emop_time_match[0]
            time = emop_time_match[1]
            if head not in csv_header:
                csv_header.append(head + " (ms)")
            row_data.append(time)
            analysis_time += int(time)
        csv_header.append("Analysis time (s)")
        row_data.append(analysis_time/1000)
    
    # Write results to CSV file
    with open(output_path, mode='a', newline='') as result_table:
        writer = csv.writer(result_table)
        # Write the header if it is the first time otherwise just append the row
        if not os.path.isfile(output_path) or os.stat(output_path).st_size == 0:
            writer.writerow(csv_header)
        writer.writerow(row_data)
