import subprocess
from typing import List

class CommandRunner:
    def run(self, cmd: List[str], timeout: int = 15) -> str:
        try:
            result = subprocess.run(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                check=True,
                timeout=timeout
            )
            output = result.stdout.decode('utf-8', errors='replace')  # Replace decoding errors
            return output
        except subprocess.TimeoutExpired as e:
            raise RuntimeError(f"Command '{' '.join(cmd)}' timed out after {timeout} seconds.")
        except subprocess.CalledProcessError as e:
            error_msg = e.stderr.decode('utf-8', errors='replace')
            raise RuntimeError(f"Command '{' '.join(cmd)}' failed with error: {error_msg}")
        except Exception as e:
            raise RuntimeError(f"Unexpected error occurred: {str(e)}")
