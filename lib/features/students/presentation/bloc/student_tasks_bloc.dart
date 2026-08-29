import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaza_build/features/students/data/student_tasks_repository.dart';
import 'package:gaza_build/features/students/presentation/bloc/student_tasks_event.dart';
import 'package:gaza_build/features/students/presentation/bloc/student_tasks_state.dart';

class StudentTasksBloc extends Bloc<StudentTasksEvent, StudentTasksState> {
  final StudentTasksRepository _tasksRepository;

  StudentTasksBloc({required StudentTasksRepository tasksRepository})
      : _tasksRepository = tasksRepository,
        super(const StudentTasksState()) {
    on<LoadStudentTasksRequested>(_onLoadTasksRequested);
    on<CreateMicroTaskRequested>(_onCreateMicroTaskRequested);
    on<ApplyForTaskRequested>(_onApplyForTaskRequested);
    on<SubmitTaskDeliverableRequested>(_onSubmitTaskDeliverableRequested);
    on<ReviewTaskRequested>(_onReviewTaskRequested);
  }

  Future<void> _onLoadTasksRequested(
    LoadStudentTasksRequested event,
    Emitter<StudentTasksState> emit,
  ) async {
    emit(state.copyWith(status: StudentTasksStatus.loading));
    try {
      final tasks = await _tasksRepository.getTasks(
        studentId: event.studentId,
        engineerId: event.engineerId,
        status: event.status,
      );
      emit(state.copyWith(
        status: StudentTasksStatus.loaded,
        tasks: tasks,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudentTasksStatus.error,
        errorMessage: 'تعذر تحميل المهام: $e',
      ));
    }
  }

  Future<void> _onCreateMicroTaskRequested(
    CreateMicroTaskRequested event,
    Emitter<StudentTasksState> emit,
  ) async {
    try {
      final created = await _tasksRepository.createTask(event.task);
      final current = List.of(state.tasks)..insert(0, created);
      emit(state.copyWith(
        status: StudentTasksStatus.actionSuccess,
        tasks: current,
        successMessage: 'تم نشر المهمة لطلاب الهندسة بنجاح.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudentTasksStatus.error,
        errorMessage: 'تعذر إنشاء المهمة: $e',
      ));
    }
  }

  Future<void> _onApplyForTaskRequested(
    ApplyForTaskRequested event,
    Emitter<StudentTasksState> emit,
  ) async {
    try {
      final updated = await _tasksRepository.applyForTask(
        taskId: event.taskId,
        studentId: event.studentId,
        studentName: event.studentName,
      );
      final current = state.tasks.map((t) => t.id == updated.id ? updated : t).toList();
      emit(state.copyWith(
        status: StudentTasksStatus.actionSuccess,
        tasks: current,
        successMessage: 'تم استلام المهمة بنجاح! يمكنك الآن البدء بالتنفيذ وتسليم المخرجات.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudentTasksStatus.error,
        errorMessage: 'تعذر استلام المهمة: $e',
      ));
    }
  }

  Future<void> _onSubmitTaskDeliverableRequested(
    SubmitTaskDeliverableRequested event,
    Emitter<StudentTasksState> emit,
  ) async {
    try {
      final updated = await _tasksRepository.submitDeliverable(
        taskId: event.taskId,
        deliverableNote: event.deliverableNote,
        fileUrl: event.fileUrl,
      );
      final current = state.tasks.map((t) => t.id == updated.id ? updated : t).toList();
      emit(state.copyWith(
        status: StudentTasksStatus.actionSuccess,
        tasks: current,
        successMessage: 'تم تسليم المخرجات بنجاح وفي انتظار مراجعة واعتماد المهندس المشرف.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudentTasksStatus.error,
        errorMessage: 'تعذر تسليم المخرجات: $e',
      ));
    }
  }

  Future<void> _onReviewTaskRequested(
    ReviewTaskRequested event,
    Emitter<StudentTasksState> emit,
  ) async {
    try {
      final updated = await _tasksRepository.reviewDeliverable(
        taskId: event.taskId,
        mentorFeedback: event.mentorFeedback,
        rating: event.rating,
      );
      final current = state.tasks.map((t) => t.id == updated.id ? updated : t).toList();
      emit(state.copyWith(
        status: StudentTasksStatus.actionSuccess,
        tasks: current,
        successMessage: 'تم اعتماد عمل الطالب وإرسال التقييم والملاحظات الإرشادية.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StudentTasksStatus.error,
        errorMessage: 'تعذر اعتماد المهمة: $e',
      ));
    }
  }
}
