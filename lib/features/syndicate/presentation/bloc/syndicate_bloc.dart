import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaza_build/features/syndicate/data/syndicate_repository.dart';
import 'package:gaza_build/features/syndicate/presentation/bloc/syndicate_event.dart';
import 'package:gaza_build/features/syndicate/presentation/bloc/syndicate_state.dart';

class SyndicateBloc extends Bloc<SyndicateEvent, SyndicateState> {
  final SyndicateRepository _syndicateRepository;

  SyndicateBloc({required SyndicateRepository syndicateRepository})
      : _syndicateRepository = syndicateRepository,
        super(const SyndicateState()) {
    on<LoadSyndicateDashboardRequested>(_onLoadDashboardRequested);
    on<UpdateVerificationRequested>(_onUpdateVerificationRequested);
    on<AddGuideRequested>(_onAddGuideRequested);
    on<IssueRulingRequested>(_onIssueRulingRequested);
  }

  Future<void> _onLoadDashboardRequested(
    LoadSyndicateDashboardRequested event,
    Emitter<SyndicateState> emit,
  ) async {
    emit(state.copyWith(status: SyndicateStatus.loading));
    try {
      final pending = await _syndicateRepository.getPendingVerifications();
      final guides = await _syndicateRepository.getGuides();
      final arbitrations = await _syndicateRepository.getArbitrationCases();
      final stats = await _syndicateRepository.getStatistics();

      emit(state.copyWith(
        status: SyndicateStatus.loaded,
        pendingVerifications: pending,
        guides: guides,
        arbitrationCases: arbitrations,
        statistics: stats,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SyndicateStatus.error,
        errorMessage: 'تعذر تحميل بيانات النقابة: $e',
      ));
    }
  }

  Future<void> _onUpdateVerificationRequested(
    UpdateVerificationRequested event,
    Emitter<SyndicateState> emit,
  ) async {
    try {
      await _syndicateRepository.updateVerificationStatus(
        userId: event.userId,
        status: event.status,
        rejectionReason: event.rejectionReason,
      );

      final updatedPending = state.pendingVerifications
          .where((p) => p.id != event.userId)
          .toList();

      final message = event.status.name == 'approved'
          ? 'تم اعتماد وتوثيق العضوية بنجاح.'
          : 'تم إرجاع الطلب للتعديل.';

      emit(state.copyWith(
        status: SyndicateStatus.actionSuccess,
        pendingVerifications: updatedPending,
        successMessage: message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SyndicateStatus.error,
        errorMessage: 'تعذر تحديث حالة العضو: $e',
      ));
    }
  }

  Future<void> _onAddGuideRequested(
    AddGuideRequested event,
    Emitter<SyndicateState> emit,
  ) async {
    try {
      final created = await _syndicateRepository.addGuide(event.guide);
      final currentGuides = List.of(state.guides)..insert(0, created);

      emit(state.copyWith(
        status: SyndicateStatus.actionSuccess,
        guides: currentGuides,
        successMessage: 'تم نشر الدليل الهندسي للمجتمع بنجاح.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SyndicateStatus.error,
        errorMessage: 'تعذر نشر الدليل: $e',
      ));
    }
  }

  Future<void> _onIssueRulingRequested(
    IssueRulingRequested event,
    Emitter<SyndicateState> emit,
  ) async {
    try {
      final updated = await _syndicateRepository.issueArbitrationRuling(
        caseId: event.caseId,
        ruling: event.ruling,
      );

      final current = state.arbitrationCases
          .map((c) => c.id == updated.id ? updated : c)
          .toList();

      emit(state.copyWith(
        status: SyndicateStatus.actionSuccess,
        arbitrationCases: current,
        successMessage: 'تم إصدار ونشر قرار التحكيم الهندسي المعتمد.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SyndicateStatus.error,
        errorMessage: 'تعذر تسجيل قرار التحكيم: $e',
      ));
    }
  }
}
