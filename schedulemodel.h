#pragma once
#include <QAbstractTableModel>
#include <QStringList>
#include "schedule.h"

class ScheduleModel : public QAbstractTableModel {
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
public:
    enum Roles { SubjectRole=Qt::UserRole+1, TimeRole, RoomRole, TeacherRole, DurationRole };
    explicit ScheduleModel(QObject* parent = nullptr);
    ~ScheduleModel() override;
    int rowCount(const QModelIndex& parent = {}) const override;
    int columnCount(const QModelIndex& parent = {}) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    QVariant headerData(int section, Qt::Orientation orientation, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    int count() const { return m_size; }

public slots:
    bool loadFromFile(const QString& path);
    bool saveToFile(const QString& path);
    bool saveToSqlite(const QString& path);
    bool loadFromSqlite(const QString& path);
    void addRecord(const QString& subject, int startTime, const QString& room, const QString& teacher, int duration);
    void insertBefore(int index, const QString& subject, int startTime, const QString& room, const QString& teacher, int duration);
    void insertAfter(int index, const QString& subject, int startTime, const QString& room, const QString& teacher, int duration);
    void replaceRecord(int index, const QString& subject, int startTime, const QString& room, const QString& teacher, int duration);
    void deleteFrom(int fromIndex, int count);
    void sortByTime();
    QString searchBySubject(const QString& subject);
    QString rangeStats(int fromTime, int toTime);
    Q_INVOKABLE QString timeToStr(int hhmm) const;
    Q_INVOKABLE QVariantMap getRecord(int index) const;

signals:
    void message(const QString& text, bool isError);
    void countChanged();

private:
    ScheduleRecord** m_arr;
    int m_size;
    int m_capacity;
    void refresh();
};
