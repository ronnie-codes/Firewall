import subprocess
from typing import List

class CommandRunner:
    def run(self, cmd: List[str]) -> str:
        try:
            result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
            output = result.stdout.decode('utf-8')
            return output
        except subprocess.CalledProcessError as e:
            error_msg = e.stderr.decode('utf-8')
            raise RuntimeError(f"Command '{' '.join(cmd)}' failed with error: {error_msg}")
