// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewOrder _$NewOrderFromJson(Map<String, dynamic> json) => NewOrder(
      orderNumber: json['orderNumber'] as String,
      name: json['name'] as String,
      process: json['process'] as String,
      unit: json['unit'] as String,
      type: json['type'] as String,
      quantity: (json['quantity'] as num).toInt(),
      rate: (json['rate'] as num).toDouble(),
      estimatedPrice: (json['estimatedPrice'] as num).toDouble(),
      filePath: json['filePath'] as String,
      dates: json['dates'] as Map<String, dynamic>,
      journalTransferNumber: json['journalTransferNumber'] as String,
      department: json['department'] as String,
      status: json['status'] as String,
      comment: (json['comment'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      successMessage: json['successMessage'] as String?,
      imagePath: json['imagePath'] as String?,
      cancelRequested: json['cancelRequested'] as bool,
    );

Map<String, dynamic> _$NewOrderToJson(NewOrder instance) => <String, dynamic>{
      'orderNumber': instance.orderNumber,
      'name': instance.name,
      'process': instance.process,
      'unit': instance.unit,
      'type': instance.type,
      'quantity': instance.quantity,
      'rate': instance.rate,
      'estimatedPrice': instance.estimatedPrice,
      'filePath': instance.filePath,
      'dates': instance.dates,
      'journalTransferNumber': instance.journalTransferNumber,
      'department': instance.department,
      'imagePath': instance.imagePath,
      'status': instance.status,
      'comment': instance.comment,
      'successMessage': instance.successMessage,
      'cancelRequested': instance.cancelRequested,
    };
