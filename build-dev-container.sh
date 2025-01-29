#!/bin/bash

# Define image and container names
IMAGE_NAME="dev-container-image"
CONTAINER_NAME="dev-container"

# Function to display the menu
display_menu() {
    echo "=============================================="
    echo " Dev Container Manager"
    echo "=============================================="
    echo "1) Build or Rebuild the Container"
    echo "2) Start the Container (Use Existing Image)"
    echo "3) Exec into the Running Container"
    echo "4) Cleanup Docker (Keep Mounted Data)"
    echo "5) Exit"
    echo "=============================================="
    read -p "Select an option: " choice
}

# Function to check if the image exists
check_existing_image() {
    docker images | grep -q "$IMAGE_NAME"
    return $?
}

# Function to check if the container is running
check_running_container() {
    docker ps | grep -q "$CONTAINER_NAME"
    return $?
}

# Function to build the image
build_image() {
    echo "Building Docker image: $IMAGE_NAME..."
    docker build -t $IMAGE_NAME .
    if [ $? -ne 0 ]; then
        echo "Error: Docker image build failed!"
        exit 1
    fi
    echo "Docker image built successfully."
}

# Function to start the container
start_container() {
    echo "Starting the container using docker compose..."
    docker compose up -d
    if [ $? -ne 0 ]; then
        echo "Error: Failed to start the container!"
        exit 1
    fi
    echo "Container started successfully."
}

# Function to exec into the container
exec_into_container() {
    check_running_container
    if [ $? -eq 0 ]; then
        echo "Accessing the container shell..."
        docker exec -it $CONTAINER_NAME bash
    else
        echo "Error: The container is not running!"
    fi
}

# Function to clean up Docker (remove containers, images, and networks but keep volumes)
cleanup_docker() {
    echo "Cleaning up Docker (containers, images, and networks)..."
    docker compose down --rmi all --remove-orphans
    docker system prune -f
    echo "Cleanup complete. Mounted data remains intact."
}

# Main menu loop
while true; do
    display_menu
    case $choice in
        1)
            check_existing_image
            if [ $? -eq 0 ]; then
                echo "Existing image found. Do you want to rebuild it?"
                read -p "(y/n): " rebuild_choice
                if [[ "$rebuild_choice" == "y" || "$rebuild_choice" == "Y" ]]; then
                    build_image
                else
                    echo "Using existing image."
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
            cleanup_docker
            ;;
        5)
            echo "Exiting script."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            ;;
    esac
done
