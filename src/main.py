from HostsService import HostsService

def main():
    """Main"""
    hosts_service = HostsService()
    hosts_service.sync_hosts()
    print('finished...')

if __name__ == "__main__":
    main()
