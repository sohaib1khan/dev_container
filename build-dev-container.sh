#!/bin/bash

# Define image and container names
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

# Function to display the menu
display_menu() {
    echo "=============================================="
    echo " Dev Container Manager"
    echo "=============================================="
    echo "1) Build or Rebuild the Container (if needed)"
    echo "2) Start the Container (reuse if already exists)"
    echo "3) Access the Container Shell (exec into it)"
    echo "4) Pause, Unpause, or Stop the Container"
    echo "5) Cleanup Docker (Remove Container & Image, Keep Data)"
    echo "6) Exit"
    echo "=============================================="
    read -p "Select an option: " choice
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

    # Wait for 2 seconds and check if the container is still running
    sleep 2
    check_running_container
    if [ $? -ne 0 ]; then
        echo "❌ Error: Container failed to stay running!"
        echo "📜 Checking container logs for errors..."
        docker logs $CONTAINER_NAME 2>/dev/null
        echo "🔍 Possible issues:"
        echo "  - The container may have crashed due to a missing dependency."
        echo "  - Check volume mounts to ensure necessary files exist."
        echo "  - Run 'docker compose up' manually to see more detailed errors."
        exit 1
    fi

    echo "✅ Container started successfully."
}

# Function to exec into the container
exec_into_container() {
    check_running_container
    if [ $? -eq 0 ]; then
        echo "💻 Accessing the container shell..."
        docker exec -it $CONTAINER_NAME bash
    else
        echo "⚠️ Error: The container is not running!"
        echo "📜 Checking logs..."
        docker logs $CONTAINER_NAME 2>/dev/null
        echo "💡 Try running: docker start $CONTAINER_NAME"
    fi
}

# Function to pause, unpause, or stop the container
pause_unpause_stop_container() {
    check_running_container
    if [ $? -eq 0 ]; then
        echo "🔧 What would you like to do?"
        echo "1) Pause the container"
        echo "2) Unpause the container"
        echo "3) Stop the container"
        read -p "Select an option (1/2/3): " action
        case $action in
            1)
                docker pause $CONTAINER_NAME
                echo "⏸ Container paused."
                ;;
            2)
                docker unpause $CONTAINER_NAME
                echo "▶️ Container resumed."
                ;;
            3)
                docker stop $CONTAINER_NAME
                echo "🛑 Container stopped."
                ;;
            *)
                echo "❌ Invalid choice. Please select 1, 2, or 3."
                ;;
        esac
    else
        echo "⚠️ Error: The container is not running!"
        echo "💡 Try running: docker start $CONTAINER_NAME"
    fi
}

# Function to clean up Docker (remove containers, images, and networks but keep volumes)
cleanup_docker() {
    check_existing_container
    if [ $? -eq 0 ]; then
        echo "⚠️ A container is currently running."
        read -p "Are you sure you want to remove it? (y/n): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo "🛑 Cleanup aborted."
            return
        fi
        docker compose down --rmi all --remove-orphans
        docker system prune -f
        echo "🧹 Cleanup complete. Mounted data remains intact."
    else
        echo "🧹 No existing container found. Cleaning up Docker resources..."
        docker system prune -f
    fi
}

# Run checks before starting the script
check_docker
check_docker_running

# Main menu loop
while true; do
    display_menu
    case $choice in
        1)
            check_existing_image
            if [ $? -eq 0 ]; then
                echo "⚙️ Existing image found. Do you want to rebuild it?"
                read -p "(y/n): " rebuild_choice
                if [[ "$rebuild_choice" == "y" || "$rebuild_choice" == "Y" ]]; then
                    build_image
                else
                    echo "✅ Using existing image."
                fi
            else
                build_image
            fi
            start_container
            ;;
        2)
            start_container
            ;;
        3)
            exec_into_container
            ;;
        4)
            pause_unpause_stop_container
            ;;
        5)
            cleanup_docker
            ;;
        6)
            echo "👋 Exiting script."
            exit 0
            ;;
        *)
            echo "❌ Invalid choice. Please select a valid option."
            ;;
    esac
done
