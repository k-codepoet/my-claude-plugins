#!/bin/bash
# validate-plugin.sh - 플러그인 기본 검증 스크립트
# Usage: ./validate-plugin.sh [plugin-path]
#
# Exit codes:
#   0 - 검증 통과 (errors=0)
#   1 - 검증 실패 (errors>0)
#   2 - 플러그인 경로 오류

set -euo pipefail

PLUGIN_PATH="${1:-.}"
ERRORS=0
WARNINGS=0

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

error() {
    echo -e "${RED}❌ [ERROR]${NC} $1"
    ((ERRORS++)) || true
}

warning() {
    echo -e "${YELLOW}⚠️  [WARN]${NC} $1"
    ((WARNINGS++)) || true
}

success() {
    echo -e "${GREEN}✅${NC} $1"
}

# 플러그인 경로 확인
if [ ! -d "$PLUGIN_PATH" ]; then
    echo "Error: Plugin path not found: $PLUGIN_PATH"
    exit 2
fi

PLUGIN_JSON="$PLUGIN_PATH/.claude-plugin/plugin.json"
if [ ! -f "$PLUGIN_JSON" ]; then
    echo "Error: plugin.json not found at $PLUGIN_JSON"
    exit 2
fi

PLUGIN_NAME=$(jq -r '.name // empty' "$PLUGIN_JSON")
echo "=========================================="
echo "Validation Report: $PLUGIN_NAME"
echo "=========================================="
echo ""

# 1. plugin.json 검증
echo "## plugin.json"

# name (kebab-case)
if [ -z "$PLUGIN_NAME" ]; then
    error "plugin.json: Missing required field 'name'"
elif ! echo "$PLUGIN_NAME" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    error "plugin.json: 'name' must be kebab-case (got: $PLUGIN_NAME)"
else
    success "name: $PLUGIN_NAME"
fi

# version
VERSION=$(jq -r '.version // empty' "$PLUGIN_JSON")
if [ -z "$VERSION" ]; then
    error "plugin.json: Missing required field 'version'"
else
    success "version: $VERSION"
fi

# description
DESC=$(jq -r '.description // empty' "$PLUGIN_JSON")
if [ -z "$DESC" ]; then
    error "plugin.json: Missing required field 'description'"
else
    success "description: present"
fi

# author.name
AUTHOR=$(jq -r '.author.name // empty' "$PLUGIN_JSON")
if [ -z "$AUTHOR" ]; then
    error "plugin.json: Missing required field 'author.name'"
else
    success "author.name: $AUTHOR"
fi

echo ""

# 2. commands/*.md 검증
echo "## commands/"
COMMANDS_DIR="$PLUGIN_PATH/commands"
if [ -d "$COMMANDS_DIR" ]; then
    CMD_COUNT=0
    CMD_OK=0
    for cmd_file in "$COMMANDS_DIR"/*.md; do
        [ -f "$cmd_file" ] || continue
        ((CMD_COUNT++)) || true
        cmd_name=$(basename "$cmd_file")

        # description frontmatter 확인
        if head -20 "$cmd_file" | grep -q "^description:"; then
            ((CMD_OK++)) || true
        else
            error "commands/$cmd_name: Missing 'description' in frontmatter"
        fi
    done

    if [ "$CMD_COUNT" -eq "$CMD_OK" ] && [ "$CMD_COUNT" -gt 0 ]; then
        success "All $CMD_COUNT commands have description"
    elif [ "$CMD_COUNT" -eq 0 ]; then
        warning "No commands found"
    fi
else
    warning "No commands/ directory"
fi

echo ""

# 3. skills/*/SKILL.md 검증
echo "## skills/"
SKILLS_DIR="$PLUGIN_PATH/skills"
if [ -d "$SKILLS_DIR" ]; then
    SKILL_COUNT=0
    SKILL_OK=0
    for skill_dir in "$SKILLS_DIR"/*/; do
        [ -d "$skill_dir" ] || continue
        skill_name=$(basename "$skill_dir")
        skill_file="$skill_dir/SKILL.md"

        ((SKILL_COUNT++)) || true

        if [ ! -f "$skill_file" ]; then
            error "skills/$skill_name: Missing SKILL.md"
            continue
        fi

        # name 필드 확인 (디렉토리명과 일치)
        name_in_file=$(grep -m1 "^name:" "$skill_file" 2>/dev/null | sed 's/name: *//' || echo "")
        if [ -z "$name_in_file" ]; then
            error "skills/$skill_name/SKILL.md: Missing 'name' in frontmatter"
        elif [ "$name_in_file" != "$skill_name" ]; then
            error "skills/$skill_name/SKILL.md: name mismatch (file: $name_in_file, dir: $skill_name)"
        else
            # description 확인
            if head -10 "$skill_file" | grep -q "^description:"; then
                ((SKILL_OK++)) || true
            else
                error "skills/$skill_name/SKILL.md: Missing 'description' in frontmatter"
            fi
        fi
    done

    if [ "$SKILL_COUNT" -eq "$SKILL_OK" ] && [ "$SKILL_COUNT" -gt 0 ]; then
        success "All $SKILL_COUNT skills valid"
    elif [ "$SKILL_COUNT" -eq 0 ]; then
        warning "No skills found"
    fi
else
    warning "No skills/ directory"
fi

echo ""

# 4. agents/*.md 검증 (있는 경우)
echo "## agents/"
AGENTS_DIR="$PLUGIN_PATH/agents"
if [ -d "$AGENTS_DIR" ]; then
    AGENT_COUNT=0
    AGENT_OK=0
    for agent_file in "$AGENTS_DIR"/*.md; do
        [ -f "$agent_file" ] || continue
        ((AGENT_COUNT++)) || true
        agent_name=$(basename "$agent_file")

        # name, description, example 확인
        has_name=$(head -20 "$agent_file" | grep -c "^name:" 2>/dev/null) || has_name=0
        has_desc=$(head -20 "$agent_file" | grep -c "^description:" 2>/dev/null) || has_desc=0
        has_example=$(grep -c "<example>" "$agent_file" 2>/dev/null) || has_example=0

        if [ "$has_name" -eq 0 ]; then
            error "agents/$agent_name: Missing 'name' in frontmatter"
        elif [ "$has_desc" -eq 0 ]; then
            error "agents/$agent_name: Missing 'description' in frontmatter"
        elif [ "$has_example" -eq 0 ]; then
            warning "agents/$agent_name: Missing <example> block (recommended)"
            ((AGENT_OK++)) || true
        else
            ((AGENT_OK++)) || true
        fi
    done

    if [ "$AGENT_COUNT" -eq "$AGENT_OK" ] && [ "$AGENT_COUNT" -gt 0 ]; then
        success "All $AGENT_COUNT agents valid"
    elif [ "$AGENT_COUNT" -eq 0 ]; then
        echo "No agents found (optional)"
    fi
else
    echo "No agents/ directory (optional)"
fi

echo ""

# 5. hooks/hooks.json 검증 (있는 경우)
echo "## hooks/"
HOOKS_JSON="$PLUGIN_PATH/hooks/hooks.json"
if [ -f "$HOOKS_JSON" ]; then
    # hooks 객체 존재 확인
    if jq -e '.hooks' "$HOOKS_JSON" > /dev/null 2>&1; then
        success "hooks.json structure valid"
    else
        error "hooks/hooks.json: Missing 'hooks' object"
    fi
else
    echo "No hooks/hooks.json (optional)"
fi

echo ""

# 6. CHANGELOG.md 검증
echo "## changelog/"
CHANGELOG_FILE="$PLUGIN_PATH/CHANGELOG.md"
if [ -f "$CHANGELOG_FILE" ]; then
    # 최신 버전 및 날짜 추출
    CHANGELOG_VERSION=$(grep -m1 '## \[' "$CHANGELOG_FILE" | grep -oE '\[[0-9]+\.[0-9]+\.[0-9]+\]' | tr -d '[]' || echo "")
    CHANGELOG_DATE=$(grep -m1 '## \[' "$CHANGELOG_FILE" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || echo "")

    if [ -z "$CHANGELOG_VERSION" ]; then
        warning "CHANGELOG.md: Could not parse version"
    elif [ "$VERSION" != "$CHANGELOG_VERSION" ]; then
        error "Version mismatch: plugin.json ($VERSION) != CHANGELOG.md ($CHANGELOG_VERSION)"
    else
        success "Version match: plugin.json ($VERSION) = CHANGELOG.md ($CHANGELOG_VERSION)"
    fi

    # Git history 기반 변경 파일 추적
    if [ -n "$CHANGELOG_DATE" ] && command -v git &> /dev/null; then
        # git repo 내부인지 확인
        if git -C "$PLUGIN_PATH" rev-parse --git-dir > /dev/null 2>&1; then
            # 해당 날짜 이후 변경된 파일 조회 (의미 있는 파일만)
            CHANGED_FILES=$(git -C "$PLUGIN_PATH" log --since="$CHANGELOG_DATE 23:59:59" --name-only --pretty=format: -- . 2>/dev/null | \
                grep -v '^$' | \
                grep -v 'CHANGELOG.md' | \
                grep -v '\.gitignore' | \
                grep -v '\.gitkeep' | \
                grep -vE '\.(bak|tmp)$' | \
                sort -u || echo "")

            if [ -n "$CHANGED_FILES" ]; then
                FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')
                warning "Found $FILE_COUNT file(s) changed after $CHANGELOG_DATE not in CHANGELOG:"
                echo "$CHANGED_FILES" | head -10 | while read -r file; do
                    echo "    - $file"
                done
                if [ "$FILE_COUNT" -gt 10 ]; then
                    echo "    ... and $((FILE_COUNT - 10)) more"
                fi
                echo ""
                echo "  Recommendation:"
                echo "    1. Review if these changes warrant a version bump"
                echo "    2. Update CHANGELOG.md with changes"
                echo "    3. Bump version in plugin.json"
            else
                success "No unreported changes since $CHANGELOG_DATE"
            fi
        else
            echo "  (git not available for history check)"
        fi
    fi
else
    warning "No CHANGELOG.md found"
fi

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo "Errors:   $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ "$ERRORS" -gt 0 ]; then
    echo -e "${RED}❌ Validation FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Validation PASSED${NC}"
    exit 0
fi
