const Roles = {
  EMPLOYEE: 'Employee',
  LEAD_TRAINER: 'Lead Trainer',
  SUPERVISOR: 'Supervisor',
  STUDENT_MANAGER: 'Student Manager',
  DISHROOM_LEAD_TRAINER: 'Dishroom Lead Trainer',
};

const AdminLandingRoles = [Roles.STUDENT_MANAGER];
const TrainingRoles = [Roles.LEAD_TRAINER, Roles.SUPERVISOR, Roles.STUDENT_MANAGER];
const SupervisorBoardRoles = [Roles.SUPERVISOR, Roles.STUDENT_MANAGER];

module.exports = {
  Roles,
  AdminLandingRoles,
  TrainingRoles,
  SupervisorBoardRoles,
};
