# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MsnrApi.Repo.insert!(%MsnrApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias MsnrApi.Accounts.User
alias MsnrApi.Accounts.Role
alias MsnrApi.Semesters.Semester
alias MsnrApi.Tasks
alias MsnrApi.Tasks.Task
alias MsnrApi.Tasks.TaskType
alias MsnrApi.Activities.Activity

student = %Role{} |> Role.changeset(%{name: Role.student, description: "Student"}) |> MsnrApi.Repo.insert!
professor = %Role{} |> Role.changeset(%{name: Role.professor, description: "Profesor"}) |> MsnrApi.Repo.insert!
admin = %Role{} |> Role.changeset(%{name: Role.admin, description: "Administrator"}) |> MsnrApi.Repo.insert!

%User{} |> User.changeset_password(%{ email: "test@student", password: "test", first_name: "Test", last_name: "Student"}) |> User.changeset_role(student) |> MsnrApi.Repo.insert!
%User{} |> User.changeset_password(%{ email: "test@professor", password: "test", first_name: "Test", last_name: "Profesor"}) |> User.changeset_role(professor) |> MsnrApi.Repo.insert!
%User{} |> User.changeset_password(%{ email: "test@admin", password: "test", first_name: "Test", last_name: "Admin"}) |> User.changeset_role(admin) |> MsnrApi.Repo.insert!

#semester
semester =  %Semester{} |> Semester.changeset(%{year: 2021 , ordinal_number: 2 , module: "I" , is_active: true}) |> MsnrApi.Repo.insert!

#task types
group_type = %TaskType{} |> TaskType.changeset(%{type: "group"}) |> MsnrApi.Repo.insert!
topic_type = %TaskType{} |> TaskType.changeset(%{type: "topic"}) |> MsnrApi.Repo.insert!
cv_type = %TaskType{} |> TaskType.changeset(%{type: "cv"}) |> MsnrApi.Repo.insert!

#task
group_task = %Task{} |> Task.changeset(%{name: "Prijavljivanje grupe", description: "Prijavite grupu", points: 0, is_group: true, type: group_type.type}) |> MsnrApi.Repo.insert!
topic_task = %Task{} |> Task.changeset(%{name: "Odabir teme", description: "Odaberite temu", points: 0, is_group: true, type: topic_type.type}) |> MsnrApi.Repo.insert!
cv_task = %Task{} |> Task.changeset(%{name: "Predaja CV-a", description: "Predaja CV", points: 10, is_group: false, type: cv_type.type}) |> MsnrApi.Repo.insert!


group_activity = %Activity{} |> Activity.changeset(%{starts_sec: 1617241701, ends_sec: 1617591701, task_id: group_task.id, semester_id: semester.id}) |> MsnrApi.Repo.insert!
topic_activity = %Activity{} |> Activity.changeset(%{starts_sec: 1617641701, ends_sec: 1617991701, task_id: topic_task.id, semester_id: semester.id}) |> MsnrApi.Repo.insert!
cv_activity = %Activity{} |> Activity.changeset(%{starts_sec: 1617641701, ends_sec: 1617991701, task_id: cv_task.id, semester_id: semester.id}) |> MsnrApi.Repo.insert!
