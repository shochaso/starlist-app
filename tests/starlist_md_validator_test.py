#!/usr/bin/env python3
"""
Unit tests for STARLIST Markdown Validator
"""
import unittest
import tempfile
from pathlib import Path
from scripts.starlist_md_validator import (
    parse_frontmatter,
    extract_headings,
    CheckLogger,
    run_checks,
    determine_governance,
    FORBIDDEN_WORDS,
    REQUIRED_FRONTMATTER,
)


class TestStarlistMdValidator(unittest.TestCase):
    def setUp(self):
        self.temp_dir = Path(tempfile.mkdtemp())
        self.logger = CheckLogger()

    def tearDown(self):
        # Clean up temp files
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)

    def create_test_file(self, content: str, filename: str = "test.md") -> Path:
        """Create a temporary test file with given content"""
        test_file = self.temp_dir / filename
        test_file.write_text(content, encoding="utf-8")
        return test_file

    def test_parse_frontmatter_valid(self):
        """Test parsing valid frontmatter"""
        content = """---
source_of_truth: true
version: 1.0.0
updated_date: 2025-01-01
owner: Test Team
---

# Test Document
"""
        lines = content.splitlines()
        frontmatter, start, end = parse_frontmatter(lines)

        self.assertIsNotNone(frontmatter)
        self.assertEqual(frontmatter["source_of_truth"], "true")
        self.assertEqual(frontmatter["version"], "1.0.0")
        self.assertEqual(frontmatter["updated_date"], "2025-01-01")
        self.assertEqual(frontmatter["owner"], "Test Team")
        self.assertEqual(start, 0)
        self.assertEqual(end, 5)

    def test_parse_frontmatter_missing(self):
        """Test parsing content without frontmatter"""
        content = "# Test Document\n\nSome content here."
        lines = content.splitlines()
        frontmatter, start, end = parse_frontmatter(lines)

        self.assertIsNone(frontmatter)
        self.assertIsNone(start)
        self.assertIsNone(end)

    def test_parse_frontmatter_malformed(self):
        """Test parsing malformed frontmatter"""
        content = """---
source_of_truth: true
version: 1.0.0
incomplete frontmatter

# Test Document
"""
        lines = content.splitlines()
        frontmatter, start, end = parse_frontmatter(lines)

        self.assertIsNone(frontmatter)
        self.assertEqual(start, 0)
        self.assertIsNone(end)

    def test_extract_headings(self):
        """Test heading extraction"""
        content = """# Main Title

## Section 1

Some content here.

### Subsection 1.1

## Section 2

#### Invalid Jump (should be flagged)
"""
        lines = content.splitlines()
        headings = extract_headings(lines)

        # Should extract 5 headings
        self.assertEqual(len(headings), 5)

        # Check first heading
        self.assertEqual(headings[0], (1, 1, "Main Title"))

        # Check heading levels
        levels = [level for level, line_num, text in headings]
        self.assertEqual(levels, [1, 2, 3, 2, 4])

    def test_determine_governance(self):
        """Test governance determination"""
        # Governed file (in docs/ops/)
        governed_path = Path("docs/ops/test.md")
        self.assertTrue(determine_governance(governed_path))

        # Non-governed file (in docs/ but not ops/)
        non_governed_path = Path("docs/guides/test.md")
        self.assertFalse(determine_governance(non_governed_path))

        # Non-governed file (outside docs/)
        other_path = Path("README.md")
        self.assertFalse(determine_governance(other_path))

    def test_forbidden_words_detection(self):
        """Test forbidden words detection"""
        # This would be tested in run_checks, but let's verify the constants
        self.assertIn("tbd", FORBIDDEN_WORDS)
        self.assertIn("todo", FORBIDDEN_WORDS)
        self.assertIn("fixme", FORBIDDEN_WORDS)
        self.assertIn("wip", FORBIDDEN_WORDS)

    def test_run_checks_valid_file(self):
        """Test running checks on a valid file"""
        content = """---
source_of_truth: true
version: 1.0.0
updated_date: 2025-01-01
owner: Test Team
---

# Test Document

## 背景
Background content here.

## 要件
Requirements here.

## Runbook
Runbook content.

## 更新
Updates here.

## DoD (Definition of Done)
- [ ] Criteria defined.

## Cursor Implementation Prompt
Implementation details here.

## GitHub Copilot Implementation Prompt
Copilot details here.

```mermaid
graph TD
    A --> B
```

![Alt text](test.png)

| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
"""
        test_file = self.create_test_file(content)
        scanned = run_checks([test_file], self.temp_dir, self.logger)

        # Should scan 1 file
        self.assertEqual(scanned, 1)

        # Should have no errors for a valid file
        self.assertEqual(len(self.logger.entries), 0)

    def test_run_checks_missing_frontmatter(self):
        """Test detection of missing frontmatter"""
        content = """# Test Document

Some content without frontmatter.
"""
        test_file = self.create_test_file(content, "docs/ops/test.md")
        scanned = run_checks([test_file], self.temp_dir, self.logger)

        self.assertEqual(scanned, 1)

        # Should have error for missing frontmatter
        error_codes = [entry["check"] for entry in self.logger.entries]
        self.assertIn("frontmatter-missing", error_codes)

    def test_run_checks_forbidden_word(self):
        """Test detection of forbidden words"""
        content = """---
source_of_truth: true
version: 1.0.0
updated_date: 2025-01-01
owner: Test Team
---

# Test Document

This document is still tbd and needs to be fixed.
"""
        test_file = self.create_test_file(content)
        scanned = run_checks([test_file], self.temp_dir, self.logger)

        self.assertEqual(scanned, 1)

        # Should have error for forbidden word
        error_codes = [entry["check"] for entry in self.logger.entries]
        self.assertIn("forbidden-word", error_codes)

    def test_run_checks_heading_hierarchy(self):
        """Test heading hierarchy validation"""
        content = """---
source_of_truth: true
version: 1.0.0
updated_date: 2025-01-01
owner: Test Team
---

# Main Title

## Section 1

#### Invalid jump from H2 to H4
"""
        test_file = self.create_test_file(content)
        scanned = run_checks([test_file], self.temp_dir, self.logger)

        self.assertEqual(scanned, 1)

        # Should have error for heading hierarchy
        error_codes = [entry["check"] for entry in self.logger.entries]
        self.assertIn("heading-hierarchy", error_codes)

    def test_run_checks_empty_file(self):
        """Test detection of empty files"""
        content = ""
        test_file = self.create_test_file(content)
        scanned = run_checks([test_file], self.temp_dir, self.logger)

        self.assertEqual(scanned, 1)

        # Should have error for empty file
        error_codes = [entry["check"] for entry in self.logger.entries]
        self.assertIn("empty-file", error_codes)

    def test_run_checks_bom_detection(self):
        """Test BOM detection"""
        # Create file with BOM
        test_file = self.temp_dir / "test.md"
        with open(test_file, 'wb') as f:
            f.write(b'\xef\xbb\xbf# Test Document\n')

        scanned = run_checks([test_file], self.temp_dir, self.logger)

        self.assertEqual(scanned, 1)

        # Should have error for BOM
        error_codes = [entry["check"] for entry in self.logger.entries]
        self.assertIn("bom-detected", error_codes)


if __name__ == "__main__":
    unittest.main()
