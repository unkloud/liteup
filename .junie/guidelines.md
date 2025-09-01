## General Guidelines:

- **No system component installations**.
- Document AI coding agent contribution in the `README.md`.
- Keep code compact; avoid excessive blank lines.
- Limit comments to obscure logic only. Break complex logic into smaller explainable components instead.
- Failing early is preferable—provide clear error messages.
- Update `README.md` with every script update.
- Log prompts in `prompt_log.txt`.

## Python Scripts:

- Follow Python best practices; prioritize clean, readable code.
- Minimize print statements.
- Format and lint with `black` and `ruff` on every save.
- Update `README.md` for script changes.

## Bash Scripts:

- Use simple, idiomatic, and clean Bash practices.
- Avoid clever tricks; keep scripts readable.
- Validate scripts with `shellcheck`.

## D Projects:

- **Compiler Setup:**  
  Activate D compilers with:
  ```bash
  source /home/ew/dlang/dmd-2.111.0/activate
  source /home/ew/dlang/gdc-4.8.5/activate
  source /home/ew/dlang/ldc-1.41.0/activate
  ```
  Use `deactivate` to turn off the compiler. Fail with an error if no compiler is available.
- **Coding Practices**:
    - Write straightforward, self-explanatory code; avoid meta-programming unless necessary.
    - Prefer clarity over premature optimizations. Design modules for performance and modularity.
    - Use reliable dependencies (`vibe-d` is highly recommended).
    - Avoid deep class hierarchies. Opt for functional composition where possible.
- **Testing**:
    - Cover essential functionalities; exhaustive test coverage isn’t required.
- **Documentation**:
    - Update `design.md` for design changes, including reasoning for key components.
    - Reflect usage/interface updates in `README.md`.
- **Formatting**:
    - Run `dfmt` on every change.
- **Code Style**:
    - Avoid abstractions unless absolutely required.
    - Minimize logging, print statements, and empty lines. Compact code is preferred.
