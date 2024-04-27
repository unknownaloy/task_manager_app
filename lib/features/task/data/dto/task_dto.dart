class TaskDto {
  const TaskDto({
    required this.skip,
    this.limit = 10,
  });

  final int limit;
  final int skip;

  Map<String, dynamic> toJson() => {
        "limit": limit.toString(),
        "skip": skip.toString(),
      };

  TaskDto copyWith({
    int? limit,
    int? skip,
  }) {
    return TaskDto(
      limit: limit ?? this.limit,
      skip: skip ?? this.skip,
    );
  }
}
