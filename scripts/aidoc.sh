#!/bin/bash

# Initialize library
source "$SHELLTOOLSPATH"/lib/.toolbox

parse_options 0 AIDOC_ \
  "--usage: Read php files and create functional documentation." \
  "--type:t=|default=f:Search for files (f) or directories (d)." \
  "--name:n=:Find files/dirs matching pattern." \
  "--output:o=|default=$HOME/vaults/functional_doc:Find files/dirs matching pattern." \
  "--batch-size:b=|default=3:Find files/dirs matching pattern." \
  "--examples:    ${GREENF}aidoc${RESET} -t f -n \"*.php\" -o ~/docs ./src" \
  "--requirements:    - Set GITHUB_TOKEN environment variable with your GitHub personal access token\n \
        - Your token needs appropriate permissions for GitHub Models API access" \
  -- "$@"
shift "$((TBOPTIND))"

# Configuration
API_ENDPOINT="https://models.github.ai/inference/chat/completions"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"

# Function to check if GitHub API token is available
check_api_token() {
  [[ -z "$GITHUB_TOKEN" ]] && {
    error_exit "GITHUB_TOKEN environment variable is not set.\n" \
      "Please set it with: export GITHUB_TOKEN='your-github-token-here'" 1
  }
  return 0
}

# Function to process a batch of files and generate documentation
process_file_batch() {
  local file_list=("$@")
  local file_contents=""
  local files_description=""
  local output_filename=""

  echo "Processing batch of ${#file_list[@]} files..."

  # Gather contents and build description
  for file in "${file_list[@]}"; do
    # Skip if not a file
    [[ ! -f "$file" ]] && continue

    # Extract relative path from search path for cleaner naming
    local relative_path="${file#"$search_path"/}"

    # Use the first file for naming the output
    [[ -z "$output_filename" ]] && {
      local sanitized
      sanitized=$(sanitize_filename "$relative_path")
      output_filename="${sanitized%.*}_documentation.md"
    }

    # Add file path as a header
    files_description+="## File: $relative_path\n\n"

    # Add truncated file content (e.g., first 100 lines)
    local truncated_content
    truncated_content=$(head -n 100 "$file")
    file_contents+="File: $relative_path\n\n\`\`\`\n$truncated_content\n\`\`\`\n\n"
  done

  # Skip if no valid files
  [[ -z "$files_description" ]] && return 0

  echo "Generating documentation for batch with primary file: ${file_list[0]}"

  # Prepare prompt for context-aware explanation
  local prompt="I'm analyzing a legacy SugarCRM PHP application. Please provide a comprehensive functional explanation of the following code files, focusing on their purpose, functionality, and how they relate to each other. Format your response in Markdown with clear sections for each file and their relationships:\n\n${file_contents}"

  # Send to GitHub Inference API
  local json_payload
  json_payload=$(jq -n \
    --arg model "openai/gpt-4.1" \
    --arg system_content "You are a senior SugarCRM and PHP developer documenting a complex legacy application. Focus on functional explanations including business logic, data flow, and relationships between files. Structure your response as a clear, comprehensive Markdown document that will be useful for developers who need to understand the system. The answer must be in french." \
    --arg user_content "$prompt" \
    --argjson temperature 0.5 \
    '{
    model: $model,
    messages: [
      {role: "system", content: $system_content},
      {role: "user", content: $user_content}
    ],
    temperature: $temperature
  }')

  local response
  response=$(curl -s -X POST "$API_ENDPOINT" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -H "Content-Type: application/json" \
    -d "$json_payload") || {
    echo "API request failed" >&2
    return 1
  }

  # Extract explanation from response
  local explanation
  explanation=$(echo "$response" | jq -r '.choices[0].message.content // "No explanation available"')

  # Create markdown file with formatted content
  local output_path="${AIDOC_OUTPUT}/${output_filename}"

  {
    echo "# Functional Documentation"
    echo ""
    echo "## Files Analyzed"
    echo ""
    for file in "${file_list[@]}"; do
      [[ -f "$file" ]] && echo "- \`${file#"$search_path"/}\`"
    done
    echo ""
    echo "$explanation"
    echo ""
    echo "---"
    echo "Generated on $(date '+%Y-%m-%d %H:%M:%S')"
  } >"$output_path"

  echo "Documentation saved to: $output_path"
  echo "----------------------------------------"
}

# =================
# BEGIN MAIN SCRIPT
# =================

# Parse command line arguments
search_path=""
search_type="f" # Default to files
name_pattern=""
batch_size=$MAX_FILES_PER_BATCH

while [[ $# -gt 0 ]]; do
  case "$1" in
  -t | --type)
    search_type="$2"
    shift 2
    ;;
  -n | --name)
    name_pattern="$2"
    shift 2
    ;;
  -o | --output)
    AIDOC_OUTPUT="$2"
    shift 2
    ;;
  -b | --batch-size)
    batch_size="$2"
    shift 2
    ;;
  -h | --help)
    usage
    ;;
  *)
    if [[ -z "$search_path" ]]; then
      search_path="$1"
    else
      error_usage "Unexpected argument: $1"
    fi
    shift
    ;;
  esac
done

# Validate arguments
[[ -z "$search_path" ]] && {
  error_usage "Search path is required"
}

[[ ! -d "$search_path" ]] && {
  error_exit "'$search_path' is not a valid directory" 2
}

# Check if GitHub token is available
check_api_token

# Ensure output directory exists
ensure_output_dir $AIDOC_OUTPUT

# Construct find command based on arguments
find_cmd="find \"$search_path\" -type"
case "$search_type" in
"d") find_cmd+=" d" ;;
*) find_cmd+=" f" ;;
esac

[[ -n "$name_pattern" ]] && find_cmd+=" -iname \"$name_pattern\""

# Execute find command and collect files
mapfile -t all_files < <(eval "$find_cmd")

# Skip if no files found
[[ "${#all_files[@]}" -eq 0 ]] && {
  error_exit "No files found matching criteria." 1
}

echo "Found ${#all_files[@]} files/directories matching criteria."

# Process files in batches to maintain context
if [[ "$search_type" == "d" ]]; then
  # For directories, just list them
  for dir in "${all_files[@]}"; do
    echo "Directory: $dir (skipping explanation)"
  done
else
  for ((i = 0; i < ${#all_files[@]}; i += batch_size)); do
    # Get batch of files
    batch=("${all_files[@]:i:batch_size}")
    process_file_batch "${batch[@]}"
  done
fi

echo "Processing complete. Documentation saved to ${AIDOC_OUTPUT}"
