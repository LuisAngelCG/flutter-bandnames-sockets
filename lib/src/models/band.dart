class Band {
  //lo quye llega del backend
  String id;
  String name;
  int votes;

  //se define el constructor
  Band({
    required this.id,
    required this.name,
    required this.votes,
  });

  //respuesta del backend como mapa
  factory Band.fromMap(Map<String, dynamic> obj) =>
      Band(
        id: obj.containsKey('id') ? obj['id']:'no-id',
        name: obj.containsKey('name') ? obj['name']: 'no-name',
        votes: obj.containsKey('votes') ? obj['votes']: 'no-votes'
      );
}
