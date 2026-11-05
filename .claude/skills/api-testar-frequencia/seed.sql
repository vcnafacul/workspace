-- Dados fictícios para testar a frequência. Só para o MySQL local da stack.
-- __SENHA_HASH__ é trocado pelo hash bcrypt gerado na hora (ver SKILL.md).
-- Pode rodar de novo: não duplica nada e só atualiza a senha.

SET FOREIGN_KEY_CHECKS = 0;

INSERT IGNORE INTO roles (id, name, base) VALUES
  ('00000000-0000-0000-0000-000000000001', 'admin', 1),
  ('00000000-0000-0000-0000-000000000002', 'aluno', 1);

-- Todas as permissões para o admin, sem repetir a lista de colunas aqui.
SET SESSION group_concat_max_len = 8192;
SET @liga_tudo = (
  SELECT CONCAT('UPDATE roles SET ', GROUP_CONCAT(CONCAT('`', COLUMN_NAME, '` = 1')), ' WHERE name = ''admin''')
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'roles' AND DATA_TYPE = 'tinyint' AND COLUMN_NAME <> 'base'
);
PREPARE liga_tudo FROM @liga_tudo;
EXECUTE liga_tudo;
DEALLOCATE PREPARE liga_tudo;

INSERT INTO users (id, email, password, firstName, lastName, phone, gender, birthday, state, city, lgpd, roleId)
VALUES
  ('00000000-0000-0000-0000-000000000010', 'admin@example.com', '__SENHA_HASH__',
   'Admin', 'Teste', '11999999999', 0, '1990-01-01', 'SP', 'São Paulo', 1,
   (SELECT id FROM roles WHERE name = 'admin')),
  ('00000000-0000-0000-0000-000000000011', 'estudante@example.com', '__SENHA_HASH__',
   'Estudante', 'Teste', '11988888888', 0, '2000-06-15', 'SP', 'São Paulo', 1,
   (SELECT id FROM roles WHERE name = 'aluno'))
ON DUPLICATE KEY UPDATE password = VALUES(password);

INSERT IGNORE INTO geolocations (id, latitude, longitude, name, cep, state, city, neighborhood, street,
  user_fullname, user_phone, user_connection, user_email, status, type)
VALUES (
  '00000000-0000-0000-0000-000000000020',
  -23.5505, -46.6333,
  'Cursinho Teste', '01001-000',
  'SP', 'São Paulo', 'Centro', 'Rua Teste 123',
  'Admin Teste', '11999999999', 'Representante', 'admin@example.com',
  1, 0
);

INSERT IGNORE INTO partner_prep_course (id, geo_id, representative)
VALUES (
  '00000000-0000-0000-0000-000000000030',
  '00000000-0000-0000-0000-000000000020',
  '00000000-0000-0000-0000-000000000010'
);

INSERT IGNORE INTO collaborators (id, user_id, partner_prep_course_id, actived)
VALUES (
  '00000000-0000-0000-0000-000000000040',
  '00000000-0000-0000-0000-000000000010',
  '00000000-0000-0000-0000-000000000030',
  1
);

INSERT IGNORE INTO inscription_course (id, name, description, start_date, end_date, actived, expected_opening,
  partner_prep_course_id, requestDocuments, lenght)
VALUES (
  '00000000-0000-0000-0000-000000000050',
  'Processo Seletivo de Teste', 'Processo seletivo de teste',
  '2026-01-01 00:00:00', '2026-12-31 23:59:59',
  1, 50,
  '00000000-0000-0000-0000-000000000030',
  0, 0
);

INSERT IGNORE INTO course_periods (id, name, year, startDate, endDate, partner_prep_course_id)
VALUES (
  '00000000-0000-0000-0000-000000000060',
  '1º Semestre 2026', 2026,
  '2026-01-01 00:00:00', '2026-06-30 23:59:59',
  '00000000-0000-0000-0000-000000000030'
);

INSERT IGNORE INTO classes (id, name, description, partner_prep_course_id, course_period_id)
VALUES (
  '00000000-0000-0000-0000-000000000070',
  'Turma A', 'Turma de teste para frequência',
  '00000000-0000-0000-0000-000000000030',
  '00000000-0000-0000-0000-000000000060'
);

INSERT IGNORE INTO classes_collaborators (class_id, collaborator_id)
VALUES (
  '00000000-0000-0000-0000-000000000070',
  '00000000-0000-0000-0000-000000000040'
);

INSERT IGNORE INTO student_course (id, user_id, cpf, email, partner_prep_course_id,
  inscriptionCourseId, applicationStatus, cod_enrolled, classId, isFree, selectEnrolled, waitingList,
  documents_done, photo_done, survey_done)
VALUES (
  '00000000-0000-0000-0000-000000000080',
  '00000000-0000-0000-0000-000000000011',
  '00000000000', 'estudante@example.com',
  '00000000-0000-0000-0000-000000000030',
  '00000000-0000-0000-0000-000000000050',
  'Matriculado', 'MAT-001',
  '00000000-0000-0000-0000-000000000070',
  1, 0, 0, 0, 0, 0
);

SET FOREIGN_KEY_CHECKS = 1;
