# Rule: Component Documentation Standards

1. **Docstrings**:
   - Every public component must have a clear doc comment describing its interaction behavior, tactile properties, and configurable parameters.
2. **Catalog Metadata**:
   - Every component must declare:
     - `name`: Display name shown in the gallery.
     - `category`: Category chip grouping (`.buttons`, `.sheets`, `.navigation`, `.controls`, `.flows`).
     - `windowShape`: `.rectangle` (wide) or `.square` (1:1).
     - `description`: 1-2 sentence description.
     - `tags`: Keywords for searching.
3. **Previews**:
   - Include both isolated view previews and interactive sandbox states in `#Preview`.
