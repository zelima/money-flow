-- Insert main departments (matching the translated names)
INSERT INTO departments (name_english, name_georgian, description) VALUES
('General Public Services', 'საერთო დანიშნულების მომსახურება', 'Administrative and general government services'),
('Economic Affairs', 'ეკონომიკური საქმიანობა', 'Economic development and business support'),
('Social Protection', 'სოციალური დაცვა', 'Social welfare and protection programs'),
('Health', 'ჯანმრთელობის დაცვა', 'Healthcare services and medical programs'),
('Education', 'განათლება', 'Educational institutions and programs'),
('Banking and Agriculture', 'საბინაო-კომუნალური მეურნეობა', 'Banking sector and agricultural development'),
('Culture, Religion, Recreation and Sport', 'დასვენება, კულტურა რელიგია', 'Cultural and recreational activities'),
('Public Order and Safety', 'საზოგადოებრივი წესრიგი და უშიშროება', 'Police, security, and public safety'),
('Environment Protection', 'გარემოს დაცვა', 'Environmental conservation and protection'),
('Defense', 'თავდაცვა', 'National defense and military');

-- Insert sub-departments for General Public Services
INSERT INTO sub_departments (department_id, name_english, name_georgian, allocation_percentage, employee_count, projects_count) VALUES
((SELECT id FROM departments WHERE name_english = 'General Public Services'), 'Central Administration', 'ცენტრალური ადმინისტრაცია', 35.0, 2500, 12),
((SELECT id FROM departments WHERE name_english = 'General Public Services'), 'Parliament Operations', 'პარლამენტის ოპერაციები', 15.0, 800, 5),
((SELECT id FROM departments WHERE name_english = 'General Public Services'), 'Local Government Support', 'ადგილობრივი ხელისუფლების მხარდაჭერა', 25.0, 1200, 8),
((SELECT id FROM departments WHERE name_english = 'General Public Services'), 'Public Service Management', 'საჯარო სერვისების მართვა', 20.0, 900, 6),
((SELECT id FROM departments WHERE name_english = 'General Public Services'), 'Digital Government Initiatives', 'ციფრული ხელისუფლების ინიციატივები', 5.0, 150, 3);

-- Insert sub-departments for Economic Affairs
INSERT INTO sub_departments (department_id, name_english, name_georgian, allocation_percentage, employee_count, projects_count) VALUES
((SELECT id FROM departments WHERE name_english = 'Economic Affairs'), 'Business Development', 'ბიზნეს განვითარება', 30.0, 400, 15),
((SELECT id FROM departments WHERE name_english = 'Economic Affairs'), 'Infrastructure Investment', 'ინფრასტრუქტურული ინვესტიციები', 40.0, 600, 20),
((SELECT id FROM departments WHERE name_english = 'Economic Affairs'), 'Trade Promotion', 'ვაჭრობის ხელშეწყობა', 15.0, 200, 8),
((SELECT id FROM departments WHERE name_english = 'Economic Affairs'), 'Tourism Development', 'ტურიზმის განვითარება', 10.0, 150, 12),
((SELECT id FROM departments WHERE name_english = 'Economic Affairs'), 'Financial Services Regulation', 'ფინანსური სერვისების რეგულირება', 5.0, 80, 4);

-- Insert sub-departments for Social Protection
INSERT INTO sub_departments (department_id, name_english, name_georgian, allocation_percentage, employee_count, projects_count) VALUES
((SELECT id FROM departments WHERE name_english = 'Social Protection'), 'Pension Services', 'საპენსიო სერვისები', 45.0, 1500, 10),
((SELECT id FROM departments WHERE name_english = 'Social Protection'), 'Unemployment Benefits', 'უმუშევრობის შემწეობები', 25.0, 800, 7),
((SELECT id FROM departments WHERE name_english = 'Social Protection'), 'Family Support Programs', 'ოჯახური მხარდაჭერის პროგრამები', 15.0, 600, 12),
((SELECT id FROM departments WHERE name_english = 'Social Protection'), 'Disability Services', 'შეზღუდული შესაძლებლობების სერვისები', 10.0, 400, 8),
((SELECT id FROM departments WHERE name_english = 'Social Protection'), 'Social Housing', 'სოციალური საცხოვრებელი', 5.0, 200, 5);

-- Insert sub-departments for Health
INSERT INTO sub_departments (department_id, name_english, name_georgian, allocation_percentage, employee_count, projects_count) VALUES
((SELECT id FROM departments WHERE name_english = 'Health'), 'Primary Healthcare', 'პირველადი ჯანდაცვა', 35.0, 3000, 25),
((SELECT id FROM departments WHERE name_english = 'Health'), 'Hospital Services', 'საავადმყოფოს სერვისები', 40.0, 4500, 15),
((SELECT id FROM departments WHERE name_english = 'Health'), 'Emergency Medical Services', 'გადაუდებელი სამედიცინო სერვისები', 15.0, 800, 8),
((SELECT id FROM departments WHERE name_english = 'Health'), 'Public Health Programs', 'საზოგადოებრივი ჯანმრთელობის პროგრამები', 7.0, 300, 12),
((SELECT id FROM departments WHERE name_english = 'Health'), 'Medical Research', 'სამედიცინო კვლევა', 3.0, 150, 5);

-- Insert sub-departments for Education
INSERT INTO sub_departments (department_id, name_english, name_georgian, allocation_percentage, employee_count, projects_count) VALUES
((SELECT id FROM departments WHERE name_english = 'Education'), 'Primary Education', 'დაწყებითი განათლება', 40.0, 8000, 30),
((SELECT id FROM departments WHERE name_english = 'Education'), 'Secondary Education', 'საშუალო განათლება', 30.0, 6000, 25),
((SELECT id FROM departments WHERE name_english = 'Education'), 'Higher Education', 'უმაღლესი განათლება', 20.0, 2000, 15),
((SELECT id FROM departments WHERE name_english = 'Education'), 'Vocational Training', 'პროფესიული მომზადება', 7.0, 800, 10),
((SELECT id FROM departments WHERE name_english = 'Education'), 'Educational Infrastructure', 'განათლების ინფრასტრუქტურა', 3.0, 300, 8);

-- Insert sub-departments for Banking and Agriculture
INSERT INTO sub_departments (department_id, name_english, name_georgian, allocation_percentage, employee_count, projects_count) VALUES
((SELECT id FROM departments WHERE name_english = 'Banking and Agriculture'), 'Agricultural Development', 'სოფლის მეურნეობის განვითარება', 50.0, 1200, 20),
((SELECT id FROM departments WHERE name_english = 'Banking and Agriculture'), 'Rural Banking Services', 'სოფლის ბანკინგ სერვისები', 25.0, 400, 8),
((SELECT id FROM departments WHERE name_english = 'Banking and Agriculture'), 'Farmer Support Programs', 'ფერმერთა მხარდაჭერის პროგრამები', 15.0, 300, 12),
((SELECT id FROM departments WHERE name_english = 'Banking and Agriculture'), 'Agricultural Research', 'სოფლის მეურნეობის კვლევა', 6.0, 150, 5),
((SELECT id FROM departments WHERE name_english = 'Banking and Agriculture'), 'Food Safety Inspection', 'სურსათის უსაფრთხოების ინსპექტირება', 4.0, 100, 4);

-- Insert sub-departments for Culture, Religion, Recreation and Sport
INSERT INTO sub_departments (department_id, name_english, name_georgian, allocation_percentage, employee_count, projects_count) VALUES
((SELECT id FROM departments WHERE name_english = 'Culture, Religion, Recreation and Sport'), 'Cultural Heritage', 'კულტურული მემკვიდრეობა', 35.0, 600, 15),
((SELECT id FROM departments WHERE name_english = 'Culture, Religion, Recreation and Sport'), 'Sports Development', 'სპორტის განვითარება', 30.0, 400, 20),
((SELECT id FROM departments WHERE name_english = 'Culture, Religion, Recreation and Sport'), 'Religious Affairs', 'რელიგიური საქმეები', 15.0, 200, 5),
((SELECT id FROM departments WHERE name_english = 'Culture, Religion, Recreation and Sport'), 'Arts and Entertainment', 'ხელოვნება და გართობა', 15.0, 300, 12),
((SELECT id FROM departments WHERE name_english = 'Culture, Religion, Recreation and Sport'), 'Recreation Facilities', 'დასვენების ობიექტები', 5.0, 150, 8);

-- Insert sub-departments for Public Order and Safety
INSERT INTO sub_departments (department_id, name_english, name_georgian, allocation_percentage, employee_count, projects_count) VALUES
((SELECT id FROM departments WHERE name_english = 'Public Order and Safety'), 'Police Services', 'პოლიციის სერვისები', 60.0, 12000, 25),
((SELECT id FROM departments WHERE name_english = 'Public Order and Safety'), 'Emergency Response', 'გადაუდებელი რეაგირება', 20.0, 2000, 10),
((SELECT id FROM departments WHERE name_english = 'Public Order and Safety'), 'Border Security', 'საზღვრის უსაფრთხოება', 12.0, 1500, 8),
((SELECT id FROM departments WHERE name_english = 'Public Order and Safety'), 'Crime Investigation', 'დანაშაულის გამოძიება', 5.0, 800, 12),
((SELECT id FROM departments WHERE name_english = 'Public Order and Safety'), 'Public Safety Education', 'საზოგადოებრივი უსაფრთხოების განათლება', 3.0, 200, 5);

-- Insert sub-departments for Environment Protection
INSERT INTO sub_departments (department_id, name_english, name_georgian, allocation_percentage, employee_count, projects_count) VALUES
((SELECT id FROM departments WHERE name_english = 'Environment Protection'), 'Forest Conservation', 'ტყის კონსერვაცია', 40.0, 800, 15),
((SELECT id FROM departments WHERE name_english = 'Environment Protection'), 'Water Resource Management', 'წყლის რესურსების მართვა', 30.0, 500, 12),
((SELECT id FROM departments WHERE name_english = 'Environment Protection'), 'Air Quality Monitoring', 'ჰაერის ხარისხის მონიტორინგი', 15.0, 200, 8),
((SELECT id FROM departments WHERE name_english = 'Environment Protection'), 'Waste Management', 'ნარჩენების მართვა', 10.0, 300, 10),
((SELECT id FROM departments WHERE name_english = 'Environment Protection'), 'Climate Change Initiatives', 'კლიმატის ცვლილების ინიციატივები', 5.0, 100, 6);

-- Insert sub-departments for Defense
INSERT INTO sub_departments (department_id, name_english, name_georgian, allocation_percentage, employee_count, projects_count) VALUES
((SELECT id FROM departments WHERE name_english = 'Defense'), 'Military Operations', 'სამხედრო ოპერაციები', 50.0, 8000, 20),
((SELECT id FROM departments WHERE name_english = 'Defense'), 'Defense Equipment', 'თავდაცვის აღჭურვილობა', 25.0, 1000, 10),
((SELECT id FROM departments WHERE name_english = 'Defense'), 'Military Training', 'სამხედრო მომზადება', 15.0, 1500, 8),
((SELECT id FROM departments WHERE name_english = 'Defense'), 'Intelligence Services', 'დაზვერვის სერვისები', 7.0, 500, 5),
((SELECT id FROM departments WHERE name_english = 'Defense'), 'Veteran Affairs', 'ვეტერანთა საქმეები', 3.0, 200, 4);
