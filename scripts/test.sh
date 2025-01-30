#!/bin/bash

# Run Flutter tests with coverage and capture output
test_output=$(flutter test --no-pub --coverage -r expanded 2>/dev/null)  # Capture both stdout and stderr


# # Get the last line of the output
output=$(echo "$test_output" | tail -n 1)
echo $output

# output="00:00 +5: Some tests failed."

# passed=$(echo "$output" | sed -n 's/.*+\([0-9]*\).*/\1/p')
# failed=$(echo "$output" | sed -n 's/.*-\([0-9]*\).*/\1/p')

passed=$(echo "$output" | grep -o '\+[0-9]*' | tr -d '+' || echo 0)
failed=$(echo "$output" | grep -o '\-[0-9]*' | tr -d '-' || echo 0)

passed=${passed:-0}
failed=${failed:-0}


# Calculate total tests
total=$((passed+failed))

# Print the results
echo "Passed tests: $passed"
echo "Failed tests: $failed"
echo "Total tests: $total"