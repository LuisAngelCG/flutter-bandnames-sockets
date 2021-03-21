class Band {
  //lo quye llega del backend
  String id;
  String name;
  int votes;

  //se define el constructor
  Band({
    this.id,
    this.name,
    this.votes,
  });

  //respuesta del backend como mapa
  factory Band.fromMap(Map<String, dynamic> obj) =>
      Band(id: obj['id'], name: obj['name'], votes: obj['votes']);
}
