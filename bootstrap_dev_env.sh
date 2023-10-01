#!/bin/bash

# Script Name: bootstrap_dev_env.sh
# Description: Setup script for a development environment.

# Define an array with package names for dependencies
dependencies=("autoconf" "m4" "patch" "build-essential" "curl" "git" "rustc" "libssl-dev" "libreadline-dev" "libyaml-dev" "libreadline6-dev" "zlib1g-dev" "libgmp-dev" "libncurses5-dev" "libwxgtk3.2-dev" "libwxgtk-webview3.2-dev" "libgl1-mesa-dev" "libglu1-mesa-dev" "libpng-dev" "libssh-dev" "unixodbc-dev" "xsltproc" "fop" "libxml2-utils" "libncurses-dev" "openjdk-17-jdk" "libffi-dev" "libgdbm6" "libgdbm-dev" "libdb-dev" "uuid-dev" "unzip" "exa" "zsh" "zsh-antigen" "wget" "lsb-release" "gpg")

# Function to display a progress message
progress_message() {
    echo "[ ] $1"
}

# Function to display a progress completion message
progress_done() {
    echo "[✔] $1"
}

# Function to check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to update the packages list
update_packages_list() {
    progress_message "Updating available packages list"
    $SUDO apt update -y > /dev/null 2>&1 || { echo "Failed to update packages list"; exit 1; }
    progress_done "Updated available packages list"
}

# Function to upgrade installed packages
upgrade_packages() {
    progress_message "Upgrading installed packages"
    $SUDO apt upgrade -y > /dev/null 2>&1 || { echo "Failed to upgrade installed packages"; exit 1; }
    progress_done "Upgraded installed packages"
}

# Function to install packages from the array
install_dependency_packages() {
    local packages=("$@")  # Pass all arguments to the function as an array
    local package_list="${packages[*]}"  # Convert the array into a single string

    progress_message "Installing packages: $package_list"
    $SUDO apt install -y $package_list > /dev/null 2>&1 || { echo "Failed to install packages"; exit 1; }
    progress_done "Installed packages: $package_list"
}

# Function to install Heroku CLI
install_heroku_cli() {
    progress_message "Installing Heroku CLI"
    curl https://cli-assets.heroku.com/install.sh | sh > /dev/null 2>&1 || { echo "Failed to install Heroku CLI"; exit 1; }
    progress_done "Installed Heroku CLI"
}

# Function to install AWS CLI
install_aws_cli() {
    progress_message "Installing AWS CLI"

    {
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        $SUDO ./aws/install
        rm -R aws* # Remove temporary installation folder
    } > /dev/null 2>&1 || { echo "Failed to install AWS CLI"; exit 1; }

    progress_done "Installed AWS CLI"
}

# Function to install asdf plugin
install_asdf() {
    if [ -d "$HOME/.asdf" ]; then
        echo "asdf is already installed."
        return
    fi

    progress_message "Installing asdf"

    {
        git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1

        echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
        echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
        source ~/.bashrc

        echo '. "$HOME/.asdf/asdf.sh"' >> ~/.zshrc
        echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.zshrc
        source ~/.zshrc
    } > /dev/null 2>&1 || { echo "Failed to install asdf"; exit 1; }

    progress_done "Installed asdf"
}

# Function to install asdf Ruby plugin and latest Ruby version (make it global)
install_asdf_ruby_plugin_and_latest_ruby() {
    progress_message "Installing asdf Ruby plugin and latest Ruby"

    {
        asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
        latest_ruby_version=$(asdf latest ruby)
        asdf install ruby "$latest_ruby_version"
        asdf global ruby "$latest_ruby_version"
    } > /dev/null 2>&1 || { echo "Failed to install asdf Ruby plugin"; exit 1; }

    progress_done "Installed asdf Ruby plugin and Ruby $latest_ruby_version"
}

# Function to install PostgreSQL
install_postgresql() {
    progress_message "Installing PostgreSQL"

    {
        $SUDO sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
        wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | $SUDO apt-key add - > /dev/null 2>&1
        $SUDO apt update
        $SUDO apt -y install postgresql > /dev/null 2>&1
    } > /dev/null 2>&1 || { echo "Failed to install PostgreSQL"; exit 1; }

    progress_done "Installed PostgreSQL"
}

# Function to install Redis Server
install_redis() {
    progress_message "Installing Redis"

    {
        curl -fsSL https://packages.redis.io/gpg | $SUDO gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | $SUDO tee /etc/apt/sources.list.d/redis.list
        $SUDO apt update
        $SUDO apt install redis > /dev/null 2>&1
    } > /dev/null 2>&1 || { echo "Failed to install Redis"; exit 1; }

    progress_done "Installed Redis"
}

# Function to install RabbitMQ
install_rabbitmq() {
    progress_message "Installing RabbitMQ"

    {
        asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
        asdf install erlang 26.1.1
        asdf global erlang 26.1.1

        $SUDO apt install rabbitmq-server > /dev/null 2>&1
        $SUDO rabbitmq-plugins enable rabbitmq_management
        $SUDO rabbitmq-plugins enable rabbitmq_shovel

        if command_exists systemctl && systemctl --quiet --failed rabbitmq-server; then
            $SUDO systemctl restart rabbitmq-server
        else
            # For WSL Distro
            $SUDO service rabbitmq-server restart
        fi
    } > /dev/null 2>&1 || { echo "Failed to install RabbitMQ"; exit 1; }

    progress_done "Installed RabbitMQ"
}

# Prints summary of installed tools
print_summary() {
    echo "========================="
    echo "Summary of Installed Tools"
    echo "========================="

    echo "Installed Dependencies:"
    for dep in "${dependencies[@]}"; do
        if command_exists "$dep"; then
            dep_version=$("$dep" --version)
            echo "$dep: $dep_version"
        else
            echo "$dep: Not installed"
        fi
    done

    echo "Installed Tools:"
    if command_exists "heroku"; then
        heroku_version=$(heroku --version)
        echo "Heroku CLI: $heroku_version"
    else
        echo "Heroku CLI: Not installed"
    fi

    if command_exists "aws"; then
        aws_version=$(aws --version 2>&1 | head -n 1)
        echo "AWS CLI: $aws_version"
    else
        echo "AWS CLI: Not installed"
    fi

    if command_exists "asdf"; then
        asdf_version=$(asdf --version)
        echo "asdf: $asdf_version"
    else
        echo "asdf: Not installed"
    fi

    if command_exists "ruby"; then
        ruby_version=$(ruby --version)
        echo "Ruby: $ruby_version"
    else
        echo "Ruby: Not installed"
    fi

    if command_exists "psql"; then
        postgres_version=$(psql --version)
        echo "PostgreSQL: $postgres_version"
    else
        echo "PostgreSQL: Not installed"
    fi

    if command_exists "redis-server"; then
        redis_version=$(redis-server --version)
        echo "Redis: $redis_version"
    else
        echo "Redis: Not installed"
    fi

    if command_exists "rabbitmq-server"; then
        rabbitmq_version=$(rabbitmq-server --version)
        echo "RabbitMQ: $rabbitmq_version"
    else
        echo "RabbitMQ: Not installed"
    fi
}

# Main script
{
    echo "Setting up the development environment"
    echo "-> Bootstrapping development environment"

    SUDO=''

    # Check if the script is running as root
    if [ "$(id -u)" != "0" ]; then
        SUDO='sudo'

        echo "This script requires superuser access."
        echo "You will be prompted for your password by sudo."

        # Clear any previous sudo permission
        sudo -k
    fi

    # Check if required commands are available
    if ! command_exists "apt"; then
        echo "apt command not found. Please make sure you are running this on a Debian-based system."
        exit 1
    fi

    # Call the functions
    update_packages_list
    upgrade_packages
    install_dependency_packages "${dependencies[@]}"
    install_heroku_cli
    install_aws_cli
    install_asdf
    install_asdf_ruby_plugin_and_latest_ruby
    install_postgresql
    install_redis
    install_rabbitmq

    # Print the summary
    print_summary
}
