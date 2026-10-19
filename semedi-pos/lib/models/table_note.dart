class TableNote {
  final int tableNumber;
  final String note;

  const TableNote({
    required this.tableNumber,
    required this.note,
  });

  factory TableNote.fromJson(Map<String, dynamic> json) {
    return TableNote(
      tableNumber: json['table_number'] as int,
      note: json['note'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'table_number': tableNumber,
      'note': note,
    };
  }
}
