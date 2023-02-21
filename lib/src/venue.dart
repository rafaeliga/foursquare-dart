import 'api.dart';

class Venue {
  Venue({
    this.venueId,
    this.name,
    this.location,
    this.city,
    this.state,
    this.cc,
    this.categories,
    this.rating,
    this.locationDetails,
    this.distance,
    this.phone,
    this.address,
  });

  final String? venueId;
  final String? name;
  final String? location;
  final String? city;
  final String? state;
  final String? cc;
  final List? categories;
  final double? rating;
  final Map? locationDetails;
  final int? distance;
  final String? phone;
  final String? address;

  @override
  String toString() {
    return '$venueId, $name, $location, $rating';
  }

  bool operator ==(otherVenue) => otherVenue is Venue && venueId == otherVenue.venueId;
  int get hashCode => venueId.hashCode;

  factory Venue.fromJson(Map<String, dynamic> json) {
    String? locationText;

    if (json['location']['formattedAddress'] is List) {
      locationText = json['location']['formattedAddress'].join(' ');
    } else if (json['location']['formattedAddress'].containsKey('text')) {
      locationText = json['location']['formattedAddress']['text'];
    }

    return Venue(
      venueId: json['id'],
      name: json['name'],
      location: locationText,
      city: json['location']['city'] ?? null,
      state: json['location']['state'] ?? null,
      cc: json['location']['cc'] ?? null,
      categories: json['categories'] ?? null,
      rating: json['rating'] ?? null,
      locationDetails: json['location'],
      distance: json['location']['distance'],
      phone: json['contact']['phone'] ?? null,
      address: json['location']['address'] ?? null,
    );
  }

  static Future<Venue> get(API api, String venueId) async {
    return Venue.fromJson((await api.get('venues/$venueId'))!['venue']);
  }

  static Future<List<Venue>> search(API api, double latitude, double longitude, {Map<String, String> parameters = const {}}) async {
    List items = (await api.get('venues/search', parameters: {'ll': '$latitude,$longitude', ...parameters}))!['venues'];
    return items.map((item) => Venue.fromJson(item)).toList();
  }

  static Future<Venue> current(API api, double latitude, double longitude) async {
    return (await Venue.search(api, latitude, longitude, parameters: {'limit': '1'})).elementAt(0);
  }

  static Future<List<Venue>> recommendations(API api, double latitude, double longitude, {Map<String, String> parameters = const {}}) async {
    List items = (await api.get('search/recommendations', parameters: {'ll': '$latitude,$longitude', ...parameters}))!['group']['results'];
    return items.map((item) => Venue.fromJson(item['venue'])).toList();
  }

  static Future<List<Venue>> liked(API api, {userId = 'self'}) async {
    List items = (await api.get('lists/$userId/venuelikes', parameters: {'limit': '10000'}))!['list']['listItems']['items'];
    return items.where((item) => item['type'] == 'venue').map((item) => Venue.fromJson(item['venue'])).toList();
  }

  static Future<List<Venue>> saved(API api, {userId = 'self'}) async {
    List items = (await api.get('lists/$userId/todos', parameters: {'limit': '10000'}))!['list']['listItems']['items'];
    return items.where((item) => item['type'] == 'venue').map((item) => Venue.fromJson(item['venue'])).toList();
  }

  String? getCategoryImageUrl(Map category, int size) {
    if (category['icon'] == null) return null;

    Map icon = category['icon'];

    return "${icon['prefix']}$size${icon['suffix']}";
  }
}
