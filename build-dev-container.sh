#!/bin/bash

# Maintainer: Sohaib

# Define image and container names.
IMAGE_NAME="dev-container-image"
CONTAINER_NAME="dev-container"

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker is not installed or not in your PATH. Please install Docker and try again."
        exit 1
    fi
}

# Function to check if Docker is running
check_docker_running() {
    if ! docker info &> /dev/null; then
        echo "⚠️ Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to display Docker container status with ASCII art and colors
display_container_status() {
    local status_info=$(docker ps -a --filter "name=$CONTAINER_NAME" --format "{{.Names}}: {{.Status}}, Ports: {{.Ports}}")
    local container_id=$(docker ps -aqf "name=$CONTAINER_NAME")
    local container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME 2>/dev/null)
    local image_info=$(docker inspect --format='Image: {{.Config.Image}}' $CONTAINER_NAME 2>/dev/null)
    local uptime_info=$(docker ps --filter "name=$CONTAINER_NAME" --format "Uptime: {{.RunningFor}}")
    local status=$(docker inspect -f '{{.State.Status}}' $CONTAINER_NAME 2>/dev/null)

    echo -e "\e[1;34m==============================================\e[0m"
    echo -e "\e[1;36m      ☁️  Cloud Container Status Dashboard ☁️ \e[0m"
    echo -e "\e[1;34m==============================================\e[0m"
    echo -e "\e[1;33mMaintainer:\e[0m Sohaib"

    cat << 'EOF'
        .--.
     .-(    ).
    (___.__)__)  🚀
EOF

    if [ -n "$status_info" ]; then
        echo -e "📦 \e[1;32m$status_info\e[0m"
        echo -e "🆔 Container ID: \e[1;35m${container_id:-N/A}\e[0m"
        echo -e "🌐 IP Address: \e[1;36m${container_ip:-N/A}\e[0m"
        echo -e "📋 $image_info"
        echo -e "⏱ $uptime_info"
        echo -e "🔍 Status: \e[1;33m${status:-Unknown}\e[0m"
    else
        echo "❌ No container named '$CONTAINER_NAME' found."
    fi
    echo -e "\e[1;34m==============================================\e[0m"
}

# Function to display the menu with arrow key navigation
display_menu() {
    local options=(
        "Build or Rebuild the Container (if needed)"
        "Start the Container (reuse if already exists)"
        "Access the Container Shell (exec into it)"
        "Pause, Unpause, or Stop the Container"
        "Cleanup Docker (Remove Container & Image, Keep Data)"
        "Exit"
    )
    local choice=0

    while true; do
        clear
        display_container_status

        for i in "${!options[@]}"; do
            if [ $i -eq $choice ]; then
                echo -e "\e[1;32m> ${options[$i]}\e[0m"
            else
                echo "  ${options[$i]}"
            fi
        done

        read -rsn1 input

        case "$input" in
            $'\x1b') # Escape character
                read -rsn2 -t 0.1 input
                case "$input" in
                    "[A") # Up arrow
                        ((choice--))
                        ((choice < 0)) && choice=$((${#options[@]} - 1))
                        ;;
                    "[B") # Down arrow
                        ((choice++))
                        ((choice >= ${#options[@]})) && choice=0
                        ;;
                esac
                ;;
            "") # Enter key
                break
                ;;
        esac
    done

    return $choice
}

# Function to check if the image exists
check_existing_image() {
    docker images | grep -q "$IMAGE_NAME"
    return $?
}

# Function to check if the container exists (running or stopped)
check_existing_container() {
    docker ps -a --format "{{.Names}}" | grep -q "$CONTAINER_NAME"
    return $?
}

# Function to check if the container is running
check_running_container() {
    docker ps --format "{{.Names}}" | grep -q "$CONTAINER_NAME"
    return $?
}

# Function to build the image
build_image() {
    echo "🔨 Building Docker image: $IMAGE_NAME..."
    docker build -t $IMAGE_NAME .
    if [ $? -ne 0 ]; then
        echo "❌ Error: Docker image build failed! Check your Dockerfile and try again."
        exit 1
    fi
    echo "✅ Docker image built successfully."
}

# Function to start the container
start_container() {
    check_existing_container
    if [ $? -eq 0 ]; then
        echo "🔄 Container already exists. Starting it..."
        docker start $CONTAINER_NAME
    else
        echo "🚀 Starting a new container..."
        docker compose up -d
    fi

    sleep 2
    check_running_container
    if [ $? -ne 0 ]; then
        echo "❌ Error: Container failed to stay running!"
        docker logs $CONTAINER_NAME 2>/dev/null
        exit 1
    fi
    echo "✅ Container started successfully."
}

# Function to exec into the container with static dashboard
display_static_dashboard_and_exec() {
    check_running_container
    if [ $? -eq 0 ]; then
        clear
        display_container_status
        echo -e "\e[1;36m💻 Opening container shell below...\e[0m"
        echo -e "\e[1;34m----------------------------------------------\e[0m"
        docker exec -it $CONTAINER_NAME bash
    else
        echo "⚠️ Error: The container is not running!"
    fi
}

# Function to pause, unpause, or stop the container
pause_unpause_stop_container() {
    check_running_container
    if [ $? -eq 0 ]; then
        PS3="Select an option: "
        select action in "Pause" "Unpause" "Stop" "Cancel"; do
            case $REPLY in
                1) docker pause $CONTAINER_NAME; echo "⏸ Container paused."; break;;
                2) docker unpause $CONTAINER_NAME; echo "▶️ Container resumed."; break;;
                3) docker stop $CONTAINER_NAME; echo "🛑 Container stopped."; break;;
                4) break;;
                *) echo "❌ Invalid choice.";;
            esac
        done
    else
        echo "⚠️ Error: The container is not running!"
    fi
}

# Function to clean up Docker
cleanup_docker() {
    check_existing_container
    if [ $? -eq 0 ]; then
        read -p "Are you sure you want to remove it? (y/n): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            return
        fi
        docker compose down --rmi all --remove-orphans
        docker system prune -f
    else
        docker system prune -f
    fi
    echo "🧹 Cleanup complete."
}

# Run checks before starting the script
check_docker
check_docker_running

# Main menu loop
while true; do
    display_menu
    choice=$?

    case $choice in
        0)
            check_existing_image
            if [ $? -eq 0 ]; then
                read -p "Rebuild image? (y/n): " rebuild_choice
                [[ "$rebuild_choice" =~ [Yy] ]] && build_image
            else
                build_image
            fi
            start_container
            ;;
        1)
            start_container
            ;;
        2)
            display_static_dashboard_and_exec
            ;;
        3)
            pause_unpause_stop_container
            ;;
        4)
            cleanup_docker
            ;;
        5)
            echo "👋 Exiting script."
            exit 0
            ;;
    esac

done
