##Data Dictionary Format (For Dev 2 / Parser Dev)

When emitting `dialogue_requested`, the `data` parameter MUST be a Dictionary containing the following exact keys to ensure the UI can read it:

| Key | Data Type | Description |
| :--- | :--- | :--- |
| `"speaker"` | `String` | The name to display in the NameLabel (e.g., "Kian", "System"). |
| `"text"` | `String` | The actual dialogue string for the typewriter effect. |
| `"expression"` | `String` | The identifier for the character's portrait/emotion. (optional) |

**Example Emission from Parser:**
```gdscript
var current_line = {
    "speaker": "Kian",
    "text": "Hello, testing line, lorem ipsum bro",
    "expression": "neutral"
}
EventBus.dialogue_requested.emit(current_line)
