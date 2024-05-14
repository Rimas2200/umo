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