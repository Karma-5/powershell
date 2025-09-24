import csv
import sys

def create_users_from_csv(filename):
    """
    Reads user data from a CSV file and simulates user creation.

    Args:
        filename (str): The path to the CSV file containing user data.
    """
    try:
        # Open the CSV file. The 'with' statement ensures the file is
        # automatically closed even if errors occur.
        with open(filename, mode='r', newline='', encoding='utf-8') as csvfile:
            # Use DictReader to read each row as a dictionary with column headers
            # as keys. This is more readable than using indices.
            reader = csv.DictReader(csvfile)

            # Check if the required headers are present.
            required_headers = ['username', 'email', 'first_name', 'last_name']
            if not all(header in reader.fieldnames for header in required_headers):
                print(f"Error: CSV file must contain the following headers: {required_headers}")
                return

            print(f"Processing users from {filename}...")
            # Loop through each row (user) in the CSV file
            for row in reader:
                # Extract user information from the dictionary.
                username = row.get('username')
                email = row.get('email')
                first_name = row.get('first_name')
                last_name = row.get('last_name')

                # Basic validation: ensure essential fields are not empty.
                if not username or not email:
                    print(f"Skipping row with missing username or email: {row}")
                    continue

                # --- The actual user creation logic goes here ---
                # This is a placeholder. In a real-world scenario, you would
                # replace this with code that interacts with your system,
                # e.g., a user management API, a database, or a system command.

                # Example of a mock user creation process:
                print(f"\nAttempting to create user: {username}")
                print(f"  - Username: {username}")
                print(f"  - Email: {email}")
                print(f"  - Full Name: {first_name} {last_name}")

                # Simulate a successful creation.
                print(f"Successfully processed user '{username}'.")

    except FileNotFoundError:
        print(f"Error: The file '{filename}' was not found.")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        sys.exit(1)

# This block allows the script to be run directly from the command line.
if __name__ == "__main__":
    # To run this script, you'll need a CSV file named 'users.csv'
    # in the same directory.
    # Here's an example of what the file should look like:
    # username,email,first_name,last_name
    # jdoe,jdoe@example.com,John,Doe
    # asmith,asmith@example.com,Alice,Smith
    # rparker,rparker@example.com,Robert,Parker

    # You can also pass the filename as a command-line argument.
    if len(sys.argv) > 1:
        csv_file = sys.argv[1]
    else:
        csv_file = 'users.csv' # Default filename if no argument is provided

    create_users_from_csv(csv_file)
