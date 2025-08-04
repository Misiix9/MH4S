# Contributing to MH4S

Thank you for your interest in contributing to MH4S! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone.

## How to Contribute

### Reporting Issues

1. Check if the issue already exists in our [issue tracker](https://github.com/Misiix9/MH4S/issues)
2. If not, create a new issue with:
   - Clear title
   - Detailed description
   - Steps to reproduce
   - Expected vs actual behavior
   - System information
   - Relevant logs

### Submitting Changes

1. Fork the repository
2. Create a new branch:
   ```bash
   git checkout -b feature/your-feature
   # or
   git checkout -b fix/your-fix
   ```

3. Make your changes following our guidelines
4. Test your changes thoroughly
5. Commit your changes:
   ```bash
   git add .
   git commit -m "Description of changes"
   ```

6. Push to your fork:
   ```bash
   git push origin feature/your-feature
   ```

7. Create a Pull Request

### Pull Request Guidelines

- One feature/fix per PR
- Clear description of changes
- Reference related issues
- Include testing steps
- Update documentation if needed

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/Misiix9/MH4S.git
   cd MH4S
   ```

2. Create a development environment:
   ```bash
   # Install dependencies
   yay -S hyprland waybar kitty rofi
   
   # Install development tools
   yay -S shellcheck
   ```

3. Test your changes:
   ```bash
   # Test installer
   ./installer/main.sh
   
   # Test individual scripts
   ~/.config/hypr/scripts/your-script.sh
   ```

## Code Style

### Shell Scripts

- Use shellcheck
- Include error handling
- Add logging
- Document functions
- Use meaningful variable names

Example:
```bash
#!/bin/bash

# Function description
my_function() {
    local var="$1"
    
    if [ -z "$var" ]; then
        error "Variable is empty"
        return 1
    fi
    
    log "Processing $var"
}
```

### Configuration Files

- Use consistent indentation
- Add comments for clarity
- Group related settings
- Follow format conventions

Example:
```ini
# Window configuration
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
}
```

### CSS Styling

- Use consistent naming
- Group related styles
- Add comments for sections
- Follow BEM methodology

Example:
```css
/* Module styling */
.module {
    padding: 10px;
}

.module__header {
    font-weight: bold;
}
```

## Testing

1. Test functionality:
   - Installation process
   - Configuration files
   - Scripts and utilities
   - Error handling

2. Test on different systems:
   - Various hardware
   - Different GPU drivers
   - Multiple screen setups

3. Test edge cases:
   - Invalid inputs
   - Missing dependencies
   - Error conditions

## Documentation

- Update README.md for new features
- Add comments in code
- Update troubleshooting guide
- Include examples

## Release Process

1. Version bump in relevant files
2. Update changelog
3. Create release notes
4. Tag release
5. Update documentation

## Getting Help

- Join our community
- Check existing issues
- Review documentation
- Ask questions

## Recognition

Contributors will be:
- Listed in README.md
- Mentioned in release notes
- Added to contributors list

Thank you for contributing to MH4S!
