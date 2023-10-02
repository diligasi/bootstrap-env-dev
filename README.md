# Bootstrap Dev Environment

![GitHub License](https://img.shields.io/github/license/diligasi/bootstrap-env-dev)
![GitHub last commit](https://img.shields.io/github/last-commit/diligasi/bootstrap-env-dev)

This is a script to quickly set up a development environment on a Debian-based system. It installs essential packages and tools commonly used by developers.

## Features

- Installs development dependencies such as compilers, build tools, and libraries.
- Sets up popular tools like Heroku CLI, AWS CLI, Ruby via asdf, PostgreSQL, Redis, and RabbitMQ.
- Provides an option to update and upgrade system packages.
- Generates a summary of installed tools and their versions for easy reference.

## Prerequisites

- This script is intended for use on Debian-based Linux distributions.
- Make sure you have sudo access on your system.
- Git should be installed for fetching the script from the repository.

## Usage

### Method 1: Run the Script Remotely

If you prefer not to clone the repository, you can run the script remotely using curl:

   ```shell
   curl -sSL https://raw.githubusercontent.com/diligasi/bootstrap-env-dev/main/bootstrap_dev_env.sh | bash
   ```

### Method 2: Clone the Repository

1. Open your terminal.

2. Clone this repository:

   ```shell
   git clone https://github.com/yourusername/bootstrap-dev-env.git
   ```

3. Navigate to the project directory:

   ```shell
   cd bootstrap-dev-env
   ```

4. Make the script executable:

   ```shell
   chmod +x bootstrap_dev_env.sh
   ```

5. Run the script:

   ```shell
   ./bootstrap_dev_env.sh
   ```

6. Follow the on-screen prompts and provide your sudo password when prompted.

7. Once the script completes, your development environment will be ready to use.



## Notes
- This script is intended for use on Debian-based Linux distributions.
- You should have sudo access on your system.

## License
This project is licensed under the MIT License - see the [LICENSE](https://chat.openai.com/c/LICENSE) file for details.

## Acknowledgments
- This script is inspired by the need for an easy way to set up a development environment quickly.
- Feel free to contribute, open issues, or provide feedback to improve this script!
