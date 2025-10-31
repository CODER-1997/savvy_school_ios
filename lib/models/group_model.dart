class GroupModel {
  final String name;
  final String uniqueId;
  final String warnedDay;
  final String docId;
  final int order;




  GroupModel( {
    required this.name,
    required this.uniqueId,
    required this.order,
    required this.warnedDay,
    required this.docId,


  });

// Convert the object to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uniqueId': uniqueId,
      'order': order,
      'warnedDay': warnedDay,
      'docId': docId,


    };
  }
}
