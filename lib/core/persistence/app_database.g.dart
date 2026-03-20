// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $StoredEventSessionsTable extends StoredEventSessions
    with TableInfo<$StoredEventSessionsTable, StoredEventSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredEventSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventNameMeta = const VerificationMeta(
    'eventName',
  );
  @override
  late final GeneratedColumn<String> eventName = GeneratedColumn<String>(
    'event_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostLanguageMeta = const VerificationMeta(
    'hostLanguage',
  );
  @override
  late final GeneratedColumn<String> hostLanguage = GeneratedColumn<String>(
    'host_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTimeZoneMeta = const VerificationMeta(
    'eventTimeZone',
  );
  @override
  late final GeneratedColumn<String> eventTimeZone = GeneratedColumn<String>(
    'event_time_zone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDaylightSavingTimeEnabledMeta =
      const VerificationMeta('isDaylightSavingTimeEnabled');
  @override
  late final GeneratedColumn<bool> isDaylightSavingTimeEnabled =
      GeneratedColumn<bool>(
        'is_daylight_saving_time_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_daylight_saving_time_enabled" IN (0, 1))',
        ),
      );
  static const VerificationMeta _scheduledStartAtMeta = const VerificationMeta(
    'scheduledStartAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledStartAt =
      GeneratedColumn<DateTime>(
        'scheduled_start_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _actualStartAtMeta = const VerificationMeta(
    'actualStartAt',
  );
  @override
  late final GeneratedColumn<DateTime> actualStartAt =
      GeneratedColumn<DateTime>(
        'actual_start_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supportedLanguagesJsonMeta =
      const VerificationMeta('supportedLanguagesJson');
  @override
  late final GeneratedColumn<String> supportedLanguagesJson =
      GeneratedColumn<String>(
        'supported_languages_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _moderationSettingsJsonMeta =
      const VerificationMeta('moderationSettingsJson');
  @override
  late final GeneratedColumn<String> moderationSettingsJson =
      GeneratedColumn<String>(
        'moderation_settings_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _moderationRuntimeJsonMeta =
      const VerificationMeta('moderationRuntimeJson');
  @override
  late final GeneratedColumn<String> moderationRuntimeJson =
      GeneratedColumn<String>(
        'moderation_runtime_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _transcriptRetentionPolicyMeta =
      const VerificationMeta('transcriptRetentionPolicy');
  @override
  late final GeneratedColumn<String> transcriptRetentionPolicy =
      GeneratedColumn<String>(
        'transcript_retention_policy',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _transcriptExpiresAtMeta =
      const VerificationMeta('transcriptExpiresAt');
  @override
  late final GeneratedColumn<DateTime> transcriptExpiresAt =
      GeneratedColumn<DateTime>(
        'transcript_expires_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    eventName,
    hostLanguage,
    eventTimeZone,
    isDaylightSavingTimeEnabled,
    scheduledStartAt,
    actualStartAt,
    endedAt,
    status,
    supportedLanguagesJson,
    moderationSettingsJson,
    moderationRuntimeJson,
    transcriptRetentionPolicy,
    transcriptExpiresAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_event_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredEventSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('event_name')) {
      context.handle(
        _eventNameMeta,
        eventName.isAcceptableOrUnknown(data['event_name']!, _eventNameMeta),
      );
    } else if (isInserting) {
      context.missing(_eventNameMeta);
    }
    if (data.containsKey('host_language')) {
      context.handle(
        _hostLanguageMeta,
        hostLanguage.isAcceptableOrUnknown(
          data['host_language']!,
          _hostLanguageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hostLanguageMeta);
    }
    if (data.containsKey('event_time_zone')) {
      context.handle(
        _eventTimeZoneMeta,
        eventTimeZone.isAcceptableOrUnknown(
          data['event_time_zone']!,
          _eventTimeZoneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventTimeZoneMeta);
    }
    if (data.containsKey('is_daylight_saving_time_enabled')) {
      context.handle(
        _isDaylightSavingTimeEnabledMeta,
        isDaylightSavingTimeEnabled.isAcceptableOrUnknown(
          data['is_daylight_saving_time_enabled']!,
          _isDaylightSavingTimeEnabledMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isDaylightSavingTimeEnabledMeta);
    }
    if (data.containsKey('scheduled_start_at')) {
      context.handle(
        _scheduledStartAtMeta,
        scheduledStartAt.isAcceptableOrUnknown(
          data['scheduled_start_at']!,
          _scheduledStartAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledStartAtMeta);
    }
    if (data.containsKey('actual_start_at')) {
      context.handle(
        _actualStartAtMeta,
        actualStartAt.isAcceptableOrUnknown(
          data['actual_start_at']!,
          _actualStartAtMeta,
        ),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('supported_languages_json')) {
      context.handle(
        _supportedLanguagesJsonMeta,
        supportedLanguagesJson.isAcceptableOrUnknown(
          data['supported_languages_json']!,
          _supportedLanguagesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_supportedLanguagesJsonMeta);
    }
    if (data.containsKey('moderation_settings_json')) {
      context.handle(
        _moderationSettingsJsonMeta,
        moderationSettingsJson.isAcceptableOrUnknown(
          data['moderation_settings_json']!,
          _moderationSettingsJsonMeta,
        ),
      );
    }
    if (data.containsKey('moderation_runtime_json')) {
      context.handle(
        _moderationRuntimeJsonMeta,
        moderationRuntimeJson.isAcceptableOrUnknown(
          data['moderation_runtime_json']!,
          _moderationRuntimeJsonMeta,
        ),
      );
    }
    if (data.containsKey('transcript_retention_policy')) {
      context.handle(
        _transcriptRetentionPolicyMeta,
        transcriptRetentionPolicy.isAcceptableOrUnknown(
          data['transcript_retention_policy']!,
          _transcriptRetentionPolicyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transcriptRetentionPolicyMeta);
    }
    if (data.containsKey('transcript_expires_at')) {
      context.handle(
        _transcriptExpiresAtMeta,
        transcriptExpiresAt.isAcceptableOrUnknown(
          data['transcript_expires_at']!,
          _transcriptExpiresAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  StoredEventSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredEventSession(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      eventName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_name'],
      )!,
      hostLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host_language'],
      )!,
      eventTimeZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_time_zone'],
      )!,
      isDaylightSavingTimeEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_daylight_saving_time_enabled'],
      )!,
      scheduledStartAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_start_at'],
      )!,
      actualStartAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actual_start_at'],
      ),
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      supportedLanguagesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supported_languages_json'],
      )!,
      moderationSettingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moderation_settings_json'],
      )!,
      moderationRuntimeJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moderation_runtime_json'],
      )!,
      transcriptRetentionPolicy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript_retention_policy'],
      )!,
      transcriptExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transcript_expires_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StoredEventSessionsTable createAlias(String alias) {
    return $StoredEventSessionsTable(attachedDatabase, alias);
  }
}

class StoredEventSession extends DataClass
    implements Insertable<StoredEventSession> {
  final String eventId;
  final String eventName;
  final String hostLanguage;
  final String eventTimeZone;
  final bool isDaylightSavingTimeEnabled;
  final DateTime scheduledStartAt;
  final DateTime? actualStartAt;
  final DateTime? endedAt;
  final String status;
  final String supportedLanguagesJson;
  final String moderationSettingsJson;
  final String moderationRuntimeJson;
  final String transcriptRetentionPolicy;
  final DateTime? transcriptExpiresAt;
  final DateTime updatedAt;
  const StoredEventSession({
    required this.eventId,
    required this.eventName,
    required this.hostLanguage,
    required this.eventTimeZone,
    required this.isDaylightSavingTimeEnabled,
    required this.scheduledStartAt,
    this.actualStartAt,
    this.endedAt,
    required this.status,
    required this.supportedLanguagesJson,
    required this.moderationSettingsJson,
    required this.moderationRuntimeJson,
    required this.transcriptRetentionPolicy,
    this.transcriptExpiresAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['event_name'] = Variable<String>(eventName);
    map['host_language'] = Variable<String>(hostLanguage);
    map['event_time_zone'] = Variable<String>(eventTimeZone);
    map['is_daylight_saving_time_enabled'] = Variable<bool>(
      isDaylightSavingTimeEnabled,
    );
    map['scheduled_start_at'] = Variable<DateTime>(scheduledStartAt);
    if (!nullToAbsent || actualStartAt != null) {
      map['actual_start_at'] = Variable<DateTime>(actualStartAt);
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['status'] = Variable<String>(status);
    map['supported_languages_json'] = Variable<String>(supportedLanguagesJson);
    map['moderation_settings_json'] = Variable<String>(moderationSettingsJson);
    map['moderation_runtime_json'] = Variable<String>(moderationRuntimeJson);
    map['transcript_retention_policy'] = Variable<String>(
      transcriptRetentionPolicy,
    );
    if (!nullToAbsent || transcriptExpiresAt != null) {
      map['transcript_expires_at'] = Variable<DateTime>(transcriptExpiresAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StoredEventSessionsCompanion toCompanion(bool nullToAbsent) {
    return StoredEventSessionsCompanion(
      eventId: Value(eventId),
      eventName: Value(eventName),
      hostLanguage: Value(hostLanguage),
      eventTimeZone: Value(eventTimeZone),
      isDaylightSavingTimeEnabled: Value(isDaylightSavingTimeEnabled),
      scheduledStartAt: Value(scheduledStartAt),
      actualStartAt: actualStartAt == null && nullToAbsent
          ? const Value.absent()
          : Value(actualStartAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      status: Value(status),
      supportedLanguagesJson: Value(supportedLanguagesJson),
      moderationSettingsJson: Value(moderationSettingsJson),
      moderationRuntimeJson: Value(moderationRuntimeJson),
      transcriptRetentionPolicy: Value(transcriptRetentionPolicy),
      transcriptExpiresAt: transcriptExpiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(transcriptExpiresAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory StoredEventSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredEventSession(
      eventId: serializer.fromJson<String>(json['eventId']),
      eventName: serializer.fromJson<String>(json['eventName']),
      hostLanguage: serializer.fromJson<String>(json['hostLanguage']),
      eventTimeZone: serializer.fromJson<String>(json['eventTimeZone']),
      isDaylightSavingTimeEnabled: serializer.fromJson<bool>(
        json['isDaylightSavingTimeEnabled'],
      ),
      scheduledStartAt: serializer.fromJson<DateTime>(json['scheduledStartAt']),
      actualStartAt: serializer.fromJson<DateTime?>(json['actualStartAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      status: serializer.fromJson<String>(json['status']),
      supportedLanguagesJson: serializer.fromJson<String>(
        json['supportedLanguagesJson'],
      ),
      moderationSettingsJson: serializer.fromJson<String>(
        json['moderationSettingsJson'],
      ),
      moderationRuntimeJson: serializer.fromJson<String>(
        json['moderationRuntimeJson'],
      ),
      transcriptRetentionPolicy: serializer.fromJson<String>(
        json['transcriptRetentionPolicy'],
      ),
      transcriptExpiresAt: serializer.fromJson<DateTime?>(
        json['transcriptExpiresAt'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'eventName': serializer.toJson<String>(eventName),
      'hostLanguage': serializer.toJson<String>(hostLanguage),
      'eventTimeZone': serializer.toJson<String>(eventTimeZone),
      'isDaylightSavingTimeEnabled': serializer.toJson<bool>(
        isDaylightSavingTimeEnabled,
      ),
      'scheduledStartAt': serializer.toJson<DateTime>(scheduledStartAt),
      'actualStartAt': serializer.toJson<DateTime?>(actualStartAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'status': serializer.toJson<String>(status),
      'supportedLanguagesJson': serializer.toJson<String>(
        supportedLanguagesJson,
      ),
      'moderationSettingsJson': serializer.toJson<String>(
        moderationSettingsJson,
      ),
      'moderationRuntimeJson': serializer.toJson<String>(moderationRuntimeJson),
      'transcriptRetentionPolicy': serializer.toJson<String>(
        transcriptRetentionPolicy,
      ),
      'transcriptExpiresAt': serializer.toJson<DateTime?>(transcriptExpiresAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StoredEventSession copyWith({
    String? eventId,
    String? eventName,
    String? hostLanguage,
    String? eventTimeZone,
    bool? isDaylightSavingTimeEnabled,
    DateTime? scheduledStartAt,
    Value<DateTime?> actualStartAt = const Value.absent(),
    Value<DateTime?> endedAt = const Value.absent(),
    String? status,
    String? supportedLanguagesJson,
    String? moderationSettingsJson,
    String? moderationRuntimeJson,
    String? transcriptRetentionPolicy,
    Value<DateTime?> transcriptExpiresAt = const Value.absent(),
    DateTime? updatedAt,
  }) => StoredEventSession(
    eventId: eventId ?? this.eventId,
    eventName: eventName ?? this.eventName,
    hostLanguage: hostLanguage ?? this.hostLanguage,
    eventTimeZone: eventTimeZone ?? this.eventTimeZone,
    isDaylightSavingTimeEnabled:
        isDaylightSavingTimeEnabled ?? this.isDaylightSavingTimeEnabled,
    scheduledStartAt: scheduledStartAt ?? this.scheduledStartAt,
    actualStartAt: actualStartAt.present
        ? actualStartAt.value
        : this.actualStartAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    status: status ?? this.status,
    supportedLanguagesJson:
        supportedLanguagesJson ?? this.supportedLanguagesJson,
    moderationSettingsJson:
        moderationSettingsJson ?? this.moderationSettingsJson,
    moderationRuntimeJson: moderationRuntimeJson ?? this.moderationRuntimeJson,
    transcriptRetentionPolicy:
        transcriptRetentionPolicy ?? this.transcriptRetentionPolicy,
    transcriptExpiresAt: transcriptExpiresAt.present
        ? transcriptExpiresAt.value
        : this.transcriptExpiresAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StoredEventSession copyWithCompanion(StoredEventSessionsCompanion data) {
    return StoredEventSession(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      eventName: data.eventName.present ? data.eventName.value : this.eventName,
      hostLanguage: data.hostLanguage.present
          ? data.hostLanguage.value
          : this.hostLanguage,
      eventTimeZone: data.eventTimeZone.present
          ? data.eventTimeZone.value
          : this.eventTimeZone,
      isDaylightSavingTimeEnabled: data.isDaylightSavingTimeEnabled.present
          ? data.isDaylightSavingTimeEnabled.value
          : this.isDaylightSavingTimeEnabled,
      scheduledStartAt: data.scheduledStartAt.present
          ? data.scheduledStartAt.value
          : this.scheduledStartAt,
      actualStartAt: data.actualStartAt.present
          ? data.actualStartAt.value
          : this.actualStartAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      status: data.status.present ? data.status.value : this.status,
      supportedLanguagesJson: data.supportedLanguagesJson.present
          ? data.supportedLanguagesJson.value
          : this.supportedLanguagesJson,
      moderationSettingsJson: data.moderationSettingsJson.present
          ? data.moderationSettingsJson.value
          : this.moderationSettingsJson,
      moderationRuntimeJson: data.moderationRuntimeJson.present
          ? data.moderationRuntimeJson.value
          : this.moderationRuntimeJson,
      transcriptRetentionPolicy: data.transcriptRetentionPolicy.present
          ? data.transcriptRetentionPolicy.value
          : this.transcriptRetentionPolicy,
      transcriptExpiresAt: data.transcriptExpiresAt.present
          ? data.transcriptExpiresAt.value
          : this.transcriptExpiresAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredEventSession(')
          ..write('eventId: $eventId, ')
          ..write('eventName: $eventName, ')
          ..write('hostLanguage: $hostLanguage, ')
          ..write('eventTimeZone: $eventTimeZone, ')
          ..write('isDaylightSavingTimeEnabled: $isDaylightSavingTimeEnabled, ')
          ..write('scheduledStartAt: $scheduledStartAt, ')
          ..write('actualStartAt: $actualStartAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('supportedLanguagesJson: $supportedLanguagesJson, ')
          ..write('moderationSettingsJson: $moderationSettingsJson, ')
          ..write('moderationRuntimeJson: $moderationRuntimeJson, ')
          ..write('transcriptRetentionPolicy: $transcriptRetentionPolicy, ')
          ..write('transcriptExpiresAt: $transcriptExpiresAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    eventName,
    hostLanguage,
    eventTimeZone,
    isDaylightSavingTimeEnabled,
    scheduledStartAt,
    actualStartAt,
    endedAt,
    status,
    supportedLanguagesJson,
    moderationSettingsJson,
    moderationRuntimeJson,
    transcriptRetentionPolicy,
    transcriptExpiresAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredEventSession &&
          other.eventId == this.eventId &&
          other.eventName == this.eventName &&
          other.hostLanguage == this.hostLanguage &&
          other.eventTimeZone == this.eventTimeZone &&
          other.isDaylightSavingTimeEnabled ==
              this.isDaylightSavingTimeEnabled &&
          other.scheduledStartAt == this.scheduledStartAt &&
          other.actualStartAt == this.actualStartAt &&
          other.endedAt == this.endedAt &&
          other.status == this.status &&
          other.supportedLanguagesJson == this.supportedLanguagesJson &&
          other.moderationSettingsJson == this.moderationSettingsJson &&
          other.moderationRuntimeJson == this.moderationRuntimeJson &&
          other.transcriptRetentionPolicy == this.transcriptRetentionPolicy &&
          other.transcriptExpiresAt == this.transcriptExpiresAt &&
          other.updatedAt == this.updatedAt);
}

class StoredEventSessionsCompanion extends UpdateCompanion<StoredEventSession> {
  final Value<String> eventId;
  final Value<String> eventName;
  final Value<String> hostLanguage;
  final Value<String> eventTimeZone;
  final Value<bool> isDaylightSavingTimeEnabled;
  final Value<DateTime> scheduledStartAt;
  final Value<DateTime?> actualStartAt;
  final Value<DateTime?> endedAt;
  final Value<String> status;
  final Value<String> supportedLanguagesJson;
  final Value<String> moderationSettingsJson;
  final Value<String> moderationRuntimeJson;
  final Value<String> transcriptRetentionPolicy;
  final Value<DateTime?> transcriptExpiresAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StoredEventSessionsCompanion({
    this.eventId = const Value.absent(),
    this.eventName = const Value.absent(),
    this.hostLanguage = const Value.absent(),
    this.eventTimeZone = const Value.absent(),
    this.isDaylightSavingTimeEnabled = const Value.absent(),
    this.scheduledStartAt = const Value.absent(),
    this.actualStartAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.supportedLanguagesJson = const Value.absent(),
    this.moderationSettingsJson = const Value.absent(),
    this.moderationRuntimeJson = const Value.absent(),
    this.transcriptRetentionPolicy = const Value.absent(),
    this.transcriptExpiresAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredEventSessionsCompanion.insert({
    required String eventId,
    required String eventName,
    required String hostLanguage,
    required String eventTimeZone,
    required bool isDaylightSavingTimeEnabled,
    required DateTime scheduledStartAt,
    this.actualStartAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    required String status,
    required String supportedLanguagesJson,
    this.moderationSettingsJson = const Value.absent(),
    this.moderationRuntimeJson = const Value.absent(),
    required String transcriptRetentionPolicy,
    this.transcriptExpiresAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       eventName = Value(eventName),
       hostLanguage = Value(hostLanguage),
       eventTimeZone = Value(eventTimeZone),
       isDaylightSavingTimeEnabled = Value(isDaylightSavingTimeEnabled),
       scheduledStartAt = Value(scheduledStartAt),
       status = Value(status),
       supportedLanguagesJson = Value(supportedLanguagesJson),
       transcriptRetentionPolicy = Value(transcriptRetentionPolicy);
  static Insertable<StoredEventSession> custom({
    Expression<String>? eventId,
    Expression<String>? eventName,
    Expression<String>? hostLanguage,
    Expression<String>? eventTimeZone,
    Expression<bool>? isDaylightSavingTimeEnabled,
    Expression<DateTime>? scheduledStartAt,
    Expression<DateTime>? actualStartAt,
    Expression<DateTime>? endedAt,
    Expression<String>? status,
    Expression<String>? supportedLanguagesJson,
    Expression<String>? moderationSettingsJson,
    Expression<String>? moderationRuntimeJson,
    Expression<String>? transcriptRetentionPolicy,
    Expression<DateTime>? transcriptExpiresAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (eventName != null) 'event_name': eventName,
      if (hostLanguage != null) 'host_language': hostLanguage,
      if (eventTimeZone != null) 'event_time_zone': eventTimeZone,
      if (isDaylightSavingTimeEnabled != null)
        'is_daylight_saving_time_enabled': isDaylightSavingTimeEnabled,
      if (scheduledStartAt != null) 'scheduled_start_at': scheduledStartAt,
      if (actualStartAt != null) 'actual_start_at': actualStartAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (status != null) 'status': status,
      if (supportedLanguagesJson != null)
        'supported_languages_json': supportedLanguagesJson,
      if (moderationSettingsJson != null)
        'moderation_settings_json': moderationSettingsJson,
      if (moderationRuntimeJson != null)
        'moderation_runtime_json': moderationRuntimeJson,
      if (transcriptRetentionPolicy != null)
        'transcript_retention_policy': transcriptRetentionPolicy,
      if (transcriptExpiresAt != null)
        'transcript_expires_at': transcriptExpiresAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredEventSessionsCompanion copyWith({
    Value<String>? eventId,
    Value<String>? eventName,
    Value<String>? hostLanguage,
    Value<String>? eventTimeZone,
    Value<bool>? isDaylightSavingTimeEnabled,
    Value<DateTime>? scheduledStartAt,
    Value<DateTime?>? actualStartAt,
    Value<DateTime?>? endedAt,
    Value<String>? status,
    Value<String>? supportedLanguagesJson,
    Value<String>? moderationSettingsJson,
    Value<String>? moderationRuntimeJson,
    Value<String>? transcriptRetentionPolicy,
    Value<DateTime?>? transcriptExpiresAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return StoredEventSessionsCompanion(
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      hostLanguage: hostLanguage ?? this.hostLanguage,
      eventTimeZone: eventTimeZone ?? this.eventTimeZone,
      isDaylightSavingTimeEnabled:
          isDaylightSavingTimeEnabled ?? this.isDaylightSavingTimeEnabled,
      scheduledStartAt: scheduledStartAt ?? this.scheduledStartAt,
      actualStartAt: actualStartAt ?? this.actualStartAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      supportedLanguagesJson:
          supportedLanguagesJson ?? this.supportedLanguagesJson,
      moderationSettingsJson:
          moderationSettingsJson ?? this.moderationSettingsJson,
      moderationRuntimeJson:
          moderationRuntimeJson ?? this.moderationRuntimeJson,
      transcriptRetentionPolicy:
          transcriptRetentionPolicy ?? this.transcriptRetentionPolicy,
      transcriptExpiresAt: transcriptExpiresAt ?? this.transcriptExpiresAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (eventName.present) {
      map['event_name'] = Variable<String>(eventName.value);
    }
    if (hostLanguage.present) {
      map['host_language'] = Variable<String>(hostLanguage.value);
    }
    if (eventTimeZone.present) {
      map['event_time_zone'] = Variable<String>(eventTimeZone.value);
    }
    if (isDaylightSavingTimeEnabled.present) {
      map['is_daylight_saving_time_enabled'] = Variable<bool>(
        isDaylightSavingTimeEnabled.value,
      );
    }
    if (scheduledStartAt.present) {
      map['scheduled_start_at'] = Variable<DateTime>(scheduledStartAt.value);
    }
    if (actualStartAt.present) {
      map['actual_start_at'] = Variable<DateTime>(actualStartAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (supportedLanguagesJson.present) {
      map['supported_languages_json'] = Variable<String>(
        supportedLanguagesJson.value,
      );
    }
    if (moderationSettingsJson.present) {
      map['moderation_settings_json'] = Variable<String>(
        moderationSettingsJson.value,
      );
    }
    if (moderationRuntimeJson.present) {
      map['moderation_runtime_json'] = Variable<String>(
        moderationRuntimeJson.value,
      );
    }
    if (transcriptRetentionPolicy.present) {
      map['transcript_retention_policy'] = Variable<String>(
        transcriptRetentionPolicy.value,
      );
    }
    if (transcriptExpiresAt.present) {
      map['transcript_expires_at'] = Variable<DateTime>(
        transcriptExpiresAt.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredEventSessionsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('eventName: $eventName, ')
          ..write('hostLanguage: $hostLanguage, ')
          ..write('eventTimeZone: $eventTimeZone, ')
          ..write('isDaylightSavingTimeEnabled: $isDaylightSavingTimeEnabled, ')
          ..write('scheduledStartAt: $scheduledStartAt, ')
          ..write('actualStartAt: $actualStartAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('supportedLanguagesJson: $supportedLanguagesJson, ')
          ..write('moderationSettingsJson: $moderationSettingsJson, ')
          ..write('moderationRuntimeJson: $moderationRuntimeJson, ')
          ..write('transcriptRetentionPolicy: $transcriptRetentionPolicy, ')
          ..write('transcriptExpiresAt: $transcriptExpiresAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoredTranscriptUtterancesTable extends StoredTranscriptUtterances
    with
        TableInfo<$StoredTranscriptUtterancesTable, StoredTranscriptUtterance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredTranscriptUtterancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _utteranceIdMeta = const VerificationMeta(
    'utteranceId',
  );
  @override
  late final GeneratedColumn<String> utteranceId = GeneratedColumn<String>(
    'utterance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stored_event_sessions (event_id)',
    ),
  );
  static const VerificationMeta _sequenceNumberMeta = const VerificationMeta(
    'sequenceNumber',
  );
  @override
  late final GeneratedColumn<int> sequenceNumber = GeneratedColumn<int>(
    'sequence_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speakerLabelMeta = const VerificationMeta(
    'speakerLabel',
  );
  @override
  late final GeneratedColumn<String> speakerLabel = GeneratedColumn<String>(
    'speaker_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spokenLanguageMeta = const VerificationMeta(
    'spokenLanguage',
  );
  @override
  late final GeneratedColumn<String> spokenLanguage = GeneratedColumn<String>(
    'spoken_language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalTextMeta = const VerificationMeta(
    'originalText',
  );
  @override
  late final GeneratedColumn<String> originalText = GeneratedColumn<String>(
    'original_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translatedTextMeta = const VerificationMeta(
    'translatedText',
  );
  @override
  late final GeneratedColumn<String> translatedText = GeneratedColumn<String>(
    'translated_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetLanguageMeta = const VerificationMeta(
    'targetLanguage',
  );
  @override
  late final GeneratedColumn<String> targetLanguage = GeneratedColumn<String>(
    'target_language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _segmentStatusMeta = const VerificationMeta(
    'segmentStatus',
  );
  @override
  late final GeneratedColumn<String> segmentStatus = GeneratedColumn<String>(
    'segment_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _editedFinalTextMeta = const VerificationMeta(
    'editedFinalText',
  );
  @override
  late final GeneratedColumn<String> editedFinalText = GeneratedColumn<String>(
    'edited_final_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finalizedAtMeta = const VerificationMeta(
    'finalizedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finalizedAt = GeneratedColumn<DateTime>(
    'finalized_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    utteranceId,
    eventId,
    sequenceNumber,
    speakerLabel,
    spokenLanguage,
    originalText,
    translatedText,
    targetLanguage,
    segmentStatus,
    editedFinalText,
    confidence,
    capturedAt,
    finalizedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_transcript_utterances';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredTranscriptUtterance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('utterance_id')) {
      context.handle(
        _utteranceIdMeta,
        utteranceId.isAcceptableOrUnknown(
          data['utterance_id']!,
          _utteranceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_utteranceIdMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('sequence_number')) {
      context.handle(
        _sequenceNumberMeta,
        sequenceNumber.isAcceptableOrUnknown(
          data['sequence_number']!,
          _sequenceNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sequenceNumberMeta);
    }
    if (data.containsKey('speaker_label')) {
      context.handle(
        _speakerLabelMeta,
        speakerLabel.isAcceptableOrUnknown(
          data['speaker_label']!,
          _speakerLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_speakerLabelMeta);
    }
    if (data.containsKey('spoken_language')) {
      context.handle(
        _spokenLanguageMeta,
        spokenLanguage.isAcceptableOrUnknown(
          data['spoken_language']!,
          _spokenLanguageMeta,
        ),
      );
    }
    if (data.containsKey('original_text')) {
      context.handle(
        _originalTextMeta,
        originalText.isAcceptableOrUnknown(
          data['original_text']!,
          _originalTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalTextMeta);
    }
    if (data.containsKey('translated_text')) {
      context.handle(
        _translatedTextMeta,
        translatedText.isAcceptableOrUnknown(
          data['translated_text']!,
          _translatedTextMeta,
        ),
      );
    }
    if (data.containsKey('target_language')) {
      context.handle(
        _targetLanguageMeta,
        targetLanguage.isAcceptableOrUnknown(
          data['target_language']!,
          _targetLanguageMeta,
        ),
      );
    }
    if (data.containsKey('segment_status')) {
      context.handle(
        _segmentStatusMeta,
        segmentStatus.isAcceptableOrUnknown(
          data['segment_status']!,
          _segmentStatusMeta,
        ),
      );
    }
    if (data.containsKey('edited_final_text')) {
      context.handle(
        _editedFinalTextMeta,
        editedFinalText.isAcceptableOrUnknown(
          data['edited_final_text']!,
          _editedFinalTextMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('finalized_at')) {
      context.handle(
        _finalizedAtMeta,
        finalizedAt.isAcceptableOrUnknown(
          data['finalized_at']!,
          _finalizedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {utteranceId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {eventId, sequenceNumber},
  ];
  @override
  StoredTranscriptUtterance map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredTranscriptUtterance(
      utteranceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}utterance_id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      sequenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_number'],
      )!,
      speakerLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}speaker_label'],
      )!,
      spokenLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spoken_language'],
      ),
      originalText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_text'],
      )!,
      translatedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translated_text'],
      ),
      targetLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_language'],
      ),
      segmentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}segment_status'],
      ),
      editedFinalText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edited_final_text'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      finalizedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finalized_at'],
      ),
    );
  }

  @override
  $StoredTranscriptUtterancesTable createAlias(String alias) {
    return $StoredTranscriptUtterancesTable(attachedDatabase, alias);
  }
}

class StoredTranscriptUtterance extends DataClass
    implements Insertable<StoredTranscriptUtterance> {
  final String utteranceId;
  final String eventId;
  final int sequenceNumber;
  final String speakerLabel;
  final String? spokenLanguage;
  final String originalText;
  final String? translatedText;
  final String? targetLanguage;
  final String? segmentStatus;
  final String? editedFinalText;
  final double? confidence;
  final DateTime capturedAt;
  final DateTime? finalizedAt;
  const StoredTranscriptUtterance({
    required this.utteranceId,
    required this.eventId,
    required this.sequenceNumber,
    required this.speakerLabel,
    this.spokenLanguage,
    required this.originalText,
    this.translatedText,
    this.targetLanguage,
    this.segmentStatus,
    this.editedFinalText,
    this.confidence,
    required this.capturedAt,
    this.finalizedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['utterance_id'] = Variable<String>(utteranceId);
    map['event_id'] = Variable<String>(eventId);
    map['sequence_number'] = Variable<int>(sequenceNumber);
    map['speaker_label'] = Variable<String>(speakerLabel);
    if (!nullToAbsent || spokenLanguage != null) {
      map['spoken_language'] = Variable<String>(spokenLanguage);
    }
    map['original_text'] = Variable<String>(originalText);
    if (!nullToAbsent || translatedText != null) {
      map['translated_text'] = Variable<String>(translatedText);
    }
    if (!nullToAbsent || targetLanguage != null) {
      map['target_language'] = Variable<String>(targetLanguage);
    }
    if (!nullToAbsent || segmentStatus != null) {
      map['segment_status'] = Variable<String>(segmentStatus);
    }
    if (!nullToAbsent || editedFinalText != null) {
      map['edited_final_text'] = Variable<String>(editedFinalText);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['captured_at'] = Variable<DateTime>(capturedAt);
    if (!nullToAbsent || finalizedAt != null) {
      map['finalized_at'] = Variable<DateTime>(finalizedAt);
    }
    return map;
  }

  StoredTranscriptUtterancesCompanion toCompanion(bool nullToAbsent) {
    return StoredTranscriptUtterancesCompanion(
      utteranceId: Value(utteranceId),
      eventId: Value(eventId),
      sequenceNumber: Value(sequenceNumber),
      speakerLabel: Value(speakerLabel),
      spokenLanguage: spokenLanguage == null && nullToAbsent
          ? const Value.absent()
          : Value(spokenLanguage),
      originalText: Value(originalText),
      translatedText: translatedText == null && nullToAbsent
          ? const Value.absent()
          : Value(translatedText),
      targetLanguage: targetLanguage == null && nullToAbsent
          ? const Value.absent()
          : Value(targetLanguage),
      segmentStatus: segmentStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(segmentStatus),
      editedFinalText: editedFinalText == null && nullToAbsent
          ? const Value.absent()
          : Value(editedFinalText),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      capturedAt: Value(capturedAt),
      finalizedAt: finalizedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finalizedAt),
    );
  }

  factory StoredTranscriptUtterance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredTranscriptUtterance(
      utteranceId: serializer.fromJson<String>(json['utteranceId']),
      eventId: serializer.fromJson<String>(json['eventId']),
      sequenceNumber: serializer.fromJson<int>(json['sequenceNumber']),
      speakerLabel: serializer.fromJson<String>(json['speakerLabel']),
      spokenLanguage: serializer.fromJson<String?>(json['spokenLanguage']),
      originalText: serializer.fromJson<String>(json['originalText']),
      translatedText: serializer.fromJson<String?>(json['translatedText']),
      targetLanguage: serializer.fromJson<String?>(json['targetLanguage']),
      segmentStatus: serializer.fromJson<String?>(json['segmentStatus']),
      editedFinalText: serializer.fromJson<String?>(json['editedFinalText']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      finalizedAt: serializer.fromJson<DateTime?>(json['finalizedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'utteranceId': serializer.toJson<String>(utteranceId),
      'eventId': serializer.toJson<String>(eventId),
      'sequenceNumber': serializer.toJson<int>(sequenceNumber),
      'speakerLabel': serializer.toJson<String>(speakerLabel),
      'spokenLanguage': serializer.toJson<String?>(spokenLanguage),
      'originalText': serializer.toJson<String>(originalText),
      'translatedText': serializer.toJson<String?>(translatedText),
      'targetLanguage': serializer.toJson<String?>(targetLanguage),
      'segmentStatus': serializer.toJson<String?>(segmentStatus),
      'editedFinalText': serializer.toJson<String?>(editedFinalText),
      'confidence': serializer.toJson<double?>(confidence),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'finalizedAt': serializer.toJson<DateTime?>(finalizedAt),
    };
  }

  StoredTranscriptUtterance copyWith({
    String? utteranceId,
    String? eventId,
    int? sequenceNumber,
    String? speakerLabel,
    Value<String?> spokenLanguage = const Value.absent(),
    String? originalText,
    Value<String?> translatedText = const Value.absent(),
    Value<String?> targetLanguage = const Value.absent(),
    Value<String?> segmentStatus = const Value.absent(),
    Value<String?> editedFinalText = const Value.absent(),
    Value<double?> confidence = const Value.absent(),
    DateTime? capturedAt,
    Value<DateTime?> finalizedAt = const Value.absent(),
  }) => StoredTranscriptUtterance(
    utteranceId: utteranceId ?? this.utteranceId,
    eventId: eventId ?? this.eventId,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    speakerLabel: speakerLabel ?? this.speakerLabel,
    spokenLanguage: spokenLanguage.present
        ? spokenLanguage.value
        : this.spokenLanguage,
    originalText: originalText ?? this.originalText,
    translatedText: translatedText.present
        ? translatedText.value
        : this.translatedText,
    targetLanguage: targetLanguage.present
        ? targetLanguage.value
        : this.targetLanguage,
    segmentStatus: segmentStatus.present
        ? segmentStatus.value
        : this.segmentStatus,
    editedFinalText: editedFinalText.present
        ? editedFinalText.value
        : this.editedFinalText,
    confidence: confidence.present ? confidence.value : this.confidence,
    capturedAt: capturedAt ?? this.capturedAt,
    finalizedAt: finalizedAt.present ? finalizedAt.value : this.finalizedAt,
  );
  StoredTranscriptUtterance copyWithCompanion(
    StoredTranscriptUtterancesCompanion data,
  ) {
    return StoredTranscriptUtterance(
      utteranceId: data.utteranceId.present
          ? data.utteranceId.value
          : this.utteranceId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      sequenceNumber: data.sequenceNumber.present
          ? data.sequenceNumber.value
          : this.sequenceNumber,
      speakerLabel: data.speakerLabel.present
          ? data.speakerLabel.value
          : this.speakerLabel,
      spokenLanguage: data.spokenLanguage.present
          ? data.spokenLanguage.value
          : this.spokenLanguage,
      originalText: data.originalText.present
          ? data.originalText.value
          : this.originalText,
      translatedText: data.translatedText.present
          ? data.translatedText.value
          : this.translatedText,
      targetLanguage: data.targetLanguage.present
          ? data.targetLanguage.value
          : this.targetLanguage,
      segmentStatus: data.segmentStatus.present
          ? data.segmentStatus.value
          : this.segmentStatus,
      editedFinalText: data.editedFinalText.present
          ? data.editedFinalText.value
          : this.editedFinalText,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      finalizedAt: data.finalizedAt.present
          ? data.finalizedAt.value
          : this.finalizedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredTranscriptUtterance(')
          ..write('utteranceId: $utteranceId, ')
          ..write('eventId: $eventId, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('speakerLabel: $speakerLabel, ')
          ..write('spokenLanguage: $spokenLanguage, ')
          ..write('originalText: $originalText, ')
          ..write('translatedText: $translatedText, ')
          ..write('targetLanguage: $targetLanguage, ')
          ..write('segmentStatus: $segmentStatus, ')
          ..write('editedFinalText: $editedFinalText, ')
          ..write('confidence: $confidence, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('finalizedAt: $finalizedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    utteranceId,
    eventId,
    sequenceNumber,
    speakerLabel,
    spokenLanguage,
    originalText,
    translatedText,
    targetLanguage,
    segmentStatus,
    editedFinalText,
    confidence,
    capturedAt,
    finalizedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredTranscriptUtterance &&
          other.utteranceId == this.utteranceId &&
          other.eventId == this.eventId &&
          other.sequenceNumber == this.sequenceNumber &&
          other.speakerLabel == this.speakerLabel &&
          other.spokenLanguage == this.spokenLanguage &&
          other.originalText == this.originalText &&
          other.translatedText == this.translatedText &&
          other.targetLanguage == this.targetLanguage &&
          other.segmentStatus == this.segmentStatus &&
          other.editedFinalText == this.editedFinalText &&
          other.confidence == this.confidence &&
          other.capturedAt == this.capturedAt &&
          other.finalizedAt == this.finalizedAt);
}

class StoredTranscriptUtterancesCompanion
    extends UpdateCompanion<StoredTranscriptUtterance> {
  final Value<String> utteranceId;
  final Value<String> eventId;
  final Value<int> sequenceNumber;
  final Value<String> speakerLabel;
  final Value<String?> spokenLanguage;
  final Value<String> originalText;
  final Value<String?> translatedText;
  final Value<String?> targetLanguage;
  final Value<String?> segmentStatus;
  final Value<String?> editedFinalText;
  final Value<double?> confidence;
  final Value<DateTime> capturedAt;
  final Value<DateTime?> finalizedAt;
  final Value<int> rowid;
  const StoredTranscriptUtterancesCompanion({
    this.utteranceId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.sequenceNumber = const Value.absent(),
    this.speakerLabel = const Value.absent(),
    this.spokenLanguage = const Value.absent(),
    this.originalText = const Value.absent(),
    this.translatedText = const Value.absent(),
    this.targetLanguage = const Value.absent(),
    this.segmentStatus = const Value.absent(),
    this.editedFinalText = const Value.absent(),
    this.confidence = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.finalizedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredTranscriptUtterancesCompanion.insert({
    required String utteranceId,
    required String eventId,
    required int sequenceNumber,
    required String speakerLabel,
    this.spokenLanguage = const Value.absent(),
    required String originalText,
    this.translatedText = const Value.absent(),
    this.targetLanguage = const Value.absent(),
    this.segmentStatus = const Value.absent(),
    this.editedFinalText = const Value.absent(),
    this.confidence = const Value.absent(),
    required DateTime capturedAt,
    this.finalizedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : utteranceId = Value(utteranceId),
       eventId = Value(eventId),
       sequenceNumber = Value(sequenceNumber),
       speakerLabel = Value(speakerLabel),
       originalText = Value(originalText),
       capturedAt = Value(capturedAt);
  static Insertable<StoredTranscriptUtterance> custom({
    Expression<String>? utteranceId,
    Expression<String>? eventId,
    Expression<int>? sequenceNumber,
    Expression<String>? speakerLabel,
    Expression<String>? spokenLanguage,
    Expression<String>? originalText,
    Expression<String>? translatedText,
    Expression<String>? targetLanguage,
    Expression<String>? segmentStatus,
    Expression<String>? editedFinalText,
    Expression<double>? confidence,
    Expression<DateTime>? capturedAt,
    Expression<DateTime>? finalizedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (utteranceId != null) 'utterance_id': utteranceId,
      if (eventId != null) 'event_id': eventId,
      if (sequenceNumber != null) 'sequence_number': sequenceNumber,
      if (speakerLabel != null) 'speaker_label': speakerLabel,
      if (spokenLanguage != null) 'spoken_language': spokenLanguage,
      if (originalText != null) 'original_text': originalText,
      if (translatedText != null) 'translated_text': translatedText,
      if (targetLanguage != null) 'target_language': targetLanguage,
      if (segmentStatus != null) 'segment_status': segmentStatus,
      if (editedFinalText != null) 'edited_final_text': editedFinalText,
      if (confidence != null) 'confidence': confidence,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (finalizedAt != null) 'finalized_at': finalizedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredTranscriptUtterancesCompanion copyWith({
    Value<String>? utteranceId,
    Value<String>? eventId,
    Value<int>? sequenceNumber,
    Value<String>? speakerLabel,
    Value<String?>? spokenLanguage,
    Value<String>? originalText,
    Value<String?>? translatedText,
    Value<String?>? targetLanguage,
    Value<String?>? segmentStatus,
    Value<String?>? editedFinalText,
    Value<double?>? confidence,
    Value<DateTime>? capturedAt,
    Value<DateTime?>? finalizedAt,
    Value<int>? rowid,
  }) {
    return StoredTranscriptUtterancesCompanion(
      utteranceId: utteranceId ?? this.utteranceId,
      eventId: eventId ?? this.eventId,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      speakerLabel: speakerLabel ?? this.speakerLabel,
      spokenLanguage: spokenLanguage ?? this.spokenLanguage,
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      segmentStatus: segmentStatus ?? this.segmentStatus,
      editedFinalText: editedFinalText ?? this.editedFinalText,
      confidence: confidence ?? this.confidence,
      capturedAt: capturedAt ?? this.capturedAt,
      finalizedAt: finalizedAt ?? this.finalizedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (utteranceId.present) {
      map['utterance_id'] = Variable<String>(utteranceId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (sequenceNumber.present) {
      map['sequence_number'] = Variable<int>(sequenceNumber.value);
    }
    if (speakerLabel.present) {
      map['speaker_label'] = Variable<String>(speakerLabel.value);
    }
    if (spokenLanguage.present) {
      map['spoken_language'] = Variable<String>(spokenLanguage.value);
    }
    if (originalText.present) {
      map['original_text'] = Variable<String>(originalText.value);
    }
    if (translatedText.present) {
      map['translated_text'] = Variable<String>(translatedText.value);
    }
    if (targetLanguage.present) {
      map['target_language'] = Variable<String>(targetLanguage.value);
    }
    if (segmentStatus.present) {
      map['segment_status'] = Variable<String>(segmentStatus.value);
    }
    if (editedFinalText.present) {
      map['edited_final_text'] = Variable<String>(editedFinalText.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (finalizedAt.present) {
      map['finalized_at'] = Variable<DateTime>(finalizedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredTranscriptUtterancesCompanion(')
          ..write('utteranceId: $utteranceId, ')
          ..write('eventId: $eventId, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('speakerLabel: $speakerLabel, ')
          ..write('spokenLanguage: $spokenLanguage, ')
          ..write('originalText: $originalText, ')
          ..write('translatedText: $translatedText, ')
          ..write('targetLanguage: $targetLanguage, ')
          ..write('segmentStatus: $segmentStatus, ')
          ..write('editedFinalText: $editedFinalText, ')
          ..write('confidence: $confidence, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('finalizedAt: $finalizedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoredTranscriptTranslationRunsTable
    extends StoredTranscriptTranslationRuns
    with
        TableInfo<
          $StoredTranscriptTranslationRunsTable,
          StoredTranscriptTranslationRun
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredTranscriptTranslationRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _translationRunIdMeta = const VerificationMeta(
    'translationRunId',
  );
  @override
  late final GeneratedColumn<String> translationRunId = GeneratedColumn<String>(
    'translation_run_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stored_event_sessions (event_id)',
    ),
  );
  static const VerificationMeta _targetLanguageMeta = const VerificationMeta(
    'targetLanguage',
  );
  @override
  late final GeneratedColumn<String> targetLanguage = GeneratedColumn<String>(
    'target_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promptConfigVersionMeta =
      const VerificationMeta('promptConfigVersion');
  @override
  late final GeneratedColumn<String> promptConfigVersion =
      GeneratedColumn<String>(
        'prompt_config_version',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    translationRunId,
    eventId,
    targetLanguage,
    provider,
    modelVersion,
    promptConfigVersion,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_transcript_translation_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredTranscriptTranslationRun> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('translation_run_id')) {
      context.handle(
        _translationRunIdMeta,
        translationRunId.isAcceptableOrUnknown(
          data['translation_run_id']!,
          _translationRunIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationRunIdMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('target_language')) {
      context.handle(
        _targetLanguageMeta,
        targetLanguage.isAcceptableOrUnknown(
          data['target_language']!,
          _targetLanguageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetLanguageMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    }
    if (data.containsKey('prompt_config_version')) {
      context.handle(
        _promptConfigVersionMeta,
        promptConfigVersion.isAcceptableOrUnknown(
          data['prompt_config_version']!,
          _promptConfigVersionMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {translationRunId};
  @override
  StoredTranscriptTranslationRun map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredTranscriptTranslationRun(
      translationRunId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_run_id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      targetLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_language'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      ),
      promptConfigVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt_config_version'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StoredTranscriptTranslationRunsTable createAlias(String alias) {
    return $StoredTranscriptTranslationRunsTable(attachedDatabase, alias);
  }
}

class StoredTranscriptTranslationRun extends DataClass
    implements Insertable<StoredTranscriptTranslationRun> {
  final String translationRunId;
  final String eventId;
  final String targetLanguage;
  final String provider;
  final String? modelVersion;
  final String? promptConfigVersion;
  final String status;
  final DateTime createdAt;
  const StoredTranscriptTranslationRun({
    required this.translationRunId,
    required this.eventId,
    required this.targetLanguage,
    required this.provider,
    this.modelVersion,
    this.promptConfigVersion,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['translation_run_id'] = Variable<String>(translationRunId);
    map['event_id'] = Variable<String>(eventId);
    map['target_language'] = Variable<String>(targetLanguage);
    map['provider'] = Variable<String>(provider);
    if (!nullToAbsent || modelVersion != null) {
      map['model_version'] = Variable<String>(modelVersion);
    }
    if (!nullToAbsent || promptConfigVersion != null) {
      map['prompt_config_version'] = Variable<String>(promptConfigVersion);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StoredTranscriptTranslationRunsCompanion toCompanion(bool nullToAbsent) {
    return StoredTranscriptTranslationRunsCompanion(
      translationRunId: Value(translationRunId),
      eventId: Value(eventId),
      targetLanguage: Value(targetLanguage),
      provider: Value(provider),
      modelVersion: modelVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(modelVersion),
      promptConfigVersion: promptConfigVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(promptConfigVersion),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory StoredTranscriptTranslationRun.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredTranscriptTranslationRun(
      translationRunId: serializer.fromJson<String>(json['translationRunId']),
      eventId: serializer.fromJson<String>(json['eventId']),
      targetLanguage: serializer.fromJson<String>(json['targetLanguage']),
      provider: serializer.fromJson<String>(json['provider']),
      modelVersion: serializer.fromJson<String?>(json['modelVersion']),
      promptConfigVersion: serializer.fromJson<String?>(
        json['promptConfigVersion'],
      ),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'translationRunId': serializer.toJson<String>(translationRunId),
      'eventId': serializer.toJson<String>(eventId),
      'targetLanguage': serializer.toJson<String>(targetLanguage),
      'provider': serializer.toJson<String>(provider),
      'modelVersion': serializer.toJson<String?>(modelVersion),
      'promptConfigVersion': serializer.toJson<String?>(promptConfigVersion),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StoredTranscriptTranslationRun copyWith({
    String? translationRunId,
    String? eventId,
    String? targetLanguage,
    String? provider,
    Value<String?> modelVersion = const Value.absent(),
    Value<String?> promptConfigVersion = const Value.absent(),
    String? status,
    DateTime? createdAt,
  }) => StoredTranscriptTranslationRun(
    translationRunId: translationRunId ?? this.translationRunId,
    eventId: eventId ?? this.eventId,
    targetLanguage: targetLanguage ?? this.targetLanguage,
    provider: provider ?? this.provider,
    modelVersion: modelVersion.present ? modelVersion.value : this.modelVersion,
    promptConfigVersion: promptConfigVersion.present
        ? promptConfigVersion.value
        : this.promptConfigVersion,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  StoredTranscriptTranslationRun copyWithCompanion(
    StoredTranscriptTranslationRunsCompanion data,
  ) {
    return StoredTranscriptTranslationRun(
      translationRunId: data.translationRunId.present
          ? data.translationRunId.value
          : this.translationRunId,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      targetLanguage: data.targetLanguage.present
          ? data.targetLanguage.value
          : this.targetLanguage,
      provider: data.provider.present ? data.provider.value : this.provider,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      promptConfigVersion: data.promptConfigVersion.present
          ? data.promptConfigVersion.value
          : this.promptConfigVersion,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredTranscriptTranslationRun(')
          ..write('translationRunId: $translationRunId, ')
          ..write('eventId: $eventId, ')
          ..write('targetLanguage: $targetLanguage, ')
          ..write('provider: $provider, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('promptConfigVersion: $promptConfigVersion, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    translationRunId,
    eventId,
    targetLanguage,
    provider,
    modelVersion,
    promptConfigVersion,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredTranscriptTranslationRun &&
          other.translationRunId == this.translationRunId &&
          other.eventId == this.eventId &&
          other.targetLanguage == this.targetLanguage &&
          other.provider == this.provider &&
          other.modelVersion == this.modelVersion &&
          other.promptConfigVersion == this.promptConfigVersion &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class StoredTranscriptTranslationRunsCompanion
    extends UpdateCompanion<StoredTranscriptTranslationRun> {
  final Value<String> translationRunId;
  final Value<String> eventId;
  final Value<String> targetLanguage;
  final Value<String> provider;
  final Value<String?> modelVersion;
  final Value<String?> promptConfigVersion;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StoredTranscriptTranslationRunsCompanion({
    this.translationRunId = const Value.absent(),
    this.eventId = const Value.absent(),
    this.targetLanguage = const Value.absent(),
    this.provider = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.promptConfigVersion = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredTranscriptTranslationRunsCompanion.insert({
    required String translationRunId,
    required String eventId,
    required String targetLanguage,
    required String provider,
    this.modelVersion = const Value.absent(),
    this.promptConfigVersion = const Value.absent(),
    required String status,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : translationRunId = Value(translationRunId),
       eventId = Value(eventId),
       targetLanguage = Value(targetLanguage),
       provider = Value(provider),
       status = Value(status);
  static Insertable<StoredTranscriptTranslationRun> custom({
    Expression<String>? translationRunId,
    Expression<String>? eventId,
    Expression<String>? targetLanguage,
    Expression<String>? provider,
    Expression<String>? modelVersion,
    Expression<String>? promptConfigVersion,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (translationRunId != null) 'translation_run_id': translationRunId,
      if (eventId != null) 'event_id': eventId,
      if (targetLanguage != null) 'target_language': targetLanguage,
      if (provider != null) 'provider': provider,
      if (modelVersion != null) 'model_version': modelVersion,
      if (promptConfigVersion != null)
        'prompt_config_version': promptConfigVersion,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredTranscriptTranslationRunsCompanion copyWith({
    Value<String>? translationRunId,
    Value<String>? eventId,
    Value<String>? targetLanguage,
    Value<String>? provider,
    Value<String?>? modelVersion,
    Value<String?>? promptConfigVersion,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StoredTranscriptTranslationRunsCompanion(
      translationRunId: translationRunId ?? this.translationRunId,
      eventId: eventId ?? this.eventId,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      provider: provider ?? this.provider,
      modelVersion: modelVersion ?? this.modelVersion,
      promptConfigVersion: promptConfigVersion ?? this.promptConfigVersion,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (translationRunId.present) {
      map['translation_run_id'] = Variable<String>(translationRunId.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (targetLanguage.present) {
      map['target_language'] = Variable<String>(targetLanguage.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (promptConfigVersion.present) {
      map['prompt_config_version'] = Variable<String>(
        promptConfigVersion.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredTranscriptTranslationRunsCompanion(')
          ..write('translationRunId: $translationRunId, ')
          ..write('eventId: $eventId, ')
          ..write('targetLanguage: $targetLanguage, ')
          ..write('provider: $provider, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('promptConfigVersion: $promptConfigVersion, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoredUtteranceTranslationsTable extends StoredUtteranceTranslations
    with
        TableInfo<
          $StoredUtteranceTranslationsTable,
          StoredUtteranceTranslation
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredUtteranceTranslationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _translationIdMeta = const VerificationMeta(
    'translationId',
  );
  @override
  late final GeneratedColumn<String> translationId = GeneratedColumn<String>(
    'translation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translationRunIdMeta = const VerificationMeta(
    'translationRunId',
  );
  @override
  late final GeneratedColumn<String> translationRunId = GeneratedColumn<String>(
    'translation_run_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stored_transcript_translation_runs (translation_run_id)',
    ),
  );
  static const VerificationMeta _utteranceIdMeta = const VerificationMeta(
    'utteranceId',
  );
  @override
  late final GeneratedColumn<String> utteranceId = GeneratedColumn<String>(
    'utterance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stored_transcript_utterances (utterance_id)',
    ),
  );
  static const VerificationMeta _targetLanguageMeta = const VerificationMeta(
    'targetLanguage',
  );
  @override
  late final GeneratedColumn<String> targetLanguage = GeneratedColumn<String>(
    'target_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translatedTextMeta = const VerificationMeta(
    'translatedText',
  );
  @override
  late final GeneratedColumn<String> translatedText = GeneratedColumn<String>(
    'translated_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qualityScoreMeta = const VerificationMeta(
    'qualityScore',
  );
  @override
  late final GeneratedColumn<double> qualityScore = GeneratedColumn<double>(
    'quality_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewStatusMeta = const VerificationMeta(
    'reviewStatus',
  );
  @override
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
    'review_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    translationId,
    translationRunId,
    utteranceId,
    targetLanguage,
    translatedText,
    qualityScore,
    reviewStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_utterance_translations';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredUtteranceTranslation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('translation_id')) {
      context.handle(
        _translationIdMeta,
        translationId.isAcceptableOrUnknown(
          data['translation_id']!,
          _translationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationIdMeta);
    }
    if (data.containsKey('translation_run_id')) {
      context.handle(
        _translationRunIdMeta,
        translationRunId.isAcceptableOrUnknown(
          data['translation_run_id']!,
          _translationRunIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationRunIdMeta);
    }
    if (data.containsKey('utterance_id')) {
      context.handle(
        _utteranceIdMeta,
        utteranceId.isAcceptableOrUnknown(
          data['utterance_id']!,
          _utteranceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_utteranceIdMeta);
    }
    if (data.containsKey('target_language')) {
      context.handle(
        _targetLanguageMeta,
        targetLanguage.isAcceptableOrUnknown(
          data['target_language']!,
          _targetLanguageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetLanguageMeta);
    }
    if (data.containsKey('translated_text')) {
      context.handle(
        _translatedTextMeta,
        translatedText.isAcceptableOrUnknown(
          data['translated_text']!,
          _translatedTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translatedTextMeta);
    }
    if (data.containsKey('quality_score')) {
      context.handle(
        _qualityScoreMeta,
        qualityScore.isAcceptableOrUnknown(
          data['quality_score']!,
          _qualityScoreMeta,
        ),
      );
    }
    if (data.containsKey('review_status')) {
      context.handle(
        _reviewStatusMeta,
        reviewStatus.isAcceptableOrUnknown(
          data['review_status']!,
          _reviewStatusMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {translationId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {translationRunId, utteranceId},
  ];
  @override
  StoredUtteranceTranslation map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredUtteranceTranslation(
      translationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_id'],
      )!,
      translationRunId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_run_id'],
      )!,
      utteranceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}utterance_id'],
      )!,
      targetLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_language'],
      )!,
      translatedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translated_text'],
      )!,
      qualityScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quality_score'],
      ),
      reviewStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review_status'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StoredUtteranceTranslationsTable createAlias(String alias) {
    return $StoredUtteranceTranslationsTable(attachedDatabase, alias);
  }
}

class StoredUtteranceTranslation extends DataClass
    implements Insertable<StoredUtteranceTranslation> {
  final String translationId;
  final String translationRunId;
  final String utteranceId;
  final String targetLanguage;
  final String translatedText;
  final double? qualityScore;
  final String? reviewStatus;
  final DateTime createdAt;
  const StoredUtteranceTranslation({
    required this.translationId,
    required this.translationRunId,
    required this.utteranceId,
    required this.targetLanguage,
    required this.translatedText,
    this.qualityScore,
    this.reviewStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['translation_id'] = Variable<String>(translationId);
    map['translation_run_id'] = Variable<String>(translationRunId);
    map['utterance_id'] = Variable<String>(utteranceId);
    map['target_language'] = Variable<String>(targetLanguage);
    map['translated_text'] = Variable<String>(translatedText);
    if (!nullToAbsent || qualityScore != null) {
      map['quality_score'] = Variable<double>(qualityScore);
    }
    if (!nullToAbsent || reviewStatus != null) {
      map['review_status'] = Variable<String>(reviewStatus);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StoredUtteranceTranslationsCompanion toCompanion(bool nullToAbsent) {
    return StoredUtteranceTranslationsCompanion(
      translationId: Value(translationId),
      translationRunId: Value(translationRunId),
      utteranceId: Value(utteranceId),
      targetLanguage: Value(targetLanguage),
      translatedText: Value(translatedText),
      qualityScore: qualityScore == null && nullToAbsent
          ? const Value.absent()
          : Value(qualityScore),
      reviewStatus: reviewStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewStatus),
      createdAt: Value(createdAt),
    );
  }

  factory StoredUtteranceTranslation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredUtteranceTranslation(
      translationId: serializer.fromJson<String>(json['translationId']),
      translationRunId: serializer.fromJson<String>(json['translationRunId']),
      utteranceId: serializer.fromJson<String>(json['utteranceId']),
      targetLanguage: serializer.fromJson<String>(json['targetLanguage']),
      translatedText: serializer.fromJson<String>(json['translatedText']),
      qualityScore: serializer.fromJson<double?>(json['qualityScore']),
      reviewStatus: serializer.fromJson<String?>(json['reviewStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'translationId': serializer.toJson<String>(translationId),
      'translationRunId': serializer.toJson<String>(translationRunId),
      'utteranceId': serializer.toJson<String>(utteranceId),
      'targetLanguage': serializer.toJson<String>(targetLanguage),
      'translatedText': serializer.toJson<String>(translatedText),
      'qualityScore': serializer.toJson<double?>(qualityScore),
      'reviewStatus': serializer.toJson<String?>(reviewStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StoredUtteranceTranslation copyWith({
    String? translationId,
    String? translationRunId,
    String? utteranceId,
    String? targetLanguage,
    String? translatedText,
    Value<double?> qualityScore = const Value.absent(),
    Value<String?> reviewStatus = const Value.absent(),
    DateTime? createdAt,
  }) => StoredUtteranceTranslation(
    translationId: translationId ?? this.translationId,
    translationRunId: translationRunId ?? this.translationRunId,
    utteranceId: utteranceId ?? this.utteranceId,
    targetLanguage: targetLanguage ?? this.targetLanguage,
    translatedText: translatedText ?? this.translatedText,
    qualityScore: qualityScore.present ? qualityScore.value : this.qualityScore,
    reviewStatus: reviewStatus.present ? reviewStatus.value : this.reviewStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  StoredUtteranceTranslation copyWithCompanion(
    StoredUtteranceTranslationsCompanion data,
  ) {
    return StoredUtteranceTranslation(
      translationId: data.translationId.present
          ? data.translationId.value
          : this.translationId,
      translationRunId: data.translationRunId.present
          ? data.translationRunId.value
          : this.translationRunId,
      utteranceId: data.utteranceId.present
          ? data.utteranceId.value
          : this.utteranceId,
      targetLanguage: data.targetLanguage.present
          ? data.targetLanguage.value
          : this.targetLanguage,
      translatedText: data.translatedText.present
          ? data.translatedText.value
          : this.translatedText,
      qualityScore: data.qualityScore.present
          ? data.qualityScore.value
          : this.qualityScore,
      reviewStatus: data.reviewStatus.present
          ? data.reviewStatus.value
          : this.reviewStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredUtteranceTranslation(')
          ..write('translationId: $translationId, ')
          ..write('translationRunId: $translationRunId, ')
          ..write('utteranceId: $utteranceId, ')
          ..write('targetLanguage: $targetLanguage, ')
          ..write('translatedText: $translatedText, ')
          ..write('qualityScore: $qualityScore, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    translationId,
    translationRunId,
    utteranceId,
    targetLanguage,
    translatedText,
    qualityScore,
    reviewStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredUtteranceTranslation &&
          other.translationId == this.translationId &&
          other.translationRunId == this.translationRunId &&
          other.utteranceId == this.utteranceId &&
          other.targetLanguage == this.targetLanguage &&
          other.translatedText == this.translatedText &&
          other.qualityScore == this.qualityScore &&
          other.reviewStatus == this.reviewStatus &&
          other.createdAt == this.createdAt);
}

class StoredUtteranceTranslationsCompanion
    extends UpdateCompanion<StoredUtteranceTranslation> {
  final Value<String> translationId;
  final Value<String> translationRunId;
  final Value<String> utteranceId;
  final Value<String> targetLanguage;
  final Value<String> translatedText;
  final Value<double?> qualityScore;
  final Value<String?> reviewStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StoredUtteranceTranslationsCompanion({
    this.translationId = const Value.absent(),
    this.translationRunId = const Value.absent(),
    this.utteranceId = const Value.absent(),
    this.targetLanguage = const Value.absent(),
    this.translatedText = const Value.absent(),
    this.qualityScore = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredUtteranceTranslationsCompanion.insert({
    required String translationId,
    required String translationRunId,
    required String utteranceId,
    required String targetLanguage,
    required String translatedText,
    this.qualityScore = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : translationId = Value(translationId),
       translationRunId = Value(translationRunId),
       utteranceId = Value(utteranceId),
       targetLanguage = Value(targetLanguage),
       translatedText = Value(translatedText);
  static Insertable<StoredUtteranceTranslation> custom({
    Expression<String>? translationId,
    Expression<String>? translationRunId,
    Expression<String>? utteranceId,
    Expression<String>? targetLanguage,
    Expression<String>? translatedText,
    Expression<double>? qualityScore,
    Expression<String>? reviewStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (translationId != null) 'translation_id': translationId,
      if (translationRunId != null) 'translation_run_id': translationRunId,
      if (utteranceId != null) 'utterance_id': utteranceId,
      if (targetLanguage != null) 'target_language': targetLanguage,
      if (translatedText != null) 'translated_text': translatedText,
      if (qualityScore != null) 'quality_score': qualityScore,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredUtteranceTranslationsCompanion copyWith({
    Value<String>? translationId,
    Value<String>? translationRunId,
    Value<String>? utteranceId,
    Value<String>? targetLanguage,
    Value<String>? translatedText,
    Value<double?>? qualityScore,
    Value<String?>? reviewStatus,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StoredUtteranceTranslationsCompanion(
      translationId: translationId ?? this.translationId,
      translationRunId: translationRunId ?? this.translationRunId,
      utteranceId: utteranceId ?? this.utteranceId,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      translatedText: translatedText ?? this.translatedText,
      qualityScore: qualityScore ?? this.qualityScore,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (translationId.present) {
      map['translation_id'] = Variable<String>(translationId.value);
    }
    if (translationRunId.present) {
      map['translation_run_id'] = Variable<String>(translationRunId.value);
    }
    if (utteranceId.present) {
      map['utterance_id'] = Variable<String>(utteranceId.value);
    }
    if (targetLanguage.present) {
      map['target_language'] = Variable<String>(targetLanguage.value);
    }
    if (translatedText.present) {
      map['translated_text'] = Variable<String>(translatedText.value);
    }
    if (qualityScore.present) {
      map['quality_score'] = Variable<double>(qualityScore.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredUtteranceTranslationsCompanion(')
          ..write('translationId: $translationId, ')
          ..write('translationRunId: $translationRunId, ')
          ..write('utteranceId: $utteranceId, ')
          ..write('targetLanguage: $targetLanguage, ')
          ..write('translatedText: $translatedText, ')
          ..write('qualityScore: $qualityScore, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoredAuthSessionsTable extends StoredAuthSessions
    with TableInfo<$StoredAuthSessionsTable, StoredAuthSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredAuthSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionSlotMeta = const VerificationMeta(
    'sessionSlot',
  );
  @override
  late final GeneratedColumn<String> sessionSlot = GeneratedColumn<String>(
    'session_slot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loggedInAtMeta = const VerificationMeta(
    'loggedInAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedInAt = GeneratedColumn<DateTime>(
    'logged_in_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preferredTranscriptLanguageMeta =
      const VerificationMeta('preferredTranscriptLanguage');
  @override
  late final GeneratedColumn<String> preferredTranscriptLanguage =
      GeneratedColumn<String>(
        'preferred_transcript_language',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    sessionSlot,
    userId,
    displayName,
    role,
    eventId,
    loggedInAt,
    preferredTranscriptLanguage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_auth_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredAuthSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_slot')) {
      context.handle(
        _sessionSlotMeta,
        sessionSlot.isAcceptableOrUnknown(
          data['session_slot']!,
          _sessionSlotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionSlotMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('logged_in_at')) {
      context.handle(
        _loggedInAtMeta,
        loggedInAt.isAcceptableOrUnknown(
          data['logged_in_at']!,
          _loggedInAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_loggedInAtMeta);
    }
    if (data.containsKey('preferred_transcript_language')) {
      context.handle(
        _preferredTranscriptLanguageMeta,
        preferredTranscriptLanguage.isAcceptableOrUnknown(
          data['preferred_transcript_language']!,
          _preferredTranscriptLanguageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionSlot};
  @override
  StoredAuthSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredAuthSession(
      sessionSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_slot'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      loggedInAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_in_at'],
      )!,
      preferredTranscriptLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_transcript_language'],
      ),
    );
  }

  @override
  $StoredAuthSessionsTable createAlias(String alias) {
    return $StoredAuthSessionsTable(attachedDatabase, alias);
  }
}

class StoredAuthSession extends DataClass
    implements Insertable<StoredAuthSession> {
  final String sessionSlot;
  final String userId;
  final String displayName;
  final String role;
  final String eventId;
  final DateTime loggedInAt;
  final String? preferredTranscriptLanguage;
  const StoredAuthSession({
    required this.sessionSlot,
    required this.userId,
    required this.displayName,
    required this.role,
    required this.eventId,
    required this.loggedInAt,
    this.preferredTranscriptLanguage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_slot'] = Variable<String>(sessionSlot);
    map['user_id'] = Variable<String>(userId);
    map['display_name'] = Variable<String>(displayName);
    map['role'] = Variable<String>(role);
    map['event_id'] = Variable<String>(eventId);
    map['logged_in_at'] = Variable<DateTime>(loggedInAt);
    if (!nullToAbsent || preferredTranscriptLanguage != null) {
      map['preferred_transcript_language'] = Variable<String>(
        preferredTranscriptLanguage,
      );
    }
    return map;
  }

  StoredAuthSessionsCompanion toCompanion(bool nullToAbsent) {
    return StoredAuthSessionsCompanion(
      sessionSlot: Value(sessionSlot),
      userId: Value(userId),
      displayName: Value(displayName),
      role: Value(role),
      eventId: Value(eventId),
      loggedInAt: Value(loggedInAt),
      preferredTranscriptLanguage:
          preferredTranscriptLanguage == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredTranscriptLanguage),
    );
  }

  factory StoredAuthSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredAuthSession(
      sessionSlot: serializer.fromJson<String>(json['sessionSlot']),
      userId: serializer.fromJson<String>(json['userId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      role: serializer.fromJson<String>(json['role']),
      eventId: serializer.fromJson<String>(json['eventId']),
      loggedInAt: serializer.fromJson<DateTime>(json['loggedInAt']),
      preferredTranscriptLanguage: serializer.fromJson<String?>(
        json['preferredTranscriptLanguage'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionSlot': serializer.toJson<String>(sessionSlot),
      'userId': serializer.toJson<String>(userId),
      'displayName': serializer.toJson<String>(displayName),
      'role': serializer.toJson<String>(role),
      'eventId': serializer.toJson<String>(eventId),
      'loggedInAt': serializer.toJson<DateTime>(loggedInAt),
      'preferredTranscriptLanguage': serializer.toJson<String?>(
        preferredTranscriptLanguage,
      ),
    };
  }

  StoredAuthSession copyWith({
    String? sessionSlot,
    String? userId,
    String? displayName,
    String? role,
    String? eventId,
    DateTime? loggedInAt,
    Value<String?> preferredTranscriptLanguage = const Value.absent(),
  }) => StoredAuthSession(
    sessionSlot: sessionSlot ?? this.sessionSlot,
    userId: userId ?? this.userId,
    displayName: displayName ?? this.displayName,
    role: role ?? this.role,
    eventId: eventId ?? this.eventId,
    loggedInAt: loggedInAt ?? this.loggedInAt,
    preferredTranscriptLanguage: preferredTranscriptLanguage.present
        ? preferredTranscriptLanguage.value
        : this.preferredTranscriptLanguage,
  );
  StoredAuthSession copyWithCompanion(StoredAuthSessionsCompanion data) {
    return StoredAuthSession(
      sessionSlot: data.sessionSlot.present
          ? data.sessionSlot.value
          : this.sessionSlot,
      userId: data.userId.present ? data.userId.value : this.userId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      role: data.role.present ? data.role.value : this.role,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      loggedInAt: data.loggedInAt.present
          ? data.loggedInAt.value
          : this.loggedInAt,
      preferredTranscriptLanguage: data.preferredTranscriptLanguage.present
          ? data.preferredTranscriptLanguage.value
          : this.preferredTranscriptLanguage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredAuthSession(')
          ..write('sessionSlot: $sessionSlot, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('eventId: $eventId, ')
          ..write('loggedInAt: $loggedInAt, ')
          ..write('preferredTranscriptLanguage: $preferredTranscriptLanguage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionSlot,
    userId,
    displayName,
    role,
    eventId,
    loggedInAt,
    preferredTranscriptLanguage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredAuthSession &&
          other.sessionSlot == this.sessionSlot &&
          other.userId == this.userId &&
          other.displayName == this.displayName &&
          other.role == this.role &&
          other.eventId == this.eventId &&
          other.loggedInAt == this.loggedInAt &&
          other.preferredTranscriptLanguage ==
              this.preferredTranscriptLanguage);
}

class StoredAuthSessionsCompanion extends UpdateCompanion<StoredAuthSession> {
  final Value<String> sessionSlot;
  final Value<String> userId;
  final Value<String> displayName;
  final Value<String> role;
  final Value<String> eventId;
  final Value<DateTime> loggedInAt;
  final Value<String?> preferredTranscriptLanguage;
  final Value<int> rowid;
  const StoredAuthSessionsCompanion({
    this.sessionSlot = const Value.absent(),
    this.userId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.role = const Value.absent(),
    this.eventId = const Value.absent(),
    this.loggedInAt = const Value.absent(),
    this.preferredTranscriptLanguage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredAuthSessionsCompanion.insert({
    required String sessionSlot,
    required String userId,
    required String displayName,
    required String role,
    required String eventId,
    required DateTime loggedInAt,
    this.preferredTranscriptLanguage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionSlot = Value(sessionSlot),
       userId = Value(userId),
       displayName = Value(displayName),
       role = Value(role),
       eventId = Value(eventId),
       loggedInAt = Value(loggedInAt);
  static Insertable<StoredAuthSession> custom({
    Expression<String>? sessionSlot,
    Expression<String>? userId,
    Expression<String>? displayName,
    Expression<String>? role,
    Expression<String>? eventId,
    Expression<DateTime>? loggedInAt,
    Expression<String>? preferredTranscriptLanguage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionSlot != null) 'session_slot': sessionSlot,
      if (userId != null) 'user_id': userId,
      if (displayName != null) 'display_name': displayName,
      if (role != null) 'role': role,
      if (eventId != null) 'event_id': eventId,
      if (loggedInAt != null) 'logged_in_at': loggedInAt,
      if (preferredTranscriptLanguage != null)
        'preferred_transcript_language': preferredTranscriptLanguage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredAuthSessionsCompanion copyWith({
    Value<String>? sessionSlot,
    Value<String>? userId,
    Value<String>? displayName,
    Value<String>? role,
    Value<String>? eventId,
    Value<DateTime>? loggedInAt,
    Value<String?>? preferredTranscriptLanguage,
    Value<int>? rowid,
  }) {
    return StoredAuthSessionsCompanion(
      sessionSlot: sessionSlot ?? this.sessionSlot,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      eventId: eventId ?? this.eventId,
      loggedInAt: loggedInAt ?? this.loggedInAt,
      preferredTranscriptLanguage:
          preferredTranscriptLanguage ?? this.preferredTranscriptLanguage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionSlot.present) {
      map['session_slot'] = Variable<String>(sessionSlot.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (loggedInAt.present) {
      map['logged_in_at'] = Variable<DateTime>(loggedInAt.value);
    }
    if (preferredTranscriptLanguage.present) {
      map['preferred_transcript_language'] = Variable<String>(
        preferredTranscriptLanguage.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredAuthSessionsCompanion(')
          ..write('sessionSlot: $sessionSlot, ')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('eventId: $eventId, ')
          ..write('loggedInAt: $loggedInAt, ')
          ..write('preferredTranscriptLanguage: $preferredTranscriptLanguage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StoredEventSessionsTable storedEventSessions =
      $StoredEventSessionsTable(this);
  late final $StoredTranscriptUtterancesTable storedTranscriptUtterances =
      $StoredTranscriptUtterancesTable(this);
  late final $StoredTranscriptTranslationRunsTable
  storedTranscriptTranslationRuns = $StoredTranscriptTranslationRunsTable(this);
  late final $StoredUtteranceTranslationsTable storedUtteranceTranslations =
      $StoredUtteranceTranslationsTable(this);
  late final $StoredAuthSessionsTable storedAuthSessions =
      $StoredAuthSessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    storedEventSessions,
    storedTranscriptUtterances,
    storedTranscriptTranslationRuns,
    storedUtteranceTranslations,
    storedAuthSessions,
  ];
}

typedef $$StoredEventSessionsTableCreateCompanionBuilder =
    StoredEventSessionsCompanion Function({
      required String eventId,
      required String eventName,
      required String hostLanguage,
      required String eventTimeZone,
      required bool isDaylightSavingTimeEnabled,
      required DateTime scheduledStartAt,
      Value<DateTime?> actualStartAt,
      Value<DateTime?> endedAt,
      required String status,
      required String supportedLanguagesJson,
      Value<String> moderationSettingsJson,
      Value<String> moderationRuntimeJson,
      required String transcriptRetentionPolicy,
      Value<DateTime?> transcriptExpiresAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$StoredEventSessionsTableUpdateCompanionBuilder =
    StoredEventSessionsCompanion Function({
      Value<String> eventId,
      Value<String> eventName,
      Value<String> hostLanguage,
      Value<String> eventTimeZone,
      Value<bool> isDaylightSavingTimeEnabled,
      Value<DateTime> scheduledStartAt,
      Value<DateTime?> actualStartAt,
      Value<DateTime?> endedAt,
      Value<String> status,
      Value<String> supportedLanguagesJson,
      Value<String> moderationSettingsJson,
      Value<String> moderationRuntimeJson,
      Value<String> transcriptRetentionPolicy,
      Value<DateTime?> transcriptExpiresAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$StoredEventSessionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StoredEventSessionsTable,
          StoredEventSession
        > {
  $$StoredEventSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $StoredTranscriptUtterancesTable,
    List<StoredTranscriptUtterance>
  >
  _storedTranscriptUtterancesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.storedTranscriptUtterances,
        aliasName: $_aliasNameGenerator(
          db.storedEventSessions.eventId,
          db.storedTranscriptUtterances.eventId,
        ),
      );

  $$StoredTranscriptUtterancesTableProcessedTableManager
  get storedTranscriptUtterancesRefs {
    final manager =
        $$StoredTranscriptUtterancesTableTableManager(
          $_db,
          $_db.storedTranscriptUtterances,
        ).filter(
          (f) => f.eventId.eventId.sqlEquals($_itemColumn<String>('event_id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _storedTranscriptUtterancesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $StoredTranscriptTranslationRunsTable,
    List<StoredTranscriptTranslationRun>
  >
  _storedTranscriptTranslationRunsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.storedTranscriptTranslationRuns,
        aliasName: $_aliasNameGenerator(
          db.storedEventSessions.eventId,
          db.storedTranscriptTranslationRuns.eventId,
        ),
      );

  $$StoredTranscriptTranslationRunsTableProcessedTableManager
  get storedTranscriptTranslationRunsRefs {
    final manager =
        $$StoredTranscriptTranslationRunsTableTableManager(
          $_db,
          $_db.storedTranscriptTranslationRuns,
        ).filter(
          (f) => f.eventId.eventId.sqlEquals($_itemColumn<String>('event_id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _storedTranscriptTranslationRunsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StoredEventSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $StoredEventSessionsTable> {
  $$StoredEventSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventName => $composableBuilder(
    column: $table.eventName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hostLanguage => $composableBuilder(
    column: $table.hostLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventTimeZone => $composableBuilder(
    column: $table.eventTimeZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDaylightSavingTimeEnabled => $composableBuilder(
    column: $table.isDaylightSavingTimeEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledStartAt => $composableBuilder(
    column: $table.scheduledStartAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualStartAt => $composableBuilder(
    column: $table.actualStartAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supportedLanguagesJson => $composableBuilder(
    column: $table.supportedLanguagesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moderationSettingsJson => $composableBuilder(
    column: $table.moderationSettingsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moderationRuntimeJson => $composableBuilder(
    column: $table.moderationRuntimeJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcriptRetentionPolicy => $composableBuilder(
    column: $table.transcriptRetentionPolicy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transcriptExpiresAt => $composableBuilder(
    column: $table.transcriptExpiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> storedTranscriptUtterancesRefs(
    Expression<bool> Function($$StoredTranscriptUtterancesTableFilterComposer f)
    f,
  ) {
    final $$StoredTranscriptUtterancesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.eventId,
          referencedTable: $db.storedTranscriptUtterances,
          getReferencedColumn: (t) => t.eventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StoredTranscriptUtterancesTableFilterComposer(
                $db: $db,
                $table: $db.storedTranscriptUtterances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> storedTranscriptTranslationRunsRefs(
    Expression<bool> Function(
      $$StoredTranscriptTranslationRunsTableFilterComposer f,
    )
    f,
  ) {
    final $$StoredTranscriptTranslationRunsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.eventId,
          referencedTable: $db.storedTranscriptTranslationRuns,
          getReferencedColumn: (t) => t.eventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StoredTranscriptTranslationRunsTableFilterComposer(
                $db: $db,
                $table: $db.storedTranscriptTranslationRuns,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StoredEventSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StoredEventSessionsTable> {
  $$StoredEventSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventName => $composableBuilder(
    column: $table.eventName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hostLanguage => $composableBuilder(
    column: $table.hostLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventTimeZone => $composableBuilder(
    column: $table.eventTimeZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDaylightSavingTimeEnabled => $composableBuilder(
    column: $table.isDaylightSavingTimeEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledStartAt => $composableBuilder(
    column: $table.scheduledStartAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualStartAt => $composableBuilder(
    column: $table.actualStartAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supportedLanguagesJson => $composableBuilder(
    column: $table.supportedLanguagesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moderationSettingsJson => $composableBuilder(
    column: $table.moderationSettingsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moderationRuntimeJson => $composableBuilder(
    column: $table.moderationRuntimeJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcriptRetentionPolicy => $composableBuilder(
    column: $table.transcriptRetentionPolicy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transcriptExpiresAt => $composableBuilder(
    column: $table.transcriptExpiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoredEventSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoredEventSessionsTable> {
  $$StoredEventSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get eventName =>
      $composableBuilder(column: $table.eventName, builder: (column) => column);

  GeneratedColumn<String> get hostLanguage => $composableBuilder(
    column: $table.hostLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventTimeZone => $composableBuilder(
    column: $table.eventTimeZone,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDaylightSavingTimeEnabled => $composableBuilder(
    column: $table.isDaylightSavingTimeEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledStartAt => $composableBuilder(
    column: $table.scheduledStartAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get actualStartAt => $composableBuilder(
    column: $table.actualStartAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get supportedLanguagesJson => $composableBuilder(
    column: $table.supportedLanguagesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get moderationSettingsJson => $composableBuilder(
    column: $table.moderationSettingsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get moderationRuntimeJson => $composableBuilder(
    column: $table.moderationRuntimeJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transcriptRetentionPolicy => $composableBuilder(
    column: $table.transcriptRetentionPolicy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get transcriptExpiresAt => $composableBuilder(
    column: $table.transcriptExpiresAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> storedTranscriptUtterancesRefs<T extends Object>(
    Expression<T> Function(
      $$StoredTranscriptUtterancesTableAnnotationComposer a,
    )
    f,
  ) {
    final $$StoredTranscriptUtterancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.eventId,
          referencedTable: $db.storedTranscriptUtterances,
          getReferencedColumn: (t) => t.eventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StoredTranscriptUtterancesTableAnnotationComposer(
                $db: $db,
                $table: $db.storedTranscriptUtterances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> storedTranscriptTranslationRunsRefs<T extends Object>(
    Expression<T> Function(
      $$StoredTranscriptTranslationRunsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$StoredTranscriptTranslationRunsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.eventId,
          referencedTable: $db.storedTranscriptTranslationRuns,
          getReferencedColumn: (t) => t.eventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StoredTranscriptTranslationRunsTableAnnotationComposer(
                $db: $db,
                $table: $db.storedTranscriptTranslationRuns,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StoredEventSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoredEventSessionsTable,
          StoredEventSession,
          $$StoredEventSessionsTableFilterComposer,
          $$StoredEventSessionsTableOrderingComposer,
          $$StoredEventSessionsTableAnnotationComposer,
          $$StoredEventSessionsTableCreateCompanionBuilder,
          $$StoredEventSessionsTableUpdateCompanionBuilder,
          (StoredEventSession, $$StoredEventSessionsTableReferences),
          StoredEventSession,
          PrefetchHooks Function({
            bool storedTranscriptUtterancesRefs,
            bool storedTranscriptTranslationRunsRefs,
          })
        > {
  $$StoredEventSessionsTableTableManager(
    _$AppDatabase db,
    $StoredEventSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoredEventSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoredEventSessionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StoredEventSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> eventName = const Value.absent(),
                Value<String> hostLanguage = const Value.absent(),
                Value<String> eventTimeZone = const Value.absent(),
                Value<bool> isDaylightSavingTimeEnabled = const Value.absent(),
                Value<DateTime> scheduledStartAt = const Value.absent(),
                Value<DateTime?> actualStartAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> supportedLanguagesJson = const Value.absent(),
                Value<String> moderationSettingsJson = const Value.absent(),
                Value<String> moderationRuntimeJson = const Value.absent(),
                Value<String> transcriptRetentionPolicy = const Value.absent(),
                Value<DateTime?> transcriptExpiresAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredEventSessionsCompanion(
                eventId: eventId,
                eventName: eventName,
                hostLanguage: hostLanguage,
                eventTimeZone: eventTimeZone,
                isDaylightSavingTimeEnabled: isDaylightSavingTimeEnabled,
                scheduledStartAt: scheduledStartAt,
                actualStartAt: actualStartAt,
                endedAt: endedAt,
                status: status,
                supportedLanguagesJson: supportedLanguagesJson,
                moderationSettingsJson: moderationSettingsJson,
                moderationRuntimeJson: moderationRuntimeJson,
                transcriptRetentionPolicy: transcriptRetentionPolicy,
                transcriptExpiresAt: transcriptExpiresAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String eventName,
                required String hostLanguage,
                required String eventTimeZone,
                required bool isDaylightSavingTimeEnabled,
                required DateTime scheduledStartAt,
                Value<DateTime?> actualStartAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                required String status,
                required String supportedLanguagesJson,
                Value<String> moderationSettingsJson = const Value.absent(),
                Value<String> moderationRuntimeJson = const Value.absent(),
                required String transcriptRetentionPolicy,
                Value<DateTime?> transcriptExpiresAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredEventSessionsCompanion.insert(
                eventId: eventId,
                eventName: eventName,
                hostLanguage: hostLanguage,
                eventTimeZone: eventTimeZone,
                isDaylightSavingTimeEnabled: isDaylightSavingTimeEnabled,
                scheduledStartAt: scheduledStartAt,
                actualStartAt: actualStartAt,
                endedAt: endedAt,
                status: status,
                supportedLanguagesJson: supportedLanguagesJson,
                moderationSettingsJson: moderationSettingsJson,
                moderationRuntimeJson: moderationRuntimeJson,
                transcriptRetentionPolicy: transcriptRetentionPolicy,
                transcriptExpiresAt: transcriptExpiresAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StoredEventSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                storedTranscriptUtterancesRefs = false,
                storedTranscriptTranslationRunsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (storedTranscriptUtterancesRefs)
                      db.storedTranscriptUtterances,
                    if (storedTranscriptTranslationRunsRefs)
                      db.storedTranscriptTranslationRuns,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (storedTranscriptUtterancesRefs)
                        await $_getPrefetchedData<
                          StoredEventSession,
                          $StoredEventSessionsTable,
                          StoredTranscriptUtterance
                        >(
                          currentTable: table,
                          referencedTable: $$StoredEventSessionsTableReferences
                              ._storedTranscriptUtterancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StoredEventSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).storedTranscriptUtterancesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.eventId,
                              ),
                          typedResults: items,
                        ),
                      if (storedTranscriptTranslationRunsRefs)
                        await $_getPrefetchedData<
                          StoredEventSession,
                          $StoredEventSessionsTable,
                          StoredTranscriptTranslationRun
                        >(
                          currentTable: table,
                          referencedTable: $$StoredEventSessionsTableReferences
                              ._storedTranscriptTranslationRunsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StoredEventSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).storedTranscriptTranslationRunsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.eventId == item.eventId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StoredEventSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoredEventSessionsTable,
      StoredEventSession,
      $$StoredEventSessionsTableFilterComposer,
      $$StoredEventSessionsTableOrderingComposer,
      $$StoredEventSessionsTableAnnotationComposer,
      $$StoredEventSessionsTableCreateCompanionBuilder,
      $$StoredEventSessionsTableUpdateCompanionBuilder,
      (StoredEventSession, $$StoredEventSessionsTableReferences),
      StoredEventSession,
      PrefetchHooks Function({
        bool storedTranscriptUtterancesRefs,
        bool storedTranscriptTranslationRunsRefs,
      })
    >;
typedef $$StoredTranscriptUtterancesTableCreateCompanionBuilder =
    StoredTranscriptUtterancesCompanion Function({
      required String utteranceId,
      required String eventId,
      required int sequenceNumber,
      required String speakerLabel,
      Value<String?> spokenLanguage,
      required String originalText,
      Value<String?> translatedText,
      Value<String?> targetLanguage,
      Value<String?> segmentStatus,
      Value<String?> editedFinalText,
      Value<double?> confidence,
      required DateTime capturedAt,
      Value<DateTime?> finalizedAt,
      Value<int> rowid,
    });
typedef $$StoredTranscriptUtterancesTableUpdateCompanionBuilder =
    StoredTranscriptUtterancesCompanion Function({
      Value<String> utteranceId,
      Value<String> eventId,
      Value<int> sequenceNumber,
      Value<String> speakerLabel,
      Value<String?> spokenLanguage,
      Value<String> originalText,
      Value<String?> translatedText,
      Value<String?> targetLanguage,
      Value<String?> segmentStatus,
      Value<String?> editedFinalText,
      Value<double?> confidence,
      Value<DateTime> capturedAt,
      Value<DateTime?> finalizedAt,
      Value<int> rowid,
    });

final class $$StoredTranscriptUtterancesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StoredTranscriptUtterancesTable,
          StoredTranscriptUtterance
        > {
  $$StoredTranscriptUtterancesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StoredEventSessionsTable _eventIdTable(_$AppDatabase db) =>
      db.storedEventSessions.createAlias(
        $_aliasNameGenerator(
          db.storedTranscriptUtterances.eventId,
          db.storedEventSessions.eventId,
        ),
      );

  $$StoredEventSessionsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<String>('event_id')!;

    final manager = $$StoredEventSessionsTableTableManager(
      $_db,
      $_db.storedEventSessions,
    ).filter((f) => f.eventId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $StoredUtteranceTranslationsTable,
    List<StoredUtteranceTranslation>
  >
  _storedUtteranceTranslationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.storedUtteranceTranslations,
        aliasName: $_aliasNameGenerator(
          db.storedTranscriptUtterances.utteranceId,
          db.storedUtteranceTranslations.utteranceId,
        ),
      );

  $$StoredUtteranceTranslationsTableProcessedTableManager
  get storedUtteranceTranslationsRefs {
    final manager =
        $$StoredUtteranceTranslationsTableTableManager(
          $_db,
          $_db.storedUtteranceTranslations,
        ).filter(
          (f) => f.utteranceId.utteranceId.sqlEquals(
            $_itemColumn<String>('utterance_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _storedUtteranceTranslationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StoredTranscriptUtterancesTableFilterComposer
    extends Composer<_$AppDatabase, $StoredTranscriptUtterancesTable> {
  $$StoredTranscriptUtterancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get utteranceId => $composableBuilder(
    column: $table.utteranceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speakerLabel => $composableBuilder(
    column: $table.speakerLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spokenLanguage => $composableBuilder(
    column: $table.spokenLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalText => $composableBuilder(
    column: $table.originalText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translatedText => $composableBuilder(
    column: $table.translatedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetLanguage => $composableBuilder(
    column: $table.targetLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get segmentStatus => $composableBuilder(
    column: $table.segmentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get editedFinalText => $composableBuilder(
    column: $table.editedFinalText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StoredEventSessionsTableFilterComposer get eventId {
    final $$StoredEventSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.storedEventSessions,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoredEventSessionsTableFilterComposer(
            $db: $db,
            $table: $db.storedEventSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> storedUtteranceTranslationsRefs(
    Expression<bool> Function(
      $$StoredUtteranceTranslationsTableFilterComposer f,
    )
    f,
  ) {
    final $$StoredUtteranceTranslationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.utteranceId,
          referencedTable: $db.storedUtteranceTranslations,
          getReferencedColumn: (t) => t.utteranceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StoredUtteranceTranslationsTableFilterComposer(
                $db: $db,
                $table: $db.storedUtteranceTranslations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StoredTranscriptUtterancesTableOrderingComposer
    extends Composer<_$AppDatabase, $StoredTranscriptUtterancesTable> {
  $$StoredTranscriptUtterancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get utteranceId => $composableBuilder(
    column: $table.utteranceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speakerLabel => $composableBuilder(
    column: $table.speakerLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spokenLanguage => $composableBuilder(
    column: $table.spokenLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalText => $composableBuilder(
    column: $table.originalText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translatedText => $composableBuilder(
    column: $table.translatedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetLanguage => $composableBuilder(
    column: $table.targetLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get segmentStatus => $composableBuilder(
    column: $table.segmentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get editedFinalText => $composableBuilder(
    column: $table.editedFinalText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StoredEventSessionsTableOrderingComposer get eventId {
    final $$StoredEventSessionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.eventId,
          referencedTable: $db.storedEventSessions,
          getReferencedColumn: (t) => t.eventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StoredEventSessionsTableOrderingComposer(
                $db: $db,
                $table: $db.storedEventSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$StoredTranscriptUtterancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoredTranscriptUtterancesTable> {
  $$StoredTranscriptUtterancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get utteranceId => $composableBuilder(
    column: $table.utteranceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get speakerLabel => $composableBuilder(
    column: $table.speakerLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get spokenLanguage => $composableBuilder(
    column: $table.spokenLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalText => $composableBuilder(
    column: $table.originalText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translatedText => $composableBuilder(
    column: $table.translatedText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetLanguage => $composableBuilder(
    column: $table.targetLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get segmentStatus => $composableBuilder(
    column: $table.segmentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get editedFinalText => $composableBuilder(
    column: $table.editedFinalText,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
    builder: (column) => column,
  );

  $$StoredEventSessionsTableAnnotationComposer get eventId {
    final $$StoredEventSessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.eventId,
          referencedTable: $db.storedEventSessions,
          getReferencedColumn: (t) => t.eventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StoredEventSessionsTableAnnotationComposer(
                $db: $db,
                $table: $db.storedEventSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> storedUtteranceTranslationsRefs<T extends Object>(
    Expression<T> Function(
      $$StoredUtteranceTranslationsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$StoredUtteranceTranslationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.utteranceId,
          referencedTable: $db.storedUtteranceTranslations,
          getReferencedColumn: (t) => t.utteranceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StoredUtteranceTranslationsTableAnnotationComposer(
                $db: $db,
                $table: $db.storedUtteranceTranslations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StoredTranscriptUtterancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoredTranscriptUtterancesTable,
          StoredTranscriptUtterance,
          $$StoredTranscriptUtterancesTableFilterComposer,
          $$StoredTranscriptUtterancesTableOrderingComposer,
          $$StoredTranscriptUtterancesTableAnnotationComposer,
          $$StoredTranscriptUtterancesTableCreateCompanionBuilder,
          $$StoredTranscriptUtterancesTableUpdateCompanionBuilder,
          (
            StoredTranscriptUtterance,
            $$StoredTranscriptUtterancesTableReferences,
          ),
          StoredTranscriptUtterance,
          PrefetchHooks Function({
            bool eventId,
            bool storedUtteranceTranslationsRefs,
          })
        > {
  $$StoredTranscriptUtterancesTableTableManager(
    _$AppDatabase db,
    $StoredTranscriptUtterancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoredTranscriptUtterancesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$StoredTranscriptUtterancesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StoredTranscriptUtterancesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> utteranceId = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<int> sequenceNumber = const Value.absent(),
                Value<String> speakerLabel = const Value.absent(),
                Value<String?> spokenLanguage = const Value.absent(),
                Value<String> originalText = const Value.absent(),
                Value<String?> translatedText = const Value.absent(),
                Value<String?> targetLanguage = const Value.absent(),
                Value<String?> segmentStatus = const Value.absent(),
                Value<String?> editedFinalText = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<DateTime?> finalizedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredTranscriptUtterancesCompanion(
                utteranceId: utteranceId,
                eventId: eventId,
                sequenceNumber: sequenceNumber,
                speakerLabel: speakerLabel,
                spokenLanguage: spokenLanguage,
                originalText: originalText,
                translatedText: translatedText,
                targetLanguage: targetLanguage,
                segmentStatus: segmentStatus,
                editedFinalText: editedFinalText,
                confidence: confidence,
                capturedAt: capturedAt,
                finalizedAt: finalizedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String utteranceId,
                required String eventId,
                required int sequenceNumber,
                required String speakerLabel,
                Value<String?> spokenLanguage = const Value.absent(),
                required String originalText,
                Value<String?> translatedText = const Value.absent(),
                Value<String?> targetLanguage = const Value.absent(),
                Value<String?> segmentStatus = const Value.absent(),
                Value<String?> editedFinalText = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                required DateTime capturedAt,
                Value<DateTime?> finalizedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredTranscriptUtterancesCompanion.insert(
                utteranceId: utteranceId,
                eventId: eventId,
                sequenceNumber: sequenceNumber,
                speakerLabel: speakerLabel,
                spokenLanguage: spokenLanguage,
                originalText: originalText,
                translatedText: translatedText,
                targetLanguage: targetLanguage,
                segmentStatus: segmentStatus,
                editedFinalText: editedFinalText,
                confidence: confidence,
                capturedAt: capturedAt,
                finalizedAt: finalizedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StoredTranscriptUtterancesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({eventId = false, storedUtteranceTranslationsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (storedUtteranceTranslationsRefs)
                      db.storedUtteranceTranslations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (eventId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.eventId,
                                    referencedTable:
                                        $$StoredTranscriptUtterancesTableReferences
                                            ._eventIdTable(db),
                                    referencedColumn:
                                        $$StoredTranscriptUtterancesTableReferences
                                            ._eventIdTable(db)
                                            .eventId,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (storedUtteranceTranslationsRefs)
                        await $_getPrefetchedData<
                          StoredTranscriptUtterance,
                          $StoredTranscriptUtterancesTable,
                          StoredUtteranceTranslation
                        >(
                          currentTable: table,
                          referencedTable:
                              $$StoredTranscriptUtterancesTableReferences
                                  ._storedUtteranceTranslationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StoredTranscriptUtterancesTableReferences(
                                db,
                                table,
                                p0,
                              ).storedUtteranceTranslationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.utteranceId == item.utteranceId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StoredTranscriptUtterancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoredTranscriptUtterancesTable,
      StoredTranscriptUtterance,
      $$StoredTranscriptUtterancesTableFilterComposer,
      $$StoredTranscriptUtterancesTableOrderingComposer,
      $$StoredTranscriptUtterancesTableAnnotationComposer,
      $$StoredTranscriptUtterancesTableCreateCompanionBuilder,
      $$StoredTranscriptUtterancesTableUpdateCompanionBuilder,
      (StoredTranscriptUtterance, $$StoredTranscriptUtterancesTableReferences),
      StoredTranscriptUtterance,
      PrefetchHooks Function({
        bool eventId,
        bool storedUtteranceTranslationsRefs,
      })
    >;
typedef $$StoredTranscriptTranslationRunsTableCreateCompanionBuilder =
    StoredTranscriptTranslationRunsCompanion Function({
      required String translationRunId,
      required String eventId,
      required String targetLanguage,
      required String provider,
      Value<String?> modelVersion,
      Value<String?> promptConfigVersion,
      required String status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$StoredTranscriptTranslationRunsTableUpdateCompanionBuilder =
    StoredTranscriptTranslationRunsCompanion Function({
      Value<String> translationRunId,
      Value<String> eventId,
      Value<String> targetLanguage,
      Value<String> provider,
      Value<String?> modelVersion,
      Value<String?> promptConfigVersion,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$StoredTranscriptTranslationRunsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StoredTranscriptTranslationRunsTable,
          StoredTranscriptTranslationRun
        > {
  $$StoredTranscriptTranslationRunsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StoredEventSessionsTable _eventIdTable(_$AppDatabase db) =>
      db.storedEventSessions.createAlias(
        $_aliasNameGenerator(
          db.storedTranscriptTranslationRuns.eventId,
          db.storedEventSessions.eventId,
        ),
      );

  $$StoredEventSessionsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<String>('event_id')!;

    final manager = $$StoredEventSessionsTableTableManager(
      $_db,
      $_db.storedEventSessions,
    ).filter((f) => f.eventId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $StoredUtteranceTranslationsTable,
    List<StoredUtteranceTranslation>
  >
  _storedUtteranceTranslationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.storedUtteranceTranslations,
        aliasName: $_aliasNameGenerator(
          db.storedTranscriptTranslationRuns.translationRunId,
          db.storedUtteranceTranslations.translationRunId,
        ),
      );

  $$StoredUtteranceTranslationsTableProcessedTableManager
  get storedUtteranceTranslationsRefs {
    final manager =
        $$StoredUtteranceTranslationsTableTableManager(
          $_db,
          $_db.storedUtteranceTranslations,
        ).filter(
          (f) => f.translationRunId.translationRunId.sqlEquals(
            $_itemColumn<String>('translation_run_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _storedUtteranceTranslationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StoredTranscriptTranslationRunsTableFilterComposer
    extends Composer<_$AppDatabase, $StoredTranscriptTranslationRunsTable> {
  $$StoredTranscriptTranslationRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get translationRunId => $composableBuilder(
    column: $table.translationRunId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetLanguage => $composableBuilder(
    column: $table.targetLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promptConfigVersion => $composableBuilder(
    column: $table.promptConfigVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StoredEventSessionsTableFilterComposer get eventId {
    final $$StoredEventSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.eventId,
      referencedTable: $db.storedEventSessions,
      getReferencedColumn: (t) => t.eventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoredEventSessionsTableFilterComposer(
            $db: $db,
            $table: $db.storedEventSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> storedUtteranceTranslationsRefs(
    Expression<bool> Function(
      $$StoredUtteranceTranslationsTableFilterComposer f,
    )
    f,
  ) {
    final $$StoredUtteranceTranslationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.translationRunId,
          referencedTable: $db.storedUtteranceTranslations,
          getReferencedColumn: (t) => t.translationRunId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StoredUtteranceTranslationsTableFilterComposer(
                $db: $db,
                $table: $db.storedUtteranceTranslations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StoredTranscriptTranslationRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $StoredTranscriptTranslationRunsTable> {
  $$StoredTranscriptTranslationRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get translationRunId => $composableBuilder(
    column: $table.translationRunId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetLanguage => $composableBuilder(
    column: $table.targetLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promptConfigVersion => $composableBuilder(
    column: $table.promptConfigVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StoredEventSessionsTableOrderingComposer get eventId {
    final $$StoredEventSessionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.eventId,
          referencedTable: $db.storedEventSessions,
          getReferencedColumn: (t) => t.eventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StoredEventSessionsTableOrderingComposer(
                $db: $db,
                $table: $db.storedEventSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$StoredTranscriptTranslationRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoredTranscriptTranslationRunsTable> {
  $$StoredTranscriptTranslationRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get translationRunId => $composableBuilder(
    column: $table.translationRunId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetLanguage => $composableBuilder(
    column: $table.targetLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get promptConfigVersion => $composableBuilder(
    column: $table.promptConfigVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$StoredEventSessionsTableAnnotationComposer get eventId {
    final $$StoredEventSessionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.eventId,
          referencedTable: $db.storedEventSessions,
          getReferencedColumn: (t) => t.eventId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StoredEventSessionsTableAnnotationComposer(
                $db: $db,
                $table: $db.storedEventSessions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> storedUtteranceTranslationsRefs<T extends Object>(
    Expression<T> Function(
      $$StoredUtteranceTranslationsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$StoredUtteranceTranslationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.translationRunId,
          referencedTable: $db.storedUtteranceTranslations,
          getReferencedColumn: (t) => t.translationRunId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StoredUtteranceTranslationsTableAnnotationComposer(
                $db: $db,
                $table: $db.storedUtteranceTranslations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StoredTranscriptTranslationRunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoredTranscriptTranslationRunsTable,
          StoredTranscriptTranslationRun,
          $$StoredTranscriptTranslationRunsTableFilterComposer,
          $$StoredTranscriptTranslationRunsTableOrderingComposer,
          $$StoredTranscriptTranslationRunsTableAnnotationComposer,
          $$StoredTranscriptTranslationRunsTableCreateCompanionBuilder,
          $$StoredTranscriptTranslationRunsTableUpdateCompanionBuilder,
          (
            StoredTranscriptTranslationRun,
            $$StoredTranscriptTranslationRunsTableReferences,
          ),
          StoredTranscriptTranslationRun,
          PrefetchHooks Function({
            bool eventId,
            bool storedUtteranceTranslationsRefs,
          })
        > {
  $$StoredTranscriptTranslationRunsTableTableManager(
    _$AppDatabase db,
    $StoredTranscriptTranslationRunsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoredTranscriptTranslationRunsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$StoredTranscriptTranslationRunsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StoredTranscriptTranslationRunsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> translationRunId = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String> targetLanguage = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String?> modelVersion = const Value.absent(),
                Value<String?> promptConfigVersion = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredTranscriptTranslationRunsCompanion(
                translationRunId: translationRunId,
                eventId: eventId,
                targetLanguage: targetLanguage,
                provider: provider,
                modelVersion: modelVersion,
                promptConfigVersion: promptConfigVersion,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String translationRunId,
                required String eventId,
                required String targetLanguage,
                required String provider,
                Value<String?> modelVersion = const Value.absent(),
                Value<String?> promptConfigVersion = const Value.absent(),
                required String status,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredTranscriptTranslationRunsCompanion.insert(
                translationRunId: translationRunId,
                eventId: eventId,
                targetLanguage: targetLanguage,
                provider: provider,
                modelVersion: modelVersion,
                promptConfigVersion: promptConfigVersion,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StoredTranscriptTranslationRunsTableReferences(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({eventId = false, storedUtteranceTranslationsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (storedUtteranceTranslationsRefs)
                      db.storedUtteranceTranslations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (eventId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.eventId,
                                    referencedTable:
                                        $$StoredTranscriptTranslationRunsTableReferences
                                            ._eventIdTable(db),
                                    referencedColumn:
                                        $$StoredTranscriptTranslationRunsTableReferences
                                            ._eventIdTable(db)
                                            .eventId,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (storedUtteranceTranslationsRefs)
                        await $_getPrefetchedData<
                          StoredTranscriptTranslationRun,
                          $StoredTranscriptTranslationRunsTable,
                          StoredUtteranceTranslation
                        >(
                          currentTable: table,
                          referencedTable:
                              $$StoredTranscriptTranslationRunsTableReferences
                                  ._storedUtteranceTranslationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StoredTranscriptTranslationRunsTableReferences(
                                db,
                                table,
                                p0,
                              ).storedUtteranceTranslationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.translationRunId == item.translationRunId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StoredTranscriptTranslationRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoredTranscriptTranslationRunsTable,
      StoredTranscriptTranslationRun,
      $$StoredTranscriptTranslationRunsTableFilterComposer,
      $$StoredTranscriptTranslationRunsTableOrderingComposer,
      $$StoredTranscriptTranslationRunsTableAnnotationComposer,
      $$StoredTranscriptTranslationRunsTableCreateCompanionBuilder,
      $$StoredTranscriptTranslationRunsTableUpdateCompanionBuilder,
      (
        StoredTranscriptTranslationRun,
        $$StoredTranscriptTranslationRunsTableReferences,
      ),
      StoredTranscriptTranslationRun,
      PrefetchHooks Function({
        bool eventId,
        bool storedUtteranceTranslationsRefs,
      })
    >;
typedef $$StoredUtteranceTranslationsTableCreateCompanionBuilder =
    StoredUtteranceTranslationsCompanion Function({
      required String translationId,
      required String translationRunId,
      required String utteranceId,
      required String targetLanguage,
      required String translatedText,
      Value<double?> qualityScore,
      Value<String?> reviewStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$StoredUtteranceTranslationsTableUpdateCompanionBuilder =
    StoredUtteranceTranslationsCompanion Function({
      Value<String> translationId,
      Value<String> translationRunId,
      Value<String> utteranceId,
      Value<String> targetLanguage,
      Value<String> translatedText,
      Value<double?> qualityScore,
      Value<String?> reviewStatus,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$StoredUtteranceTranslationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StoredUtteranceTranslationsTable,
          StoredUtteranceTranslation
        > {
  $$StoredUtteranceTranslationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StoredTranscriptTranslationRunsTable _translationRunIdTable(
    _$AppDatabase db,
  ) => db.storedTranscriptTranslationRuns.createAlias(
    $_aliasNameGenerator(
      db.storedUtteranceTranslations.translationRunId,
      db.storedTranscriptTranslationRuns.translationRunId,
    ),
  );

  $$StoredTranscriptTranslationRunsTableProcessedTableManager
  get translationRunId {
    final $_column = $_itemColumn<String>('translation_run_id')!;

    final manager = $$StoredTranscriptTranslationRunsTableTableManager(
      $_db,
      $_db.storedTranscriptTranslationRuns,
    ).filter((f) => f.translationRunId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_translationRunIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StoredTranscriptUtterancesTable _utteranceIdTable(_$AppDatabase db) =>
      db.storedTranscriptUtterances.createAlias(
        $_aliasNameGenerator(
          db.storedUtteranceTranslations.utteranceId,
          db.storedTranscriptUtterances.utteranceId,
        ),
      );

  $$StoredTranscriptUtterancesTableProcessedTableManager get utteranceId {
    final $_column = $_itemColumn<String>('utterance_id')!;

    final manager = $$StoredTranscriptUtterancesTableTableManager(
      $_db,
      $_db.storedTranscriptUtterances,
    ).filter((f) => f.utteranceId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_utteranceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StoredUtteranceTranslationsTableFilterComposer
    extends Composer<_$AppDatabase, $StoredUtteranceTranslationsTable> {
  $$StoredUtteranceTranslationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetLanguage => $composableBuilder(
    column: $table.targetLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translatedText => $composableBuilder(
    column: $table.translatedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get qualityScore => $composableBuilder(
    column: $table.qualityScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StoredTranscriptTranslationRunsTableFilterComposer get translationRunId {
    final $$StoredTranscriptTranslationRunsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.translationRunId,
          referencedTable: $db.storedTranscriptTranslationRuns,
          getReferencedColumn: (t) => t.translationRunId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StoredTranscriptTranslationRunsTableFilterComposer(
                $db: $db,
                $table: $db.storedTranscriptTranslationRuns,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$StoredTranscriptUtterancesTableFilterComposer get utteranceId {
    final $$StoredTranscriptUtterancesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.utteranceId,
          referencedTable: $db.storedTranscriptUtterances,
          getReferencedColumn: (t) => t.utteranceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StoredTranscriptUtterancesTableFilterComposer(
                $db: $db,
                $table: $db.storedTranscriptUtterances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$StoredUtteranceTranslationsTableOrderingComposer
    extends Composer<_$AppDatabase, $StoredUtteranceTranslationsTable> {
  $$StoredUtteranceTranslationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetLanguage => $composableBuilder(
    column: $table.targetLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translatedText => $composableBuilder(
    column: $table.translatedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get qualityScore => $composableBuilder(
    column: $table.qualityScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StoredTranscriptTranslationRunsTableOrderingComposer get translationRunId {
    final $$StoredTranscriptTranslationRunsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.translationRunId,
          referencedTable: $db.storedTranscriptTranslationRuns,
          getReferencedColumn: (t) => t.translationRunId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StoredTranscriptTranslationRunsTableOrderingComposer(
                $db: $db,
                $table: $db.storedTranscriptTranslationRuns,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$StoredTranscriptUtterancesTableOrderingComposer get utteranceId {
    final $$StoredTranscriptUtterancesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.utteranceId,
          referencedTable: $db.storedTranscriptUtterances,
          getReferencedColumn: (t) => t.utteranceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StoredTranscriptUtterancesTableOrderingComposer(
                $db: $db,
                $table: $db.storedTranscriptUtterances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$StoredUtteranceTranslationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoredUtteranceTranslationsTable> {
  $$StoredUtteranceTranslationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get translationId => $composableBuilder(
    column: $table.translationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetLanguage => $composableBuilder(
    column: $table.targetLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translatedText => $composableBuilder(
    column: $table.translatedText,
    builder: (column) => column,
  );

  GeneratedColumn<double> get qualityScore => $composableBuilder(
    column: $table.qualityScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$StoredTranscriptTranslationRunsTableAnnotationComposer
  get translationRunId {
    final $$StoredTranscriptTranslationRunsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.translationRunId,
          referencedTable: $db.storedTranscriptTranslationRuns,
          getReferencedColumn: (t) => t.translationRunId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StoredTranscriptTranslationRunsTableAnnotationComposer(
                $db: $db,
                $table: $db.storedTranscriptTranslationRuns,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$StoredTranscriptUtterancesTableAnnotationComposer get utteranceId {
    final $$StoredTranscriptUtterancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.utteranceId,
          referencedTable: $db.storedTranscriptUtterances,
          getReferencedColumn: (t) => t.utteranceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StoredTranscriptUtterancesTableAnnotationComposer(
                $db: $db,
                $table: $db.storedTranscriptUtterances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$StoredUtteranceTranslationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoredUtteranceTranslationsTable,
          StoredUtteranceTranslation,
          $$StoredUtteranceTranslationsTableFilterComposer,
          $$StoredUtteranceTranslationsTableOrderingComposer,
          $$StoredUtteranceTranslationsTableAnnotationComposer,
          $$StoredUtteranceTranslationsTableCreateCompanionBuilder,
          $$StoredUtteranceTranslationsTableUpdateCompanionBuilder,
          (
            StoredUtteranceTranslation,
            $$StoredUtteranceTranslationsTableReferences,
          ),
          StoredUtteranceTranslation,
          PrefetchHooks Function({bool translationRunId, bool utteranceId})
        > {
  $$StoredUtteranceTranslationsTableTableManager(
    _$AppDatabase db,
    $StoredUtteranceTranslationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoredUtteranceTranslationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$StoredUtteranceTranslationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$StoredUtteranceTranslationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> translationId = const Value.absent(),
                Value<String> translationRunId = const Value.absent(),
                Value<String> utteranceId = const Value.absent(),
                Value<String> targetLanguage = const Value.absent(),
                Value<String> translatedText = const Value.absent(),
                Value<double?> qualityScore = const Value.absent(),
                Value<String?> reviewStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredUtteranceTranslationsCompanion(
                translationId: translationId,
                translationRunId: translationRunId,
                utteranceId: utteranceId,
                targetLanguage: targetLanguage,
                translatedText: translatedText,
                qualityScore: qualityScore,
                reviewStatus: reviewStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String translationId,
                required String translationRunId,
                required String utteranceId,
                required String targetLanguage,
                required String translatedText,
                Value<double?> qualityScore = const Value.absent(),
                Value<String?> reviewStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredUtteranceTranslationsCompanion.insert(
                translationId: translationId,
                translationRunId: translationRunId,
                utteranceId: utteranceId,
                targetLanguage: targetLanguage,
                translatedText: translatedText,
                qualityScore: qualityScore,
                reviewStatus: reviewStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StoredUtteranceTranslationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({translationRunId = false, utteranceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (translationRunId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.translationRunId,
                                referencedTable:
                                    $$StoredUtteranceTranslationsTableReferences
                                        ._translationRunIdTable(db),
                                referencedColumn:
                                    $$StoredUtteranceTranslationsTableReferences
                                        ._translationRunIdTable(db)
                                        .translationRunId,
                              )
                              as T;
                    }
                    if (utteranceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.utteranceId,
                                referencedTable:
                                    $$StoredUtteranceTranslationsTableReferences
                                        ._utteranceIdTable(db),
                                referencedColumn:
                                    $$StoredUtteranceTranslationsTableReferences
                                        ._utteranceIdTable(db)
                                        .utteranceId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StoredUtteranceTranslationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoredUtteranceTranslationsTable,
      StoredUtteranceTranslation,
      $$StoredUtteranceTranslationsTableFilterComposer,
      $$StoredUtteranceTranslationsTableOrderingComposer,
      $$StoredUtteranceTranslationsTableAnnotationComposer,
      $$StoredUtteranceTranslationsTableCreateCompanionBuilder,
      $$StoredUtteranceTranslationsTableUpdateCompanionBuilder,
      (
        StoredUtteranceTranslation,
        $$StoredUtteranceTranslationsTableReferences,
      ),
      StoredUtteranceTranslation,
      PrefetchHooks Function({bool translationRunId, bool utteranceId})
    >;
typedef $$StoredAuthSessionsTableCreateCompanionBuilder =
    StoredAuthSessionsCompanion Function({
      required String sessionSlot,
      required String userId,
      required String displayName,
      required String role,
      required String eventId,
      required DateTime loggedInAt,
      Value<String?> preferredTranscriptLanguage,
      Value<int> rowid,
    });
typedef $$StoredAuthSessionsTableUpdateCompanionBuilder =
    StoredAuthSessionsCompanion Function({
      Value<String> sessionSlot,
      Value<String> userId,
      Value<String> displayName,
      Value<String> role,
      Value<String> eventId,
      Value<DateTime> loggedInAt,
      Value<String?> preferredTranscriptLanguage,
      Value<int> rowid,
    });

class $$StoredAuthSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $StoredAuthSessionsTable> {
  $$StoredAuthSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sessionSlot => $composableBuilder(
    column: $table.sessionSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedInAt => $composableBuilder(
    column: $table.loggedInAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredTranscriptLanguage => $composableBuilder(
    column: $table.preferredTranscriptLanguage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StoredAuthSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StoredAuthSessionsTable> {
  $$StoredAuthSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sessionSlot => $composableBuilder(
    column: $table.sessionSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedInAt => $composableBuilder(
    column: $table.loggedInAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredTranscriptLanguage => $composableBuilder(
    column: $table.preferredTranscriptLanguage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoredAuthSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoredAuthSessionsTable> {
  $$StoredAuthSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sessionSlot => $composableBuilder(
    column: $table.sessionSlot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedInAt => $composableBuilder(
    column: $table.loggedInAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredTranscriptLanguage => $composableBuilder(
    column: $table.preferredTranscriptLanguage,
    builder: (column) => column,
  );
}

class $$StoredAuthSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoredAuthSessionsTable,
          StoredAuthSession,
          $$StoredAuthSessionsTableFilterComposer,
          $$StoredAuthSessionsTableOrderingComposer,
          $$StoredAuthSessionsTableAnnotationComposer,
          $$StoredAuthSessionsTableCreateCompanionBuilder,
          $$StoredAuthSessionsTableUpdateCompanionBuilder,
          (
            StoredAuthSession,
            BaseReferences<
              _$AppDatabase,
              $StoredAuthSessionsTable,
              StoredAuthSession
            >,
          ),
          StoredAuthSession,
          PrefetchHooks Function()
        > {
  $$StoredAuthSessionsTableTableManager(
    _$AppDatabase db,
    $StoredAuthSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoredAuthSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoredAuthSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoredAuthSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionSlot = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<DateTime> loggedInAt = const Value.absent(),
                Value<String?> preferredTranscriptLanguage =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredAuthSessionsCompanion(
                sessionSlot: sessionSlot,
                userId: userId,
                displayName: displayName,
                role: role,
                eventId: eventId,
                loggedInAt: loggedInAt,
                preferredTranscriptLanguage: preferredTranscriptLanguage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionSlot,
                required String userId,
                required String displayName,
                required String role,
                required String eventId,
                required DateTime loggedInAt,
                Value<String?> preferredTranscriptLanguage =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredAuthSessionsCompanion.insert(
                sessionSlot: sessionSlot,
                userId: userId,
                displayName: displayName,
                role: role,
                eventId: eventId,
                loggedInAt: loggedInAt,
                preferredTranscriptLanguage: preferredTranscriptLanguage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StoredAuthSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoredAuthSessionsTable,
      StoredAuthSession,
      $$StoredAuthSessionsTableFilterComposer,
      $$StoredAuthSessionsTableOrderingComposer,
      $$StoredAuthSessionsTableAnnotationComposer,
      $$StoredAuthSessionsTableCreateCompanionBuilder,
      $$StoredAuthSessionsTableUpdateCompanionBuilder,
      (
        StoredAuthSession,
        BaseReferences<
          _$AppDatabase,
          $StoredAuthSessionsTable,
          StoredAuthSession
        >,
      ),
      StoredAuthSession,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StoredEventSessionsTableTableManager get storedEventSessions =>
      $$StoredEventSessionsTableTableManager(_db, _db.storedEventSessions);
  $$StoredTranscriptUtterancesTableTableManager
  get storedTranscriptUtterances =>
      $$StoredTranscriptUtterancesTableTableManager(
        _db,
        _db.storedTranscriptUtterances,
      );
  $$StoredTranscriptTranslationRunsTableTableManager
  get storedTranscriptTranslationRuns =>
      $$StoredTranscriptTranslationRunsTableTableManager(
        _db,
        _db.storedTranscriptTranslationRuns,
      );
  $$StoredUtteranceTranslationsTableTableManager
  get storedUtteranceTranslations =>
      $$StoredUtteranceTranslationsTableTableManager(
        _db,
        _db.storedUtteranceTranslations,
      );
  $$StoredAuthSessionsTableTableManager get storedAuthSessions =>
      $$StoredAuthSessionsTableTableManager(_db, _db.storedAuthSessions);
}
