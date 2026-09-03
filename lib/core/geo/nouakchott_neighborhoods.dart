class NouakchottNeighborhood {
  const NouakchottNeighborhood({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
}

class NouakchottMapBounds {
  const NouakchottMapBounds._();

  static const minLatitude = 18.02;
  static const maxLatitude = 18.16;
  static const minLongitude = -16.05;
  static const maxLongitude = -15.90;
}

const nouakchottNeighborhoods = [
  NouakchottNeighborhood(
    id: 'tevragh-zeina',
    name: 'Tevragh Zeina',
    latitude: 18.109,
    longitude: -15.999,
  ),
  NouakchottNeighborhood(
    id: 'ksar',
    name: 'Ksar',
    latitude: 18.086,
    longitude: -15.978,
  ),
  NouakchottNeighborhood(
    id: 'capitale',
    name: 'Capitale',
    latitude: 18.085,
    longitude: -15.978,
  ),
  NouakchottNeighborhood(
    id: 'arafat',
    name: 'Arafat',
    latitude: 18.047,
    longitude: -15.962,
  ),
  NouakchottNeighborhood(
    id: 'dar-naim',
    name: 'Dar Naim',
    latitude: 18.100,
    longitude: -15.920,
  ),
  NouakchottNeighborhood(
    id: 'sebkha',
    name: 'Sebkha',
    latitude: 18.073,
    longitude: -16.000,
  ),
  NouakchottNeighborhood(
    id: 'el-mina',
    name: 'El Mina',
    latitude: 18.068,
    longitude: -16.015,
  ),
  NouakchottNeighborhood(
    id: 'toujounine',
    name: 'Toujounine',
    latitude: 18.078,
    longitude: -15.930,
  ),
  NouakchottNeighborhood(
    id: 'teyarett',
    name: 'Teyarett',
    latitude: 18.120,
    longitude: -15.950,
  ),
];
