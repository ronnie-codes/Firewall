from script import PacketFilterService

def main():
    """Main"""
    print('running...')
    packet_filter_service = PacketFilterService()
    packet_filter_service.update_tables_with_resolver()
    print('finished...')

if __name__ == "__main__":
    main()