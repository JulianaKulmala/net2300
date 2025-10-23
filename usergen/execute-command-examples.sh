#!/bin/bash

################################################################################
# Execute Command from String - Examples
################################################################################

echo "========================================"
echo "Method 1: Using eval"
echo "========================================"

# Read command as string
command_string="ls -la /tmp"
echo "Command string: $command_string"

# Execute using eval
eval "$command_string"

echo ""
echo "========================================"
echo "Method 2: Using bash -c"
echo "========================================"

command_string="echo 'Hello World' && date"
echo "Command string: $command_string"

# Execute using bash -c
bash -c "$command_string"

echo ""
echo "========================================"
echo "Method 3: Direct execution with $(...)"
echo "========================================"

command_string="whoami"
echo "Command string: $command_string"

# Execute and capture output
result=$($command_string)
echo "Result: $result"

echo ""
echo "========================================"
echo "Method 4: Read from user input"
echo "========================================"

read -p "Enter a command to execute: " user_command
echo "Executing: $user_command"
eval "$user_command"

echo ""
echo "========================================"
echo "Method 5: Read from file and execute"
echo "========================================"

# Create sample command file
cat > /tmp/commands.txt << 'EOF'
echo "Command 1: Show date"
date
echo "Command 2: Show current user"
whoami
echo "Command 3: List files"
ls -lh ~
EOF

# Read and execute each line
while IFS= read -r cmd; do
    echo "Executing: $cmd"
    eval "$cmd"
    echo "---"
done < /tmp/commands.txt

echo ""
echo "========================================"
echo "Method 6: Read from database simulation"
echo "========================================"

# Simulate database query result
database_commands=(
    "echo 'Task 1: System info'"
    "uname -a"
    "echo 'Task 2: Disk usage'"
    "df -h | head -5"
)

# Execute each command from array
for cmd in "${database_commands[@]}"; do
    echo "Executing: $cmd"
    eval "$cmd"
    echo "---"
done

echo ""
echo "========================================"
echo "Method 7: Safe execution with validation"
echo "========================================"

execute_safe_command() {
    local cmd="$1"
    
    # List of allowed commands (whitelist)
    local allowed_commands=("ls" "date" "whoami" "pwd" "echo")
    
    # Extract first word (command name)
    local cmd_name=$(echo "$cmd" | awk '{print $1}')
    
    # Check if command is in whitelist
    if [[ " ${allowed_commands[@]} " =~ " ${cmd_name} " ]]; then
        echo "✓ Executing allowed command: $cmd"
        eval "$cmd"
    else
        echo "✗ Command not allowed: $cmd_name"
        return 1
    fi
}

# Test safe execution
execute_safe_command "ls -la"
execute_safe_command "date"
execute_safe_command "rm -rf /"  # This will be blocked

echo ""
echo "========================================"
echo "Method 8: Execute with error handling"
echo "========================================"

execute_with_error_handling() {
    local cmd="$1"
    
    echo "Executing: $cmd"
    
    # Execute and capture exit code
    if eval "$cmd"; then
        echo "✓ Command succeeded"
        return 0
    else
        local exit_code=$?
        echo "✗ Command failed with exit code: $exit_code"
        return $exit_code
    fi
}

# Test error handling
execute_with_error_handling "ls /tmp"
execute_with_error_handling "ls /nonexistent_directory"

echo ""
echo "========================================"
echo "Method 9: Interactive command executor"
echo "========================================"

run_interactive() {
    echo "Interactive Command Executor (type 'exit' to quit)"
    
    while true; do
        read -p "$ " cmd
        
        # Exit condition
        if [ "$cmd" = "exit" ] || [ "$cmd" = "quit" ]; then
            echo "Exiting..."
            break
        fi
        
        # Skip empty commands
        if [ -z "$cmd" ]; then
            continue
        fi
        
        # Execute command
        eval "$cmd"
    done
}

# Uncomment to run interactive mode
# run_interactive

echo ""
echo "========================================"
echo "Method 10: Execute commands from variable"
echo "========================================"

# Multiple commands in variable
COMMANDS="
echo 'Starting batch execution...'
date
echo 'Current user:'
whoami
echo 'Current directory:'
pwd
echo 'Batch execution complete'
"

# Execute all commands
eval "$COMMANDS"

echo ""
echo "Script completed!"
