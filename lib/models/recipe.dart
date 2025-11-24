class Recipe {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? imagePath;
  final int servings;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Recipe({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.imagePath,
    required this.servings,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imagePath: json['image_path'] as String?,
      servings: json['servings'] as int? ?? 1,
      prepTimeMinutes: json['prep_time_minutes'] as int?,
      cookTimeMinutes: json['cook_time_minutes'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'image_path': imagePath,
      'servings': servings,
      'prep_time_minutes': prepTimeMinutes,
      'cook_time_minutes': cookTimeMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class RecipeIngredient {
  final String id;
  final String recipeId;
  final String ingredientId;
  final double amountGrams;
  final String? notes;
  final DateTime createdAt;

  const RecipeIngredient({
    required this.id,
    required this.recipeId,
    required this.ingredientId,
    required this.amountGrams,
    this.notes,
    required this.createdAt,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'] as String,
      recipeId: json['recipe_id'] as String,
      ingredientId: json['ingredient_id'] as String,
      amountGrams: (json['amount_grams'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'ingredient_id': ingredientId,
      'amount_grams': amountGrams,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class CookingStep {
  final String id;
  final String recipeId;
  final int stepNumber;
  final String instruction;
  final int? durationMinutes;
  final DateTime createdAt;

  const CookingStep({
    required this.id,
    required this.recipeId,
    required this.stepNumber,
    required this.instruction,
    this.durationMinutes,
    required this.createdAt,
  });

  factory CookingStep.fromJson(Map<String, dynamic> json) {
    return CookingStep(
      id: json['id'] as String,
      recipeId: json['recipe_id'] as String,
      stepNumber: json['step_number'] as int,
      instruction: json['instruction'] as String,
      durationMinutes: json['duration_minutes'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'step_number': stepNumber,
      'instruction': instruction,
      'duration_minutes': durationMinutes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
