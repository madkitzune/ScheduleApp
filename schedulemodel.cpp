// schedulemodel.cpp — реалізація Qt-моделі для таблиці розкладу

#include "schedulemodel.h"
#include "schedule.h"

#include <QFile>
#include <QUrl>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QtSql/QSqlError>
#include <QVariantMap>
#include <climits>
#include <algorithm>

// -----------------------------------------------------------------------
// Конвертація QUrl/рядка у звичайний шлях на диску
// -----------------------------------------------------------------------
static QString toLocalPath(const QString& raw) {
    // QML FileDialog повертає "file:///C:/..." або "file:/C:/..."
    QUrl url(raw);
    if (url.isLocalFile()) return url.toLocalFile();
    return raw; // вже звичайний шлях
}

// -----------------------------------------------------------------------
// Конструктор / деструктор
// -----------------------------------------------------------------------
ScheduleModel::ScheduleModel(QObject* parent)
    : QAbstractTableModel(parent), m_arr(nullptr), m_size(0), m_capacity(0) {}

ScheduleModel::~ScheduleModel() {
    freeAll(m_arr, m_size, m_capacity);
}

int ScheduleModel::rowCount(const QModelIndex&) const { return m_size; }
int ScheduleModel::columnCount(const QModelIndex&) const { return 5; }

QVariant ScheduleModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() >= m_size) return {};
    auto* rec = m_arr[index.row()];
    if (role == Qt::DisplayRole || role == Qt::EditRole) {
        switch (index.column()) {
        case 0: return QString::fromStdString(rec->subject);
        case 1: return timeToStr(rec->startTime);
        case 2: return QString::fromStdString(rec->room);
        case 3: return QString::fromStdString(rec->teacher);
        case 4: return rec->duration;
        }
    }
    switch (role) {
    case SubjectRole:  return QString::fromStdString(rec->subject);
    case TimeRole:     return timeToStr(rec->startTime);
    case RoomRole:     return QString::fromStdString(rec->room);
    case TeacherRole:  return QString::fromStdString(rec->teacher);
    case DurationRole: return rec->duration;
    }
    return {};
}

QVariant ScheduleModel::headerData(int section, Qt::Orientation orientation, int role) const {
    if (role != Qt::DisplayRole) return {};
    if (orientation == Qt::Horizontal) {
        switch (section) {
        case 0: return QString::fromUtf8("Предмет");
        case 1: return QString::fromUtf8("Початок");
        case 2: return QString::fromUtf8("Аудиторія");
        case 3: return QString::fromUtf8("Викладач");
        case 4: return QString::fromUtf8("Хв.");
        }
    }
    return section + 1;
}

QHash<int, QByteArray> ScheduleModel::roleNames() const {
    return {
        {SubjectRole,  "subject"},
        {TimeRole,     "startTime"},
        {RoomRole,     "room"},
        {TeacherRole,  "teacher"},
        {DurationRole, "duration"},
    };
}

void ScheduleModel::refresh() {
    emit countChanged();
    beginResetModel();
    endResetModel();
}

QString ScheduleModel::timeToStr(int hhmm) const {
    return QString("%1:%2")
        .arg(hhmm / 100, 2, 10, QChar('0'))
        .arg(hhmm % 100, 2, 10, QChar('0'));
}

QVariantMap ScheduleModel::getRecord(int index) const {
    if (index < 0 || index >= m_size) return {};
    auto* r = m_arr[index];
    return {
        {"subject",   QString::fromStdString(r->subject)},
        {"startTime", r->startTime},
        {"room",      QString::fromStdString(r->room)},
        {"teacher",   QString::fromStdString(r->teacher)},
        {"duration",  r->duration},
    };
}

// -----------------------------------------------------------------------
// Завантажити з TXT
// -----------------------------------------------------------------------
bool ScheduleModel::loadFromFile(const QString& path) {
    QString local = toLocalPath(path);
    freeAll(m_arr, m_size, m_capacity);
    int n = ::loadFromFile(local.toStdString(), m_arr, m_size, m_capacity);
    refresh();
    if (n > 0) emit message(QString::fromUtf8("Завантажено %1 записів").arg(n), false);
    else       emit message(QString::fromUtf8("Не вдалося завантажити файл: ") + local, true);
    return n > 0;
}

// -----------------------------------------------------------------------
// Зберегти у TXT
// -----------------------------------------------------------------------
bool ScheduleModel::saveToFile(const QString& path) {
    QString local = toLocalPath(path);
    ::saveToFile(local.toStdString(), m_arr, m_size);
    emit message(QString::fromUtf8("Збережено %1 записів").arg(m_size), false);
    return true;
}

// -----------------------------------------------------------------------
// Зберегти у SQLite (виправлено дублікат з'єднання)
// -----------------------------------------------------------------------
bool ScheduleModel::saveToSqlite(const QString& path) {
    QString local = toLocalPath(path);
    // Видаляємо старе з'єднання якщо існує
    if (QSqlDatabase::contains("sched_save"))
        QSqlDatabase::removeDatabase("sched_save");

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", "sched_save");
    db.setDatabaseName(local);
    if (!db.open()) {
        emit message(QString::fromUtf8("Помилка SQLite: ") + db.lastError().text(), true);
        return false;
    }
    QSqlQuery q(db);
    q.exec("CREATE TABLE IF NOT EXISTS schedule ("
           "id INTEGER PRIMARY KEY AUTOINCREMENT,"
           "subject TEXT, startTime INTEGER, room TEXT, teacher TEXT, duration INTEGER)");
    q.exec("DELETE FROM schedule");
    for (int i = 0; i < m_size; ++i) {
        q.prepare("INSERT INTO schedule(subject,startTime,room,teacher,duration) VALUES(?,?,?,?,?)");
        q.addBindValue(QString::fromStdString(m_arr[i]->subject));
        q.addBindValue(m_arr[i]->startTime);
        q.addBindValue(QString::fromStdString(m_arr[i]->room));
        q.addBindValue(QString::fromStdString(m_arr[i]->teacher));
        q.addBindValue(m_arr[i]->duration);
        q.exec();
    }
    db.close();
    QSqlDatabase::removeDatabase("sched_save");
    emit message(QString::fromUtf8("Збережено %1 записів у SQLite").arg(m_size), false);
    return true;
}

// -----------------------------------------------------------------------
// Завантажити з SQLite
// -----------------------------------------------------------------------
bool ScheduleModel::loadFromSqlite(const QString& path) {
    QString local = toLocalPath(path);
    if (QSqlDatabase::contains("sched_load"))
        QSqlDatabase::removeDatabase("sched_load");

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", "sched_load");
    db.setDatabaseName(local);
    if (!db.open()) {
        emit message(QString::fromUtf8("Помилка SQLite: ") + db.lastError().text(), true);
        return false;
    }
    freeAll(m_arr, m_size, m_capacity);
    QSqlQuery q("SELECT subject,startTime,room,teacher,duration FROM schedule", db);
    int n = 0;
    while (q.next()) {
        auto* rec = new ScheduleRecord(
            q.value(0).toString().toStdString(),
            q.value(1).toInt(),
            q.value(2).toString().toStdString(),
            q.value(3).toString().toStdString(),
            q.value(4).toInt()
        );
        appendRecord(m_arr, m_size, m_capacity, rec);
        ++n;
    }
    db.close();
    QSqlDatabase::removeDatabase("sched_load");
    refresh();
    emit message(QString::fromUtf8("Завантажено %1 записів з SQLite").arg(n), false);
    return n > 0;
}

void ScheduleModel::addRecord(const QString& subject, int startTime,
                               const QString& room, const QString& teacher, int duration) {
    auto* rec = new ScheduleRecord(subject.toStdString(), startTime,
                                   room.toStdString(), teacher.toStdString(), duration);
    beginInsertRows({}, m_size, m_size);
    appendRecord(m_arr, m_size, m_capacity, rec);
    endInsertRows();
    emit countChanged();
    emit message(QString::fromUtf8("Запис додано"), false);
}

void ScheduleModel::insertBefore(int index, const QString& subject, int startTime,
                                  const QString& room, const QString& teacher, int duration) {
    auto* rec = new ScheduleRecord(subject.toStdString(), startTime,
                                   room.toStdString(), teacher.toStdString(), duration);
    ::insertBefore(m_arr, m_size, m_capacity, index, rec);
    refresh();
    emit message(QString::fromUtf8("Вставлено перед #%1").arg(index+1), false);
}

void ScheduleModel::insertAfter(int index, const QString& subject, int startTime,
                                 const QString& room, const QString& teacher, int duration) {
    auto* rec = new ScheduleRecord(subject.toStdString(), startTime,
                                   room.toStdString(), teacher.toStdString(), duration);
    ::insertAfter(m_arr, m_size, m_capacity, index, rec);
    refresh();
    emit message(QString::fromUtf8("Вставлено після #%1").arg(index+1), false);
}

void ScheduleModel::replaceRecord(int index, const QString& subject, int startTime,
                                   const QString& room, const QString& teacher, int duration) {
    auto* rec = new ScheduleRecord(subject.toStdString(), startTime,
                                   room.toStdString(), teacher.toStdString(), duration);
    ::replaceRecord(m_arr, m_size, index, rec);
    emit dataChanged(createIndex(index,0), createIndex(index,4));
    emit message(QString::fromUtf8("Запис #%1 замінено").arg(index+1), false);
}

void ScheduleModel::deleteFrom(int fromIndex, int count) {
    ::deleteFrom(m_arr, m_size, fromIndex, count == 0 ? -1 : count);
    refresh();
    emit message(QString::fromUtf8("Записи видалено"), false);
}

void ScheduleModel::sortByTime() {
    shellSortByTime(m_arr, m_size);
    refresh();
    emit message(QString::fromUtf8("Відсортовано за часом (Shell sort)"), false);
}

// -----------------------------------------------------------------------
// Бінарний пошук — знаходить ВСІ збіги
// -----------------------------------------------------------------------
QString ScheduleModel::searchBySubject(const QString& subject) {
    if (m_size == 0) return QString::fromUtf8("Масив порожній");

    std::string subj = subject.toStdString();
    QStringList results;

    // Тимчасово сортуємо копію за назвою
    ScheduleRecord** tmp = new ScheduleRecord*[m_size];
    for (int i = 0; i < m_size; ++i) tmp[i] = m_arr[i];
    std::sort(tmp, tmp + m_size, [](const ScheduleRecord* a, const ScheduleRecord* b){
        return a->subject < b->subject;
    });

    // Бінарний пошук першого входження
    int lo = 0, hi = m_size - 1, first = -1;
    while (lo <= hi) {
        int mid = lo + (hi - lo) / 2;
        if (tmp[mid]->subject == subj) { first = mid; hi = mid - 1; }
        else if (tmp[mid]->subject < subj) lo = mid + 1;
        else hi = mid - 1;
    }

    if (first == -1) {
        delete[] tmp;
        return QString::fromUtf8("[X] Не знайдено: \"%1\"").arg(subject);
    }

    // Збираємо всі збіги
    for (int i = first; i < m_size && tmp[i]->subject == subj; ++i) {
        results << QString::fromUtf8("[OK] %1  |  %2  |  %3  |  %4  |  %5 хв.")
            .arg(QString::fromStdString(tmp[i]->subject))
            .arg(timeToStr(tmp[i]->startTime))
            .arg(QString::fromStdString(tmp[i]->room))
            .arg(QString::fromStdString(tmp[i]->teacher))
            .arg(tmp[i]->duration);
    }
    delete[] tmp;
    return results.join("\n");
}

// -----------------------------------------------------------------------
// Статистика
// -----------------------------------------------------------------------
QString ScheduleModel::rangeStats(int fromTime, int toTime) {
    int maxVal = -1, minVal = INT_MAX, count = 0;
    long long sum = 0;
    ScheduleRecord* maxRec = nullptr;
    ScheduleRecord* minRec = nullptr;

    for (int i = 0; i < m_size; ++i) {
        int t = m_arr[i]->startTime;
        if (t >= fromTime && t <= toTime) {
            ++count; sum += t;
            if (t > maxVal) { maxVal = t; maxRec = m_arr[i]; }
            if (t < minVal) { minVal = t; minRec = m_arr[i]; }
        }
    }
    if (count == 0)
        return QString::fromUtf8("У діапазоні [%1 - %2] записів не знайдено")
            .arg(timeToStr(fromTime)).arg(timeToStr(toTime));

    double avg = (double)sum / count;
    int avgH = (int)avg / 100, avgM = (int)avg % 100;
    return QString::fromUtf8(
        "Діапазон [%1 - %2]  |  Знайдено: %3 записів\n"
        "MAX: %4  (%5)\n"
        "MIN: %6  (%7)\n"
        "AVG: %8:%9")
        .arg(timeToStr(fromTime)).arg(timeToStr(toTime)).arg(count)
        .arg(timeToStr(maxVal)).arg(QString::fromStdString(maxRec->subject))
        .arg(timeToStr(minVal)).arg(QString::fromStdString(minRec->subject))
        .arg(avgH, 2, 10, QChar('0')).arg(avgM, 2, 10, QChar('0'));
}


