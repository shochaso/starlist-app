import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/content_model.dart';
import '../repositories/content_repository.dart';

// イベント
abstract class ContentEvent extends Equatable {
  const ContentEvent();

  @override
  List<Object?> get props => [];
}

class FetchContentsEvent extends ContentEvent {
  final String? authorId;
  final ContentTypeModel? type;
  final int limit;
  final int offset;

  const FetchContentsEvent({
    this.authorId,
    this.type,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [authorId, type, limit, offset];
}

class FetchContentDetailEvent extends ContentEvent {
  final String contentId;

  const FetchContentDetailEvent(this.contentId);

  @override
  List<Object?> get props => [contentId];
}

class CreateContentEvent extends ContentEvent {
  final ContentModel content;

  const CreateContentEvent(this.content);

  @override
  List<Object?> get props => [content];
}

class UpdateContentEvent extends ContentEvent {
  final ContentModel content;

  const UpdateContentEvent(this.content);

  @override
  List<Object?> get props => [content];
}

class DeleteContentEvent extends ContentEvent {
  final String contentId;

  const DeleteContentEvent(this.contentId);

  @override
  List<Object?> get props => [contentId];
}

// 状態
abstract class ContentState extends Equatable {
  const ContentState();

  @override
  List<Object?> get props => [];
}

class ContentInitial extends ContentState {}

class ContentLoading extends ContentState {}

class ContentError extends ContentState {
  final String message;

  const ContentError(this.message);

  @override
  List<Object?> get props => [message];
}

class ContentsLoaded extends ContentState {
  final List<ContentModel> contents;
  final bool hasMore;

  const ContentsLoaded({
    required this.contents,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [contents, hasMore];
}

class ContentDetailLoaded extends ContentState {
  final ContentModel content;

  const ContentDetailLoaded(this.content);

  @override
  List<Object?> get props => [content];
}

class ContentCreated extends ContentState {
  final ContentModel content;

  const ContentCreated(this.content);

  @override
  List<Object?> get props => [content];
}

class ContentUpdated extends ContentState {
  final ContentModel content;

  const ContentUpdated(this.content);

  @override
  List<Object?> get props => [content];
}

class ContentDeleted extends ContentState {
  final String contentId;

  const ContentDeleted(this.contentId);

  @override
  List<Object?> get props => [contentId];
}

// BLoCクラス
class ContentBloc extends Bloc<ContentEvent, ContentState> {
  final ContentRepository contentRepository;

  ContentBloc({required this.contentRepository}) : super(ContentInitial()) {
    on<FetchContentsEvent>(_onFetchContents);
    on<FetchContentDetailEvent>(_onFetchContentDetail);
    on<CreateContentEvent>(_onCreateContent);
    on<UpdateContentEvent>(_onUpdateContent);
    on<DeleteContentEvent>(_onDeleteContent);
  }

  Future<void> _onFetchContents(
    FetchContentsEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentLoading());
    try {
      final contents = await contentRepository.getContents(
        authorId: event.authorId,
        type: event.type,
        limit: event.limit,
        offset: event.offset,
      );
      
      emit(ContentsLoaded(
        contents: contents,
        hasMore: contents.length >= event.limit,
      ));
    } catch (e) {
      emit(ContentError('コンテンツの取得に失敗しました: $e'));
    }
  }

  Future<void> _onFetchContentDetail(
    FetchContentDetailEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentLoading());
    try {
      final content = await contentRepository.getContentById(event.contentId);
      if (content != null) {
        emit(ContentDetailLoaded(content));
      } else {
        emit(const ContentError('コンテンツが見つかりませんでした'));
      }
    } catch (e) {
      emit(ContentError('コンテンツ詳細の取得に失敗しました: $e'));
    }
  }

  Future<void> _onCreateContent(
    CreateContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentLoading());
    try {
      final newContent = await contentRepository.createContent(event.content);
      if (newContent != null) {
        emit(ContentCreated(newContent));
      } else {
        emit(const ContentError('コンテンツの作成に失敗しました'));
      }
    } catch (e) {
      emit(ContentError('コンテンツの作成中にエラーが発生しました: $e'));
    }
  }

  Future<void> _onUpdateContent(
    UpdateContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentLoading());
    try {
      final success = await contentRepository.updateContent(event.content);
      if (success) {
        emit(ContentUpdated(event.content));
      } else {
        emit(const ContentError('コンテンツの更新に失敗しました'));
      }
    } catch (e) {
      emit(ContentError('コンテンツの更新中にエラーが発生しました: $e'));
    }
  }

  Future<void> _onDeleteContent(
    DeleteContentEvent event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentLoading());
    try {
      final success = await contentRepository.deleteContent(event.contentId);
      if (success) {
        emit(ContentDeleted(event.contentId));
      } else {
        emit(const ContentError('コンテンツの削除に失敗しました'));
      }
    } catch (e) {
      emit(ContentError('コンテンツの削除中にエラーが発生しました: $e'));
    }
  }
} 