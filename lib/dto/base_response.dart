// lib/dto/base_response.dart

class BaseResponse<T> {
  final Metadata metadata;
  final T response;

  BaseResponse({
    required this.metadata,
    required this.response,
  });

  factory BaseResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return BaseResponse(
      metadata: Metadata.fromJson(json['metadata']),
      response: fromJsonT(json['response']),
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'metadata': metadata.toJson(),
      'response': toJsonT(response),
    };
  }
}

//metda data

class Metadata {
  final int code;
  final String message;

  Metadata({
    required this.code,
    required this.message,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      code: json['code'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
