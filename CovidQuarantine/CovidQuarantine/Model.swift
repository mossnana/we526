class AppUser {
    let name: String
    let id: String
    let latitude: String
    let longtitude: String
    init(name, id, latitude, longtitude) {
        self.name = name
        self.id = id
        self.latitude = latitude
        self.longtitude = longtitude
    }
    override convenience init(name, id, latitude, longtitude) {
        self.init(name, id, latitude, longtitude)
    }
}
