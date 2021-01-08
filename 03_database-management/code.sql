create domain Rating smallint check (VALUE > 0 and VALUE < 10)

create TYPE Feedback as (
    student_id uuid,
    rating Rating,
    feedback text
)


create table student (
    id uuid primary key default uuid_generate_v4(),
    first_name varchar(255),
    last_name varchar(255),
    date_of_birth date
)

alter table student
add column email text


create table subject (
    id uuid primary key default uuid_generate_v4(),
    subject text not NULL,
    description text 
)


create table teacher (
    id uuid primary key default uuid_generate_v4(),
    first_name varchar(255) not NULL,
    last_name varchar(255) not null,
    date_of_birth date not NULL,
    email text
)


create table course (
    id uuid primary key DEFAULT uuid_generate_v4(),
    "name" text not NULL,
    description text,
    subject_id uuid REFERENCES subject (id),
    teacher_id uuid REFERENCES teacher (id),
    feedback feedback[]
)


create table enrollment (
    course_id uuid REFERENCES course(id) not null,
    student_id uuid REFERENCES student(id) not null,
    enrollment_date date not NULL,
    CONSTRAINT id primary key (course_id, student_id)
)

-----
insert into student(
    first_name,
    last_name,
    email,
    date_of_birth
) values(
    'Tajib',
    'Smajlović',
    'test@mail.com',
    '2020-12-12'::DATE
)


insert into teacher(
    first_name,
    last_name,
    email,
    date_of_birth
) values(
    'Tajib',
    'Smajlović',
    'test@mail.com',
    '2020-12-12'::DATE
)


delete from subject where subject = 'test_coourse'

insert into subject(
    subject,
    description
) values(
    'React',
    'nekiiiii deskrips'
)

alter table course alter column subject_id set not null
alter table course alter column teacher_id set not null

update table course 
set subject_id = '6e0ae609-f954-4037-826b-7c500b56da34'
where subject_id is null

insert into course(
    "name",
    description,
    teacher_id,
    subject_id
) values(
    'React',
    'nekiiiii deskrips',
    '0e0418ff-5c08-4172-843e-02cd8532725c',
    '6e0ae609-f954-4037-826b-7c500b56da34'
)

insert into enrollment(
    course_id,
    student_id,
    enrollment_date
) values (
    '45bc35ed-f918-43c7-8911-632272bf9ef1',
    'cf150810-c115-46da-99a9-972fd1c686b3',
    now()::DATE
)


update course
set feedback = array_append(
    feedback,
    ROW(
        'cf150810-c115-46da-99a9-972fd1c686b3',
        7,
        'Dobarrr'
    )::feedback
)
where course_id = '45bc35ed-f918-43c7-8911-632272bf9ef1'


----
BEGIN;
  delete from employees where emp_no between 10000 and 10005;
COMMIT;