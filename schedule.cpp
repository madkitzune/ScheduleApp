// schedule.cpp — реалізація всіх функцій модуля розкладу

#include "schedule.h"

#include <iostream>
#include <fstream>
#include <iomanip>
#include <algorithm>
#include <climits>
#include <limits>
#include <sstream>
#include <stdexcept>

// -----------------------------------------------------------------------
// Допоміжна функція: перетворення HHMM -> рядок "HH:MM"
// -----------------------------------------------------------------------
static std::string timeToStr(int hhmm) {
    int h = hhmm / 100;
    int m = hhmm % 100;
    std::ostringstream oss;
    oss << std::setw(2) << std::setfill('0') << h << ":"
        << std::setw(2) << std::setfill('0') << m;
    return oss.str();
}

// -----------------------------------------------------------------------
// Конструктори ScheduleRecord
// -----------------------------------------------------------------------
ScheduleRecord::ScheduleRecord()
    : subject(""), startTime(0), room(""), teacher(""), duration(0) {}

ScheduleRecord::ScheduleRecord(const std::string& subj, int start,
                               const std::string& rm,
                               const std::string& tchr, int dur)
    : subject(subj), startTime(start), room(rm), teacher(tchr), duration(dur) {}

// -----------------------------------------------------------------------
// Виводить один рядок таблиці
// -----------------------------------------------------------------------
void ScheduleRecord::printRow(int index) const {
    std::cout << std::left
              << std::setw(4)  << index + 1
              << std::setw(26) << subject
              << std::setw(8)  << timeToStr(startTime)
              << std::setw(8)  << room
              << std::setw(30) << teacher
              << std::setw(6)  << duration
              << "\n";
}

// -----------------------------------------------------------------------
// Виводить повну таблицю
// -----------------------------------------------------------------------
void printTable(ScheduleRecord** arr, int size) {
    if (size == 0) {
        std::cout << "  [Масив порожній]\n";
        return;
    }
    // Роздільник
    std::string sep(82, '-');
    std::cout << sep << "\n";
    std::cout << std::left
              << std::setw(4)  << "#"
              << std::setw(26) << "Предмет"
              << std::setw(8)  << "Початок"
              << std::setw(8)  << "Ауд."
              << std::setw(30) << "Викладач"
              << std::setw(6)  << "Хв."
              << "\n";
    std::cout << sep << "\n";
    for (int i = 0; i < size; ++i) {
        arr[i]->printRow(i);
    }
    std::cout << sep << "\n";
}

// -----------------------------------------------------------------------
// Розширення масиву (подвоєння ємності)
// -----------------------------------------------------------------------
static void grow(ScheduleRecord**& arr, int& capacity) {
    int newCap = (capacity == 0) ? 4 : capacity * 2;
    ScheduleRecord** tmp = new ScheduleRecord*[newCap];
    for (int i = 0; i < capacity; ++i) tmp[i] = arr[i];
    delete[] arr;
    arr = tmp;
    capacity = newCap;
}

// -----------------------------------------------------------------------
// Зчитування записів з файлу
// Формат рядка: subject|startTime|room|teacher|duration
// -----------------------------------------------------------------------
int loadFromFile(const std::string& filename,
                 ScheduleRecord**& arr, int& size, int& capacity) {
    std::ifstream fin(filename);
    if (!fin.is_open()) {
        std::cerr << "  Помилка: не вдалося відкрити файл \"" << filename << "\"\n";
        return 0;
    }

    int loaded = 0;
    std::string line;
    while (std::getline(fin, line)) {
        if (line.empty() || line[0] == '#') continue; // пропускаємо коментарі

        // Розбиваємо рядок по символу '|'
        std::istringstream ss(line);
        std::string subj, startStr, rm, tchr, durStr;
        if (!std::getline(ss, subj,     '|')) continue;
        if (!std::getline(ss, startStr, '|')) continue;
        if (!std::getline(ss, rm,       '|')) continue;
        if (!std::getline(ss, tchr,     '|')) continue;
        if (!std::getline(ss, durStr,   '|')) continue;

        try {
            int startTime = std::stoi(startStr);
            int dur       = std::stoi(durStr);
            ScheduleRecord* rec = new ScheduleRecord(subj, startTime, rm, tchr, dur);
            appendRecord(arr, size, capacity, rec);
            ++loaded;
        } catch (...) {
            std::cerr << "  Попередження: некоректний рядок у файлі, пропущено.\n";
        }
    }
    fin.close();
    return loaded;
}

// -----------------------------------------------------------------------
// Збереження записів у файл
// -----------------------------------------------------------------------
void saveToFile(const std::string& filename,
                ScheduleRecord** arr, int size) {
    std::ofstream fout(filename);
    if (!fout.is_open()) {
        std::cerr << "  Помилка: не вдалося відкрити файл для запису \"" << filename << "\"\n";
        return;
    }
    fout << "# Розклад занять. Формат: subject|startHHMM|room|teacher|durationMin\n";
    for (int i = 0; i < size; ++i) {
        fout << arr[i]->subject  << "|"
             << arr[i]->startTime << "|"
             << arr[i]->room     << "|"
             << arr[i]->teacher  << "|"
             << arr[i]->duration << "\n";
    }
    fout.close();
    std::cout << "  Збережено " << size << " записів у файл \"" << filename << "\"\n";
}

// -----------------------------------------------------------------------
// Додавання запису в кінець
// -----------------------------------------------------------------------
void appendRecord(ScheduleRecord**& arr, int& size, int& capacity,
                  ScheduleRecord* rec) {
    if (size >= capacity) grow(arr, capacity);
    arr[size++] = rec;
}

// -----------------------------------------------------------------------
// Вставка запису перед index
// -----------------------------------------------------------------------
void insertBefore(ScheduleRecord**& arr, int& size, int& capacity,
                  int index, ScheduleRecord* rec) {
    if (index < 0 || index > size) {
        std::cerr << "  Помилка: індекс поза межами масиву.\n";
        delete rec;
        return;
    }
    if (size >= capacity) grow(arr, capacity);
    // Зсуваємо елементи вправо
    for (int i = size; i > index; --i)
        arr[i] = arr[i - 1];
    arr[index] = rec;
    ++size;
}

// -----------------------------------------------------------------------
// Вставка запису після index
// -----------------------------------------------------------------------
void insertAfter(ScheduleRecord**& arr, int& size, int& capacity,
                 int index, ScheduleRecord* rec) {
    // Вставка після index — це вставка перед index+1
    insertBefore(arr, size, capacity, index + 1, rec);
}

// -----------------------------------------------------------------------
// Заміна запису за індексом
// -----------------------------------------------------------------------
void replaceRecord(ScheduleRecord** arr, int size,
                   int index, ScheduleRecord* rec) {
    if (index < 0 || index >= size) {
        std::cerr << "  Помилка: індекс поза межами масиву.\n";
        delete rec;
        return;
    }
    delete arr[index]; // звільняємо старий об'єкт
    arr[index] = rec;
}

// -----------------------------------------------------------------------
// Видалення count елементів починаючи з fromIndex
// Якщо count == -1, видаляється від fromIndex до кінця
// -----------------------------------------------------------------------
void deleteFrom(ScheduleRecord**& arr, int& size,
                int fromIndex, int count) {
    if (fromIndex < 0 || fromIndex >= size) {
        std::cerr << "  Помилка: початковий індекс поза межами масиву.\n";
        return;
    }
    if (count == -1 || fromIndex + count > size)
        count = size - fromIndex;

    // Звільняємо пам'ять видалених об'єктів
    for (int i = fromIndex; i < fromIndex + count; ++i)
        delete arr[i];

    // Зсуваємо решту ліворуч
    int shift = size - fromIndex - count;
    for (int i = 0; i < shift; ++i)
        arr[fromIndex + i] = arr[fromIndex + count + i];

    size -= count;
}

// -----------------------------------------------------------------------
// Сортування Шелла за полем startTime
// -----------------------------------------------------------------------
void shellSortByTime(ScheduleRecord** arr, int size) {
    // Послідовність кроків Кнута: 1, 4, 13, 40, 121, ...
    int gap = 1;
    while (gap < size / 3) gap = gap * 3 + 1;

    while (gap >= 1) {
        for (int i = gap; i < size; ++i) {
            ScheduleRecord* tmp = arr[i];
            int j = i;
            while (j >= gap && arr[j - gap]->startTime > tmp->startTime) {
                arr[j] = arr[j - gap];
                j -= gap;
            }
            arr[j] = tmp;
        }
        gap /= 3;
    }
}

// -----------------------------------------------------------------------
// Бінарний пошук за назвою предмету
// Перед викликом масив повинен бути відсортований за subject (лексично)
// -----------------------------------------------------------------------
static void sortBySubject(ScheduleRecord** arr, int size) {
    // Простий std::sort за рядком для тимчасового впорядкування
    std::sort(arr, arr + size,
        [](const ScheduleRecord* a, const ScheduleRecord* b) {
            return a->subject < b->subject;
        });
}

int binarySearchBySubject(ScheduleRecord** arr, int size,
                           const std::string& subject) {
    if (size == 0) return -1;

    // Робимо тимчасову копію масиву покажчиків для сортування
    ScheduleRecord** tmp = new ScheduleRecord*[size];
    for (int i = 0; i < size; ++i) tmp[i] = arr[i];
    sortBySubject(tmp, size);

    // Власне бінарний пошук
    int lo = 0, hi = size - 1, found = -1;
    while (lo <= hi) {
        int mid = lo + (hi - lo) / 2;
        if (tmp[mid]->subject == subject) {
            found = mid;
            break;
        } else if (tmp[mid]->subject < subject) {
            lo = mid + 1;
        } else {
            hi = mid - 1;
        }
    }

    // Якщо знайдено — виводимо результат
    if (found != -1) {
        std::cout << "  Знайдено (у відсортованому за назвою масиві):\n";
        printTable(tmp + found, 1);
    } else {
        std::cout << "  Предмет \"" << subject << "\" не знайдено.\n";
    }

    delete[] tmp; // звільняємо тимчасовий масив (не самі записи!)
    return found;
}

// -----------------------------------------------------------------------
// Статистика за часом початку у діапазоні [fromTime, toTime]
// -----------------------------------------------------------------------
void rangeStats(ScheduleRecord** arr, int size,
                int fromTime, int toTime) {
    int maxVal = -1, minVal = INT_MAX;
    ScheduleRecord* maxRec = nullptr;
    ScheduleRecord* minRec = nullptr;
    long long sum = 0;
    int count = 0;

    // Збираємо записи, що потрапляють у діапазон
    ScheduleRecord** subset = new ScheduleRecord*[size];

    for (int i = 0; i < size; ++i) {
        int t = arr[i]->startTime;
        if (t >= fromTime && t <= toTime) {
            subset[count++] = arr[i];
            sum += t;
            if (t > maxVal) { maxVal = t; maxRec = arr[i]; }
            if (t < minVal) { minVal = t; minRec = arr[i]; }
        }
    }

    if (count == 0) {
        std::cout << "  У вказаному діапазоні [" << timeToStr(fromTime)
                  << " – " << timeToStr(toTime) << "] записів не знайдено.\n";
        delete[] subset;
        return;
    }

    std::cout << "\n  Записи у діапазоні [" << timeToStr(fromTime)
              << " – " << timeToStr(toTime) << "]:\n";
    printTable(subset, count);

    std::cout << "  Максимальний час початку : " << timeToStr(maxVal)
              << "  (" << maxRec->subject << ")\n";
    std::cout << "  Мінімальний час початку  : " << timeToStr(minVal)
              << "  (" << minRec->subject << ")\n";
    double avg = static_cast<double>(sum) / count;
    int avgH = static_cast<int>(avg) / 100;
    int avgM = static_cast<int>(avg) % 100;
    std::cout << "  Середній час початку     : "
              << std::setw(2) << std::setfill('0') << avgH << ":"
              << std::setw(2) << std::setfill('0') << avgM << "\n";

    delete[] subset;
}

// -----------------------------------------------------------------------
// Зчитує один запис з консолі
// -----------------------------------------------------------------------
ScheduleRecord* readRecordFromConsole() {
    std::string subj, rm, tchr;
    int startTime, dur;

    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

    std::cout << "  Назва предмету          : ";
    std::getline(std::cin, subj);

    std::cout << "  Час початку (HHMM, напр. 900 або 1330): ";
    std::cin >> startTime;

    std::cout << "  Аудиторія               : ";
    std::cin.ignore();
    std::getline(std::cin, rm);

    std::cout << "  ПІБ викладача           : ";
    std::getline(std::cin, tchr);

    std::cout << "  Тривалість (хвилин)     : ";
    std::cin >> dur;

    return new ScheduleRecord(subj, startTime, rm, tchr, dur);
}

// -----------------------------------------------------------------------
// Звільняє всі елементи масиву та сам масив
// -----------------------------------------------------------------------
void freeAll(ScheduleRecord**& arr, int& size, int& capacity) {
    for (int i = 0; i < size; ++i)
        delete arr[i];
    delete[] arr;
    arr      = nullptr;
    size     = 0;
    capacity = 0;
}
