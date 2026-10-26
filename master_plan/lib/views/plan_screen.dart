import 'package:flutter/material.dart';
import '../models/data_layer.dart';
import '../provider/plan_provider.dart';

class PlanScreen extends StatefulWidget {
  final Plan plan;
  const PlanScreen({super.key, required this.plan});

  @override
  State createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late ScrollController scrollController;
  Plan get plan => widget.plan;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()
      ..addListener(() {
        FocusScope.of(context).requestFocus(FocusNode());
      });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<List<Plan>> plansNotifier = PlanProvider.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(plan.name)),
      body: ValueListenableBuilder<List<Plan>>(
        valueListenable: plansNotifier,
        builder: (context, plans, child) {
          final Plan currentPlan = plans.firstWhere((p) => p.name == plan.name);
          return Column(
            children: [
              Expanded(child: _buildList(currentPlan)),
              SafeArea(child: Text(currentPlan.completenessMessage)),
            ],
          );
        },
      ),
      floatingActionButton: _buildAddTaskButton(context),
    );
  }

  Widget _buildAddTaskButton(BuildContext context) {
    final ValueNotifier<List<Plan>> plansNotifier = PlanProvider.of(context);
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        final plans = plansNotifier.value;
        final int planIndex = plans.indexWhere((p) => p.name == plan.name);
        final Plan currentPlan = plans[planIndex];

        plansNotifier.value = List<Plan>.from(plans)
          ..[planIndex] = Plan(
            name: currentPlan.name,
            tasks: List<Task>.from(currentPlan.tasks)..add(const Task()),
          );
      },
    );
  }

  Widget _buildList(Plan currentPlan) {
    return ListView.builder(
      controller: scrollController,
      keyboardDismissBehavior: Theme.of(context).platform == TargetPlatform.iOS
          ? ScrollViewKeyboardDismissBehavior.onDrag
          : ScrollViewKeyboardDismissBehavior.manual,
      itemCount: currentPlan.tasks.length,
      itemBuilder: (context, index) =>
          _buildTaskTile(currentPlan, currentPlan.tasks[index], index, context),
    );
  }

  Widget _buildTaskTile(
      Plan currentPlan, Task task, int index, BuildContext context) {
    final ValueNotifier<List<Plan>> plansNotifier = PlanProvider.of(context);

    void updateTask(Task newTask) {
      final plans = plansNotifier.value;
      final int planIndex = plans.indexWhere((p) => p.name == currentPlan.name);
      final Plan latest = plans[planIndex];
      plansNotifier.value = List<Plan>.from(plans)
        ..[planIndex] = Plan(
          name: latest.name,
          tasks: List<Task>.from(latest.tasks)..[index] = newTask,
        );
    }

    return ListTile(
      leading: Checkbox(
        value: task.complete,
        onChanged: (selected) {
          updateTask(Task(
            description: task.description,
            complete: selected ?? false,
          ));
        },
      ),
      title: TextFormField(
        initialValue: task.description,
        onChanged: (text) {
          updateTask(Task(
            description: text,
            complete: task.complete,
          ));
        },
      ),
    );
  }
}
