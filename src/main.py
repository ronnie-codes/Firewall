from HostsService import HostsService
import getpass
import os

def main():
    """Main"""
    print(f"Running as user: {getpass.getuser()}")
    print(f"Current directory: {os.getcwd()}")
    print(f"File exists: {os.path.exists('hosts.txt')}")
    print(f"File readable: {os.access('hosts.txt', os.R_OK)}")

    hosts_service = HostsService()
    hosts_service.sync_hosts()
    print('finished...')

if __name__ == "__main__":
    main()
