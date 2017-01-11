angular.module('doubtfire.units.states.tasks', [
  'doubtfire.units.states.tasks.inbox'
  'doubtfire.units.states.tasks.feedback'
  'doubtfire.units.states.tasks.definition'
])

#
# Teacher child state for units for task-related activites
#
.config(($stateProvider) ->
  $stateProvider.state 'units/tasks', {
    abstract: true
    parent: 'units/index'
    url: '/tasks'
    controller: 'UnitsTasksStateCtrl'
    template: '<ui-view/>'
    data:
      pageTitle: "_Home_"
      roleWhitelist: ['Tutor', 'Convenor', 'Admin']
   }
)

.controller('UnitsTasksStateCtrl', ($scope, $state, taskService) ->
  # Cleanup
  listeners = []
  $scope.$on '$destroy', -> _.each(listeners, (l) -> l())

  # Task data wraps:
  #  * the URL task composite key (project username + task def abbreviation) sourced from the URL,
  #  * the task source used for the task inbox list,
  #  * the actual selectedTask reference
  #  * the callback for when a task is updated (accepts the new task)
  $scope.taskData = {
    taskKey: null
    source: null
    selectedTask: null
    onSelectedTaskChange: (task) ->
      taskKey = task?.taskKey()
      $scope.taskData.taskKey = taskKey
      setTaskKeyAsUrlParams(task)
  }

  # Sets URL parameters for the task key
  setTaskKeyAsUrlParams = (task) ->
    # Change URL of new task without notify
    $state.go($state.$current, {taskKey: task?.taskKeyToUrlString()}, {notify: false})

  # Sets task key from URL parameters
  setTaskKeyFromUrlParams = (taskKeyString) ->
    # Propagate selected task change downward to search for actual task
    # inside the task inbox list
    $scope.taskData.taskKey = taskService.taskKeyFromString(taskKeyString)

  # Child states will use taskKey to notify what task has been
  # selected by the child on first load.
  taskKey = $state.$current.locals.globals.$stateParams.taskKey
  setTaskKeyFromUrlParams(taskKey)

  # Whenever the state is changed, we look at the taskKey in the URL params
  # see if we can set it as an actual taskKey object
  listeners.push $scope.$on '$stateChangeStart', ($event, toState, toParams, fromState, fromParams) ->
    setTaskKeyFromUrlParams(toParams.taskKey)
    # Use preventDefault to prevent destroying the child state's
    # scope if they are the same states. Otherwise, if they are
    # the same, we destroy the state's scope and recreate it again
    # unnecessarily; doing so will cause a re-request in the task
    # list which is not required.
    $event.preventDefault() if fromState == toState
)
