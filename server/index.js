const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

const app = express();
const pool = mysql.createPool({
  host: '127.0.0.1',
  user: 'root',
  database: 'respGlobalChange',
  password: '',
});

app.use(express.json());
app.use(cors());

app.post('/timetable', async (req, res) => {
  const { discipline, classroom, group_name, pair_name, teacher_name, day_of_the_week, week, subgroup} = req.body;
  console.log(req.body)
  if (!(discipline && classroom && group_name && pair_name && teacher_name && day_of_the_week && week && subgroup)) {
    return res.status(409).json({ error: 'Данные не соответствуют запросу' });
  }
  try {
    const newtimetable = {
      discipline,
      classroom,
      group_name,
      pair_name,
      teacher_name,
      day_of_the_week,
      week,
      subgroup
    };
    await savetimetable(newtimetable);
    res.status(200).json(newtimetable);
  } catch (error) {
    console.error('Ошибка сохранения расписания:', error);
    res.status(500).json({ error: 'Ошибка сервера' });
  }
});
function savetimetable(newtimetable) {
  return new Promise((resolve, reject) => {
    const query = 'INSERT INTO schedule (discipline, classroom, group_name, pair_name, teacher_name, day_of_the_week, week, subgroup) VALUES (?, ?, ?, ?, ?, ?, ?, ?)';
    const values = [newtimetable.discipline, newtimetable.classroom, newtimetable.group_name, newtimetable.pair_name, newtimetable.teacher_name, newtimetable.day_of_the_week, newtimetable.week, newtimetable.subgroup];
    pool.query(query, values, (error, results) => {
      if (error) {
        reject(error);
      } else {
        resolve(results);
      }
    });
  });
}
app.get('/discipline', (req, res) => {
  pool.query('SELECT * FROM discipline', (error, results) => {
    console.log('запрос есть');
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json({ disciplines: results });
      } else {
        res.status(404).json({ error: 'Данные не найдены' });
      }
    }
  });
});
app.get('/couple_type', (req, res) => {
  pool.query('SELECT * FROM couple_type', (error, results) => {
    console.log('запрос есть');
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json({ pair_type: results });
      } else {
        res.status(404).json({ error: 'Данные не найдены' });
      }
    }
  });
});
app.get('/professor', (req, res) => {
  pool.query('SELECT last_name, CONCAT(LEFT(first_name, 1), ". ", LEFT(middle_name, 1), ".") AS initials FROM professor', (error, results) => {
    console.log('запрос есть');
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json({ professors: results });
      } else {
        res.status(404).json({ error: 'Преподаватели не найдены' });
      }
    }
  });
});
app.get('/classroom', (req, res) => {
  pool.query('SELECT CONCAT(room_number, " Корпус: ", building) AS initials FROM classroom', (error, results) => {
    console.log('запрос есть');
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json({ classrooms: results });
      } else {
        res.status(404).json({ error: 'Данные не найдены' });
      }
    }
  });
});
app.get('/address', (req, res) => {
  pool.query('SELECT * FROM address', (error, results) => {
    console.log('запрос есть');
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json({ address: results });
      } else {
        res.status(404).json({ error: 'Данные не найдены' });
      }
    }
  });
});
app.get('/addresses', (req, res) => {
  pool.query('SELECT * FROM address', (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json(results);
      } else {
        res.json([]);
      }
    }
  });
});
app.post('/addresses/insert', (req, res) => {
  const { address, faculty } = req.body;
  pool.query('INSERT INTO address (address, faculty) VALUES (?, ?)', [address, faculty], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      const newAddressId = results.insertId;
      console.log(`Добавлен новый адрес с id ${newAddressId}`);
      res.status(201).json({ id: newAddressId, message: 'Адрес успешно добавлен' });
    }
  });
});

app.put('/addresses/update/:id', (req, res) => {
  const id = req.params.id;
  const { address, faculty } = req.body;
  pool.query(
    'UPDATE address SET address = ?, faculty = ? WHERE id = ?',
    [address, faculty, id],
    (error, results) => {
      if (error) {
        console.error('Ошибка при выполнении запроса:', error);
        res.status(500).json({ error: 'Ошибка сервера' });
      } else {
        console.log(`Адрес с id ${id} успешно отредактирован`);
        res.status(200).json({ message: 'Адрес успешно отредактирован' });
      }
    }
  );
});
app.delete('/addresses/:id', (req, res) => {
  const addressId = req.params.id;

  pool.query('DELETE FROM address WHERE id = ?', [addressId], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      console.log(`Адрес с id ${addressId} успешно удален`);
      res.status(200).json({ message: 'Адрес успешно удален' });
    }
  });
});
app.get('/classrooms', (req, res) => {
  pool.query('SELECT * FROM classroom', (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json(results);
      } else {
        res.json([]);
      }
    }
  });
});
app.post('/classrooms/insert', (req, res) => {
  const { room_number, building } = req.body;
  pool.query('INSERT INTO classroom (room_number, building) VALUES (?, ?)', [room_number, building], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      const newClassroomId = results.insertId;
      console.log(`Добавлена новая аудитория с id ${newClassroomId}`);
      res.status(201).json({ id: newClassroomId, message: 'Аудитория успешно добавлена' });
    }
  });
});
app.put('/classrooms/update/:id', (req, res) => {
  const id = req.params.id;
  const { room_number, building } = req.body;
  pool.query(
    'UPDATE classroom SET room_number = ?, building = ? WHERE id = ?',
    [room_number, building, id],
    (error, results) => {
      if (error) {
        console.error('Ошибка при выполнении запроса:', error);
        res.status(500).json({ error: 'Ошибка сервера' });
      } else {
        console.log(`Аудитория с id ${id} успешно отредактирована`);
        res.status(200).json({ message: 'Аудитория успешно отредактирована' });
      }
    }
  );
});
app.delete('/classrooms/:id', (req, res) => {
  const classroomId = req.params.id;
  pool.query('DELETE FROM classroom WHERE id = ?', [classroomId], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      console.log(`Аудитория с id ${classroomId} успешно удалена`);
      res.status(200).json({ message: 'Аудитория успешно удалена' });
    }
  });
});
app.get('/departaments', (req, res) => {
  pool.query('SELECT * FROM departament', (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json(results);
      } else {
        res.json([]);
      }
    }
  });
});
app.post('/departaments/insert', (req, res) => {
  const { name, phone } = req.body;
  pool.query('INSERT INTO departament (name, phone) VALUES (?, ?)', [name, phone], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      const newDepartamentId = results.insertId;
      console.log(`Добавлен новый департамент с id ${newDepartamentId}`);
      res.status(201).json({ id: newDepartamentId, message: 'Департамент успешно добавлен' });
    }
  });
});
app.put('/departaments/update/:id', (req, res) => {
  const id = req.params.id;
  const { name, phone } = req.body;
  pool.query(
    'UPDATE departament SET name = ?, phone = ? WHERE id = ?',
    [name, phone, id],
    (error, results) => {
      if (error) {
        console.error('Ошибка при выполнении запроса:', error);
        res.status(500).json({ error: 'Ошибка сервера' });
      } else {
        console.log(`Департамент с id ${id} успешно отредактирован`);
        res.status(200).json({ message: 'Департамент успешно отредактирован' });
      }
    }
  );
});
app.delete('/departaments/:id', (req, res) => {
  const departamentId = req.params.id;
  pool.query('DELETE FROM departament WHERE id = ?', [departamentId], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      console.log(`Департамент с id ${departamentId} успешно удален`);
      res.status(200).json({ message: 'Департамент успешно удален' });
    }
  });
});
app.get('/directions', (req, res) => {
  pool.query('SELECT * FROM direction', (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json(results);
      } else {
        res.json([]);
      }
    }
  });
});
app.post('/directions/insert', (req, res) => {
  const { direction_abbreviation, name, faculty } = req.body;
  pool.query('INSERT INTO direction (direction_abbreviation, name, faculty) VALUES (?, ?, ?)', [direction_abbreviation, name, faculty], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      const newDirectionId = results.insertId;
      console.log(`Добавлена новая специальность с id ${newDirectionId}`);
      res.status(201).json({ id: newDirectionId, message: 'Специальность успешно добавлена' });
    }
  });
});
app.put('/directions/update/:id', (req, res) => {
  const id = req.params.id;
  const { direction_abbreviation, name, faculty } = req.body;
  pool.query(
    'UPDATE direction SET direction_abbreviation = ?, name = ?, faculty = ? WHERE id = ?',
    [direction_abbreviation, name, faculty, id],
    (error, results) => {
      if (error) {
        console.error('Ошибка при выполнении запроса:', error);
        res.status(500).json({ error: 'Ошибка сервера' });
      } else {
        console.log(`Специальность с id ${id} успешно отредактирована`);
        res.status(200).json({ message: 'Специальность успешно отредактирована' });
      }
    }
  );
});
app.delete('/directions/:id', (req, res) => {
  const directionId = req.params.id;

  pool.query('DELETE FROM direction WHERE id = ?', [directionId], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      console.log(`Специальность с id ${directionId} успешно удалена`);
      res.status(200).json({ message: 'Специальность успешно удалена' });
    }
  });
});
app.get('/group_names', (req, res) => {
  pool.query('SELECT * FROM group_name', (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json(results);
      } else {
        res.json([]);
      }
    }
  });
});
app.post('/group_names/insert', (req, res) => {
  const { name, direction_abbreviation } = req.body;
  pool.query('INSERT INTO group_name (name, direction_abbreviation) VALUES (?, ?)', [name, direction_abbreviation], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      const newGroupId = results.insertId;
      console.log(`Добавлена новая группа с id ${newGroupId}`);
      res.status(201).json({ id: newGroupId, message: 'Группа успешно добавлена' });
    }
  });
});
app.put('/group_names/update/:id', (req, res) => {
  const id = req.params.id;
  const { name, direction_abbreviation } = req.body;
  pool.query(
    'UPDATE group_name SET name = ?, direction_abbreviation = ? WHERE id = ?',
    [name, direction_abbreviation, id],
    (error, results) => {
      if (error) {
        console.error('Ошибка при выполнении запроса:', error);
        res.status(500).json({ error: 'Ошибка сервера' });
      } else {
        console.log(`Группа с id ${id} успешно отредактирована`);
        res.status(200).json({ message: 'Группа успешно отредактирована' });
      }
    }
  );
});
app.delete('/group_names/:id', (req, res) => {
  const groupId = req.params.id;

  pool.query('DELETE FROM group_name WHERE id = ?', [groupId], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      console.log(`Группа с id ${groupId} успешно удалена`);
      res.status(200).json({ message: 'Группа успешно удалена' });
    }
  });
});
app.get('/couple_types', (req, res) => {
  pool.query('SELECT * FROM couple_type', (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json(results);
      } else {
        res.json([]);
      }
    }
  });
});
app.post('/couple_types/insert', (req, res) => {
  const { pair_type } = req.body;
  pool.query('INSERT INTO couple_type (pair_type) VALUES (?)', [pair_type], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      const newCoupleTypeId = results.insertId;
      console.log(`Добавлен новый тип пары с id ${newCoupleTypeId}`);
      res.status(201).json({ id: newCoupleTypeId, message: 'Тип пары успешно добавлен' });
    }
  });
});
app.put('/couple_types/update/:id', (req, res) => {
  const id = req.params.id;
  const { pair_type } = req.body;
  pool.query(
    'UPDATE couple_type SET pair_type = ? WHERE id = ?',
    [pair_type, id],
    (error, results) => {
      if (error) {
        console.error('Ошибка при выполнении запроса:', error);
        res.status(500).json({ error: 'Ошибка сервера' });
      } else {
        console.log(`Тип пары с id ${id} успешно отредактирован`);
        res.status(200).json({ message: 'Тип пары успешно отредактирован' });
      }
    }
  );
});
app.delete('/couple_types/:id', (req, res) => {
  const coupleTypeId = req.params.id;
  pool.query('DELETE FROM couple_type WHERE id = ?', [coupleTypeId], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      console.log(`Тип пары с id ${coupleTypeId} успешно удален`);
      res.status(200).json({ message: 'Тип пары успешно удален' });
    }
  });
});
app.get('/disciplines', (req, res) => {
  pool.query('SELECT * FROM discipline', (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json(results);
      } else {
        res.json([]);
      }
    }
  });
});
app.post('/disciplines/insert', (req, res) => {
  const { discipline_name } = req.body;
  pool.query('INSERT INTO discipline (discipline_name) VALUES (?)', [discipline_name], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      const newDisciplineId = results.insertId;
      console.log(`Добавлена новая дисциплина с id ${newDisciplineId}`);
      res.status(201).json({ id: newDisciplineId, message: 'Дисциплина успешно добавлена' });
    }
  });
});
app.put('/disciplines/update/:id', (req, res) => {
  const id = req.params.id;
  const { discipline_name } = req.body;
  pool.query(
    'UPDATE discipline SET discipline_name = ? WHERE id = ?',
    [discipline_name, id],
    (error, results) => {
      if (error) {
        console.error('Ошибка при выполнении запроса:', error);
        res.status(500).json({ error: 'Ошибка сервера' });
      } else {
        console.log(`Дисциплина с id ${id} успешно отредактирована`);
        res.status(200).json({ message: 'Дисциплина успешно отредактирована' });
      }
    }
  );
});
app.delete('/disciplines/:id', (req, res) => {
  const disciplineId = req.params.id;
  pool.query('DELETE FROM discipline WHERE id = ?', [disciplineId], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      console.log(`Дисциплина с id ${disciplineId} успешно удалена`);
      res.status(200).json({ message: 'Дисциплина успешно удалена' });
    }
  });
});
app.get('/professors', (req, res) => {
  pool.query('SELECT * FROM professor', (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json(results);
      } else {
        res.json([]);
      }
    }
  });
});
app.post('/professors/insert', (req, res) => {
  const { last_name, first_name, middle_name, position, department } = req.body;
  pool.query('INSERT INTO professor (last_name, first_name, middle_name, position, departement) VALUES (?, ?, ?, ?, ?)', [last_name, first_name, middle_name, position, department], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      const newProfessorId = results.insertId;
      console.log(`Добавлен новый преподаватель с id ${newProfessorId}`);
      res.status(201).json({ id: newProfessorId, message: 'Преподаватель успешно добавлен' });
    }
  });
});
app.put('/professors/update/:id', (req, res) => {
  const id = req.params.id;
  const { last_name, first_name, middle_name, position, department } = req.body;
  pool.query(
    'UPDATE professor SET last_name = ?, first_name = ?, middle_name = ?, position = ?, departement = ? WHERE id = ?',
    [last_name, first_name, middle_name, position, department, id],
    (error, results) => {
      if (error) {
        console.error('Ошибка при выполнении запроса:', error);
        res.status(500).json({ error: 'Ошибка сервера' });
      } else {
        console.log(`Преподаватель с id ${id} успешно отредактирован`);
        res.status(200).json({ message: 'Преподаватель успешно отредактирован' });
      }
    }
  );
});
app.delete('/professors/:id', (req, res) => {
  const professorId = req.params.id;
  pool.query('DELETE FROM professor WHERE id = ?', [professorId], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      console.log(`Преподаватель с id ${professorId} успешно удален`);
      res.status(200).json({ message: 'Преподаватель успешно удален' });
    }
  });
});
app.get('/userstest', (req, res) => {
  const userEmail = req.query.user_email;
  if (!userEmail) {
    return res.status(400).json({ error: 'Отсутствует почта пользователя' });
  }
  pool.query('SELECT group_name, subgroup FROM users WHERE email = ?', [userEmail], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json(results[0]);
      } else {
        res.status(404).json({ error: 'Данные не найдены' });
      }
    }
  });
});

app.get('/userstests', (req, res) => {
  const userEmail = req.query.userEmail;
  if (!userEmail) {
    return res.status(400).json({ error: 'Отсутствует email пользователя' });
  }
  pool.query('SELECT username FROM users WHERE email = ?', [userEmail], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json({ username: results[0].username });
      } else {
        res.status(404).json({ error: 'Пользователь не найден' });
      }
    }
  });
});

app.get('/schedule/teacher', (req, res) => {
  const userEmail = req.query.user_email;
  const weekday = req.query.weekday;
  const weekType = req.query.week_type;
  console.log(userEmail, weekday, weekType);
  if (!userEmail || !weekday || !weekType) {
    return res.status(400).json({ error: 'Where are the data? Aaa?' });
  }
  pool.query('SELECT * FROM users WHERE email = ?', userEmail, (error, userResults) => {
    if (error) {
      console.error('Error executing user query:', error);
      return res.status(500).json({ error: 'Server error' });
    }
    if (!userResults || userResults.length === 0 || !userResults[0].professor || !userResults[0].departament) {
      return res.status(400).json({ error: 'Fill in your information' });
    }
    pool.query('SELECT * FROM schedule WHERE teacher_name = ? AND day_of_the_week = ? AND (week = ? OR week = "")', [userResults[0].professor, weekday, weekType], (error, results) => {
    console.log(userResults[0].professor, weekday, weekType);
      if (error) {
        console.error('Error executing schedule query:', error);
        return res.status(500).json({ error: 'Server error' });
      }
      if (results && results.length > 0) {
        res.json(results);
      } else {
        res.json([]);
      }
    });
  });
});
app.get('/schedule', (req, res) => {
  const userEmail = req.query.user_email;
  const weekday = req.query.weekday;
  const weekType = req.query.week_type;
  if (!userEmail || !weekday || !weekType) {
    return res.status(400).json({ error: 'Where are the data? Aaa?' });
  }
  pool.query('SELECT * FROM users WHERE email = ?', userEmail, (error, userResults) => {
    if (error) {
      console.error('Error executing user query:', error);
      return res.status(500).json({ error: 'Server error' });
    }
    if (!userResults || userResults.length === 0 || !userResults[0].group_name || !userResults[0].subgroup) {
      return res.status(400).json({ error: 'Fill in your information' });
    }
    pool.query('SELECT * FROM schedule WHERE group_name = ? AND subgroup = ? AND day_of_the_week = ? AND (week = ? OR week = "")', [userResults[0].group_name, userResults[0].subgroup, weekday, weekType], (error, results) => {
      if (error) {
        console.error('Error executing schedule query:', error);
        return res.status(500).json({ error: 'Server error' });
      }
      if (results && results.length > 0) {
        res.json(results);
      } else {
        res.json([]);
      }
    });
  });
});
app.get('/faculties', (req, res) => {
  pool.query('SELECT * FROM faculty', (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json(results);
      } else {
        res.json([]);
      }
    }
  });
});
app.post('/faculties/insert', (req, res) => {
  const { faculty_name, dean_fullname } = req.body;
  pool.query('INSERT INTO faculty (faculty_name, dean_fullname) VALUES (?, ?)', [faculty_name, dean_fullname], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      const newFacultyId = results.insertId;
      console.log(`Добавлен новый факультет с id ${newFacultyId}`);
      res.status(201).json({ id: newFacultyId, message: 'Факультет успешно добавлен' });
    }
  });
});
app.put('/faculties/update/:id', (req, res) => {
  const id = req.params.id;
  const { faculty_name, dean_fullname } = req.body;
  pool.query(
    'UPDATE faculty SET faculty_name = ?, dean_fullname = ? WHERE id = ?',
    [faculty_name, dean_fullname, id],
    (error, results) => {
      if (error) {
        console.error('Ошибка при выполнении запроса:', error);
        res.status(500).json({ error: 'Ошибка сервера' });
      } else {
        console.log(`Факультет с id ${id} успешно отредактирован`);
        res.status(200).json({ message: 'Факультет успешно отредактирован' });
      }
    }
  );
});
app.delete('/faculties/:id', (req, res) => {
  const facultyId = req.params.id;
  pool.query('DELETE FROM faculty WHERE id = ?', [facultyId], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      console.log(`Факультет с id ${facultyId} успешно удален`);
      res.status(200).json({ message: 'Факультет успешно удален' });
    }
  });
});
app.get('/departament', (req, res) => {
  pool.query('SELECT * FROM departament', (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json(results);
      } else {
        res.json([]);
      }
    }
  });
});
app.get('/professor/:department', (req, res) => {
  const department = req.params.department;
  pool.query('SELECT CONCAT(last_name, " ", LEFT(first_name, 1), ". ", LEFT(middle_name, 1), ".") AS name FROM professor WHERE departement = ?', [department], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json(results);
      } else {
        res.json([]);
      }
    }
  });
});
app.get('/directions/:facultyId', (req, res) => {
  const facultyId = req.params.facultyId;
  pool.query('SELECT direction_abbreviation FROM direction WHERE faculty = ?', [facultyId], (error, results) => {
  console.log("запрос есть", facultyId);
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json(results);
      } else {
        res.json([]);
      }
    }
  });
});
app.get('/group_name/:directionId', (req, res) => {
  const directionId = req.params.directionId;
  pool.query('SELECT name FROM group_name WHERE direction_abbreviation = ?', [directionId], (error, results) => {
    if (error) {
      console.error('Ошибка при выполнении запроса:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    } else {
      if (results && results.length > 0) {
        res.json(results);
      } else {
        res.json([]);
      }
    }
  });
});
app.post('/register', async (req, res) => {
  const { username, email, password } = req.body;
  console.log(req.body)
  if (!(username && email && password)) {
    return res.status(409).json({ error: 'Данные не соответствуют запросу' });
  }
  console.log(email)
  try {
    const exists = await userExists(email);
    if (exists) {
      return res.status(416).json({ error: 'Пользователь с такой почтой уже существует' });
    }
    const newUser = {
      username,
      email,
      password,
    };
    await saveUser(newUser);
    res.status(200).json(newUser);
  } catch (error) {
    console.error('Ошибка сохранения пользователя:', error);
    res.status(500).json({ error: 'Ошибка сервера' });
  }
});
function userExists(email) {
  return new Promise((resolve, reject) => {
    const query = 'SELECT COUNT(*) AS count FROM users WHERE email = ?';
    const values = [email];
    pool.query(query, values, (error, results) => {
      if (error) {
        reject(error);
      } else {
        const count = results[0].count;
        resolve(count > 0);
        console.log(count)
      }
    });
  });
}
function saveUser(user) {
  return new Promise((resolve, reject) => {
    const query = 'INSERT INTO users (username, email, password, token) VALUES (?, ?, ?, ?)';
    const values = [user.username, user.email, user.password, "token"];
    pool.query(query, values, (error, results) => {
      if (error) {
        reject(error);
      } else {
        resolve(results);
      }
    });
  });
}
app.post('/auth', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(416).json({ error: 'Данные не соответствуют запросу' });
  }
  const secretKey = crypto.randomBytes(32).toString('hex');
  const token = jwt.sign({ email }, secretKey);
  authenticateUser(email, password, token)
    .then((authenticated) => {
      if (authenticated) {
        res.status(200).json({ token });
      } else {
        res.status(401).json({ error: 'Не авторизован' });
      }
    })
    .catch((error) => {
      console.error('Ошибка проверки авторизации:', error);
      res.status(500).json({ error: 'Ошибка сервера' });
    });
});
app.post('/users/profile_one', (req, res) => {
  const { user_email, department, professor } = req.body;
  if (!user_email || !department || !professor) {
    console.log(user_email, department, professor);
    return res.status(400).json({ error: 'Отсутствуют обязательные параметры' });
  }
  pool.query('UPDATE users SET departament = ?, professor = ? WHERE email = ?', [department, professor, user_email], (error, results) => {
    if (error) {
      console.error('Ошибка при обновлении данных:', error);
      return res.status(500).json({ error: 'Ошибка сервера' });
    }
    if (results.affectedRows === 0) {
      return res.status(404).json({ error: 'Пользователь с указанной почтой не найден' });
    }
    return res.status(200).json({ message: 'Данные успешно обновлены' });
  });
});
app.post('/users/profile_two', (req, res) => {
  const { user_email, faculty, direction, group_name, subgroup} = req.body;
  console.log(user_email, faculty, direction, group_name, subgroup);
  if (!user_email || !direction || !group_name || !subgroup || !faculty) {
    console.log(user_email, department, professor);
    return res.status(400).json({ error: 'Отсутствуют обязательные параметры' });
  }
  pool.query('UPDATE users SET faculty = ?, direction = ?,  group_name = ?, subgroup = ? WHERE email = ?', [faculty, direction, group_name, subgroup, user_email], (error, results) => {
    if (error) {
      console.error('Ошибка при обновлении данных:', error);
      return res.status(500).json({ error: 'Ошибка сервера' });
    }
    if (results.affectedRows === 0) {
      return res.status(404).json({ error: 'Пользователь с указанной почтой не найден' });
    }
    return res.status(200).json({ message: 'Данные успешно обновлены' });
  });
});
function authenticateUser(email, password, token) {
  return new Promise((resolve, reject) => {
    const query = 'SELECT * FROM users WHERE email = ? AND password = ?';
    const values = [email, password];
    pool.query(query, values, (error, results) => {
      if (error) {
        reject(error);
      } else {
        const authenticated = results.length > 0;
        if (authenticated) {
          const updateQuery = 'UPDATE users SET token = ? WHERE email = ?';
          const updateValues = [token, email];
          pool.query(updateQuery, updateValues, (error, results) => {
            if (error) {
              reject(error);
            } else {
              resolve(authenticated);
            }
          });
        } else {
          resolve(authenticated);
        }
      }
    });
  });
}
app.listen(3000, () => {
  console.log('Сервер запущен на порту 3000');
  pool.getConnection((error, connection) => {
    if (error) {
      console.error('Ошибка подключения к базе данных:', error);
      return;
    }
    console.log('Соединение с базой данных успешно установлено.');
    connection.query('SELECT 1 + 1 AS result', (error, results) => {
      if (error) {
        console.error('Ошибка выполнения запроса:', error);
        return;
      }
      console.log('Результат запроса:', results[0].result);
      connection.release();
      console.log('Соединение с базой данных успешно закрыто.');
    });
  });
});