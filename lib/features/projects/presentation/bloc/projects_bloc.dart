import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/projects_repository.dart';
import 'projects_event.dart';
import 'projects_state.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final ProjectsRepository _projectsRepository;

  ProjectsBloc({required ProjectsRepository projectsRepository})
      : _projectsRepository = projectsRepository,
        super(const ProjectsState()) {
    on<LoadProjectsRequested>(_onLoadProjectsRequested);
    on<CreateProjectRequested>(_onCreateProjectRequested);
    on<SubmitBidRequested>(_onSubmitBidRequested);
    on<AcceptBidRequested>(_onAcceptBidRequested);
    on<UpdateMilestoneRequested>(_onUpdateMilestoneRequested);
  }

  Future<void> _onLoadProjectsRequested(
    LoadProjectsRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(state.copyWith(status: ProjectsStatus.loading));
    try {
      final list = await _projectsRepository.getProjects(
        clientId: event.clientId,
        engineerId: event.engineerId,
        status: event.status,
      );
      emit(state.copyWith(
        status: ProjectsStatus.loaded,
        projects: list,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProjectsStatus.error,
        errorMessage: 'تعذر تحميل المشاريع: $e',
      ));
    }
  }

  Future<void> _onCreateProjectRequested(
    CreateProjectRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(state.copyWith(status: ProjectsStatus.loading));
    try {
      final created = await _projectsRepository.createProject(event.project);
      final currentList = List.of(state.projects)..insert(0, created);
      emit(state.copyWith(
        status: ProjectsStatus.actionSuccess,
        projects: currentList,
        selectedProject: created,
        successMessage: 'تم نشر طلب المشروع بنجاح وسيصل للمهندسين المعتمدين.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProjectsStatus.error,
        errorMessage: 'حدث خطأ أثناء طرح المشروع: $e',
      ));
    }
  }

  Future<void> _onSubmitBidRequested(
    SubmitBidRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(state.copyWith(status: ProjectsStatus.loading));
    try {
      final updatedProject = await _projectsRepository.submitBid(event.bid);
      final currentList = state.projects.map((p) {
        return p.id == updatedProject.id ? updatedProject : p;
      }).toList();

      emit(state.copyWith(
        status: ProjectsStatus.actionSuccess,
        projects: currentList,
        selectedProject: updatedProject,
        successMessage: 'تم إرسال عرضك الفني والمالي بنجاح إلى صاحب المشروع.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProjectsStatus.error,
        errorMessage: 'تعذر تقديم العرض: $e',
      ));
    }
  }

  Future<void> _onAcceptBidRequested(
    AcceptBidRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(state.copyWith(status: ProjectsStatus.loading));
    try {
      final updatedProject = await _projectsRepository.acceptBid(
        projectId: event.projectId,
        bidId: event.bidId,
      );
      final currentList = state.projects.map((p) {
        return p.id == updatedProject.id ? updatedProject : p;
      }).toList();

      emit(state.copyWith(
        status: ProjectsStatus.actionSuccess,
        projects: currentList,
        selectedProject: updatedProject,
        successMessage: 'تم توقيع العقد الرقمي واعتماد المهندس وبدء المشروع!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProjectsStatus.error,
        errorMessage: 'تعذر قبول العرض: $e',
      ));
    }
  }

  Future<void> _onUpdateMilestoneRequested(
    UpdateMilestoneRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    try {
      final updatedProject = await _projectsRepository.updateMilestoneStatus(
        projectId: event.projectId,
        milestoneId: event.milestoneId,
        isCompleted: event.isCompleted,
        proofImageUrl: event.proofImageUrl,
      );
      final currentList = state.projects.map((p) {
        return p.id == updatedProject.id ? updatedProject : p;
      }).toList();

      emit(state.copyWith(
        status: ProjectsStatus.actionSuccess,
        projects: currentList,
        selectedProject: updatedProject,
        successMessage: 'تم تحديث حالة المرحلة الإنجازية بنجاح.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProjectsStatus.error,
        errorMessage: 'تعذر تحديث المرحلة: $e',
      ));
    }
  }
}
