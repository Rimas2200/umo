const express = require('express');
const path = require('path');

const app = express();
const port = 3001;

// Установка статической папки для обслуживания файлов из build/web
app.use(express.static(path.join(__dirname, 'build', 'web')));

// Роут для отображения веб-приложения
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'web', 'index.html'));
});

// Запуск сервера
app.listen(port, () => {
  console.log(`Сервер запущен на порту ${port}`);
});
