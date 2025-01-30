#!/bin/bash


# Generate coverage report
# flutter test --coverage --no-pub

test

# Define files
NEW_LCOV="coverage/lcov.info"
OLD_LCOV="old_lcov.info"

# Check if old lcov.info exists
if [ ! -f "$OLD_LCOV" ]; then
    echo "No previous lcov.info file found. Skipping comparison."
    exit 0
fi

calculate_coverage() {
  local file=$1
  total_lines=0
  lines_hit=0

  # Read the lcov.info file line by line
  while IFS= read -r line; do
    # If the line starts with 'LF:', it indicates the total number of lines
    if [[ $line =~ ^LF: ]]; then
      total_lines=$((total_lines + ${line#*:}))
    fi
    
    # If the line starts with 'LH:', it indicates the number of lines hit
    if [[ $line =~ ^LH: ]]; then
      lines_hit=$((lines_hit + ${line#*:}))
    fi
  done < "$file"

  # If total_lines is 0, set to 1 to avoid division by zero
  if [ $total_lines -eq 0 ]; then
    lines_hit=0
    total_lines=1
  fi

  # Calculate the line coverage percentage
  coverage_percentage=$(echo "scale=2; $lines_hit / $total_lines * 100" | bc)
  coverage_percentage=$(( ${coverage_percentage%.*} ))

  # Return values via echo
  echo "$coverage_percentage"
}


new_percentage=$(calculate_coverage $NEW_LCOV)
old_percentage=$(calculate_coverage $OLD_LCOV)

# Calculate new coverage metrics
# new_coverage=$(ggrep -A 1 "lines" "$NEW_LCOV" | tail -n 1 | awk '{print $2}')
# new_total=$(ggrep -A 1 "lines" "$NEW_LCOV" | tail -n 1 | awk '{print $3}')
# new_percentage=$(echo "scale=2; ($new_coverage / $new_total) * 100" | bc)

# # Calculate old coverage metrics
# old_coverage=$(ggrep -A 1 "lines" "$OLD_LCOV" | tail -n 1 | awk '{print $2}')
# old_total=$(ggrep -A 1 "lines" "$OLD_LCOV" | tail -n 1 | awk '{print $3}')
# old_percentage=$(echo "scale=2; ($old_coverage / $old_total) * 100" | bc)

# Calculate test cases passed
# new_tests_passed=$(ggrep -oP '\d+(?=/)' "$NEW_LCOV" | head -n 1)
# new_tests_total=$(ggrep -oP '(?<=/)\d+' "$NEW_LCOV" | head -n 1)

echo "New Coverage Percentage: $new_percentage%"
echo "Old Coverage Percentage: $old_percentage%"
echo $new_tests_passed
echo $old_tests_passed
# echo "Test Cases Passed: $new_tests_passed/$new_tests_total"

# Set threshold for coverage percentage
# threshold=80.00

# # Check if new coverage is below threshold
# if (( $(echo "$new_percentage < $threshold" | bc -l) )); then
#     echo "Coverage percentage ($new_percentage%) is below the threshold ($threshold%). Blocking PR."
#     exit 1
# else
#     echo "Coverage percentage is acceptable."
# fi

# Update old lcov file for future comparisons
# cp "$NEW_LCOV" "$OLD_LCOV"

# # Export results for GitHub Actions to use later
# echo "TEST_CASES_PASSED=$new_tests_passed/$new_tests_total" >> $GITHUB_ENV
# echo "DIFF_PERCENTAGE=$(echo "scale=2; $new_percentage - $old_percentage" | bc)" >> $GITHUB_ENV