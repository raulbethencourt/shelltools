# Shelltools

<!--toc:start-->
- [Shelltools](#shelltools)
  - [🏗️ Repository Structure](#🏗️-repository-structure)
    - [bin/](#bin)
    - [lib/](#lib)
    - [scripts/](#scripts)
    - [wcss/ (Wicked Cool Shell Scripts)](#wcss-wicked-cool-shell-scripts)
    - [manuals/](#manuals)
    - [restapi/](#restapi)
  - [🚀 Getting Started](#🚀-getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
    - [Usage Examples](#usage-examples)
      - [Using Core Tools](#using-core-tools)
      - [Using Library Functions](#using-library-functions)
      - [AI Documentation Generation](#ai-documentation-generation)
  - [🛠️ Development](#🛠️-development)
    - [Code Style](#code-style)
    - [Testing & Linting](#testing-linting)
    - [Contributing](#contributing)
  - [📚 Resources](#📚-resources)
  - [📄 License](#📄-license)
  - [🤝 Acknowledgments](#🤝-acknowledgments)
<!--toc:end-->

A comprehensive collection of Bash shell scripts, utilities, and tools for everyday command-line
tasks. This repository serves as both a personal toolbox and a learning resource for shell
scripting.

## 🏗️ Repository Structure

### bin/

Core executable tools and utilities:

- **agenda** - Manage personal agendas and reminders
- **calc** - Command-line calculator
- **cht** - Query cheat.sh for programming help
- **convertatemp** - Temperature conversion utility
- **diskhogs** - Find disk space hogs
- **fman** - Fast manual page lookup
- **formatdir** - Directory formatting tools
- **loancalc** - Loan calculator
- **remember** - Note-taking utility
- And many more...

### lib/

Shared library files and utilities:

- **core.sh** - Core functions (error handling, logging)
- **.library** - Extended utility functions (file sanitization, ANSI colors, directory
management)
- **.toolbox** - Additional toolbox functions

### scripts/

Advanced scripts leveraging the library:

- **aidoc.sh** - AI-powered documentation generator using GitHub Models
- **cht.sh** - Enhanced cheat.sh interface with tmux
- **dbcompare.sh** - Database comparison tools
- **fcurl.sh** - Enhanced curl wrapper
- **jsql.sh** - JSON SQL query tools
- **mysql_tunnel.sh** - MySQL tunneling utilities

### wcss/ (Wicked Cool Shell Scripts)

Examples and implementations from the "Wicked Cool Shell Scripts" book, organized by chapters:

- **chapter1/** - Basic utilities (validation, colors, etc.)
- **chapter2/** - File management tools
- **chapter3/** - Productivity scripts (agenda, calculator)
- **chapter4/** - System utilities
- **chapter5/** - Advanced tools

### manuals/

Offline documentation for reference:

- **php/** - Comprehensive PHP manual (11,000+ pages)
- **vim/** - Vim tutorial and cheatsheets

### restapi/

Scripts for interacting with various REST APIs:

- **AIOC/** - Artworks API tools
- **rickmorty/** - Rick and Morty API client
- **SUGARCRM/** & **SUITECRM/** - CRM system integrations
- **TEAMS/** - Microsoft Teams workflow automation

## 🚀 Getting Started

### Prerequisites

- Bash shell
- Standard Unix tools (grep, sed, awk, etc.)
- For AI features: GitHub token with Models API access

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/shelltools.git cd shelltools
   ```

2. Add to your PATH (optional):

   ```bash
   export PATH="$PATH:$(pwd)/bin"
   ```

3. Source the library in your scripts:

   ```bash
   source "$(pwd)/lib/.toolbox" 
   ```

### Usage Examples

#### Using Core Tools

```bash
# Calculate expressions 
calc "2 + 3 * 4"

# Get programming help 
cht
```

#### Using Library Functions

```bash
#!/bin/bash 
source "lib/.toolbox"

# Use ANSI colors 
initANSI echo "${greenf}Success!${reset}"

# Sanitize filenames 
safe_name=$(sanitize_filename "file with spaces.txt")
```

#### AI Documentation Generation

```bash
# Generate documentation for PHP files 
export GITHUB_TOKEN="your-token-here" aidoc.sh -n "*.php" ./src
```

## 🛠️ Development

### Code Style

- Follows ShellCheck linting rules
- Uses strict mode: `set -euo pipefail`
- Functions use snake_case naming
- Proper error handling with custom functions

### Testing & Linting

Run shellcheck on scripts:

```bash
shellcheck *.sh scripts/*.sh bin/* lib/* 
```

### Contributing

1. Follow the established code style
2. Add tests for new functionality
3. Update documentation as needed
4. Run linting before committing

## 📚 Resources

- **Wicked Cool Shell Scripts** book examples in `wcss/`
- Offline manuals in `manuals/` for quick reference
- Extensive library of reusable Bash functions

## 📄 License

See LICENSE file for details.

## 🤝 Acknowledgments

- Inspired by "Wicked Cool Shell Scripts" by Dale Dougherty & Arnold Robbins
- Built upon community contributions and personal scripting experience
