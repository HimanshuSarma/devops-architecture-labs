import sys
import json
from datetime import datetime

def analyze_data(input_string):
    # Perform some "analysis"
    result = {
        "status": "success",
        "timestamp": datetime.now().isoformat(),
        "original_input": input_string,
        "metadata": {
            "char_count": len(input_string),
            "uppercase_version": input_string.upper(),
            "is_numeric": input_string.isdigit()
        },
        "message": f"Python analyzed the data: '{input_string}'"
    }
    return result

if __name__ == "__main__":
    # Check if an argument was passed
    if len(sys.argv) > 1:
        user_input = sys.argv[1]
    else:
        user_input = "no data provided"

    # Run analysis
    analysis_result = analyze_data(user_input)

    # Output as JSON string so Node.js can read it via stdout
    print(json.dumps(analysis_result))