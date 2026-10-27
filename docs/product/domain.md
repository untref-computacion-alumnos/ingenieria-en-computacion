# Domain

## Glossary (Spanish → English)

Code uses the English term; the UI shows the Spanish one through I18n (es-AR).

| Spanish | English (code) | Meaning |
| --- | --- | --- |
| Carrera | `Career` | The degree (only one for now) |
| Plan de estudios | `StudyPlan` | A versioned curriculum of the career (e.g. 2011, 2018) |
| Materia / asignatura | `Subject` | A course in a plan |
| Año / cuatrimestre | `year` / `term` | Position of a subject in the plan |
| Correlativa | `Prerequisite` | Requirement to take a course or sit its final |
| Cursar / cursada | coursing | Taking the course during a term |
| Final | `final` | Final exam |
| Equivalencia | `Equivalence` | Mapping of a subject in one plan to another plan |
| Optativa / electiva | `elective` | Subject chosen from a pool |
| Título intermedio | `IntermediateDegree` | Earlier degree inside the career |
| Requisito extra | `ExtraRequirement` | Language, internship, thesis, etc. |
| Docente | `Teacher` | Teaching staff member |
| Alumno | `Student` (role) | A user studying the career |
| Ingresante | applicant | Prospective student |
| Historia académica | academic record | SIU Guaraní transcript |

## Subject status for a student

| Status | Spanish | Notes |
| --- | --- | --- |
| `pending` | Pendiente | Default |
| `in_progress` | Cursando | Currently taking the course |
| `regular` | Regular | Course passed, final pending |
| `approved` | Aprobada | Final passed; has grade and date |
| `promoted` | Promocionada | Passed without a final (grade, date; flag whether a final was sat) |
| `free` | Libre | Lost regularity |
| `retaking` | Recursada | Taking the course again |
| `dropped` | Abandonada | Left the course |

MVP uses: `pending`, `in_progress`, `regular`, `approved`, `promoted`. The rest arrive with their own stories.

## Prerequisite kinds

1. **Course prerequisite**: to take subject B you need subject A `regular` or `approved`.
2. **Final prerequisite**: to sit B's final you need subject A `approved`.
3. **Count/credit prerequisite**: e.g. "N subjects approved" or "first-cycle complete".

All requirements of one kind are AND-ed. OR-alternatives are out of scope for now.

## First draft of the model

```text
Career 1──* StudyPlan 1──* Subject
StudyPlan 1──* ExtraRequirement
Subject *──* Subject            (Prerequisite: subject, required_subject, kind, min_status)
Subject *──* Subject            (Equivalence across plans)
User 1──* SubjectProgress *──1 Subject   (status, grade, approved_on)
User *──1 StudyPlan             (selected plan)
User *──* Role                  (Rolify: student, teacher, moderator, admin)
```

- `Subject` belongs to one `StudyPlan`; a subject that exists in two plans is two rows linked by `Equivalence`.
- `SubjectProgress` is one row per user and subject in the MVP. Attempt history (retaking, dropping)
  can become a separate `Attempt` table later without breaking the MVP.
- Switching a student to another plan uses `Equivalence` to carry progress over.
- Changes to plan data are versioned with PaperTrail once admins/proposals exist.

These are starting points, not final; each user story may refine them.
