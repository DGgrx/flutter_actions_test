#!/bin/bash

set -e
set -u 

# Generate coverage report
flutter test --coverage

# Define files
NEW_LCOV="coverage/lcov.info"
OLD_LCOV="old_lcov.info"

# Check if old lcov.info exists
if [ ! -f "$OLD_LCOV" ]; then
    echo "No previous lcov.info file found. Skipping comparison."
    exit 0
fi

# Calculate new coverage metrics
new_coverage=$(grep -A 1 "lines" "$NEW_LCOV" | tail -n 1 | awk '{print $2}')
new_total=$(grep -A 1 "lines" "$NEW_LCOV" | tail -n 1 | awk '{print $3}')
new_percentage=$(echo "scale=2; ($new_coverage / $new_total) * 100" | bc)

# Calculate old coverage metrics
old_coverage=$(grep -A 1 "lines" "$OLD_LCOV" | tail -n 1 | awk '{print $2}')
old_total=$(grep -A 1 "lines" "$OLD_LCOV" | tail -n 1 | awk '{print $3}')
old_percentage=$(echo "scale=2; ($old_coverage / $old_total) * 100" | bc)

# Calculate test cases passed
new_tests_passed=$(grep -oP '\d+(?=/)' "$NEW_LCOV" | head -n 1)
new_tests_total=$(grep -oP '(?<=/)\d+' "$NEW_LCOV" | head -n 1)

echo "New Coverage Percentage: $new_percentage%"
echo "Old Coverage Percentage: $old_percentage%"
echo "Test Cases Passed: $new_tests_passed/$new_tests_total"

# Set threshold for coverage percentage
threshold=80.00

# Check if new coverage is below threshold
if (( $(echo "$new_percentage < $threshold" | bc -l) )); then
    echo "Coverage percentage ($new_percentage%) is below the threshold ($threshold%). Blocking PR."
    exit 1
else
    echo "Coverage percentage is acceptable."
fi

# Update old lcov file for future comparisons
cp "$NEW_LCOV" "$OLD_LCOV"

# Export results for GitHub Actions to use later
echo "TEST_CASES_PASSED=$new_tests_passed/$new_tests_total" >> $GITHUB_ENV
echo "DIFF_PERCENTAGE=$(echo "scale=2; $new_percentage - $old_percentage" | bc)" >> $GITHUB_ENV
