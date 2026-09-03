
# Generate latest packages list and write to README.md
gen-readme:
    python3 ./scripts/gen-readme.py

# Run passthru.updateScript-based package updates
# Usage: just update-pkg [--all | <attr-path>...]
update-pkg *args:
    ./scripts/update-package {{args}}
