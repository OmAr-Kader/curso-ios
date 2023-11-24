import Network

func isNetworkAvailable() -> Bool {
    return NWPathMonitor().currentPath.status == .satisfied
}
