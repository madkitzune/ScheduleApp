#pragma once
// schedule.h — оголошення класу ScheduleRecord та функцій модуля розкладу

#include <string>

// -----------------------------------------------------------------------
// Клас одного запису розкладу
// -----------------------------------------------------------------------
class ScheduleRecord {
public:
    std::string subject;    // Назва предмету
    int         startTime;  // Час початку у форматі HHMM (наприклад, 900 = 09:00)
    std::string room;       // Аудиторія
    std::string teacher;    // ПІБ викладача
    int         duration;   // Тривалість заняття у хвилинах

    // Конструктор за замовчуванням
    ScheduleRecord();

    // Конструктор з параметрами
    ScheduleRecord(const std::string& subj, int start,
                   const std::string& rm, const std::string& tchr, int dur);

    // Виводить рядок таблиці для цього запису
    void printRow(int index) const;
};

// -----------------------------------------------------------------------
// Функції управління масивом
// -----------------------------------------------------------------------

// Виводить всю таблицю записів (заголовок + рядки)
void printTable(ScheduleRecord** arr, int size);

// Зчитує записи з текстового файлу; повертає кількість прочитаних
int loadFromFile(const std::string& filename,
                 ScheduleRecord**& arr, int& size, int& capacity);

// Зберігає записи у текстовий файл
void saveToFile(const std::string& filename,
                ScheduleRecord** arr, int size);

// Додає новий запис у кінець масиву
void appendRecord(ScheduleRecord**& arr, int& size, int& capacity,
                  ScheduleRecord* rec);

// Вставляє запис перед вказаним індексом (0-based)
void insertBefore(ScheduleRecord**& arr, int& size, int& capacity,
                  int index, ScheduleRecord* rec);

// Вставляє запис після вказаного індексу (0-based)
void insertAfter(ScheduleRecord**& arr, int& size, int& capacity,
                 int index, ScheduleRecord* rec);

// Замінює запис за індексом новим
void replaceRecord(ScheduleRecord** arr, int size,
                   int index, ScheduleRecord* rec);

// Видаляє count записів починаючи з fromIndex; якщо count == -1 — до кінця
void deleteFrom(ScheduleRecord**& arr, int& size,
                int fromIndex, int count);

// Сортування масиву за часом початку алгоритмом Шелла
void shellSortByTime(ScheduleRecord** arr, int size);

// Бінарний пошук за назвою предмету (масив попередньо сортується за назвою)
// Повертає індекс знайденого запису або -1
int binarySearchBySubject(ScheduleRecord** arr, int size,
                           const std::string& subject);

// Статистика (max, min, середнє) за полем startTime у заданому діапазоні
void rangeStats(ScheduleRecord** arr, int size,
                int fromTime, int toTime);

// Зчитує один запис з консолі
ScheduleRecord* readRecordFromConsole();

// Звільняє весь масив та його елементи
void freeAll(ScheduleRecord**& arr, int& size, int& capacity);
