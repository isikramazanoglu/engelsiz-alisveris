import sys
import os

# Add backend directory to path
sys.path.append(os.path.abspath("backend"))

try:
    from backend.main import app
    print("Successfully imported app.")
    
    # Try initializing dependencies
    from backend.app.api import deps
    from backend.app.core import security
    print("Dependencies and security module imported successfully.")
    
    # Mock some token generation
    token = security.create_access_token("test_user")
    print(f"Token generation test: {token[:10]}...")
    
except Exception as e:
    import traceback
    with open("error.log", "w") as f:
        f.write(f"Failed to verify backend: {e}\n")
        traceback.print_exc(file=f)
    print(f"Failed to verify backend: {e}")
    sys.exit(1)
