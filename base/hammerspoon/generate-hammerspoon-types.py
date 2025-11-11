#!/usr/bin/env python3
"""
Generate Hammerspoon EmmyLua type definitions from official documentation.

This script fetches all API documentation pages from hammerspoon.org,
parses the HTML structure, and generates comprehensive EmmyLua annotations.

Requirements: Python 3.11+ (no external dependencies)
Output: hammerspoon.types.lua
"""

import re
import urllib.request
from html.parser import HTMLParser
from typing import Optional
from collections import defaultdict


class HammerspoonDocParser(HTMLParser):
    """Parse Hammerspoon HTML documentation to extract API definitions."""

    def __init__(self):
        super().__init__()
        self.modules = []
        self.in_module_list = False
        self.current_tag = None
        self.current_attrs = {}

    def handle_starttag(self, tag, attrs):
        self.current_tag = tag
        self.current_attrs = dict(attrs)

        # Find module links in the documentation index
        if tag == "a" and self.current_attrs.get("href", "").endswith(".html"):
            href = self.current_attrs["href"]
            # Filter out non-module links (index, tutorials, etc.)
            if not any(
                x in href for x in ["index.html", "getting_started", "tutorials"]
            ):
                self.modules.append(href)


class ModuleAPIParser(HTMLParser):
    """Parse individual module documentation to extract API items."""

    def __init__(self, module_name):
        super().__init__()
        self.module_name = module_name
        self.api_items = []
        self.current_item = {}
        self.in_h5 = False
        self.in_td = False
        self.in_th = False
        self.current_th = None
        self.current_td_content = []
        self.in_api_section = False
        self.current_tag_stack = []
        self.in_li = False
        self.current_li_content = []
        self.current_section = None  # Track current section (API Overview, etc.)
        self.in_h3 = False  # For section headers
        self.deprecation_info = {}  # Store deprecation notices

    def handle_starttag(self, tag, attrs):
        self.current_tag_stack.append(tag)
        attrs_dict = dict(attrs)

        if tag == "h3":
            self.in_h3 = True

        elif tag == "h5":
            self.in_h5 = True
            self.current_item = {"module": self.module_name}

        elif tag == "th":
            self.in_th = True
            self.current_th = None

        elif tag == "td":
            self.in_td = True
            self.current_td_content = []

        elif tag == "li" and self.in_td:
            self.in_li = True
            self.current_li_content = []

    def handle_endtag(self, tag):
        if self.current_tag_stack:
            self.current_tag_stack.pop()

        if tag == "h3":
            self.in_h3 = False

        elif tag == "h5":
            self.in_h5 = False

        elif tag == "th":
            self.in_th = False

        elif tag == "li" and self.in_li:
            self.in_li = False
            # Store list item content
            li_text = " ".join(self.current_li_content).strip()
            if li_text:
                self.current_td_content.append(li_text)
            self.current_li_content = []

        elif tag == "td":
            self.in_td = False
            if self.current_th and self.current_item:
                content = "\n".join(self.current_td_content).strip()
                self.current_item[self.current_th.lower()] = content
            self.current_td_content = []

        elif tag == "table":
            # End of current API item's table
            if self.current_item and "name" in self.current_item:
                # Store current section context
                if self.current_section:
                    self.current_item["section"] = self.current_section
                self.api_items.append(self.current_item.copy())
                self.current_item = {}

    def handle_data(self, data):
        data = data.strip()
        if not data:
            return

        if self.in_h3:
            # Track section headers (e.g., "API Overview", "Fields")
            self.current_section = data

        elif self.in_h5:
            self.current_item["name"] = data

        elif self.in_th:
            self.current_th = data

        elif self.in_li:
            self.current_li_content.append(data)

        elif self.in_td and not self.in_li:
            # Only capture non-list text (descriptions, etc.)
            self.current_td_content.append(data)


def fetch_url(url: str) -> str:
    """Fetch content from URL with error handling."""
    try:
        with urllib.request.urlopen(url, timeout=10) as response:
            return response.read().decode("utf-8")
    except Exception as e:
        print(f"Error fetching {url}: {e}")
        return ""


def get_all_modules(base_url: str) -> list[str]:
    """Fetch the main index and extract all module URLs."""
    print("Fetching module list from documentation index...")
    index_url = f"{base_url}/docs/index.html"
    html = fetch_url(index_url)

    parser = HammerspoonDocParser()
    parser.feed(html)

    # Remove duplicates and sort
    modules = sorted(set(parser.modules))
    print(f"Found {len(modules)} modules")
    return modules


def parse_module_documentation(base_url: str, module_path: str) -> list[dict]:
    """Parse a single module's documentation page."""
    module_name = module_path.replace(".html", "")
    url = f"{base_url}/docs/{module_path}"

    print(f"  Parsing {module_name}...")
    html = fetch_url(url)
    if not html:
        return []

    parser = ModuleAPIParser(module_name)
    parser.feed(html)

    return parser.api_items


def make_union_type(types: list[str]) -> str:
    """Create a clean union type string, removing duplicates while preserving order."""
    # Remove duplicates while preserving order
    seen = set()
    unique_types = []
    for t in types:
        t = t.strip()
        if t and t not in seen:
            seen.add(t)
            unique_types.append(t)

    if not unique_types:
        return "any"
    elif len(unique_types) == 1:
        return unique_types[0]
    else:
        return "|".join(unique_types)


def extract_type_from_description(description: str) -> str:
    """
    Extract type information from natural language description.
    Handles unions, hs.* types, callbacks, and table structures.
    """
    desc_lower = description.lower()

    # Check for explicit "or nil" pattern
    has_nil = " or nil" in desc_lower or "optional" in desc_lower or "may be nil" in desc_lower

    # Check if description explicitly starts with basic type indicators
    # These take precedence over module names mentioned later
    starts_with_table = re.match(r"^\s*(?:this |a |an |the )?table\b", desc_lower)
    starts_with_string = re.match(r"^\s*(?:this |a |an |the )?string\b", desc_lower)
    starts_with_number = re.match(r"^\s*(?:this |a |an |the )?number\b", desc_lower)
    starts_with_boolean = re.match(r"^\s*(?:this |a |an |the )?boolean\b", desc_lower)
    starts_with_function = re.match(r"^\s*(?:this |a |an |the )?function\b", desc_lower)

    # Extract all hs.* types (remove duplicates)
    # Match hs.module.submodule but not trailing dots
    hs_types = re.findall(r"\bhs\.[a-zA-Z0-9_]+(?:\.[a-zA-Z0-9_]+)*(?:\s+object)?", description)
    # Deduplicate while preserving order
    hs_types_unique = []
    seen = set()
    for ht in hs_types:
        # Clean up " object" suffix
        ht = re.sub(r"\s+object$", "", ht)
        # Remove trailing dots (in case any slipped through)
        ht = ht.rstrip(".")
        if ht and ht not in seen:
            seen.add(ht)
            hs_types_unique.append(ht)
    hs_types = hs_types_unique

    # Look for union patterns like "string, number, or table"
    union_match = re.search(r"(?:a |an )?(\w+)(?:,\s+(\w+))*(?:,?\s+or\s+(\w+))", desc_lower)

    # Look for callback signatures
    # Patterns: "function that receives", "callback with", "function(param1, param2)"
    is_callback = any(keyword in desc_lower for keyword in [
        "function that", "callback", "function which", "called with",
        "receives a function", "function to"
    ])

    # Look for table structure hints
    # Patterns: "table containing", "table with keys", "table of", "list of", "array of"
    is_table = "table" in desc_lower
    table_of_match = re.search(r"table of (\w+)s?", desc_lower)

    # Check for array/list patterns
    list_match = re.search(r"(?:list|array) of (\w+)", desc_lower)
    # Pattern: "returns X devices/objects/items"
    returns_list_match = re.search(r"returns? (?:a list of |an array of |)?(\w+) (?:devices|objects|items)", desc_lower)

    # Determine the base type
    base_type = "any"

    # Prioritize explicit type indicators at start of description
    if starts_with_table:
        base_type = "table"
    elif starts_with_string:
        base_type = "string"
    elif starts_with_number:
        base_type = "number"
    elif starts_with_boolean:
        base_type = "boolean"
    elif starts_with_function:
        base_type = "function"
    elif hs_types:
        # Create union from unique hs types (only if not explicitly typed above)
        base_type = make_union_type(hs_types)
    elif is_callback:
        base_type = "function"
    elif list_match or returns_list_match:
        # Array pattern: "list of X" or "returns X devices"
        match = list_match or returns_list_match
        item_type = match.group(1)

        # Map common type names
        type_map = {
            "audiodevice": "hs.audiodevice",
            "device": "hs.audiodevice",
            "window": "hs.window",
            "screen": "hs.screen",
            "application": "hs.application",
            "string": "string",
            "number": "number",
            "boolean": "boolean",
            "table": "table",
        }

        lua_type = type_map.get(item_type.lower(), item_type)
        base_type = f"{lua_type}[]"
    elif table_of_match:
        # Array-like table: table of strings -> string[]
        item_type = table_of_match.group(1)
        if item_type in ["string", "number", "boolean", "table"]:
            base_type = f"{item_type}[]"
        else:
            base_type = "table"
    elif union_match:
        # Handle union types from description
        types_found = [t for t in union_match.groups() if t]
        # Map common words to Lua types
        type_map = {
            "string": "string", "number": "number", "integer": "number",
            "boolean": "boolean", "bool": "boolean", "table": "table",
            "function": "function", "userdata": "any"
        }
        lua_types = [type_map.get(t, t) for t in types_found if t in type_map]
        base_type = make_union_type(lua_types)
    elif is_table:
        base_type = "table"
    else:
        # Fall back to keyword detection
        if "boolean" in desc_lower or "true or false" in desc_lower:
            base_type = "boolean"
        elif "string" in desc_lower:
            base_type = "string"
        elif "number" in desc_lower or "integer" in desc_lower:
            base_type = "number"
        elif "function" in desc_lower:
            base_type = "function"

    # Add nil if optional
    if has_nil and base_type != "any" and "|nil" not in base_type:
        base_type = f"{base_type}|nil"

    return base_type


def infer_type_from_param_name(param_name: str) -> str:
    """
    Infer parameter type from naming conventions.
    Returns "any" if no convention matches.
    """
    name_lower = param_name.lower()

    # String indicators
    if (name_lower.endswith("id") or name_lower.endswith("uuid") or
        name_lower.endswith("uid") or name_lower.endswith("name") or
        name_lower.endswith("path") or name_lower.endswith("text") or
        name_lower.endswith("string") or name_lower.endswith("pattern") or
        name_lower.endswith("title") or name_lower.endswith("message") or
        name_lower.endswith("url") or name_lower.endswith("uri") or
        name_lower.endswith("key") or name_lower.endswith("command")):
        return "string"

    # Boolean indicators (common prefixes and specific names)
    if (name_lower.startswith("with") or name_lower.startswith("is") or
        name_lower.startswith("has") or name_lower.startswith("should") or
        name_lower.startswith("can") or name_lower.startswith("will") or
        name_lower.startswith("enable") or name_lower.startswith("disable") or
        name_lower.startswith("show") or name_lower.startswith("hide") or
        name_lower.startswith("allow") or name_lower.startswith("bring") or
        name_lower == "state" or name_lower == "append" or
        name_lower == "bringtofront" or "tofront" in name_lower):
        return "boolean"

    # Table/Array indicators
    if (name_lower in ["array", "list", "items", "elements", "args", "arguments"] or
        name_lower.endswith("array") or name_lower.endswith("list")):
        return "table"

    # Function indicators
    if (param_name in ["fn", "func", "callback", "handler", "listener",
                       "predicate", "filter", "mapper", "reducer"]):
        return "function"

    # Number indicators
    if (name_lower.endswith("count") or name_lower.endswith("index") or
        name_lower.endswith("size") or name_lower.endswith("width") or
        name_lower.endswith("height") or name_lower.endswith("length") or
        name_lower.endswith("duration") or name_lower.endswith("delay") or
        name_lower.endswith("timeout") or name_lower.endswith("interval") or
        name_lower.endswith("x") or name_lower.endswith("y") or
        name_lower.endswith("position") or name_lower.endswith("offset")):
        return "number"

    return "any"


def parse_parameter_descriptions(param_text: str) -> dict[str, str]:
    """
    Parse parameter descriptions to extract types.
    Supports unions, callbacks, hs.* types, and table structures.
    Falls back to naming conventions if description parsing fails.

    Format: "paramName - description with type information"
    Returns: {param_name: type}
    """
    param_types = {}

    if not param_text or param_text == "None":
        return param_types

    # Split by lines (each parameter is on its own line)
    for line in param_text.split("\n"):
        line = line.strip()
        if not line or line.lower() == "none":
            continue

        # Extract parameter name (everything before first dash or colon)
        match = re.match(r"^([a-zA-Z0-9_]+)\s*[-:]", line)
        if not match:
            continue

        param_name = match.group(1)

        # Extract description (everything after the dash/colon)
        desc_match = re.search(r"[-:]\s*(.+)$", line)
        description = desc_match.group(1) if desc_match else line

        # Use enhanced type extraction
        param_type = extract_type_from_description(description)

        # If type extraction failed (returned "any"), try naming conventions
        if param_type == "any":
            param_type = infer_type_from_param_name(param_name)

        param_types[param_name] = param_type

    return param_types


def parse_signature(signature: str) -> tuple[str, list[tuple[str, str]], list[str]]:
    """
    Parse function signature to extract name, parameters, and return types.

    Hammerspoon uses format: func(req1, req2[, opt1[, opt2]]) -> return1[, return2]
    where nested brackets indicate optional parameters.

    Returns: (function_name, [(param_name, param_type)], [return_types])
    """
    signature = signature.strip()

    # Extract function name (everything before opening parenthesis)
    paren_pos = signature.find("(")
    if paren_pos == -1:
        return "", [], "any"

    func_name = signature[:paren_pos].strip()

    # Extract parameters from parentheses - find matching closing paren
    paren_count = 0
    param_start = paren_pos + 1
    param_end = param_start

    for i in range(paren_pos + 1, len(signature)):
        if signature[i] == "(":
            paren_count += 1
        elif signature[i] == ")":
            if paren_count == 0:
                param_end = i
                break
            paren_count -= 1

    param_str = signature[param_start:param_end] if param_end > param_start else ""

    # Parse parameters
    params = []
    if param_str and param_str.strip():
        # Remove all square brackets to get clean parameter list
        # Then track which ones were optional based on bracket positions

        # First, find where optional params start (first occurrence of [,)
        optional_start = -1
        for i in range(len(param_str)):
            if i > 0 and param_str[i-1:i+1] == "[,":
                optional_start = i
                break

        # Remove all brackets to get clean param string
        clean_str = param_str.replace("[", "").replace("]", "")

        # Split by comma to get individual parameters
        param_parts = [p.strip() for p in clean_str.split(",") if p.strip()]

        # Determine which params are optional
        # Count how many commas appear before the optional marker
        required_count = 0
        if optional_start > 0:
            required_count = param_str[:optional_start].count(",") + 1
        else:
            required_count = len(param_parts)

        for idx, param_name in enumerate(param_parts):
            is_optional = idx >= required_count
            param_type = "any"

            # Mark optional params with ?
            if is_optional and not param_name.endswith("?"):
                param_name += "?"

            params.append((param_name, param_type))

    # Extract return types (can be multiple, separated by commas)
    return_types = []
    return_match = re.search(r"->\s*(.+?)$", signature)
    if return_match:
        return_str = return_match.group(1).strip()
        # Handle multiple return values separated by commas
        # But be careful not to split inside type expressions like "table<string, number>"
        # For simplicity, split by comma and trim
        parts = [p.strip() for p in return_str.split(",")]
        return_types = [p for p in parts if p and p not in ["or", "and"]]

    # If no return type specified, assume "any"
    if not return_types:
        return_types = ["any"]

    return func_name, params, return_types


def convert_type_to_lua(type_str: str) -> str:
    """Convert Hammerspoon type notation to EmmyLua type notation."""
    if not type_str or type_str == "None":
        return "nil"

    # Clean up malformed brackets and parentheses that don't belong in type annotations
    # Simple approach: remove all parens and square brackets that aren't part of array notation []
    # Keep [] for arrays, remove everything else
    type_str = re.sub(r"\(.*?\)", "", type_str)  # Remove content in parentheses
    type_str = re.sub(r"[()]", "", type_str)  # Remove stray parens
    type_str = re.sub(r"\[(?!\])", "", type_str)  # Remove [ not followed by ]
    type_str = re.sub(r"(?<!\[)\]", "", type_str)  # Remove ] not preceded by [

    # Convert " or " to "|" for union types (must be done before other processing)
    type_str = re.sub(r"\s+or\s+", "|", type_str)

    # Handle array notation
    type_str = re.sub(r"table of ([a-zA-Z0-9_.]+)s?", r"\1[]", type_str)

    # Clean up " object" suffix from hs types (e.g., "hs.window object" -> "hs.window")
    type_str = re.sub(r"\s+object\b", "", type_str)

    # Remove common description words that shouldn't be in types
    # These are placeholders/descriptions from the API docs
    description_words = [
        "current value", "currentValue", "binary data",
        "errString", "value", "item", "result"
    ]
    for word in description_words:
        type_str = re.sub(rf"\b{re.escape(word)}\b", "", type_str, flags=re.IGNORECASE)

    # Map common *Object patterns to proper hs.* types
    object_type_map = {
        "axuielementObject": "hs.axuielement",
        "axTextMarkerObject": "hs.axuielement.axtextmarker",
        "axTextMarkerRangeObject": "hs.axuielement.axtextmarker",
        "observerObject": "hs.axuielement.observer",
        "browserObject": "hs.bonjour",
        "serviceObject": "hs.bonjour.service",
        "drawingObject": "hs.drawing",
        "canvasObject": "hs.canvas",
        "menubarObject": "hs.menubar",
        "menubaritem": "hs.menubar",
        "timerObject": "hs.timer",
        "watchableObject": "hs.watchable",
    }

    # Apply object type mappings
    for old_type, new_type in object_type_map.items():
        type_str = re.sub(rf"\b{re.escape(old_type)}\b", new_type, type_str, flags=re.IGNORECASE)

    # Clean up extra whitespace and pipes
    type_str = re.sub(r"\s+", " ", type_str).strip()
    type_str = re.sub(r"\|\s*\|", "|", type_str)  # Remove double pipes
    type_str = re.sub(r"^\|+", "", type_str)  # Remove leading pipes
    type_str = re.sub(r"\|+$", "", type_str)  # Remove trailing pipes

    # Remove trailing dots from type names (e.g., "hs.drawing.color." -> "hs.drawing.color")
    type_str = re.sub(r"\.(?=\||$)", "", type_str)  # Remove dots before pipe or end of string

    # Handle common type mappings (preserve unions by not replacing inside |)
    type_map = {
        "boolean": "boolean",
        "number": "number",
        "integer": "number",
        "string": "string",
        "table": "table",
        "function": "function",
        "userdata": "any",
        "nil": "nil",
        "bool": "boolean",
        "true": "boolean",
        "false": "boolean",
    }

    # For union types, process each component separately
    if "|" in type_str:
        parts = type_str.split("|")
        converted_parts = []
        for part in parts:
            part = part.strip()
            # Skip if empty or invalid
            if not part:
                continue
            # Map known types
            mapped = False
            for old, new in type_map.items():
                if part == old:
                    part = new
                    mapped = True
                    break
            # Add if valid
            if part and not part.lower() in ["or", "and", "the", "a", "an"]:
                converted_parts.append(part)

        # Deduplicate union components
        return make_union_type(converted_parts) if converted_parts else "any"
    else:
        # Single type - direct mapping
        type_str = type_str.strip()
        for old, new in type_map.items():
            if type_str == old:
                return new

    # Return cleaned type or "any" if empty or invalid
    if not type_str or type_str.lower() in ["or", "and", "the", "a", "an"]:
        return "any"

    return type_str


def format_description(desc: str, indent: str = "--- ") -> list[str]:
    """Format description text for EmmyLua comments."""
    if not desc:
        return []

    lines = []
    # Split by newlines and wrap long lines
    for line in desc.split("\n"):
        line = line.strip()
        if not line:
            continue

        # Wrap at 120 characters (more reasonable for modern editors)
        max_len = 116  # Account for "--- " prefix (4 chars)

        while len(line) > max_len:
            # Find last space before max_len chars
            wrap_pos = line[:max_len].rfind(" ")
            if wrap_pos == -1 or wrap_pos < max_len * 0.6:
                # If no good break point, don't wrap this line
                break

            lines.append(f"{indent}{line[:wrap_pos]}")
            line = line[wrap_pos:].strip()

        if line:
            lines.append(f"{indent}{line}")

    return lines


def generate_api_item_annotation(item: dict) -> list[str]:
    """Generate EmmyLua annotation for a single API item."""
    lines = []

    # Parse signature
    signature = item.get("signature", "")
    if not signature:
        return lines

    item_type = item.get("type", "").lower()
    desc = item.get("description", "").strip()

    # Check for deprecation
    is_deprecated = "deprecat" in desc.lower() or "deprecat" in item.get("notes", "").lower()

    # Handle Fields (return as field definitions, not standalone)
    if item_type == "field":
        # Fields will be handled in generate_type_definitions as @field annotations
        # Return field info in a special format
        field_name = signature.replace("`", "").strip()
        field_type = extract_type_from_description(desc) if desc else "any"

        # Store as metadata for later use in class definitions
        return []  # Fields are added to classes, not as standalone items

    # Handle Constants and Variables
    if item_type in ["constant", "variable"]:
        lines.append("")

        # Add description
        if desc:
            desc_lines = format_description(desc)
            if desc_lines:
                lines.extend(desc_lines)

        # Add deprecation notice
        if is_deprecated:
            lines.append("---@deprecated")

        # Use enhanced type extraction
        var_type = extract_type_from_description(desc) if desc else "any"

        # Extract variable name from signature (remove backticks)
        var_name = signature.replace("`", "").strip()

        lines.append(f"---@type {var_type}")
        lines.append(f"{var_name} = nil")

        return lines

    # Handle Functions, Methods, Constructors
    func_name, params, return_types = parse_signature(signature)
    if not func_name:
        return lines

    # Add separator
    lines.append("")

    # Determine if it's a method (contains :) or function (contains .)
    is_method = ":" in func_name
    is_constructor = item_type == "constructor"

    # Add description (only if not empty)
    if desc:
        desc_lines = format_description(desc)
        if desc_lines:
            lines.extend(desc_lines)

    # Add notes if present (only if not empty)
    notes = item.get("notes", "").strip()
    if notes:
        lines.append("---")
        lines.extend(format_description(f"Note: {notes}"))

    # Add deprecation notice
    if is_deprecated:
        lines.append("---@deprecated")

    # Parse parameter descriptions to get types
    param_desc = item.get("parameters", "")
    param_type_map = parse_parameter_descriptions(param_desc)

    # Add parameters with types from descriptions
    if params:
        for param_name, param_type in params:
            # Use type from parameter description if available
            clean_name = param_name.rstrip("?")
            if clean_name in param_type_map:
                param_type = param_type_map[clean_name]

            # If still "any", try naming convention inference
            if param_type == "any":
                param_type = infer_type_from_param_name(clean_name)

            lua_type = convert_type_to_lua(param_type)
            lines.append(f"---@param {param_name} {lua_type}")

    # Add return types (can be multiple)
    # Parse return description to enhance types ONLY if signature didn't provide specific types
    return_desc = item.get("returns", "")
    if return_desc and return_desc.lower() != "none":
        # Only use description if signature returned generic "any" or is empty
        if not return_types or (len(return_types) == 1 and return_types[0] in ["any", "None"]):
            # Try to extract type info from return description
            enhanced_return_type = extract_type_from_description(return_desc)
            if enhanced_return_type != "any":
                return_types = [enhanced_return_type]

    # Generate return annotations
    if return_types and not (len(return_types) == 1 and return_types[0] == "None"):
        for ret_type in return_types:
            lua_return_type = convert_type_to_lua(ret_type)
            lines.append(f"---@return {lua_return_type}")

    # Generate function signature
    param_names = ", ".join(p[0].rstrip("?") for p in params)

    # Format function declaration
    if is_method:
        # Method: remove module prefix and :
        method_name = func_name.split(":")[-1]
        module_name = func_name.split(":")[0]
        # Use lowercase version of last component as object name
        obj_name = module_name.split(".")[-1].lower()
        lines.append(f"function {obj_name}:{method_name}({param_names}) end")
    else:
        # Function or constructor
        lines.append(f"function {func_name}({param_names}) end")

    return lines


def truncate_field_description(desc: str, max_length: int = 120) -> str:
    """
    Truncate field description intelligently at word boundaries.
    Ensures no orphaned text or corrupted formatting.
    Preserves module names like hs.geometry that contain periods.
    """
    if not desc:
        return ""

    # Remove newlines and extra whitespace first
    desc = " ".join(desc.split())

    # Get first sentence - split on ". " (period + space) not just "."
    # This preserves module names like "hs.geometry" within descriptions
    sentence_end = desc.find(". ")
    if sentence_end > 0:
        short_desc = desc[:sentence_end].strip()
    else:
        # No sentence ending found, use whole description
        short_desc = desc.strip()

    # If already short enough, return as-is
    if len(short_desc) <= max_length:
        return short_desc

    # Truncate at word boundary, but avoid breaking module references
    # Find last space before max_length
    truncate_pos = short_desc[:max_length].rfind(" ")

    # Check if we're in the middle of an hs.* module reference
    # If so, try to find a better break point
    if truncate_pos > 0:
        # Check if there's an hs.* pattern near the truncation point
        check_range = short_desc[max(0, truncate_pos - 20):min(len(short_desc), truncate_pos + 20)]
        if "hs." in check_range:
            # Try to find a break point before the module reference
            better_pos = short_desc[:truncate_pos].rfind(" ", 0, truncate_pos - 15)
            if better_pos > max_length * 0.6:
                truncate_pos = better_pos

    if truncate_pos > max_length * 0.6:  # Only truncate if we found a good break point (more lenient)
        short_desc = short_desc[:truncate_pos].strip() + "..."
    else:
        # No good break point, just cut at max_length
        short_desc = short_desc[:max_length - 3].strip() + "..."

    return short_desc


def generate_type_definitions(all_api_items: list[dict]) -> str:
    """Generate complete EmmyLua type definition file."""
    output = []

    # Header
    output.append("---@meta")
    output.append("--- Hammerspoon EmmyLua Type Definitions")
    output.append("--- Auto-generated from official documentation")
    output.append("--- https://www.hammerspoon.org/docs/")
    output.append("")

    # Group items by module
    modules = defaultdict(list)
    for item in all_api_items:
        module = item.get("module", "unknown")
        modules[module].append(item)

    # Generate definitions for each module
    for module in sorted(modules.keys()):
        items = modules[module]

        output.append("")
        output.append(f"-- {'-' * 60}")
        output.append(f"-- {module}")
        output.append(f"-- {'-' * 60}")

        # Separate fields from other items
        fields = [item for item in items if item.get("type", "").lower() == "field"]
        non_field_items = [item for item in items if item.get("type", "").lower() != "field"]

        # Create module class with fields
        output.append("")
        output.append(f"---@class {module}")

        # Add field annotations to class
        for field_item in fields:
            signature = field_item.get("signature", "")
            desc = field_item.get("description", "").strip()
            full_field_name = signature.replace("`", "").strip()
            # Extract just the field name (last component after last dot)
            field_name = full_field_name.split(".")[-1] if "." in full_field_name else full_field_name
            field_type = extract_type_from_description(desc) if desc else "any"
            field_type_lua = convert_type_to_lua(field_type)

            # Add field description as comment if available
            if desc:
                short_desc = truncate_field_description(desc)
                output.append(f"---@field {field_name} {field_type_lua} {short_desc}")
            else:
                output.append(f"---@field {field_name} {field_type_lua}")

        output.append(f"{module} = {{}}")

        # Create object class for methods (if any methods exist)
        has_methods = any(":" in item.get("signature", "") for item in non_field_items)
        if has_methods:
            obj_name = module.split(".")[-1]

            # Check if any fields reference this object type
            obj_fields = [f for f in fields if obj_name in str(f.get("description", ""))]

            output.append("")
            output.append(f"---@class {obj_name}")

            # Add fields to object class too if relevant
            for field_item in obj_fields:
                signature = field_item.get("signature", "")
                desc = field_item.get("description", "").strip()
                full_field_name = signature.replace("`", "").strip()
                # Extract just the field name (last component after last dot)
                field_name = full_field_name.split(".")[-1] if "." in full_field_name else full_field_name
                field_type = extract_type_from_description(desc) if desc else "any"
                field_type_lua = convert_type_to_lua(field_type)

                if desc:
                    short_desc = truncate_field_description(desc)
                    output.append(f"---@field {field_name} {field_type_lua} {short_desc}")
                else:
                    output.append(f"---@field {field_name} {field_type_lua}")

            output.append(f"local {obj_name} = {{}}")

        # Check for enum-like constant groups
        constants = [item for item in non_field_items if item.get("type", "").lower() == "constant"]
        if len(constants) > 3:  # If module has several constants, treat as enum
            # Check if they're all in a table (common pattern)
            const_tables = {}
            for const in constants:
                sig = const.get("signature", "")
                if "." in sig:
                    # Extract table name (e.g., "hs.eventtap.event.types.keyDown" -> "types")
                    parts = sig.split(".")
                    if len(parts) > 2:
                        table_name = parts[-2]
                        if table_name not in const_tables:
                            const_tables[table_name] = []
                        const_tables[table_name].append(const)

            # Generate enum annotations for constant tables
            for table_name, table_constants in const_tables.items():
                if len(table_constants) > 2:  # Only for groups with multiple constants
                    output.append("")
                    output.append(f"---@class {module}.{table_name}")
                    for const in table_constants[:5]:  # Show first few as examples
                        const_name = const.get("signature", "").split(".")[-1]
                        const_desc = const.get("description", "")
                        if const_desc:
                            short_desc = truncate_field_description(const_desc)
                            output.append(f"---@field {const_name} any {short_desc}")

        # Generate each non-field API item
        for item in non_field_items:
            annotation = generate_api_item_annotation(item)
            output.extend(annotation)

    return "\n".join(output)


def main():
    """Main execution function."""
    print("=" * 70)
    print("Hammerspoon Type Definition Generator")
    print("=" * 70)

    base_url = "https://www.hammerspoon.org"
    output_file = "hammerspoon.types.lua"

    # Step 1: Get all module URLs
    modules = get_all_modules(base_url)

    if not modules:
        print("Error: No modules found!")
        return 1

    # Step 2: Parse each module's documentation
    print(f"\nParsing {len(modules)} modules...")
    all_api_items = []

    for module_path in modules:
        items = parse_module_documentation(base_url, module_path)
        all_api_items.extend(items)

    print(f"\nExtracted {len(all_api_items)} API items")

    # Step 3: Generate type definitions
    print("\nGenerating type definitions...")
    type_defs = generate_type_definitions(all_api_items)

    # Step 4: Write to file
    print(f"Writing to {output_file}...")
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(type_defs)

    print(f"\n✓ Successfully generated {output_file}")
    print(f"  Total lines: {len(type_defs.splitlines())}")
    print(f"  Total API items: {len(all_api_items)}")

    # Show statistics
    modules_count = len(set(item.get("module", "") for item in all_api_items))
    print(f"  Modules documented: {modules_count}")

    print("\n" + "=" * 70)
    return 0


if __name__ == "__main__":
    exit(main())
