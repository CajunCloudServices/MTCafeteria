CREATE TABLE IF NOT EXISTS roles (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role_id INT NOT NULL REFERENCES roles(id)
);

CREATE TABLE IF NOT EXISTS points (
  user_id INT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  points INT NOT NULL DEFAULT 0
);


CREATE TABLE IF NOT EXISTS point_assignments (
  id SERIAL PRIMARY KEY,
  assigned_to_user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  assigned_by_user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  points_delta INT NOT NULL CHECK (points_delta > 0),
  assignment_date DATE NOT NULL,
  reason TEXT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Accepted')),
  employee_initials VARCHAR(10),
  employee_confirmed_at TIMESTAMP,
  manager_notified_at TIMESTAMP,
  requires_manager_approval BOOLEAN NOT NULL DEFAULT false,
  manager_approved_by_user_id INT REFERENCES users(id),
  manager_approved_at TIMESTAMP,
  assignment_description TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS announcements (
  id SERIAL PRIMARY KEY,
  type VARCHAR(40) NOT NULL,
  title VARCHAR(200) NOT NULL,
  content TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  created_by INT REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS trainings (
  id SERIAL PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  content TEXT NOT NULL,
  assigned_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS shifts (
  id SERIAL PRIMARY KEY,
  shift_type VARCHAR(80) NOT NULL,
  meal_type VARCHAR(40),
  name VARCHAR(200) NOT NULL
);

CREATE TABLE IF NOT EXISTS jobs (
  id SERIAL PRIMARY KEY,
  shift_id INT NOT NULL REFERENCES shifts(id) ON DELETE CASCADE,
  name VARCHAR(200) NOT NULL
);

CREATE TABLE IF NOT EXISTS tasks (
  id SERIAL PRIMARY KEY,
  job_id INT NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  phase VARCHAR(40) NOT NULL CHECK (phase IN ('Setup', 'During Shift', 'Cleanup')),
  description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS task_progress (
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  task_id INT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  completed BOOLEAN NOT NULL DEFAULT false,
  supervisor_checked BOOLEAN NOT NULL DEFAULT false,
  PRIMARY KEY (user_id, task_id)
);

CREATE TABLE IF NOT EXISTS supervisor_job_checks (
  meal_type VARCHAR(40) NOT NULL CHECK (meal_type IN ('Breakfast', 'Lunch', 'Dinner')),
  job_id INT NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  checked BOOLEAN NOT NULL DEFAULT false,
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY (meal_type, job_id)
);

CREATE TABLE IF NOT EXISTS trainer_assignments (
  trainer_user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  trainee_user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  job_id INT NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  PRIMARY KEY (trainer_user_id, trainee_user_id, job_id)
);

CREATE TABLE IF NOT EXISTS supervisor_task_checks (
  meal_type VARCHAR(40) NOT NULL CHECK (meal_type IN ('Breakfast', 'Lunch', 'Dinner')),
  job_id INT NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  task_id INT NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  checked BOOLEAN NOT NULL DEFAULT false,
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY (meal_type, job_id, task_id)
);

CREATE TABLE IF NOT EXISTS daily_shift_reports (
  id SERIAL PRIMARY KEY,
  report_date DATE NOT NULL,
  meal_type VARCHAR(40) NOT NULL CHECK (meal_type IN ('Breakfast', 'Lunch', 'Dinner')),
  track VARCHAR(40) NOT NULL DEFAULT 'Line',
  status VARCHAR(20) NOT NULL DEFAULT 'Draft' CHECK (status IN ('Draft', 'Submitted')),
  submitted_by_user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  submitted_at TIMESTAMP,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  UNIQUE (report_date, meal_type, track, submitted_by_user_id)
);
