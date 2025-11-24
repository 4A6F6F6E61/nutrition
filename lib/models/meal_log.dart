class MealLog {
  final String id;
  final String userId;
  final String recipeId;
  final DateTime consumedAt;
  final double servingsConsumed;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MealLog({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.consumedAt,
    required this.servingsConsumed,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      recipeId: json['recipe_id'] as String,
      consumedAt: DateTime.parse(json['consumed_at'] as String),
      servingsConsumed: (json['servings_consumed'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'recipe_id': recipeId,
      'consumed_at': consumedAt.toIso8601String(),
      'servings_consumed': servingsConsumed,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class DailyNutrition {
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  const DailyNutrition({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  factory DailyNutrition.fromJson(Map<String, dynamic> json) {
    return DailyNutrition(
      totalCalories: (json['total_calories'] as num?)?.toDouble() ?? 0.0,
      totalProtein: (json['total_protein'] as num?)?.toDouble() ?? 0.0,
      totalCarbs: (json['total_carbs'] as num?)?.toDouble() ?? 0.0,
      totalFat: (json['total_fat'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class UserPreferences {
  final String userId;
  final int dailyCalorieGoal;
  final double dailyProteinGoal;
  final double dailyCarbGoal;
  final double dailyFatGoal;

  const UserPreferences({
    required this.userId,
    required this.dailyCalorieGoal,
    required this.dailyProteinGoal,
    required this.dailyCarbGoal,
    required this.dailyFatGoal,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['user_id'] as String,
      dailyCalorieGoal: json['daily_calorie_goal'] as int? ?? 2000,
      dailyProteinGoal:
          (json['daily_protein_goal'] as num?)?.toDouble() ?? 50.0,
      dailyCarbGoal: (json['daily_carb_goal'] as num?)?.toDouble() ?? 250.0,
      dailyFatGoal: (json['daily_fat_goal'] as num?)?.toDouble() ?? 70.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'daily_calorie_goal': dailyCalorieGoal,
      'daily_protein_goal': dailyProteinGoal,
      'daily_carb_goal': dailyCarbGoal,
      'daily_fat_goal': dailyFatGoal,
    };
  }
}
